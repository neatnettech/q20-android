/*
 * A7 probe 2: get a devuser window COMPOSITED by asking the right question.
 *
 * A4 (screen_probe.c) called screen_create_window_group(win, "q20probe-group"):
 * it made itself the PARENT of a group the BB10 Navigator has never heard of,
 * so the Navigator never composited it. That is expected, and it does NOT
 * prove a signing/root gate. The app contract is the opposite direction: an
 * app window JOINS a group the Navigator already manages, and the Navigator
 * composites the group it owns. This probe tests that, and separately asks
 * whether a compositing-capable context is grantable to devuser at all.
 *
 * Links the device's own libscreen, exactly like screen_probe.c:
 *   arm-blackberry-qnx8eabi-gcc -O2 -o navigator_probe navigator_probe.c \
 *       -Wl,-rpath-link,<sysroot>/base/usr/lib \
 *       -L<device-libs> -lscreen
 * (match the screen_probe build line that already worked; use the device's
 *  /base/usr/lib/libscreen.so, not the 6.5 SDK static lib.)
 *
 * Usage on device:
 *   navigator_probe                 privilege sweep + A4 baseline (create)
 *   navigator_probe join <GROUP>    create an app window and JOIN <GROUP>
 *                                   (<GROUP> = the live foreground group name
 *                                    that nav_recon.sh found)
 *   navigator_probe <mode> <GROUP> <Z>   same, with an explicit z order
 *                                   (default 200, above the Navigator's 100)
 *
 * Fills SOLID MAGENTA so you can tell it apart from A4's RGB stripes.
 */
#include <screen/screen.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define P(...) do { printf(__VA_ARGS__); fflush(stdout); } while (0)

static void logline(const char* s) {
  const char* home = getenv("HOME");
  if (home == NULL) return;
  char path[512];
  snprintf(path, sizeof(path), "%s/nav-probe.log", home);
  FILE* lf = fopen(path, "a");
  if (lf != NULL) { fprintf(lf, "%s\n", s); fclose(lf); }
}

/* Does devuser get a compositing-capable context, or is that root-gated?
 * A window-manager context can force-composite arbitrary windows; if devuser
 * can create one, A7 has a direct route with no root. EPERM here means that
 * particular route needs root, but the JOIN route below may still work. */
static void classify_contexts(void) {
  struct { int type; const char* name; } kinds[] = {
    { SCREEN_APPLICATION_CONTEXT,    "APPLICATION" },
    { SCREEN_WINDOW_MANAGER_CONTEXT, "WINDOW_MANAGER" },
    { SCREEN_DISPLAY_MANAGER_CONTEXT,"DISPLAY_MANAGER" },
    { SCREEN_INPUT_PROVIDER_CONTEXT, "INPUT_PROVIDER" },
  };
  P("=== context privilege sweep (devuser)\n");
  for (unsigned i = 0; i < sizeof(kinds) / sizeof(kinds[0]); i++) {
    screen_context_t c = 0;
    errno = 0;
    int rc = screen_create_context(&c, kinds[i].type);
    P("  %-16s rc=%d errno=%d (%s)\n", kinds[i].name, rc, errno,
      rc == 0 ? "granted" : strerror(errno));
    if (rc == 0) screen_destroy_context(c);
  }
}

int main(int argc, char** argv) {
  setbuf(stdout, NULL);
  logline("nav-probe started");

  const char* mode = (argc > 1) ? argv[1] : "create";
  const char* group = (argc > 2) ? argv[2] : "q20probe-group";
  /* Tuning knob, not a constant: the Navigator publishes its own z order in
   * /pps/services/navigator/state as navzorder:n:100, so anything meant to
   * land on top of the homescreen has to beat that. Default above it; pass
   * a third argument to sweep. */
  const int zorder_arg = (argc > 3) ? atoi(argv[3]) : 200;

  classify_contexts();

  screen_context_t ctx = 0;
  if (screen_create_context(&ctx, SCREEN_APPLICATION_CONTEXT) != 0) {
    P("screen_create_context(APPLICATION) failed errno=%d (%s)\n",
      errno, strerror(errno));
    return 1;
  }
  P("=== application context ok, mode=%s group=%s\n", mode, group);

  screen_window_t win = 0;
  if (screen_create_window(&win, ctx) != 0) {
    P("screen_create_window failed errno=%d (%s)\n", errno, strerror(errno));
    return 2;
  }
  P("window ok\n");

  /* The join vs create difference is the whole experiment. */
  if (strcmp(mode, "join") == 0) {
    errno = 0;
    int jrc = screen_join_window_group(win, group);
    P("JOIN group \"%s\" rc=%d errno=%d (%s)\n", group, jrc, errno,
      jrc == 0 ? "joined" : strerror(errno));
    if (jrc != 0)
      P("  -> could not join; the Navigator group name is wrong/stale, "
        "or joining a foreign group is denied. Re-run nav_recon.sh.\n");
  } else {
    errno = 0;
    int crc = screen_create_window_group(win, group);
    P("CREATE group \"%s\" rc=%d errno=%d (%s)  [A4 baseline]\n",
      group, crc, errno, crc == 0 ? "created" : strerror(errno));
  }

  /* Format + usage. A4 never set USAGE explicitly; some builds require
   * SCREEN_USAGE_NATIVE for the compositor to read a CPU-filled buffer. */
  int fmt = SCREEN_FORMAT_RGBA8888;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_FORMAT, &fmt);
  int usage = SCREEN_USAGE_WRITE | SCREEN_USAGE_NATIVE;
  int urc = screen_set_window_property_iv(win, SCREEN_PROPERTY_USAGE, &usage);
  P("set usage WRITE|NATIVE rc=%d errno=%d\n", urc, errno);

  int zorder = zorder_arg;  /* a sane app z, not INT_MAX */
  screen_set_window_property_iv(win, SCREEN_PROPERTY_ZORDER, &zorder);
  int alpha = 255;
  screen_set_window_property_iv(win, SCREEN_PROPERTY_GLOBAL_ALPHA, &alpha);
  int pos[2] = {0, 0};
  screen_set_window_property_iv(win, SCREEN_PROPERTY_POSITION, pos);

  /* Attach to display 0 explicitly. */
  {
    int nd = 0;
    screen_get_context_property_iv(ctx, SCREEN_PROPERTY_DISPLAY_COUNT, &nd);
    if (nd > 0) {
      screen_display_t* disps = calloc(nd, sizeof(screen_display_t));
      screen_get_context_property_pv(ctx, SCREEN_PROPERTY_DISPLAYS, (void**)disps);
      int arc = screen_set_window_property_pv(win, SCREEN_PROPERTY_DISPLAY,
                                              (void**)&disps[0]);
      P("attach display rc=%d errno=%d\n", arc, errno);
      free(disps);
    }
  }

  int visible = 1;
  P("set visible rc=%d\n",
    screen_set_window_property_iv(win, SCREEN_PROPERTY_VISIBLE, &visible));

  int bdims[2] = {0, 0};
  screen_get_window_property_iv(win, SCREEN_PROPERTY_BUFFER_SIZE, bdims);
  P("buffer size %dx%d\n", bdims[0], bdims[1]);

  if (screen_create_window_buffers(win, 1) != 0) {
    P("screen_create_window_buffers failed errno=%d (%s)\n",
      errno, strerror(errno));
    return 3;
  }
  screen_buffer_t buf = 0;
  screen_get_window_property_pv(win, SCREEN_PROPERTY_RENDER_BUFFERS, (void**)&buf);
  void* ptr = NULL;
  int stride = 0;
  screen_get_buffer_property_pv(buf, SCREEN_PROPERTY_POINTER, &ptr);
  screen_get_buffer_property_iv(buf, SCREEN_PROPERTY_STRIDE, &stride);
  P("buf=%p ptr=%p stride=%d\n", (void*)buf, ptr, stride);
  if (ptr == NULL) { P("no cpu pointer\n"); return 4; }

  /* Solid magenta: unmistakably this probe, not A4. */
  for (int y = 0; y < bdims[1]; y++) {
    unsigned char* row = (unsigned char*)ptr + y * stride;
    for (int x = 0; x < bdims[0]; x++) {
      row[x * 4 + 0] = 0xff;  /* R */
      row[x * 4 + 1] = 0x00;  /* G */
      row[x * 4 + 2] = 0xff;  /* B */
      row[x * 4 + 3] = 0xff;  /* A */
    }
  }
  P("filled magenta\n");

  int rect[4] = {0, 0, bdims[0], bdims[1]};
  int prc = screen_post_window(win, buf, 1, rect, 0);
  P("post rc=%d errno=%d (%s)\n", prc, errno, strerror(errno));
  int frc = screen_flush_context(ctx, 0);
  P("flush rc=%d errno=%d\n", frc, errno);

  {
    int ppos[2] = {-1, -1}, pvis = -1, pz = -1;
    screen_get_window_property_iv(win, SCREEN_PROPERTY_POSITION, ppos);
    screen_get_window_property_iv(win, SCREEN_PROPERTY_VISIBLE, &pvis);
    screen_get_window_property_iv(win, SCREEN_PROPERTY_ZORDER, &pz);
    P("after post: position=%d,%d visible=%d zorder=%d\n",
      ppos[0], ppos[1], pvis, pz);
  }
  P("holding 60s — look at the phone for a MAGENTA fill\n");
  logline("nav-probe posted, holding");
  sleep(60);
  return 0;
}
