/*
 * A4 probe: can an unsigned process own a window and draw on the Q20?
 * Creates a window, fills its buffer with a striped pattern, posts it, and
 * keeps it visible for 8 seconds so a human can confirm it on the phone.
 */
#include <screen/screen.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define P(...) printf(__VA_ARGS__); fflush(stdout)

int main(int argc, char** argv) {
  setbuf(stdout, NULL);
  // App runs have no terminal: mirror the output into a log file under the
  // app's HOME so it can be read back over SSH.
  const char* home = getenv("HOME");
  if (home != NULL) {
    char logpath[512];
    snprintf(logpath, sizeof(logpath), "%s/probe.log", home);
    FILE* lf = fopen(logpath, "w");
    if (lf != NULL) {
      fprintf(lf, "screen-probe started\n");
      fclose(lf);
    }
  }
  screen_context_t ctx = 0;

  if (screen_create_context(&ctx, SCREEN_APPLICATION_CONTEXT) != 0) {
    perror("screen_create_context");
    return 1;
  }
  P("context ok\n");

  screen_window_t win = 0;
  if (screen_create_window(&win, ctx) != 0) {
    perror("screen_create_window");
    return 2;
  }
  P("window ok\n");

  // Join a window group: on BB10 un-grouped windows may not be composited.
  {
    screen_window_t grp = 0;
    int grc = screen_create_window_group(win, "q20probe-group");
    P("create_window_group rc=%d errno=%d (%s)\n", grc, errno, strerror(errno));
    char gname[32] = {0};
    screen_get_window_property_cv(win, SCREEN_PROPERTY_GROUP, sizeof(gname), gname);
    P("window group=%s\n", gname);
  }

  // Diagnostics: display mode and attached state.
  {
    screen_display_t* disps = NULL;
    int nd = 0;
    screen_get_context_property_iv(ctx, SCREEN_PROPERTY_DISPLAY_COUNT, &nd);
    if (nd > 0) {
      disps = (screen_display_t*)calloc(nd, sizeof(screen_display_t));
      screen_get_context_property_pv(ctx, SCREEN_PROPERTY_DISPLAYS, (void**)disps);
      int mode = -1;
      int attached = -1;
      int pmode = -1;
      screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_MODE, &mode);
      screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_ATTACHED, &attached);
      screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_POWER_MODE, &pmode);
      int dsize[2] = {0, 0};
      screen_get_display_property_iv(disps[0], SCREEN_PROPERTY_SIZE, dsize);
      P("display mode=%d attached=%d power=%d size=%dx%d\n",
        mode, attached, pmode, dsize[0], dsize[1]);
      if (pmode != SCREEN_POWER_MODE_ON) {
        int on = SCREEN_POWER_MODE_ON;
        int src = screen_set_display_property_iv(disps[0], SCREEN_PROPERTY_POWER_MODE, &on);
        P("set power on rc=%d errno=%d\n", src, errno);
      }
    }
  }

  screen_set_window_property_cv(win, SCREEN_PROPERTY_ID_STRING,
                                strlen("q20-screen-probe") + 1, "q20-screen-probe");
  int zorder = 0x7fffffff;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_ZORDER, &zorder);
  int alpha = 255;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_GLOBAL_ALPHA, &alpha);
  int pos[2] = {60, 60};
  screen_set_window_property_iv(win, SCREEN_PROPERTY_POSITION, pos);
  // Attach the window to the first display explicitly.
  {
    screen_display_t* disps = NULL;
    int nd = 0;
    screen_get_context_property_iv(ctx, SCREEN_PROPERTY_DISPLAY_COUNT, &nd);
    if (nd > 0) {
      disps = (screen_display_t*)calloc(nd, sizeof(screen_display_t));
      screen_get_context_property_pv(ctx, SCREEN_PROPERTY_DISPLAYS, (void**)disps);
      int arc = screen_set_window_property_pv(win, SCREEN_PROPERTY_DISPLAY, (void**)&disps[0]);
      P("attach display rc=%d errno=%d\n", arc, errno);
    }
  }
  int visible = 1;
  P("visible rc=%d\n", screen_set_window_property_iv(win, SCREEN_PROPERTY_VISIBLE, &visible));

  int bdims[2] = {0, 0};
  screen_get_window_property_iv(win, SCREEN_PROPERTY_BUFFER_SIZE, bdims);
  P("buffer size %dx%d\n", bdims[0], bdims[1]);

  if (screen_create_window_buffers(win, 1) != 0) {
    perror("screen_create_window_buffers");
    return 3;
  }
  screen_buffer_t bufs[1] = {0};
  screen_get_window_property_pv(win, SCREEN_PROPERTY_RENDER_BUFFERS, (void**)bufs);
  void* ptr = NULL;
  int stride = 0;
  screen_get_buffer_property_pv(bufs[0], SCREEN_PROPERTY_POINTER, &ptr);
  screen_get_buffer_property_iv(bufs[0], SCREEN_PROPERTY_STRIDE, &stride);
  P("buf=%p ptr=%p stride=%d\n", (void*)bufs[0], ptr, stride);
  if (ptr == NULL) {
    P("no cpu pointer\n");
    return 4;
  }

  // Diagonal stripes: 80px bands of red, green, blue, white.
  static const unsigned char cols[4][4] = {
      {0xff, 0x00, 0x00, 0xff},
      {0x00, 0xff, 0x00, 0xff},
      {0x00, 0x00, 0xff, 0xff},
      {0xff, 0xff, 0xff, 0xff},
  };
  for (int y = 0; y < bdims[1]; y++) {
    unsigned char* row = (unsigned char*)ptr + y * stride;
    int band = ((y / 80) % 4 + 4) % 4;
    for (int x = 0; x < bdims[0]; x++) {
      memcpy(row + x * 4, cols[band], 4);
    }
  }
  P("filled stripes\n");

  int rect[4] = {0, 0, bdims[0], bdims[1]};
  int prc = screen_post_window(win, bufs[0], 1, rect, 0);
  P("post rc=%d errno=%d (%s)\n", prc, errno, strerror(errno));
  int frc = screen_flush_context(ctx, 0);
  P("flush rc=%d errno=%d\n", frc, errno);
  {
    int ppos[2] = {-1, -1};
    int pvis = -1;
    screen_get_window_property_iv(win, SCREEN_PROPERTY_POSITION, ppos);
    screen_get_window_property_iv(win, SCREEN_PROPERTY_VISIBLE, &pvis);
    P("after post: position=%d,%d visible=%d\n", ppos[0], ppos[1], pvis);
  }
  P("window visible for 60 seconds, look at the phone\n");
  sleep(60);
  return 0;
}
