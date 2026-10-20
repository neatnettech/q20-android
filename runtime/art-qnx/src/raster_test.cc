/*
 * Host test for the raster engine. Renders the Q20 Prober's A6 layout into a
 * 720x720 surface and asserts the pixels, then writes a PNG to eyeball.
 *
 * The A6 layout (docs/bringup-log.md), device pixels:
 *   DecorView            0,0   720x720
 *   TextView counter     273,279 173x65  "count: 0"   (48px text)
 *   Button   bump        272,344 176x96  "bump"
 *
 * Builds and runs on the host (g++ + system FreeType); the same raster.cc
 * compiles into the device facade. Any TrueType face works — the text
 * assertions are structural (pixels present inside the box, none above it), so
 * they do not depend on Roboto being the host font. Exit 0 = all pass.
 *
 *   raster_test [font.ttf] [out.png]
 * Font defaults to $RASTER_FONT or a common host path; PNG to ./raster_out.png.
 */
#include "raster.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <vector>

using raster::argb;
using raster::Canvas;
using raster::get_pixel;
using raster::Rect;
using raster::Surface;

namespace {

int g_pass = 0, g_fail = 0;

void check(bool cond, const char* what) {
  printf("  [%s] %s\n", cond ? "ok" : "FAIL", what);
  if (cond) g_pass++; else g_fail++;
}

// Assert a pixel equals an expected Color int, with a per-channel tolerance.
void check_px(const Surface& s, int x, int y, uint32_t want, int tol, const char* what) {
  uint32_t got = get_pixel(s, x, y);
  int dr = abs(raster::red(got) - raster::red(want));
  int dg = abs(raster::green(got) - raster::green(want));
  int db = abs(raster::blue(got) - raster::blue(want));
  bool ok = dr <= tol && dg <= tol && db <= tol;
  printf("  [%s] %s: (%d,%d) got #%06X want #%06X tol %d\n", ok ? "ok" : "FAIL",
         what, x, y, got & 0xffffff, want & 0xffffff, tol);
  if (ok) g_pass++; else g_fail++;
}

std::vector<uint32_t> cps(const char* ascii) {
  std::vector<uint32_t> v;
  for (const char* p = ascii; *p; p++) v.push_back((uint32_t)(unsigned char)*p);
  return v;
}

const char* resolve_font(int argc, char** argv) {
  if (argc > 1 && argv[1][0]) return argv[1];
  const char* env = getenv("RASTER_FONT");
  if (env && env[0]) return env;
  static const char* candidates[] = {
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    "/system/fonts/Roboto-Regular.ttf",
  };
  for (const char* c : candidates) {
    FILE* f = fopen(c, "rb");
    if (f) { fclose(f); return c; }
  }
  return candidates[0];
}

// Test fixtures. Not claims about the real Material theme — just distinct,
// checkable colors so the assertions mean something.
const uint32_t kDecorBg = argb(0xff, 0x20, 0x20, 0x20);  // dark gray
const uint32_t kButtonBg = argb(0xff, 0x3f, 0x51, 0xb5);  // indigo
const uint32_t kText = argb(0xff, 0xff, 0xff, 0xff);      // white

}  // namespace

int main(int argc, char** argv) {
  const char* fontPath = resolve_font(argc, argv);
  const char* outPath = (argc > 2 && argv[2][0]) ? argv[2] : "raster_out.png";

  FT_Library lib;
  FT_Face face;
  if (FT_Init_FreeType(&lib) != 0) { fprintf(stderr, "FT init failed\n"); return 2; }
  if (FT_New_Face(lib, fontPath, 0, &face) != 0) {
    fprintf(stderr, "cannot open font %s\n", fontPath);
    return 2;
  }
  printf("font: %s\n", fontPath);

  // --- unit tests on small surfaces: blend, clip, stride ---

  printf("blend (50%% white over black -> mid gray):\n");
  {
    std::vector<uint8_t> buf(4 * 4 * 4);
    Surface s{buf.data(), 4, 4, 4 * 4};
    Canvas c(s);
    c.drawColor(argb(0xff, 0, 0, 0));          // opaque black
    c.drawColor(argb(0x80, 0xff, 0xff, 0xff)); // 50% white over it
    check_px(s, 2, 2, argb(0xff, 0x80, 0x80, 0x80), 2, "half-white over black");
  }

  printf("clip (fill only inside the clip rect):\n");
  {
    std::vector<uint8_t> buf(10 * 10 * 4);
    Surface s{buf.data(), 10, 10, 10 * 4};
    Canvas c(s);
    c.drawColor(kDecorBg);
    c.save();
    bool nonEmpty = c.clipRect(Rect{3, 3, 7, 7});
    c.drawColor(kText);  // white, but only the clip should change
    c.restore();
    check(nonEmpty, "clipRect reports non-empty");
    check_px(s, 5, 5, kText, 0, "inside clip is white");
    check_px(s, 1, 1, kDecorBg, 0, "outside clip untouched");
    check_px(s, 8, 8, kDecorBg, 0, "outside clip untouched (2)");
  }

  printf("stride (padded row stride respected):\n");
  {
    const int W = 8, H = 8, tight = W * 4, padded = W * 4 + 64;
    std::vector<uint8_t> a(tight * H), b(padded * H);
    Surface sa{a.data(), W, H, tight}, sb{b.data(), W, H, padded};
    Canvas(sa).drawRect(Rect{2, 2, 6, 6}, kButtonBg);
    Canvas(sb).drawRect(Rect{2, 2, 6, 6}, kButtonBg);
    bool same = true;
    for (int y = 0; y < H && same; y++)
      for (int x = 0; x < W; x++)
        if (get_pixel(sa, x, y) != get_pixel(sb, x, y)) { same = false; break; }
    check(same, "tight and padded strides give identical pixels");
  }

  // --- the Prober A6 layout at device size and stride ---

  printf("prober layout (720x720, device stride 2944):\n");
  const int W = 720, H = 720, stride = 2944;  // A4's real window stride
  std::vector<uint8_t> fb((size_t)stride * H);
  Surface s{fb.data(), W, H, stride};
  Canvas c(s);

  c.drawColor(kDecorBg);                            // DecorView fill
  c.drawRect(Rect{272, 344, 272 + 176, 344 + 96}, kButtonBg);  // Button bg

  // counter TextView "count: 0" in its box 273,279 173x65 at 48px.
  const Rect counter{273, 279, 273 + 173, 279 + 65};
  auto counterCps = cps("count: 0");
  c.save();
  c.clipRect(counter);
  c.drawGlyphs(face, counterCps.data(), (int)counterCps.size(),
               counter.l + 2, counter.t + 48, kText, 48);  // baseline inside box
  c.restore();

  // button label "bump" roughly centered in the button at 36px.
  auto bumpCps = cps("bump");
  c.drawGlyphs(face, bumpCps.data(), (int)bumpCps.size(), 300, 344 + 60, kText, 36);

  check_px(s, 0, 0, kDecorBg, 0, "top-left corner is decor bg");
  check_px(s, 360, 392, kButtonBg, 0, "button center is button bg");
  check_px(s, 360, 300, kDecorBg, 0, "between counter and button is decor bg");

  // Text was actually drawn: count pixels in the counter box that differ from
  // the decor bg. White glyphs on dark bg produce many.
  int textPx = 0;
  for (int y = counter.t; y < counter.b; y++)
    for (int x = counter.l; x < counter.r; x++)
      if ((get_pixel(s, x, y) & 0xffffff) != (kDecorBg & 0xffffff)) textPx++;
  printf("  counter box non-bg pixels: %d\n", textPx);
  check(textPx > 150, "counter text rendered (>150 glyph pixels)");

  // Nothing bled above the counter box: a row just above it is pure decor bg.
  bool cleanAbove = true;
  for (int x = 0; x < W; x++)
    if ((get_pixel(s, x, counter.t - 4) & 0xffffff) != (kDecorBg & 0xffffff)) {
      cleanAbove = false;
      break;
    }
  check(cleanAbove, "no text above the counter box (clip holds)");

  if (!raster::write_png(outPath, s)) {
    fprintf(stderr, "write_png(%s) failed\n", outPath);
    g_fail++;
  } else {
    printf("wrote %s\n", outPath);
  }

  FT_Done_Face(face);
  FT_Done_FreeType(lib);

  printf("\n%d passed, %d failed\n", g_pass, g_fail);
  return g_fail == 0 ? 0 : 1;
}
