/*
 * raster: software canvas implementation. See raster.h for the contract.
 */
#include "raster.h"

#include <math.h>
#include <stdio.h>
#include <string.h>

namespace raster {

uint32_t get_pixel(const Surface& s, int x, int y) {
  if (x < 0 || y < 0 || x >= s.w || y >= s.h) return 0;
  const uint8_t* p = s.px + (size_t)y * s.stride + (size_t)x * 4;
  return argb(p[3], p[0], p[1], p[2]);
}

void blend_pixel(const Surface& s, int x, int y, uint32_t color, int coverage) {
  if (x < 0 || y < 0 || x >= s.w || y >= s.h) return;
  if (coverage <= 0) return;
  if (coverage > 255) coverage = 255;
  int sa = alpha(color) * coverage / 255;  // effective source alpha 0..255
  if (sa <= 0) return;
  uint8_t* p = s.px + (size_t)y * s.stride + (size_t)x * 4;
  if (sa >= 255) {
    p[0] = (uint8_t)red(color);
    p[1] = (uint8_t)green(color);
    p[2] = (uint8_t)blue(color);
    p[3] = 0xff;
    return;
  }
  int ia = 255 - sa;  // src-over, non-premultiplied source
  p[0] = (uint8_t)((red(color) * sa + p[0] * ia + 127) / 255);
  p[1] = (uint8_t)((green(color) * sa + p[1] * ia + 127) / 255);
  p[2] = (uint8_t)((blue(color) * sa + p[2] * ia + 127) / 255);
  p[3] = (uint8_t)(sa + p[3] * ia / 255);
}

Canvas::Canvas(const Surface& s) : s_(s) {
  st_.push_back(State{0.0f, 0.0f, Rect{0, 0, s.w, s.h}});
}

int Canvas::save() {
  st_.push_back(st_.back());
  return (int)st_.size() - 2;  // the save count before this save, as Canvas does
}

void Canvas::restore() {
  if (st_.size() > 1) st_.pop_back();
}

void Canvas::translate(float dx, float dy) {
  cur().dx += dx;
  cur().dy += dy;
}

bool Canvas::clipRect(const Rect& lr) {
  Rect dr{(int)lroundf(lr.l + cur().dx), (int)lroundf(lr.t + cur().dy),
          (int)lroundf(lr.r + cur().dx), (int)lroundf(lr.b + cur().dy)};
  cur().clip = cur().clip.intersect(dr);
  return !cur().clip.empty();
}

void Canvas::drawColor(uint32_t color) {
  const Rect& c = cur().clip;
  for (int y = c.t; y < c.b; y++)
    for (int x = c.l; x < c.r; x++) blend_pixel(s_, x, y, color, 255);
}

void Canvas::drawRect(const Rect& lr, uint32_t color) {
  Rect dr{(int)lroundf(lr.l + cur().dx), (int)lroundf(lr.t + cur().dy),
          (int)lroundf(lr.r + cur().dx), (int)lroundf(lr.b + cur().dy)};
  Rect c = cur().clip.intersect(dr);
  for (int y = c.t; y < c.b; y++)
    for (int x = c.l; x < c.r; x++) blend_pixel(s_, x, y, color, 255);
}

float Canvas::drawGlyphs(FT_Face face, const uint32_t* cps, int count, float x, float y,
                         uint32_t color, float pixelSize) {
  if (face == nullptr) return 0;
  FT_Set_Pixel_Sizes(face, 0, (FT_UInt)lroundf(pixelSize));
  const Rect& clip = cur().clip;
  float penx = x + cur().dx;
  const float basey = y + cur().dy;  // baseline, device space
  const float startx = penx;
  for (int i = 0; i < count; i++) {
    if (FT_Load_Char(face, cps[i], FT_LOAD_RENDER) != 0) continue;
    const FT_GlyphSlot g = face->glyph;
    const FT_Bitmap& bm = g->bitmap;
    const int ox = (int)lroundf(penx) + g->bitmap_left;
    const int oy = (int)lroundf(basey) - g->bitmap_top;
    // FreeType gray bitmap: pitch>0 is top-to-bottom, pitch<0 bottom-to-top.
    for (unsigned row = 0; row < bm.rows; row++) {
      const unsigned src = bm.pitch >= 0 ? row : (bm.rows - 1 - row);
      const uint8_t* rp = bm.buffer + (size_t)src * (bm.pitch >= 0 ? bm.pitch : -bm.pitch);
      const int py = oy + (int)row;
      if (py < clip.t || py >= clip.b) continue;
      for (unsigned col = 0; col < bm.width; col++) {
        const int px = ox + (int)col;
        if (px < clip.l || px >= clip.r) continue;
        blend_pixel(s_, px, py, color, rp[col]);  // gray byte = coverage
      }
    }
    penx += g->advance.x / 64.0f;
  }
  return penx - startx;
}

// ---- PNG writer: stored DEFLATE, no zlib ----

namespace {

uint32_t crc32_of(const uint8_t* data, size_t len, uint32_t crc) {
  static uint32_t table[256];
  static bool built = false;
  if (!built) {
    for (uint32_t n = 0; n < 256; n++) {
      uint32_t c = n;
      for (int k = 0; k < 8; k++) c = (c & 1) ? (0xedb88320u ^ (c >> 1)) : (c >> 1);
      table[n] = c;
    }
    built = true;
  }
  crc ^= 0xffffffffu;
  for (size_t i = 0; i < len; i++) crc = table[(crc ^ data[i]) & 0xff] ^ (crc >> 8);
  return crc ^ 0xffffffffu;
}

uint32_t adler32_of(const uint8_t* data, size_t len) {
  uint32_t a = 1, b = 0;
  for (size_t i = 0; i < len; i++) {
    a = (a + data[i]) % 65521;
    b = (b + a) % 65521;
  }
  return (b << 16) | a;
}

void put_be32(uint8_t* p, uint32_t v) {
  p[0] = v >> 24; p[1] = v >> 16; p[2] = v >> 8; p[3] = v;
}

bool write_chunk(FILE* f, const char* type, const uint8_t* data, uint32_t len) {
  uint8_t hdr[8];
  put_be32(hdr, len);
  memcpy(hdr + 4, type, 4);
  if (fwrite(hdr, 1, 8, f) != 8) return false;
  if (len && fwrite(data, 1, len, f) != len) return false;
  // CRC covers the type and the data. Build the run once.
  std::vector<uint8_t> tmp(4 + len);
  memcpy(tmp.data(), type, 4);
  if (len) memcpy(tmp.data() + 4, data, len);
  uint32_t crc = crc32_of(tmp.data(), tmp.size(), 0);
  uint8_t cb[4];
  put_be32(cb, crc);
  return fwrite(cb, 1, 4, f) == 4;
}

}  // namespace

bool write_png(const char* path, const Surface& s) {
  FILE* f = fopen(path, "wb");
  if (f == nullptr) return false;
  bool ok = true;

  const uint8_t sig[8] = {0x89, 'P', 'N', 'G', 0x0d, 0x0a, 0x1a, 0x0a};
  ok = ok && fwrite(sig, 1, 8, f) == 8;

  uint8_t ihdr[13];
  put_be32(ihdr, (uint32_t)s.w);
  put_be32(ihdr + 4, (uint32_t)s.h);
  ihdr[8] = 8;   // bit depth
  ihdr[9] = 2;   // color type 2 = truecolor RGB
  ihdr[10] = 0;  // deflate
  ihdr[11] = 0;  // no filter
  ihdr[12] = 0;  // no interlace
  ok = ok && write_chunk(f, "IHDR", ihdr, sizeof(ihdr));

  // Filtered raw scanlines: filter byte 0, then RGB per pixel.
  const size_t rowbytes = 1 + (size_t)s.w * 3;
  std::vector<uint8_t> raw(rowbytes * s.h);
  for (int y = 0; y < s.h; y++) {
    uint8_t* dst = raw.data() + (size_t)y * rowbytes;
    *dst++ = 0;
    const uint8_t* srow = s.px + (size_t)y * s.stride;
    for (int x = 0; x < s.w; x++) {
      *dst++ = srow[x * 4 + 0];
      *dst++ = srow[x * 4 + 1];
      *dst++ = srow[x * 4 + 2];
    }
  }

  // zlib stream: header, stored DEFLATE blocks (<=65535 each), Adler32.
  std::vector<uint8_t> z;
  z.push_back(0x78);  // CMF
  z.push_back(0x01);  // FLG (no dict, fastest)
  size_t off = 0;
  while (off < raw.size()) {
    size_t n = raw.size() - off;
    if (n > 65535) n = 65535;
    const bool last = (off + n) >= raw.size();
    z.push_back(last ? 1 : 0);  // BFINAL, BTYPE=00 stored
    z.push_back(n & 0xff);
    z.push_back((n >> 8) & 0xff);
    z.push_back(~n & 0xff);
    z.push_back((~n >> 8) & 0xff);
    z.insert(z.end(), raw.begin() + off, raw.begin() + off + n);
    off += n;
  }
  uint32_t adler = adler32_of(raw.data(), raw.size());
  uint8_t ad[4];
  put_be32(ad, adler);
  z.insert(z.end(), ad, ad + 4);
  ok = ok && write_chunk(f, "IDAT", z.data(), (uint32_t)z.size());

  ok = ok && write_chunk(f, "IEND", nullptr, 0);

  if (fclose(f) != 0) ok = false;
  return ok;
}

}  // namespace raster
