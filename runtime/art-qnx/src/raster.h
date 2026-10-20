/*
 * raster: a tiny software canvas for the Q20 facade's first pixels (A7).
 *
 * The facade measures and lays out a View tree (A6) but draws nothing. This is
 * the drawing engine: it turns fills and text runs into pixels in an RGBA8888
 * surface — the exact format of the CPU-mappable window buffer A4 proved posts
 * to the Q20 panel (screen_probe.c: bytes R,G,B,A, arbitrary row stride).
 *
 * No Skia, no JNI, no ART. Portable C++ + FreeType only, so it builds both for
 * the device (into the facade, beside graphics_facade.cc) and for the host,
 * where raster_test.cc renders the Prober layout and asserts the pixels. The
 * on-device A7 step wires android.graphics.Canvas JNI onto this API; each
 * Canvas native is then a one-line forward to a method here (see the map at the
 * bottom of this header). That binding is deliberately not written until it can
 * be exercised on hardware.
 *
 * Coordinates are integer device pixels. Colors are Android Color ints
 * (0xAARRGGBB); the surface stores them as R,G,B,A bytes to match the panel
 * buffer. Compositing is straight src-over with a non-premultiplied source.
 * Transform support is translate + rect clip (a save/restore stack), which is
 * all the Prober tree uses; rotation and scale are a documented TODO, kept out
 * until a laid-out tree needs them.
 */
#ifndef Q20_RASTER_H_
#define Q20_RASTER_H_

#include <stdint.h>

#include <ft2build.h>
#include FT_FREETYPE_H

#include <vector>

namespace raster {

// Half-open rectangle [l, r) x [t, b). Empty when r<=l or b<=t.
struct Rect {
  int l = 0, t = 0, r = 0, b = 0;
  bool empty() const { return r <= l || b <= t; }
  int width() const { return r > l ? r - l : 0; }
  int height() const { return b > t ? b - t : 0; }
  Rect intersect(const Rect& o) const {
    Rect x{l > o.l ? l : o.l, t > o.t ? t : o.t, r < o.r ? r : o.r, b < o.b ? b : o.b};
    if (x.empty()) return Rect{0, 0, 0, 0};
    return x;
  }
};

// An RGBA8888 surface: px is w*h pixels, row stride in bytes (>= w*4), byte
// order R,G,B,A. The surface does not own px — it wraps the window buffer on
// device, or a heap buffer in the host test.
struct Surface {
  uint8_t* px = nullptr;
  int w = 0, h = 0, stride = 0;
};

// Pack/unpack Android Color ints (0xAARRGGBB).
inline uint32_t argb(int a, int r, int g, int b) {
  return (uint32_t(a & 0xff) << 24) | (uint32_t(r & 0xff) << 16) |
         (uint32_t(g & 0xff) << 8) | uint32_t(b & 0xff);
}
inline int alpha(uint32_t c) { return (c >> 24) & 0xff; }
inline int red(uint32_t c)   { return (c >> 16) & 0xff; }
inline int green(uint32_t c) { return (c >> 8) & 0xff; }
inline int blue(uint32_t c)  { return c & 0xff; }

// Read a pixel back as a Color int (A=0xff; the surface keeps the stored A).
// Out-of-bounds reads return 0; used by the host test to assert results.
uint32_t get_pixel(const Surface& s, int x, int y);

// Blend one color over the pixel at (x,y) with extra coverage [0,255]
// (255 = use the color's own alpha). Clipped to the surface. The primitive
// every fill and glyph goes through.
void blend_pixel(const Surface& s, int x, int y, uint32_t color, int coverage);

// android.graphics.Canvas, as much of it as a laid-out View tree touches.
// Local coordinates are translated by the current offset and clipped by the
// current clip before anything is written.
class Canvas {
 public:
  explicit Canvas(const Surface& s);

  int save();
  void restore();
  void translate(float dx, float dy);
  // Intersect the clip with this local-space rect. Returns false if the clip
  // became empty (Canvas.clipRect's contract).
  bool clipRect(const Rect& localRect);

  const Rect& deviceClip() const { return st_.back().clip; }

  // Fill the entire current clip (Canvas.drawColor / drawPaint).
  void drawColor(uint32_t color);
  // Fill a local-space rect (Canvas.drawRect with a fill paint).
  void drawRect(const Rect& localRect, uint32_t color);

  // Draw a run of Unicode code points with their baseline origin at local
  // (x, y), at pixelSize px, in color. Glyphs come from face (caller owns it,
  // any size). Advances left to right using FreeType's advances — the same
  // metric source as graphics_facade.cc's measure path. Returns the pen x
  // advance in pixels. No shaping, kerning or hinting (A7 scope).
  float drawGlyphs(FT_Face face, const uint32_t* cps, int count, float x, float y,
                   uint32_t color, float pixelSize);

 private:
  struct State { float dx, dy; Rect clip; };
  Surface s_;
  std::vector<State> st_;
  State& cur() { return st_.back(); }
};

// Write the surface to a PNG at path (dependency-free: stored DEFLATE blocks,
// so no zlib). For eyeballing the host test's output. Returns false on I/O
// error. Alpha is written opaque; the panel is opaque anyway.
bool write_png(const char* path, const Surface& s);

/*
 * Canvas JNI -> engine, for the on-device A7 step (not built yet):
 *   native drawColor(int c)                 -> Canvas::drawColor(c)
 *   native drawRect(l,t,r,b, paintHandle)   -> Canvas::drawRect({l,t,r,b}, paint.color)
 *   native drawText(char[]/String, x, y, p) -> Canvas::drawGlyphs(face, cps, n, x, y,
 *                                                 paint.color, paint.textSize)
 *   native save()/restore()/translate()/clipRect() -> same-named methods here
 * The Canvas handle holds a Surface wrapping the posted window buffer; one
 * draw pass over the decor (decor.draw(canvas)) then post_window() shows it.
 */

}  // namespace raster

#endif  // Q20_RASTER_H_
