/*
 * Q20 Screen window. See screen_window.h for the contract and the env knobs.
 */
#define LOG_TAG "q20screen"

#include "screen_window.h"

#include <screen/screen.h>
#include <utils/Log.h>

#include <errno.h>
#include <stdlib.h>
#include <string.h>

namespace q20screen {
namespace {

screen_context_t gCtx;
screen_window_t gWin;
screen_buffer_t gBuf;
raster::Surface gSurface;
bool gTried;

int envInt(const char* name, int fallback) {
  const char* v = getenv(name);
  return (v != nullptr && v[0] != '\0') ? atoi(v) : fallback;
}

// Attach to display 0 and make sure the panel is powered. Every rc is logged:
// this runs blind inside dalvikvm, where a silently failing property read is
// indistinguishable from a working one until buffer allocation refuses.
void attachDisplay(screen_window_t win, screen_context_t ctx) {
  int nd = 0;
  const int crc = screen_get_context_property_iv(ctx, SCREEN_PROPERTY_DISPLAY_COUNT, &nd);
  ALOGI("display count rc=%d n=%d", crc, nd);
  if (crc != 0 || nd <= 0) return;
  screen_display_t* disps = static_cast<screen_display_t*>(calloc(nd, sizeof(screen_display_t)));
  if (disps == nullptr) return;
  const int drc = screen_get_context_property_pv(ctx, SCREEN_PROPERTY_DISPLAYS,
                                                 reinterpret_cast<void**>(disps));
  int power = -1, attached = -1, dsize[2] = {0, 0};
  const int prc = screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_POWER_MODE, &power);
  const int arc = screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_ATTACHED, &attached);
  const int src = screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_SIZE, dsize);
  ALOGI("displays rc=%d; display0 power=%d (rc=%d) attached=%d (rc=%d) size=%dx%d (rc=%d)",
        drc, power, prc, attached, arc, dsize[0], dsize[1], src);
  // Only poke power on a read that actually worked: a failed read leaves junk
  // in power, and writing a display property we did not understand is how a
  // context gets itself refused later.
  if (prc == 0 && power != SCREEN_POWER_MODE_ON) {
    int on = SCREEN_POWER_MODE_ON;
    ALOGI("display power was %d, setting ON rc=%d", power,
          screen_set_display_property_iv(disps[0], SCREEN_PROPERTY_POWER_MODE, &on));
  }
  ALOGI("attach display rc=%d",
        screen_set_window_property_pv(win, SCREEN_PROPERTY_DISPLAY,
                                      reinterpret_cast<void**>(&disps[0])));
  free(disps);
}

bool create() {
  if (screen_create_context(&gCtx, SCREEN_APPLICATION_CONTEXT) != 0) {
    ALOGE("screen_create_context failed errno=%d (%s)", errno, strerror(errno));
    return false;
  }
  if (screen_create_window(&gWin, gCtx) != 0) {
    ALOGE("screen_create_window failed errno=%d (%s)", errno, strerror(errno));
    return false;
  }

  // The whole A7 compositor question lives in these two lines. Creating our
  // own group is the A4 baseline (window exists, nothing composites); joining
  // a group the Navigator already owns is the app contract.
  const char* join = getenv("Q20_SCREEN_GROUP");
  if (join != nullptr && join[0] != '\0') {
    ALOGI("JOIN window group \"%s\" rc=%d errno=%d", join,
          screen_join_window_group(gWin, join), errno);
  } else {
    ALOGI("CREATE window group \"q20-facade\" rc=%d errno=%d",
          screen_create_window_group(gWin, "q20-facade"), errno);
  }

  int fmt = SCREEN_FORMAT_RGBA8888;
  ALOGI("set format rc=%d", screen_set_window_property_iv(gWin, SCREEN_PROPERTY_FORMAT, &fmt));
  // Knob, because the two probes disagree and neither ran inside dalvikvm:
  // A4 set no usage at all and got buffers, navigator_probe set WRITE|NATIVE
  // and got buffers. Q20_SCREEN_USAGE=0 drops the property entirely.
  const int usage = envInt("Q20_SCREEN_USAGE", SCREEN_USAGE_WRITE | SCREEN_USAGE_NATIVE);
  if (usage != 0) {
    ALOGI("set usage 0x%x rc=%d", usage,
          screen_set_window_property_iv(gWin, SCREEN_PROPERTY_USAGE, &usage));
  }
  screen_set_window_property_cv(gWin, SCREEN_PROPERTY_ID_STRING,
                                strlen("q20-facade") + 1, "q20-facade");
  int zorder = envInt("Q20_SCREEN_ZORDER", 200);
  screen_set_window_property_iv(gWin, SCREEN_PROPERTY_ZORDER, &zorder);
  int alpha = 255;
  screen_set_window_property_iv(gWin, SCREEN_PROPERTY_GLOBAL_ALPHA, &alpha);
  int pos[2] = {0, 0};
  screen_set_window_property_iv(gWin, SCREEN_PROPERTY_POSITION, pos);
  attachDisplay(gWin, gCtx);
  int visible = 1;
  screen_set_window_property_iv(gWin, SCREEN_PROPERTY_VISIBLE, &visible);

  // The buffer size a window inherits from its display is what gets allocated;
  // a 0x0 read here would explain a refusal without any privilege involved.
  int want[2] = {0, 0};
  ALOGI("buffer size before alloc: rc=%d %dx%d",
        screen_get_window_property_iv(gWin, SCREEN_PROPERTY_BUFFER_SIZE, want), want[0], want[1]);
  if (screen_create_window_buffers(gWin, 1) != 0) {
    ALOGE("screen_create_window_buffers failed errno=%d (%s)", errno, strerror(errno));
    return false;
  }
  screen_buffer_t bufs[1] = {0};
  screen_get_window_property_pv(gWin, SCREEN_PROPERTY_RENDER_BUFFERS,
                                reinterpret_cast<void**>(bufs));
  gBuf = bufs[0];
  void* ptr = nullptr;
  int stride = 0;
  int dims[2] = {0, 0};
  screen_get_buffer_property_pv(gBuf, SCREEN_PROPERTY_POINTER, &ptr);
  screen_get_buffer_property_iv(gBuf, SCREEN_PROPERTY_STRIDE, &stride);
  screen_get_window_property_iv(gWin, SCREEN_PROPERTY_BUFFER_SIZE, dims);
  if (ptr == nullptr || stride <= 0 || dims[0] <= 0 || dims[1] <= 0) {
    ALOGE("no cpu mapped buffer: ptr=%p stride=%d size=%dx%d", ptr, stride, dims[0], dims[1]);
    return false;
  }
  gSurface = raster::Surface{static_cast<uint8_t*>(ptr), dims[0], dims[1], stride};
  ALOGI("window buffer %dx%d stride %d at %p", dims[0], dims[1], stride, ptr);
  return true;
}

}  // namespace

bool acquire(raster::Surface* out) {
  if (!gTried) {
    gTried = true;
    if (!create()) gSurface = raster::Surface{};
  }
  if (gSurface.px == nullptr) return false;
  *out = gSurface;
  return true;
}

bool post() {
  if (gSurface.px == nullptr) return false;
  int rect[4] = {0, 0, gSurface.w, gSurface.h};
  const int prc = screen_post_window(gWin, gBuf, 1, rect, 0);
  const int frc = screen_flush_context(gCtx, 0);
  ALOGI("post rc=%d flush rc=%d errno=%d", prc, frc, errno);
  return prc == 0;
}

}  // namespace q20screen
