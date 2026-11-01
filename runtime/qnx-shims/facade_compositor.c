/*
 * A7 compositor: put the facade's drawn frame on the Q20 panel as root.
 *
 * The drawing half of A7 runs in dalvikvm as devuser and writes its RGBA8888
 * frame to a file (graphics_facade.cc, Q20_DRAW_RAW). dalvikvm cannot run as
 * root: pathtrust denies exec of untrusted-inode binaries even for uid 0
 * (token-wall section 27), and the ART runtime lives on untrusted UFS inodes.
 * So the frame producer (devuser) and the window owner (root) are split: this
 * is the root half. It is a single self-contained ELF, deployed through the
 * one writable trusted inode (/var/exfat/fs-exfat.so), which is the only way
 * to exec our own code as root.
 *
 * It runs the exact sequence navigator_probe.c proved composites as root
 * (token-wall section 27: context, window, group, display attach, 720x720
 * buffer, fill, post -> visible), but fills from the frame file instead of a
 * flat magenta, so the panel shows the real Prober decor.
 *
 * Build (match navigator_probe.c; link the device's own libscreen):
 *   arm-blackberry-qnx8eabi-gcc -O2 -o facade_compositor facade_compositor.c \
 *       -Wl,-rpath-link,<sysroot>/base/usr/lib \
 *       -L<device-libs> -lscreen
 *
 * Usage on device (as root, via the port-2225 sshd):
 *   facade_compositor <frame.rgba> [size]
 *       <frame.rgba>  tightly packed size*size*4 RGBA8888 (Q20_DRAW_RAW output)
 *       [size]        frame edge in px, default 720 (the square Q20 panel)
 * Env knobs:
 *   FACADE_WM=1       request a WINDOW_MANAGER context instead of APPLICATION
 *                     (fallback if an own-group APPLICATION window is not drawn)
 *   FACADE_ZORDER=n   window z order, default 200 (Navigator publishes 100)
 *   NAV_HOLD=n        seconds to hold the frame on screen, default 60
 *
 * ponytail: one static frame over a file is the deliberate corner (no live
 * redraw). Upgrade path: a shared-memory framebuffer + named semaphore when A8
 * wires input -> invalidate -> redraw.
 */
#include <screen/screen.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define P(...) do { printf(__VA_ARGS__); fflush(stdout); } while (0)

static int envInt(const char* name, int fallback) {
  const char* v = getenv(name);
  return (v != NULL && v[0] != '\0') ? atoi(v) : fallback;
}

int main(int argc, char** argv) {
  setbuf(stdout, NULL);
  if (argc < 2) {
    P("usage: %s <frame.rgba> [size]\n", argv[0]);
    return 64;
  }
  const char* path = argv[1];
  const int size = (argc > 2) ? atoi(argv[2]) : 720;
  if (size <= 0) { P("bad size %d\n", size); return 64; }

  /* Load the frame: tightly packed size*size*4 RGBA8888. */
  const size_t rowBytes = (size_t)size * 4;
  const size_t want = rowBytes * (size_t)size;
  unsigned char* frame = malloc(want);
  if (frame == NULL) { P("oom %zu\n", want); return 71; }
  FILE* f = fopen(path, "rb");
  if (f == NULL) { P("open %s failed errno=%d (%s)\n", path, errno, strerror(errno)); return 66; }
  size_t got = fread(frame, 1, want, f);
  fclose(f);
  if (got != want) { P("short read: %zu of %zu bytes\n", got, want); return 65; }
  P("loaded %s: %dx%d (%zu bytes)\n", path, size, size, got);

  const int ctx_type = envInt("FACADE_WM", 0)
      ? SCREEN_WINDOW_MANAGER_CONTEXT : SCREEN_APPLICATION_CONTEXT;
  screen_context_t ctx = 0;
  errno = 0;
  int crc = screen_create_context(&ctx, ctx_type);
  P("create_context type=%s rc=%d errno=%d (%s)\n",
    ctx_type == SCREEN_WINDOW_MANAGER_CONTEXT ? "WINDOW_MANAGER" : "APPLICATION",
    crc, errno, crc == 0 ? "ok" : strerror(errno));
  if (crc != 0) return 1;

  /* Claim the power-manager role (as root this context is granted): the
   * navigator holds it normally, and killing the navigator powers the panel
   * off (black screen). A WM that replaces the navigator must keep the
   * display powered itself. */
  screen_context_t pm = 0;
  int pmc = screen_create_context(&pm, SCREEN_POWER_MANAGER_CONTEXT);
  P("create_context POWER_MANAGER rc=%d errno=%d (%s)\n", pmc, errno,
    pmc == 0 ? "ok" : strerror(errno));

  screen_window_t win = 0;
  if (screen_create_window(&win, ctx) != 0) {
    P("create_window failed errno=%d (%s)\n", errno, strerror(errno));
    return 2;
  }
  P("window ok\n");

  errno = 0;
  P("CREATE group \"q20-facade\" rc=%d errno=%d\n",
    screen_create_window_group(win, "q20-facade"), errno);

  int fmt = SCREEN_FORMAT_RGBA8888;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_FORMAT, &fmt);
  int usage = SCREEN_USAGE_WRITE | SCREEN_USAGE_NATIVE;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_USAGE, &usage);
  int zorder = envInt("FACADE_ZORDER", 200);
  screen_set_window_property_iv(win, SCREEN_PROPERTY_ZORDER, &zorder);
  int alpha = 255;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_GLOBAL_ALPHA, &alpha);
  int pos[2] = {0, 0};
  screen_set_window_property_iv(win, SCREEN_PROPERTY_POSITION, pos);

  /* Attach to display 0 (navigator_probe does this explicitly). */
  {
    int nd = 0;
    screen_get_context_property_iv(ctx, SCREEN_PROPERTY_DISPLAY_COUNT, &nd);
    if (nd > 0) {
      screen_display_t* disps = calloc(nd, sizeof(screen_display_t));
      screen_get_context_property_pv(ctx, SCREEN_PROPERTY_DISPLAYS, (void**)disps);
      P("attach display rc=%d\n",
        screen_set_window_property_pv(win, SCREEN_PROPERTY_DISPLAY, (void**)&disps[0]));
      /* keep the panel powered via the power-manager context */
      if (pm != 0) {
        int mode = SCREEN_POWER_MODE_ON;
        int prc2 = screen_set_display_property_iv(disps[0], SCREEN_PROPERTY_POWER_MODE, &mode);
        P("set display POWER_MODE=ON rc=%d errno=%d\n", prc2, errno);
      }
      free(disps);
    }
  }

  int visible = 1;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_VISIBLE, &visible);

  /* Set size explicitly: an own-group window inherits the display size, but
   * navigator_probe sets it anyway and screen_window.cc omitting it is a
   * suspected contributor to 0x0 windows. Be explicit. */
  int wsize[2] = {size, size};
  screen_set_window_property_iv(win, SCREEN_PROPERTY_SIZE, wsize);
  int ssize[2] = {size, size};
  screen_set_window_property_iv(win, SCREEN_PROPERTY_SOURCE_SIZE, ssize);
  screen_set_window_property_cv(win, SCREEN_PROPERTY_ID_STRING,
                                strlen("q20-facade") + 1, "q20-facade");

  if (screen_create_window_buffers(win, 1) != 0) {
    P("create_window_buffers failed errno=%d (%s)\n", errno, strerror(errno));
    return 3;
  }
  screen_buffer_t buf = 0;
  screen_get_window_property_pv(win, SCREEN_PROPERTY_RENDER_BUFFERS, (void**)&buf);
  void* ptr = NULL;
  int stride = 0;
  screen_get_buffer_property_pv(buf, SCREEN_PROPERTY_POINTER, &ptr);
  screen_get_buffer_property_iv(buf, SCREEN_PROPERTY_STRIDE, &stride);
  P("buf=%p ptr=%p stride=%d\n", (void*)buf, ptr, stride);
  if (ptr == NULL || stride <= 0) { P("no cpu buffer\n"); return 4; }

  /* Copy the frame in, honoring the window buffer's real stride (the panel
   * uses 2944 for 720 wide, not 2880). Clamp to whichever width is smaller. */
  const size_t copyBytes = ((size_t)stride < rowBytes) ? (size_t)stride : rowBytes;
  for (int y = 0; y < size; y++)
    memcpy((unsigned char*)ptr + (size_t)y * stride, frame + (size_t)y * rowBytes, copyBytes);
  P("copied frame into window buffer (copyBytes=%zu/row)\n", copyBytes);
  free(frame);

  int rect[4] = {0, 0, size, size};
  int prc = screen_post_window(win, buf, 1, rect, 0);
  int frc = screen_flush_context(ctx, 0);
  P("post rc=%d flush rc=%d errno=%d (%s)\n", prc, frc, errno, strerror(errno));

  const int hold = envInt("NAV_HOLD", 60);
  P("holding %ds, look at the phone for the Prober decor frame\n", hold);
  if (hold > 0) sleep(hold);
  return (prc == 0) ? 0 : 5;
}
