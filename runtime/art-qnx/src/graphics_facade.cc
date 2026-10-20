/*
 * QNX graphics facade: the Paint, Path, Matrix, RenderNode, ColorFilter and
 * EmojiFactory natives a View tree reaches while it is built, measured and
 * laid out (A6), plus the Canvas and Surface natives that then draw it (A7).
 * There is no Skia, minikin or hwui on the Q20, so these natives keep plain
 * state; text metrics come from FreeType (QNX sysroot) reading
 * $ANDROID_ROOT/fonts/Roboto-Regular.ttf, and drawing goes to the software
 * rasterizer in raster.cc over the QNX Screen window in screen_window.cc.
 *
 * Typeface and FontFamily natives are deliberately absent: /system/etc/fonts.xml
 * is unreadable here, so Typeface.<clinit> leaves every Typeface null and Paint
 * only ever sees typeface handle 0, the default font.
 *
 * ponytail: no Skia. No HarfBuzz shaping, kerning or hinting (widths differ from a
 * real phone by a few percent); Roboto Regular stands in for every family, bold
 * and medium included; left to right only; Path keeps points for
 * approximate() and nothing else; Matrix is real 3x3 math for the operations
 * registered below (no rotate or skew yet); RenderNode is a property bag. A native that
 * is not registered here fails with UnsatisfiedLinkError naming the method:
 * add it when a trace reaches it.
 */
#define LOG_TAG "q20gfx"

#include <jni.h>
#include <utils/Log.h>

#include "JNIHelp.h"

#include "raster.h"
#include "screen_window.h"

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_ADVANCES_H

#include <math.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

#include <string>
#include <vector>

namespace {

// ---- font ----

pthread_mutex_t gFontLock = PTHREAD_MUTEX_INITIALIZER;
FT_Library gFtLibrary;
FT_Face gFace;
bool gFontTried;

// Caller holds gFontLock. Null when the font cannot be loaded: text then
// measures 0, loudly logged once.
FT_Face face() {
  if (!gFontTried) {
    gFontTried = true;
    const char* root = getenv("ANDROID_ROOT");
    std::string path = std::string(root ? root : "/system") + "/fonts/Roboto-Regular.ttf";
    if (FT_Init_FreeType(&gFtLibrary) != 0 || FT_New_Face(gFtLibrary, path.c_str(), 0, &gFace) != 0) {
      ALOGE("cannot load %s, all text measures 0", path.c_str());
      gFace = nullptr;
    }
  }
  return gFace;
}

// ---- Paint ----

// Java Paint flag bits (Paint.java), stored as given.
const uint32_t kFilterBitmap = 0x02;
const uint32_t kAntiAlias = 0x01, kDither = 0x04, kUnderline = 0x08, kStrikeThru = 0x10,
               kFakeBold = 0x20, kLinear = 0x40, kSubpixel = 0x80;

struct FPaint {
  uint32_t flags = 0;
  int hinting = 1;
  uint32_t color = 0xFF000000;
  float strokeWidth = 0, strokeMiter = 4;
  float textSize = 12, textScaleX = 1, textSkewX = 0, letterSpacing = 0;
  int style = 0, cap = 0, join = 0, align = 0, hyphenEdit = 0;
  bool elegant = false, shadow = false;
};

jfieldID gPaintNative;
struct { jfieldID top, ascent, descent, bottom, leading; } gFm, gFmi;

FPaint* paintOf(JNIEnv* env, jobject paint) {
  return reinterpret_cast<FPaint*>(env->GetLongField(paint, gPaintNative));
}
FPaint* paintAt(jlong handle) { return reinterpret_cast<FPaint*>(handle); }

// UTF-16 text[start, end) to code points, decoding surrogate pairs. Shared by
// the measure path (advance) and the draw path (drawRun).
void decodeUtf16(const jchar* text, int start, int end, std::vector<uint32_t>* out) {
  for (int i = start; i < end; i++) {
    uint32_t c = text[i];
    if (c >= 0xD800 && c < 0xDC00 && i + 1 < end && text[i + 1] >= 0xDC00 && text[i + 1] < 0xE000) {
      c = 0x10000 + ((c - 0xD800) << 10) + (text[i + 1] - 0xDC00);
      i++;
    }
    out->push_back(c);
  }
}

// Advance in pixels of UTF-16 text[start, end).
float advance(const FPaint* p, const jchar* text, int start, int end) {
  std::vector<uint32_t> cps;
  decodeUtf16(text, start, end, &cps);
  pthread_mutex_lock(&gFontLock);
  FT_Face f = face();
  double units = 0;
  for (size_t i = 0; f != nullptr && i < cps.size(); i++) {
    FT_Fixed a = 0;
    FT_Get_Advance(f, FT_Get_Char_Index(f, cps[i]), FT_LOAD_NO_SCALE, &a);
    units += a;
  }
  double upem = f != nullptr ? f->units_per_EM : 1;
  pthread_mutex_unlock(&gFontLock);
  double scale = p->textSize * p->textScaleX;
  return units * scale / upem + cps.size() * p->letterSpacing * scale;
}

struct Metrics { float top, ascent, descent, bottom, leading; };

// Same sign rules as Skia's FreeType backend: ascent and top negative. Returns
// the recommended line spacing, like SkPaint::getFontMetrics.
float metrics(const FPaint* p, Metrics* m) {
  float size = p->textSize;
  if (p->elegant) {
    // Stock Paint.cpp constants for elegant text height.
    m->top = -size * 2500 / 2048;
    m->bottom = size * 1000 / 2048;
    m->ascent = -size * 1900 / 2048;
    m->descent = size * 500 / 2048;
    m->leading = 0;
  } else {
    pthread_mutex_lock(&gFontLock);
    FT_Face f = face();
    if (f != nullptr) {
      float s = size / f->units_per_EM;
      m->ascent = -f->ascender * s;
      m->descent = -f->descender * s;
      m->top = -f->bbox.yMax * s;
      m->bottom = -f->bbox.yMin * s;
      m->leading = (f->height - f->ascender + f->descender) * s;
    } else {
      *m = Metrics{0, 0, 0, 0, 0};
    }
    pthread_mutex_unlock(&gFontLock);
  }
  return m->descent - m->ascent + m->leading;
}

bool checkRange(JNIEnv* env, int start, int end, int length) {
  if (start < 0 || end < start || end > length) {
    jniThrowException(env, "java/lang/ArrayIndexOutOfBoundsException", nullptr);
    return false;
  }
  return true;
}

jlong Paint_init(JNIEnv*, jclass) { return reinterpret_cast<jlong>(new FPaint()); }
jlong Paint_initWithPaint(JNIEnv*, jclass, jlong h) { return reinterpret_cast<jlong>(new FPaint(*paintAt(h))); }
void Paint_finalizer(JNIEnv*, jclass, jlong h) { delete paintAt(h); }
void Paint_reset(JNIEnv*, jclass, jlong h) { *paintAt(h) = FPaint(); }
void Paint_set(JNIEnv*, jclass, jlong dst, jlong src) { *paintAt(dst) = *paintAt(src); }

jint Paint_getFlags(JNIEnv* env, jobject o) { return paintOf(env, o)->flags; }
void Paint_setFlags(JNIEnv* env, jobject o, jint f) { paintOf(env, o)->flags = f; }
jint Paint_getHinting(JNIEnv* env, jobject o) { return paintOf(env, o)->hinting; }
void Paint_setHinting(JNIEnv* env, jobject o, jint m) { paintOf(env, o)->hinting = m; }

void setFlag(JNIEnv* env, jobject o, uint32_t bit, jboolean on) {
  FPaint* p = paintOf(env, o);
  p->flags = on ? (p->flags | bit) : (p->flags & ~bit);
}
void Paint_setAntiAlias(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kAntiAlias, v); }
void Paint_setDither(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kDither, v); }
void Paint_setUnderlineText(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kUnderline, v); }
void Paint_setStrikeThruText(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kStrikeThru, v); }
void Paint_setFakeBoldText(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kFakeBold, v); }
void Paint_setLinearText(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kLinear, v); }
void Paint_setSubpixelText(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kSubpixel, v); }
void Paint_setFilterBitmap(JNIEnv* env, jobject o, jboolean v) { setFlag(env, o, kFilterBitmap, v); }

jint Paint_getColor(JNIEnv* env, jobject o) { return paintOf(env, o)->color; }
void Paint_setColor(JNIEnv* env, jobject o, jint c) { paintOf(env, o)->color = c; }
jint Paint_getAlpha(JNIEnv* env, jobject o) { return paintOf(env, o)->color >> 24; }
void Paint_setAlpha(JNIEnv* env, jobject o, jint a) {
  FPaint* p = paintOf(env, o);
  p->color = (p->color & 0x00FFFFFF) | (static_cast<uint32_t>(a & 0xFF) << 24);
}
jfloat Paint_getStrokeWidth(JNIEnv* env, jobject o) { return paintOf(env, o)->strokeWidth; }
void Paint_setStrokeWidth(JNIEnv* env, jobject o, jfloat w) { paintOf(env, o)->strokeWidth = w; }
jfloat Paint_getStrokeMiter(JNIEnv* env, jobject o) { return paintOf(env, o)->strokeMiter; }
void Paint_setStrokeMiter(JNIEnv* env, jobject o, jfloat m) { paintOf(env, o)->strokeMiter = m; }
jboolean Paint_isElegantTextHeight(JNIEnv* env, jobject o) { return paintOf(env, o)->elegant; }
void Paint_setElegantTextHeight(JNIEnv* env, jobject o, jboolean e) { paintOf(env, o)->elegant = e; }
jfloat Paint_getTextSize(JNIEnv* env, jobject o) { return paintOf(env, o)->textSize; }
void Paint_setTextSize(JNIEnv* env, jobject o, jfloat s) { paintOf(env, o)->textSize = s; }
jfloat Paint_getTextScaleX(JNIEnv* env, jobject o) { return paintOf(env, o)->textScaleX; }
void Paint_setTextScaleX(JNIEnv* env, jobject o, jfloat s) { paintOf(env, o)->textScaleX = s; }
jfloat Paint_getTextSkewX(JNIEnv* env, jobject o) { return paintOf(env, o)->textSkewX; }
void Paint_setTextSkewX(JNIEnv* env, jobject o, jfloat s) { paintOf(env, o)->textSkewX = s; }

jint Paint_getStyle(JNIEnv*, jclass, jlong h) { return paintAt(h)->style; }
void Paint_setStyle(JNIEnv*, jclass, jlong h, jint v) { paintAt(h)->style = v; }
jint Paint_getStrokeCap(JNIEnv*, jclass, jlong h) { return paintAt(h)->cap; }
void Paint_setStrokeCap(JNIEnv*, jclass, jlong h, jint v) { paintAt(h)->cap = v; }
jint Paint_getStrokeJoin(JNIEnv*, jclass, jlong h) { return paintAt(h)->join; }
void Paint_setStrokeJoin(JNIEnv*, jclass, jlong h, jint v) { paintAt(h)->join = v; }
jint Paint_getTextAlign(JNIEnv*, jclass, jlong h) { return paintAt(h)->align; }
void Paint_setTextAlign(JNIEnv*, jclass, jlong h, jint v) { paintAt(h)->align = v; }
jfloat Paint_getLetterSpacing(JNIEnv*, jclass, jlong h) { return paintAt(h)->letterSpacing; }
void Paint_setLetterSpacing(JNIEnv*, jclass, jlong h, jfloat v) { paintAt(h)->letterSpacing = v; }
jint Paint_getHyphenEdit(JNIEnv*, jclass, jlong h) { return paintAt(h)->hyphenEdit; }
void Paint_setHyphenEdit(JNIEnv*, jclass, jlong h, jint v) { paintAt(h)->hyphenEdit = v; }
void Paint_setTextLocale(JNIEnv*, jclass, jlong, jstring) {}
void Paint_setFontFeatureSettings(JNIEnv*, jclass, jlong, jstring) {}
void Paint_setShadowLayer(JNIEnv*, jclass, jlong h, jfloat radius, jfloat, jfloat, jint) {
  paintAt(h)->shadow = radius > 0;
}
jboolean Paint_hasShadowLayer(JNIEnv*, jclass, jlong h) { return paintAt(h)->shadow; }
// Shader, filters, typeface and friends: the handle is kept by the Java object
// and nothing native draws, so only the stock return value (the new handle)
// matters.
jlong Paint_setHandle(JNIEnv*, jclass, jlong, jlong handle) { return handle; }

jfloat Paint_ascent(JNIEnv* env, jobject o) {
  Metrics m;
  metrics(paintOf(env, o), &m);
  return m.ascent;
}
jfloat Paint_descent(JNIEnv* env, jobject o) {
  Metrics m;
  metrics(paintOf(env, o), &m);
  return m.descent;
}
jfloat Paint_getFontMetrics(JNIEnv* env, jobject o, jobject fm) {
  Metrics m;
  float spacing = metrics(paintOf(env, o), &m);
  if (fm != nullptr) {
    env->SetFloatField(fm, gFm.top, m.top);
    env->SetFloatField(fm, gFm.ascent, m.ascent);
    env->SetFloatField(fm, gFm.descent, m.descent);
    env->SetFloatField(fm, gFm.bottom, m.bottom);
    env->SetFloatField(fm, gFm.leading, m.leading);
  }
  return spacing;
}
jint Paint_getFontMetricsInt(JNIEnv* env, jobject o, jobject fmi) {
  Metrics m;
  metrics(paintOf(env, o), &m);
  // Stock rounding: top floor, bottom ceil, the rest rounded.
  int ascent = lroundf(m.ascent), descent = lroundf(m.descent), leading = lroundf(m.leading);
  if (fmi != nullptr) {
    env->SetIntField(fmi, gFmi.top, static_cast<int>(floorf(m.top)));
    env->SetIntField(fmi, gFmi.ascent, ascent);
    env->SetIntField(fmi, gFmi.descent, descent);
    env->SetIntField(fmi, gFmi.bottom, static_cast<int>(ceilf(m.bottom)));
    env->SetIntField(fmi, gFmi.leading, leading);
  }
  return descent - ascent + leading;
}

jfloat Paint_measureText_CIII(JNIEnv* env, jobject o, jcharArray text, jint index, jint count, jint) {
  if (!checkRange(env, index, index + count, env->GetArrayLength(text))) return 0;
  jchar* chars = env->GetCharArrayElements(text, nullptr);
  float w = advance(paintOf(env, o), chars, index, index + count);
  env->ReleaseCharArrayElements(text, chars, JNI_ABORT);
  return w;
}
jfloat Paint_measureText_StringIII(JNIEnv* env, jobject o, jstring text, jint start, jint end, jint) {
  if (!checkRange(env, start, end, env->GetStringLength(text))) return 0;
  const jchar* chars = env->GetStringChars(text, nullptr);
  float w = advance(paintOf(env, o), chars, start, end);
  env->ReleaseStringChars(text, chars);
  return w;
}
jfloat Paint_measureText_StringI(JNIEnv* env, jobject o, jstring text, jint) {
  const jchar* chars = env->GetStringChars(text, nullptr);
  float w = advance(paintOf(env, o), chars, 0, env->GetStringLength(text));
  env->ReleaseStringChars(text, chars);
  return w;
}
// TextLine: the advance from start to offset of the run [start, end).
jfloat Paint_getRunAdvance(JNIEnv* env, jclass, jlong h, jlong, jcharArray text, jint start, jint end,
                           jint, jint, jboolean, jint offset) {
  if (!checkRange(env, start, end, env->GetArrayLength(text)) || offset < start || offset > end) {
    return 0;
  }
  jchar* chars = env->GetCharArrayElements(text, nullptr);
  float w = advance(paintAt(h), chars, start, offset);
  env->ReleaseCharArrayElements(text, chars, JNI_ABORT);
  return w;
}

JNINativeMethod gPaintMethods[] = {
  { "finalizer", "(J)V", reinterpret_cast<void*>(Paint_finalizer) },
  { "native_init", "()J", reinterpret_cast<void*>(Paint_init) },
  { "native_initWithPaint", "(J)J", reinterpret_cast<void*>(Paint_initWithPaint) },
  { "native_reset", "(J)V", reinterpret_cast<void*>(Paint_reset) },
  { "native_set", "(JJ)V", reinterpret_cast<void*>(Paint_set) },
  { "getFlags", "()I", reinterpret_cast<void*>(Paint_getFlags) },
  { "setFlags", "(I)V", reinterpret_cast<void*>(Paint_setFlags) },
  { "getHinting", "()I", reinterpret_cast<void*>(Paint_getHinting) },
  { "setHinting", "(I)V", reinterpret_cast<void*>(Paint_setHinting) },
  { "setAntiAlias", "(Z)V", reinterpret_cast<void*>(Paint_setAntiAlias) },
  { "setSubpixelText", "(Z)V", reinterpret_cast<void*>(Paint_setSubpixelText) },
  { "setLinearText", "(Z)V", reinterpret_cast<void*>(Paint_setLinearText) },
  { "setUnderlineText", "(Z)V", reinterpret_cast<void*>(Paint_setUnderlineText) },
  { "setStrikeThruText", "(Z)V", reinterpret_cast<void*>(Paint_setStrikeThruText) },
  { "setFakeBoldText", "(Z)V", reinterpret_cast<void*>(Paint_setFakeBoldText) },
  { "setFilterBitmap", "(Z)V", reinterpret_cast<void*>(Paint_setFilterBitmap) },
  { "setDither", "(Z)V", reinterpret_cast<void*>(Paint_setDither) },
  { "native_getStyle", "(J)I", reinterpret_cast<void*>(Paint_getStyle) },
  { "native_setStyle", "(JI)V", reinterpret_cast<void*>(Paint_setStyle) },
  { "getColor", "()I", reinterpret_cast<void*>(Paint_getColor) },
  { "setColor", "(I)V", reinterpret_cast<void*>(Paint_setColor) },
  { "getAlpha", "()I", reinterpret_cast<void*>(Paint_getAlpha) },
  { "setAlpha", "(I)V", reinterpret_cast<void*>(Paint_setAlpha) },
  { "getStrokeWidth", "()F", reinterpret_cast<void*>(Paint_getStrokeWidth) },
  { "setStrokeWidth", "(F)V", reinterpret_cast<void*>(Paint_setStrokeWidth) },
  { "getStrokeMiter", "()F", reinterpret_cast<void*>(Paint_getStrokeMiter) },
  { "setStrokeMiter", "(F)V", reinterpret_cast<void*>(Paint_setStrokeMiter) },
  { "native_getStrokeCap", "(J)I", reinterpret_cast<void*>(Paint_getStrokeCap) },
  { "native_setStrokeCap", "(JI)V", reinterpret_cast<void*>(Paint_setStrokeCap) },
  { "native_getStrokeJoin", "(J)I", reinterpret_cast<void*>(Paint_getStrokeJoin) },
  { "native_setStrokeJoin", "(JI)V", reinterpret_cast<void*>(Paint_setStrokeJoin) },
  { "native_setShader", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_setColorFilter", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_setXfermode", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_setPathEffect", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_setMaskFilter", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_setTypeface", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_setRasterizer", "(JJ)J", reinterpret_cast<void*>(Paint_setHandle) },
  { "native_getTextAlign", "(J)I", reinterpret_cast<void*>(Paint_getTextAlign) },
  { "native_setTextAlign", "(JI)V", reinterpret_cast<void*>(Paint_setTextAlign) },
  { "native_setTextLocale", "(JLjava/lang/String;)V", reinterpret_cast<void*>(Paint_setTextLocale) },
  { "isElegantTextHeight", "()Z", reinterpret_cast<void*>(Paint_isElegantTextHeight) },
  { "setElegantTextHeight", "(Z)V", reinterpret_cast<void*>(Paint_setElegantTextHeight) },
  { "getTextSize", "()F", reinterpret_cast<void*>(Paint_getTextSize) },
  { "setTextSize", "(F)V", reinterpret_cast<void*>(Paint_setTextSize) },
  { "getTextScaleX", "()F", reinterpret_cast<void*>(Paint_getTextScaleX) },
  { "setTextScaleX", "(F)V", reinterpret_cast<void*>(Paint_setTextScaleX) },
  { "getTextSkewX", "()F", reinterpret_cast<void*>(Paint_getTextSkewX) },
  { "setTextSkewX", "(F)V", reinterpret_cast<void*>(Paint_setTextSkewX) },
  { "native_getLetterSpacing", "(J)F", reinterpret_cast<void*>(Paint_getLetterSpacing) },
  { "native_setLetterSpacing", "(JF)V", reinterpret_cast<void*>(Paint_setLetterSpacing) },
  { "native_setFontFeatureSettings", "(JLjava/lang/String;)V", reinterpret_cast<void*>(Paint_setFontFeatureSettings) },
  { "native_getHyphenEdit", "(J)I", reinterpret_cast<void*>(Paint_getHyphenEdit) },
  { "native_setHyphenEdit", "(JI)V", reinterpret_cast<void*>(Paint_setHyphenEdit) },
  { "native_setShadowLayer", "(JFFFI)V", reinterpret_cast<void*>(Paint_setShadowLayer) },
  { "native_hasShadowLayer", "(J)Z", reinterpret_cast<void*>(Paint_hasShadowLayer) },
  { "ascent", "()F", reinterpret_cast<void*>(Paint_ascent) },
  { "descent", "()F", reinterpret_cast<void*>(Paint_descent) },
  { "getFontMetrics", "(Landroid/graphics/Paint$FontMetrics;)F", reinterpret_cast<void*>(Paint_getFontMetrics) },
  { "getFontMetricsInt", "(Landroid/graphics/Paint$FontMetricsInt;)I", reinterpret_cast<void*>(Paint_getFontMetricsInt) },
  { "native_measureText", "([CIII)F", reinterpret_cast<void*>(Paint_measureText_CIII) },
  { "native_measureText", "(Ljava/lang/String;I)F", reinterpret_cast<void*>(Paint_measureText_StringI) },
  { "native_measureText", "(Ljava/lang/String;III)F", reinterpret_cast<void*>(Paint_measureText_StringIII) },
  { "native_getRunAdvance", "(JJ[CIIIIZI)F", reinterpret_cast<void*>(Paint_getRunAdvance) },
};

// ---- Path ----

struct FPath {
  std::vector<char> verbs;   // 'M' 'L' 'Q' 'C' 'Z'
  std::vector<float> points; // x, y pairs: M and L one, Q two, C three
};

FPath* pathAt(jlong h) { return reinterpret_cast<FPath*>(h); }

jlong Path_init1(JNIEnv*, jclass) { return reinterpret_cast<jlong>(new FPath()); }
jlong Path_init2(JNIEnv*, jclass, jlong src) { return reinterpret_cast<jlong>(new FPath(*pathAt(src))); }
void Path_finalizer(JNIEnv*, jclass, jlong h) { delete pathAt(h); }
void Path_reset(JNIEnv*, jclass, jlong h) { *pathAt(h) = FPath(); }
void Path_set(JNIEnv*, jclass, jlong dst, jlong src) { *pathAt(dst) = *pathAt(src); }
jboolean Path_isEmpty(JNIEnv*, jclass, jlong h) { return pathAt(h)->verbs.empty(); }

void add(jlong h, char verb, std::initializer_list<float> pts) {
  FPath* p = pathAt(h);
  p->verbs.push_back(verb);
  p->points.insert(p->points.end(), pts);
}
void Path_moveTo(JNIEnv*, jclass, jlong h, jfloat x, jfloat y) { add(h, 'M', {x, y}); }
void Path_lineTo(JNIEnv*, jclass, jlong h, jfloat x, jfloat y) { add(h, 'L', {x, y}); }
void Path_quadTo(JNIEnv*, jclass, jlong h, jfloat x1, jfloat y1, jfloat x2, jfloat y2) {
  add(h, 'Q', {x1, y1, x2, y2});
}
void Path_cubicTo(JNIEnv*, jclass, jlong h, jfloat x1, jfloat y1, jfloat x2, jfloat y2,
                  jfloat x3, jfloat y3) {
  add(h, 'C', {x1, y1, x2, y2, x3, y3});
}
void Path_close(JNIEnv*, jclass, jlong h) { add(h, 'Z', {}); }

// Float triplets (length fraction, x, y), as stock Path.cpp. PathInterpolator
// relies on exact endpoints and x never decreasing along a monotonic curve.
// ponytail: fixed 64 segments per curve, ignoring the error bound; Skia's
// adaptive subdivision when precision matters.
jfloatArray Path_approximate(JNIEnv* env, jclass, jlong h, jfloat) {
  const int kSegments = 64;
  const FPath* path = pathAt(h);
  std::vector<float> xy;
  std::vector<bool> jump;  // a move: no length to the previous point
  float cx = 0, cy = 0, sx = 0, sy = 0;
  size_t k = 0;
  auto push = [&](float x, float y, bool isJump) {
    xy.push_back(x);
    xy.push_back(y);
    jump.push_back(isJump);
  };
  for (char v : path->verbs) {
    if (v != 'M' && xy.empty()) push(cx, cy, true);
    const float* q = path->points.data() + k;
    if (v == 'M') {
      push(q[0], q[1], true);
      sx = cx = q[0]; sy = cy = q[1]; k += 2;
    } else if (v == 'L') {
      push(q[0], q[1], false);
      cx = q[0]; cy = q[1]; k += 2;
    } else if (v == 'Q') {
      for (int i = 1; i <= kSegments; i++) {
        float t = static_cast<float>(i) / kSegments, mt = 1 - t;
        push(mt * mt * cx + 2 * mt * t * q[0] + t * t * q[2],
             mt * mt * cy + 2 * mt * t * q[1] + t * t * q[3], false);
      }
      cx = q[2]; cy = q[3]; k += 4;
    } else if (v == 'C') {
      for (int i = 1; i <= kSegments; i++) {
        float t = static_cast<float>(i) / kSegments, mt = 1 - t;
        float a = mt * mt * mt, b = 3 * mt * mt * t, c = 3 * mt * t * t, d = t * t * t;
        push(a * cx + b * q[0] + c * q[2] + d * q[4], a * cy + b * q[1] + c * q[3] + d * q[5], false);
      }
      cx = q[4]; cy = q[5]; k += 6;
    } else if (v == 'Z') {
      push(sx, sy, false);
      cx = sx; cy = sy;
    }
  }
  if (xy.empty()) push(0, 0, true);
  if (xy.size() == 2) push(xy[0], xy[1], false);  // a lone point: length 0 to 1
  size_t n = jump.size();
  std::vector<double> length(n, 0);
  for (size_t i = 1; i < n; i++) {
    double d = jump[i] ? 0 : hypot(xy[2 * i] - xy[2 * i - 2], xy[2 * i + 1] - xy[2 * i - 1]);
    length[i] = length[i - 1] + d;
  }
  double total = length[n - 1];
  std::vector<float> out(3 * n);
  for (size_t i = 0; i < n; i++) {
    out[3 * i] = total > 0 ? length[i] / total : static_cast<float>(i) / (n - 1);
    out[3 * i + 1] = xy[2 * i];
    out[3 * i + 2] = xy[2 * i + 1];
  }
  jfloatArray result = env->NewFloatArray(out.size());
  if (result != nullptr) env->SetFloatArrayRegion(result, 0, out.size(), out.data());
  return result;
}

JNINativeMethod gPathMethods[] = {
  { "init1", "()J", reinterpret_cast<void*>(Path_init1) },
  { "init2", "(J)J", reinterpret_cast<void*>(Path_init2) },
  { "finalizer", "(J)V", reinterpret_cast<void*>(Path_finalizer) },
  { "native_reset", "(J)V", reinterpret_cast<void*>(Path_reset) },
  { "native_rewind", "(J)V", reinterpret_cast<void*>(Path_reset) },
  { "native_set", "(JJ)V", reinterpret_cast<void*>(Path_set) },
  { "native_isEmpty", "(J)Z", reinterpret_cast<void*>(Path_isEmpty) },
  { "native_moveTo", "(JFF)V", reinterpret_cast<void*>(Path_moveTo) },
  { "native_lineTo", "(JFF)V", reinterpret_cast<void*>(Path_lineTo) },
  { "native_quadTo", "(JFFFF)V", reinterpret_cast<void*>(Path_quadTo) },
  { "native_cubicTo", "(JFFFFFF)V", reinterpret_cast<void*>(Path_cubicTo) },
  { "native_close", "(J)V", reinterpret_cast<void*>(Path_close) },
  { "native_approximate", "(JF)[F", reinterpret_cast<void*>(Path_approximate) },
};

// ---- Matrix ----

// Row major like android.graphics.Matrix values: x' = m[0]x + m[1]y + m[2].
struct FMatrix { float m[9] = {1, 0, 0, 0, 1, 0, 0, 0, 1}; };

FMatrix* matrixAt(jlong h) { return reinterpret_cast<FMatrix*>(h); }

FMatrix multiply(const FMatrix& a, const FMatrix& b) {
  FMatrix r;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      r.m[3 * i + j] = a.m[3 * i] * b.m[j] + a.m[3 * i + 1] * b.m[3 + j] + a.m[3 * i + 2] * b.m[6 + j];
    }
  }
  return r;
}
FMatrix translate(float dx, float dy) { FMatrix t; t.m[2] = dx; t.m[5] = dy; return t; }
FMatrix scale(float sx, float sy, float px, float py) {
  FMatrix t;
  t.m[0] = sx; t.m[4] = sy; t.m[2] = px - sx * px; t.m[5] = py - sy * py;
  return t;
}

jlong Matrix_create(JNIEnv*, jclass, jlong src) {
  return reinterpret_cast<jlong>(src != 0 ? new FMatrix(*matrixAt(src)) : new FMatrix());
}
void Matrix_finalizer(JNIEnv*, jclass, jlong h) { delete matrixAt(h); }
jboolean Matrix_isIdentity(JNIEnv*, jclass, jlong h) {
  static const FMatrix kIdentity;
  return memcmp(matrixAt(h)->m, kIdentity.m, sizeof(kIdentity.m)) == 0;
}
jboolean Matrix_isAffine(JNIEnv*, jclass, jlong h) {
  const float* m = matrixAt(h)->m;
  return m[6] == 0 && m[7] == 0 && m[8] == 1;
}
void Matrix_reset(JNIEnv*, jclass, jlong h) { *matrixAt(h) = FMatrix(); }
void Matrix_set(JNIEnv*, jclass, jlong h, jlong other) { *matrixAt(h) = *matrixAt(other); }
void Matrix_setTranslate(JNIEnv*, jclass, jlong h, jfloat dx, jfloat dy) { *matrixAt(h) = translate(dx, dy); }
void Matrix_setScale(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy) { *matrixAt(h) = scale(sx, sy, 0, 0); }
void Matrix_setScaleAt(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy, jfloat px, jfloat py) {
  *matrixAt(h) = scale(sx, sy, px, py);
}
void Matrix_setConcat(JNIEnv*, jclass, jlong h, jlong a, jlong b) { *matrixAt(h) = multiply(*matrixAt(a), *matrixAt(b)); }
void Matrix_preConcat(JNIEnv*, jclass, jlong h, jlong o) { *matrixAt(h) = multiply(*matrixAt(h), *matrixAt(o)); }
void Matrix_postConcat(JNIEnv*, jclass, jlong h, jlong o) { *matrixAt(h) = multiply(*matrixAt(o), *matrixAt(h)); }
void Matrix_preTranslate(JNIEnv*, jclass, jlong h, jfloat dx, jfloat dy) { *matrixAt(h) = multiply(*matrixAt(h), translate(dx, dy)); }
void Matrix_postTranslate(JNIEnv*, jclass, jlong h, jfloat dx, jfloat dy) { *matrixAt(h) = multiply(translate(dx, dy), *matrixAt(h)); }
void Matrix_preScale(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy) { *matrixAt(h) = multiply(*matrixAt(h), scale(sx, sy, 0, 0)); }
void Matrix_postScale(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy) { *matrixAt(h) = multiply(scale(sx, sy, 0, 0), *matrixAt(h)); }
void Matrix_preScaleAt(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy, jfloat px, jfloat py) {
  *matrixAt(h) = multiply(*matrixAt(h), scale(sx, sy, px, py));
}
void Matrix_postScaleAt(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy, jfloat px, jfloat py) {
  *matrixAt(h) = multiply(scale(sx, sy, px, py), *matrixAt(h));
}
jboolean Matrix_invert(JNIEnv*, jclass, jlong h, jlong inverse) {
  const float* m = matrixAt(h)->m;
  double det = m[0] * (m[4] * m[8] - m[5] * m[7]) - m[1] * (m[3] * m[8] - m[5] * m[6])
             + m[2] * (m[3] * m[7] - m[4] * m[6]);
  if (det == 0) return false;
  if (inverse == 0) return true;
  float* r = matrixAt(inverse)->m;
  float c[9] = {m[4] * m[8] - m[5] * m[7], m[2] * m[7] - m[1] * m[8], m[1] * m[5] - m[2] * m[4],
                m[5] * m[6] - m[3] * m[8], m[0] * m[8] - m[2] * m[6], m[2] * m[3] - m[0] * m[5],
                m[3] * m[7] - m[4] * m[6], m[1] * m[6] - m[0] * m[7], m[0] * m[4] - m[1] * m[3]};
  for (int i = 0; i < 9; i++) r[i] = c[i] / det;
  return true;
}
// isPts false maps vectors: no translation, affine part only.
void Matrix_mapPoints(JNIEnv* env, jclass, jlong h, jfloatArray dst, jint dstIndex, jfloatArray src,
                      jint srcIndex, jint count, jboolean isPts) {
  const float* m = matrixAt(h)->m;
  std::vector<float> in(2 * count), out(2 * count);
  env->GetFloatArrayRegion(src, srcIndex, 2 * count, in.data());
  for (int i = 0; i < count; i++) {
    float x = in[2 * i], y = in[2 * i + 1];
    if (isPts) {
      float w = m[6] * x + m[7] * y + m[8];
      if (w == 0) w = 1;
      out[2 * i] = (m[0] * x + m[1] * y + m[2]) / w;
      out[2 * i + 1] = (m[3] * x + m[4] * y + m[5]) / w;
    } else {
      out[2 * i] = m[0] * x + m[1] * y;
      out[2 * i + 1] = m[3] * x + m[4] * y;
    }
  }
  env->SetFloatArrayRegion(dst, dstIndex, 2 * count, out.data());
}
void Matrix_getValues(JNIEnv* env, jclass, jlong h, jfloatArray values) {
  env->SetFloatArrayRegion(values, 0, 9, matrixAt(h)->m);
}
void Matrix_setValues(JNIEnv* env, jclass, jlong h, jfloatArray values) {
  env->GetFloatArrayRegion(values, 0, 9, matrixAt(h)->m);
}
jboolean Matrix_equals(JNIEnv*, jclass, jlong a, jlong b) {
  return memcmp(matrixAt(a)->m, matrixAt(b)->m, sizeof(FMatrix::m)) == 0;
}

JNINativeMethod gMatrixMethods[] = {
  { "native_create", "(J)J", reinterpret_cast<void*>(Matrix_create) },
  { "finalizer", "(J)V", reinterpret_cast<void*>(Matrix_finalizer) },
  { "native_isIdentity", "(J)Z", reinterpret_cast<void*>(Matrix_isIdentity) },
  { "native_isAffine", "(J)Z", reinterpret_cast<void*>(Matrix_isAffine) },
  { "native_reset", "(J)V", reinterpret_cast<void*>(Matrix_reset) },
  { "native_set", "(JJ)V", reinterpret_cast<void*>(Matrix_set) },
  { "native_setTranslate", "(JFF)V", reinterpret_cast<void*>(Matrix_setTranslate) },
  { "native_setScale", "(JFF)V", reinterpret_cast<void*>(Matrix_setScale) },
  { "native_setScale", "(JFFFF)V", reinterpret_cast<void*>(Matrix_setScaleAt) },
  { "native_setConcat", "(JJJ)V", reinterpret_cast<void*>(Matrix_setConcat) },
  { "native_preConcat", "(JJ)V", reinterpret_cast<void*>(Matrix_preConcat) },
  { "native_postConcat", "(JJ)V", reinterpret_cast<void*>(Matrix_postConcat) },
  { "native_preTranslate", "(JFF)V", reinterpret_cast<void*>(Matrix_preTranslate) },
  { "native_postTranslate", "(JFF)V", reinterpret_cast<void*>(Matrix_postTranslate) },
  { "native_preScale", "(JFF)V", reinterpret_cast<void*>(Matrix_preScale) },
  { "native_postScale", "(JFF)V", reinterpret_cast<void*>(Matrix_postScale) },
  { "native_preScale", "(JFFFF)V", reinterpret_cast<void*>(Matrix_preScaleAt) },
  { "native_postScale", "(JFFFF)V", reinterpret_cast<void*>(Matrix_postScaleAt) },
  { "native_invert", "(JJ)Z", reinterpret_cast<void*>(Matrix_invert) },
  { "native_mapPoints", "(J[FI[FIIZ)V", reinterpret_cast<void*>(Matrix_mapPoints) },
  { "native_getValues", "(J[F)V", reinterpret_cast<void*>(Matrix_getValues) },
  { "native_setValues", "(J[F)V", reinterpret_cast<void*>(Matrix_setValues) },
  { "native_equals", "(JJ)Z", reinterpret_cast<void*>(Matrix_equals) },
};

// ---- RenderNode ----

// hwui RenderProperties defaults. Camera distance is in Sk3DView units.
struct FNode {
  float alpha = 1, elevation = 0, translationX = 0, translationY = 0, translationZ = 0;
  float rotation = 0, rotationX = 0, rotationY = 0, scaleX = 1, scaleY = 1;
  float pivotX = 0, pivotY = 0, cameraDistance = -8;
  bool pivotSet = false, clipToOutline = false, overlapping = true, matrix = false;
  int left = 0, top = 0, right = 0, bottom = 0;
};

FNode* nodeAt(jlong h) { return reinterpret_cast<FNode*>(h); }

template <typename T>
jboolean update(T& field, T value) {
  if (field == value) return false;
  field = value;
  return true;
}

jlong RN_create(JNIEnv*, jclass, jstring) { return reinterpret_cast<jlong>(new FNode()); }
void RN_destroy(JNIEnv*, jclass, jlong h) { delete nodeAt(h); }
void RN_setDisplayListData(JNIEnv*, jclass, jlong, jlong) {}

#define RN_FLOAT(Name, field)                                                         \
  jboolean RN_set##Name(JNIEnv*, jclass, jlong h, jfloat v) { return update(nodeAt(h)->field, v); } \
  jfloat RN_get##Name(JNIEnv*, jclass, jlong h) { return nodeAt(h)->field; }
RN_FLOAT(Alpha, alpha)
RN_FLOAT(Elevation, elevation)
RN_FLOAT(TranslationX, translationX)
RN_FLOAT(TranslationY, translationY)
RN_FLOAT(TranslationZ, translationZ)
RN_FLOAT(Rotation, rotation)
RN_FLOAT(RotationX, rotationX)
RN_FLOAT(RotationY, rotationY)
RN_FLOAT(ScaleX, scaleX)
RN_FLOAT(ScaleY, scaleY)
RN_FLOAT(CameraDistance, cameraDistance)
#undef RN_FLOAT

jboolean RN_setPivotX(JNIEnv*, jclass, jlong h, jfloat v) { nodeAt(h)->pivotSet = true; return update(nodeAt(h)->pivotX, v); }
jboolean RN_setPivotY(JNIEnv*, jclass, jlong h, jfloat v) { nodeAt(h)->pivotSet = true; return update(nodeAt(h)->pivotY, v); }
// Unset pivots follow the center of the bounds, as in hwui.
jfloat RN_getPivotX(JNIEnv*, jclass, jlong h) {
  FNode* n = nodeAt(h);
  return n->pivotSet ? n->pivotX : (n->right - n->left) / 2.0f;
}
jfloat RN_getPivotY(JNIEnv*, jclass, jlong h) {
  FNode* n = nodeAt(h);
  return n->pivotSet ? n->pivotY : (n->bottom - n->top) / 2.0f;
}
jboolean RN_isPivotExplicitlySet(JNIEnv*, jclass, jlong h) { return nodeAt(h)->pivotSet; }

jboolean RN_setLeft(JNIEnv*, jclass, jlong h, jint v) { return update(nodeAt(h)->left, static_cast<int>(v)); }
jboolean RN_setTop(JNIEnv*, jclass, jlong h, jint v) { return update(nodeAt(h)->top, static_cast<int>(v)); }
jboolean RN_setRight(JNIEnv*, jclass, jlong h, jint v) { return update(nodeAt(h)->right, static_cast<int>(v)); }
jboolean RN_setBottom(JNIEnv*, jclass, jlong h, jint v) { return update(nodeAt(h)->bottom, static_cast<int>(v)); }
jboolean RN_setLeftTopRightBottom(JNIEnv*, jclass, jlong h, jint l, jint t, jint r, jint b) {
  FNode* n = nodeAt(h);
  bool changed = n->left != l || n->top != t || n->right != r || n->bottom != b;
  n->left = l; n->top = t; n->right = r; n->bottom = b;
  return changed;
}
jboolean RN_offsetLeftAndRight(JNIEnv*, jclass, jlong h, jint d) {
  nodeAt(h)->left += d; nodeAt(h)->right += d;
  return d != 0;
}
jboolean RN_offsetTopAndBottom(JNIEnv*, jclass, jlong h, jint d) {
  nodeAt(h)->top += d; nodeAt(h)->bottom += d;
  return d != 0;
}

jboolean RN_hasIdentityMatrix(JNIEnv*, jclass, jlong h) {
  FNode* n = nodeAt(h);
  return !n->matrix && n->translationX == 0 && n->translationY == 0 && n->rotation == 0 &&
         n->rotationX == 0 && n->rotationY == 0 && n->scaleX == 1 && n->scaleY == 1;
}
jboolean RN_setMatrix(JNIEnv*, jclass, jlong h, jlong m) { return update(nodeAt(h)->matrix, m != 0); }
jboolean RN_setClipToOutline(JNIEnv*, jclass, jlong h, jboolean v) { return update(nodeAt(h)->clipToOutline, v != 0); }
jboolean RN_getClipToOutline(JNIEnv*, jclass, jlong h) { return nodeAt(h)->clipToOutline; }
jboolean RN_setHasOverlappingRendering(JNIEnv*, jclass, jlong h, jboolean v) { return update(nodeAt(h)->overlapping, v != 0); }
jboolean RN_hasOverlappingRendering(JNIEnv*, jclass, jlong h) { return nodeAt(h)->overlapping; }
jboolean RN_hasShadow(JNIEnv*, jclass, jlong) { return false; }

// Clip, outline, layer and projection state only matters to drawing: accept it.
jboolean RN_acceptJ(JNIEnv*, jclass, jlong) { return true; }
jboolean RN_acceptJI(JNIEnv*, jclass, jlong, jint) { return true; }
jboolean RN_acceptJJ(JNIEnv*, jclass, jlong, jlong) { return true; }
jboolean RN_acceptJZ(JNIEnv*, jclass, jlong, jboolean) { return true; }
jboolean RN_acceptJIIII(JNIEnv*, jclass, jlong, jint, jint, jint, jint) { return true; }
jboolean RN_acceptOutlineRoundRect(JNIEnv*, jclass, jlong, jint, jint, jint, jint, jfloat, jfloat) { return true; }
jboolean RN_acceptOutlineConvexPath(JNIEnv*, jclass, jlong, jlong, jfloat) { return true; }
jboolean RN_acceptRevealClip(JNIEnv*, jclass, jlong, jboolean, jfloat, jfloat, jfloat) { return true; }

#define RN_PAIR(Name)                                                                   \
  { "nSet" #Name, "(JF)Z", reinterpret_cast<void*>(RN_set##Name) },                    \
  { "nGet" #Name, "(J)F", reinterpret_cast<void*>(RN_get##Name) }
JNINativeMethod gRenderNodeMethods[] = {
  { "nCreate", "(Ljava/lang/String;)J", reinterpret_cast<void*>(RN_create) },
  { "nDestroyRenderNode", "(J)V", reinterpret_cast<void*>(RN_destroy) },
  { "nSetDisplayListData", "(JJ)V", reinterpret_cast<void*>(RN_setDisplayListData) },
  RN_PAIR(Alpha), RN_PAIR(Elevation), RN_PAIR(TranslationX), RN_PAIR(TranslationY),
  RN_PAIR(TranslationZ), RN_PAIR(Rotation), RN_PAIR(RotationX), RN_PAIR(RotationY),
  RN_PAIR(ScaleX), RN_PAIR(ScaleY), RN_PAIR(CameraDistance),
  { "nSetPivotX", "(JF)Z", reinterpret_cast<void*>(RN_setPivotX) },
  { "nSetPivotY", "(JF)Z", reinterpret_cast<void*>(RN_setPivotY) },
  { "nGetPivotX", "(J)F", reinterpret_cast<void*>(RN_getPivotX) },
  { "nGetPivotY", "(J)F", reinterpret_cast<void*>(RN_getPivotY) },
  { "nIsPivotExplicitlySet", "(J)Z", reinterpret_cast<void*>(RN_isPivotExplicitlySet) },
  { "nSetLeft", "(JI)Z", reinterpret_cast<void*>(RN_setLeft) },
  { "nSetTop", "(JI)Z", reinterpret_cast<void*>(RN_setTop) },
  { "nSetRight", "(JI)Z", reinterpret_cast<void*>(RN_setRight) },
  { "nSetBottom", "(JI)Z", reinterpret_cast<void*>(RN_setBottom) },
  { "nSetLeftTopRightBottom", "(JIIII)Z", reinterpret_cast<void*>(RN_setLeftTopRightBottom) },
  { "nOffsetLeftAndRight", "(JI)Z", reinterpret_cast<void*>(RN_offsetLeftAndRight) },
  { "nOffsetTopAndBottom", "(JI)Z", reinterpret_cast<void*>(RN_offsetTopAndBottom) },
  { "nHasIdentityMatrix", "(J)Z", reinterpret_cast<void*>(RN_hasIdentityMatrix) },
  { "nSetStaticMatrix", "(JJ)Z", reinterpret_cast<void*>(RN_setMatrix) },
  { "nSetAnimationMatrix", "(JJ)Z", reinterpret_cast<void*>(RN_setMatrix) },
  { "nSetClipToOutline", "(JZ)Z", reinterpret_cast<void*>(RN_setClipToOutline) },
  { "nGetClipToOutline", "(J)Z", reinterpret_cast<void*>(RN_getClipToOutline) },
  { "nSetHasOverlappingRendering", "(JZ)Z", reinterpret_cast<void*>(RN_setHasOverlappingRendering) },
  { "nHasOverlappingRendering", "(J)Z", reinterpret_cast<void*>(RN_hasOverlappingRendering) },
  { "nHasShadow", "(J)Z", reinterpret_cast<void*>(RN_hasShadow) },
  { "nSetLayerType", "(JI)Z", reinterpret_cast<void*>(RN_acceptJI) },
  { "nSetLayerPaint", "(JJ)Z", reinterpret_cast<void*>(RN_acceptJJ) },
  { "nSetClipToBounds", "(JZ)Z", reinterpret_cast<void*>(RN_acceptJZ) },
  { "nSetClipBounds", "(JIIII)Z", reinterpret_cast<void*>(RN_acceptJIIII) },
  { "nSetClipBoundsEmpty", "(J)Z", reinterpret_cast<void*>(RN_acceptJ) },
  { "nSetProjectBackwards", "(JZ)Z", reinterpret_cast<void*>(RN_acceptJZ) },
  { "nSetProjectionReceiver", "(JZ)Z", reinterpret_cast<void*>(RN_acceptJZ) },
  { "nSetOutlineRoundRect", "(JIIIIFF)Z", reinterpret_cast<void*>(RN_acceptOutlineRoundRect) },
  { "nSetOutlineConvexPath", "(JJF)Z", reinterpret_cast<void*>(RN_acceptOutlineConvexPath) },
  { "nSetOutlineEmpty", "(J)Z", reinterpret_cast<void*>(RN_acceptJ) },
  { "nSetOutlineNone", "(J)Z", reinterpret_cast<void*>(RN_acceptJ) },
  { "nSetRevealClip", "(JZFFF)Z", reinterpret_cast<void*>(RN_acceptRevealClip) },
};
#undef RN_PAIR

// ---- ColorFilter, EmojiFactory ----

// A real handle so ColorFilter.finalize has something to free.
jlong ColorFilter_createPorterDuff(JNIEnv*, jclass, jint, jint) { return reinterpret_cast<jlong>(new int(0)); }
void ColorFilter_destroy(JNIEnv*, jclass, jlong h) { delete reinterpret_cast<int*>(h); }

JNINativeMethod gPorterDuffColorFilterMethods[] = {
  { "native_CreatePorterDuffFilter", "(II)J", reinterpret_cast<void*>(ColorFilter_createPorterDuff) },
};
JNINativeMethod gColorFilterMethods[] = {
  { "destroyFilter", "(J)V", reinterpret_cast<void*>(ColorFilter_destroy) },
};

// No emoji bitmaps: Layout.<clinit> asks once and accepts null.
jobject Emoji_newAvailableInstance(JNIEnv*, jclass) { return nullptr; }
jobject Emoji_newInstance(JNIEnv*, jclass, jstring) { return nullptr; }

JNINativeMethod gEmojiFactoryMethods[] = {
  { "newAvailableInstance", "()Landroid/emoji/EmojiFactory;", reinterpret_cast<void*>(Emoji_newAvailableInstance) },
  { "newInstance", "(Ljava/lang/String;)Landroid/emoji/EmojiFactory;", reinterpret_cast<void*>(Emoji_newInstance) },
};

// ---- Canvas and Surface: the A7 draw pass ----
//
// android.graphics.Canvas forwarded onto the software engine in raster.cc,
// plus the four android.view.Surface natives that hand it the window buffer.
// Together they turn A6's laid out View tree into pixels: lockCanvas maps the
// Q20 window into the Canvas, one decor.draw(canvas) pass runs, then
// unlockCanvasAndPost posts it.
//
// Surface is the registration host on purpose: JNI_OnLoad can only FindClass
// boot classpath types, so a facade owned native class would never resolve,
// and Surface already declares exactly this contract.
//
// ponytail: fills, rects and glyph runs. Scale, rotate, skew, matrix concat
// and draw filters are accepted and ignored; round rects lose their corners;
// saveLayer loses its alpha; clipPath does not clip. The Prober's tree needs
// none of it, and each is a small addition to raster.cc when a tree does.

jfieldID gCanvasNative;
struct { jfieldID left, top, right, bottom; } gRect;

// Q20_DRAW_TRACE=1 logs every draw call with its colour and geometry. The
// frame is one pass over a tree nobody can see while it renders, so this is
// the only way to tell "drew nothing" from "drew it in the wrong colour".
bool traceOn() {
  static int on = -1;
  if (on < 0) {
    const char* e = getenv("Q20_DRAW_TRACE");
    on = (e != nullptr && e[0] != '\0' && e[0] != '0') ? 1 : 0;
  }
  return on == 1;
}
#define DTRACE(...) do { if (traceOn()) ALOGI(__VA_ARGS__); } while (0)

raster::Canvas* canvasAt(jlong h) { return reinterpret_cast<raster::Canvas*>(h); }

// Draw coordinates round like the engine's own; reject tests round outward so
// a partially visible rect is never dropped.
raster::Rect rectOf(jfloat l, jfloat t, jfloat r, jfloat b) {
  return raster::Rect{(int)lroundf(l), (int)lroundf(t), (int)lroundf(r), (int)lroundf(b)};
}
raster::Rect outerRectOf(jfloat l, jfloat t, jfloat r, jfloat b) {
  return raster::Rect{(int)floorf(l), (int)floorf(t), (int)ceilf(r), (int)ceilf(b)};
}

jlong Canvas_initRaster(JNIEnv*, jclass, jobject /*bitmap*/) {
  // The no argument Canvas() passes null, which is the only case here: there
  // is no Bitmap native layer. Surface.lockCanvas re-points this canvas at the
  // window buffer, so it starts with an empty surface and draws nothing.
  return reinterpret_cast<jlong>(new raster::Canvas(raster::Surface{}));
}
void Canvas_finalizer(JNIEnv*, jclass, jlong h) { delete canvasAt(h); }
void Canvas_setBitmap(JNIEnv*, jclass, jlong, jobject) {}
jboolean Canvas_isOpaque(JNIEnv*, jclass, jlong) { return JNI_TRUE; }
jint Canvas_getWidth(JNIEnv*, jclass, jlong h) { return canvasAt(h)->width(); }
jint Canvas_getHeight(JNIEnv*, jclass, jlong h) { return canvasAt(h)->height(); }

jint Canvas_save(JNIEnv*, jclass, jlong h, jint) { return canvasAt(h)->save(); }
jint Canvas_saveLayer(JNIEnv*, jclass, jlong h, jfloat, jfloat, jfloat, jfloat, jlong, jint) {
  return canvasAt(h)->save();
}
jint Canvas_saveLayerAlpha(JNIEnv*, jclass, jlong h, jfloat, jfloat, jfloat, jfloat, jint, jint) {
  return canvasAt(h)->save();
}
void Canvas_restore(JNIEnv*, jclass, jlong h, jboolean) { canvasAt(h)->restore(); }
void Canvas_restoreToCount(JNIEnv*, jclass, jlong h, jint count, jboolean) {
  canvasAt(h)->restoreToCount(count);
}
jint Canvas_getSaveCount(JNIEnv*, jclass, jlong h) { return canvasAt(h)->saveCount(); }
void Canvas_translate(JNIEnv*, jclass, jlong h, jfloat dx, jfloat dy) {
  canvasAt(h)->translate(dx, dy);
}

// Accepted and ignored: no transform beyond translate in this engine.
void Canvas_ignore_ff(JNIEnv*, jclass, jlong, jfloat, jfloat) {}
void Canvas_ignore_f(JNIEnv*, jclass, jlong, jfloat) {}
void Canvas_ignore_j(JNIEnv*, jclass, jlong, jlong) {}

jboolean Canvas_clipRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b, jint) {
  return canvasAt(h)->clipRect(rectOf(l, t, r, b)) ? JNI_TRUE : JNI_FALSE;
}
// Path and region clips leave the clip alone: reporting non empty is the safe
// lie, since over drawing is visible and under drawing is a missing widget.
jboolean Canvas_clipHandle(JNIEnv*, jclass, jlong, jlong, jint) { return JNI_TRUE; }

jboolean Canvas_getClipBounds(JNIEnv* env, jclass, jlong h, jobject bounds) {
  const raster::Rect c = canvasAt(h)->localClip();
  env->SetIntField(bounds, gRect.left, c.l);
  env->SetIntField(bounds, gRect.top, c.t);
  env->SetIntField(bounds, gRect.right, c.r);
  env->SetIntField(bounds, gRect.bottom, c.b);
  return c.empty() ? JNI_FALSE : JNI_TRUE;
}

jboolean Canvas_quickRejectRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b) {
  return canvasAt(h)->localClip().intersect(outerRectOf(l, t, r, b)).empty() ? JNI_TRUE : JNI_FALSE;
}
jboolean Canvas_quickRejectPath(JNIEnv*, jclass, jlong, jlong) { return JNI_FALSE; }

void Canvas_drawColor(JNIEnv*, jclass, jlong h, jint color, jint /*mode*/) {
  const raster::Rect& c = canvasAt(h)->deviceClip();
  DTRACE("drawColor #%08x clip %d,%d %dx%d", color, c.l, c.t, c.width(), c.height());
  canvasAt(h)->drawColor(static_cast<uint32_t>(color));
}
void Canvas_drawPaint(JNIEnv*, jclass, jlong h, jlong paint) {
  canvasAt(h)->drawColor(paintAt(paint)->color);
}
void Canvas_drawRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b, jlong paint) {
  DTRACE("drawRect %.0f,%.0f %.0fx%.0f #%08x style=%d", l, t, r - l, b - t,
         paintAt(paint)->color, paintAt(paint)->style);
  canvasAt(h)->drawRect(rectOf(l, t, r, b), paintAt(paint)->color);
}
void Canvas_drawRoundRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b,
                          jfloat /*rx*/, jfloat /*ry*/, jlong paint) {
  // ponytail: square corners. The Prober's Button is the stock Material shape
  // at control_corner_material, 2dp, which does not read at 176x96; corner
  // coverage is a loop in raster.cc the day a design needs it.
  DTRACE("drawRoundRect %.0f,%.0f %.0fx%.0f #%08x", l, t, r - l, b - t, paintAt(paint)->color);
  canvasAt(h)->drawRect(rectOf(l, t, r, b), paintAt(paint)->color);
}

// One glyph run at a baseline origin. textScaleX and letterSpacing are in the
// measure path but not here: both are default for every Prober run, and a
// mismatch would show as text wider than its measured box.
void drawRun(jlong canvas, const jchar* text, int start, int end, jfloat x, jfloat y, jlong paint) {
  const FPaint* p = paintAt(paint);
  std::vector<uint32_t> cps;
  decodeUtf16(text, start, end, &cps);
  DTRACE("drawRun %d glyphs at %.0f,%.0f #%08x size=%.1f first=U+%04X", (int)cps.size(), x, y,
         p->color, p->textSize, cps.empty() ? 0 : cps[0]);
  pthread_mutex_lock(&gFontLock);
  canvasAt(canvas)->drawGlyphs(face(), cps.data(), (int)cps.size(), x, y, p->color, p->textSize);
  pthread_mutex_unlock(&gFontLock);
}

void Canvas_drawText_C(JNIEnv* env, jclass, jlong h, jcharArray text, jint index, jint count,
                       jfloat x, jfloat y, jint, jlong paint, jlong) {
  if (!checkRange(env, index, index + count, env->GetArrayLength(text))) return;
  jchar* chars = env->GetCharArrayElements(text, nullptr);
  drawRun(h, chars, index, index + count, x, y, paint);
  env->ReleaseCharArrayElements(text, chars, JNI_ABORT);
}
void Canvas_drawText_String(JNIEnv* env, jclass, jlong h, jstring text, jint start, jint end,
                            jfloat x, jfloat y, jint, jlong paint, jlong) {
  if (!checkRange(env, start, end, env->GetStringLength(text))) return;
  const jchar* chars = env->GetStringChars(text, nullptr);
  drawRun(h, chars, start, end, x, y, paint);
  env->ReleaseStringChars(text, chars);
}
void Canvas_drawTextRun_C(JNIEnv* env, jclass, jlong h, jcharArray text, jint start, jint count,
                          jint, jint, jfloat x, jfloat y, jboolean, jlong paint, jlong) {
  if (!checkRange(env, start, start + count, env->GetArrayLength(text))) return;
  jchar* chars = env->GetCharArrayElements(text, nullptr);
  drawRun(h, chars, start, start + count, x, y, paint);
  env->ReleaseCharArrayElements(text, chars, JNI_ABORT);
}
void Canvas_drawTextRun_String(JNIEnv* env, jclass, jlong h, jstring text, jint start, jint end,
                               jint, jint, jfloat x, jfloat y, jboolean, jlong paint, jlong) {
  if (!checkRange(env, start, end, env->GetStringLength(text))) return;
  const jchar* chars = env->GetStringChars(text, nullptr);
  drawRun(h, chars, start, end, x, y, paint);
  env->ReleaseStringChars(text, chars);
}

JNINativeMethod gCanvasMethods[] = {
  { "initRaster", "(Landroid/graphics/Bitmap;)J", reinterpret_cast<void*>(Canvas_initRaster) },
  { "native_setBitmap", "(JLandroid/graphics/Bitmap;)V", reinterpret_cast<void*>(Canvas_setBitmap) },
  { "finalizer", "(J)V", reinterpret_cast<void*>(Canvas_finalizer) },
  { "native_isOpaque", "(J)Z", reinterpret_cast<void*>(Canvas_isOpaque) },
  { "native_getWidth", "(J)I", reinterpret_cast<void*>(Canvas_getWidth) },
  { "native_getHeight", "(J)I", reinterpret_cast<void*>(Canvas_getHeight) },
  { "native_save", "(JI)I", reinterpret_cast<void*>(Canvas_save) },
  { "native_saveLayer", "(JFFFFJI)I", reinterpret_cast<void*>(Canvas_saveLayer) },
  { "native_saveLayerAlpha", "(JFFFFII)I", reinterpret_cast<void*>(Canvas_saveLayerAlpha) },
  { "native_restore", "(JZ)V", reinterpret_cast<void*>(Canvas_restore) },
  { "native_restoreToCount", "(JIZ)V", reinterpret_cast<void*>(Canvas_restoreToCount) },
  { "native_getSaveCount", "(J)I", reinterpret_cast<void*>(Canvas_getSaveCount) },
  { "native_translate", "(JFF)V", reinterpret_cast<void*>(Canvas_translate) },
  { "native_scale", "(JFF)V", reinterpret_cast<void*>(Canvas_ignore_ff) },
  { "native_skew", "(JFF)V", reinterpret_cast<void*>(Canvas_ignore_ff) },
  { "native_rotate", "(JF)V", reinterpret_cast<void*>(Canvas_ignore_f) },
  { "native_concat", "(JJ)V", reinterpret_cast<void*>(Canvas_ignore_j) },
  { "native_setMatrix", "(JJ)V", reinterpret_cast<void*>(Canvas_ignore_j) },
  { "native_getCTM", "(JJ)V", reinterpret_cast<void*>(Canvas_ignore_j) },
  { "nativeSetDrawFilter", "(JJ)V", reinterpret_cast<void*>(Canvas_ignore_j) },
  { "native_clipRect", "(JFFFFI)Z", reinterpret_cast<void*>(Canvas_clipRect) },
  { "native_clipPath", "(JJI)Z", reinterpret_cast<void*>(Canvas_clipHandle) },
  { "native_clipRegion", "(JJI)Z", reinterpret_cast<void*>(Canvas_clipHandle) },
  { "native_getClipBounds", "(JLandroid/graphics/Rect;)Z", reinterpret_cast<void*>(Canvas_getClipBounds) },
  { "native_quickReject", "(JFFFF)Z", reinterpret_cast<void*>(Canvas_quickRejectRect) },
  { "native_quickReject", "(JJ)Z", reinterpret_cast<void*>(Canvas_quickRejectPath) },
  { "native_drawColor", "(JII)V", reinterpret_cast<void*>(Canvas_drawColor) },
  { "native_drawPaint", "(JJ)V", reinterpret_cast<void*>(Canvas_drawPaint) },
  { "native_drawRect", "(JFFFFJ)V", reinterpret_cast<void*>(Canvas_drawRect) },
  { "native_drawRoundRect", "(JFFFFFFJ)V", reinterpret_cast<void*>(Canvas_drawRoundRect) },
  { "native_drawText", "(J[CIIFFIJJ)V", reinterpret_cast<void*>(Canvas_drawText_C) },
  { "native_drawText", "(JLjava/lang/String;IIFFIJJ)V", reinterpret_cast<void*>(Canvas_drawText_String) },
  { "native_drawTextRun", "(J[CIIIIFFZJJ)V", reinterpret_cast<void*>(Canvas_drawTextRun_C) },
  { "native_drawTextRun", "(JLjava/lang/String;IIIIFFZJJ)V", reinterpret_cast<void*>(Canvas_drawTextRun_String) },
};

// ---- Surface: the window buffer behind lockCanvas ----

raster::Surface gLocked;        // what the canvas is pointed at right now
std::vector<uint8_t> gFallback; // used when Screen gives us no window
bool gPostable;

jlong Surface_lockCanvas(JNIEnv* env, jclass, jlong handle, jobject canvas, jobject /*dirty*/) {
  raster::Canvas* c = canvasAt(env->GetLongField(canvas, gCanvasNative));
  raster::Surface s;
  gPostable = q20screen::acquire(&s);
  if (!gPostable) {
    // No window to post (the open A7 compositor question). Draw into our own
    // memory anyway so the pass is still verifiable: Q20_DRAW_PNG writes it
    // out on post, which is the device evidence that does not need a
    // compositor.
    const char* sz = getenv("Q20_DRAW_SIZE");
    const int n = (sz != nullptr && sz[0] != '\0') ? atoi(sz) : 720;
    gFallback.assign((size_t)n * n * 4, 0);
    s = raster::Surface{gFallback.data(), n, n, n * 4};
    ALOGI("no Screen window, drawing into a %dx%d heap surface", n, n);
  }
  c->setSurface(s);
  gLocked = s;
  return handle != 0 ? handle : 1;  // echo it back: Surface warns if they differ
}

void Surface_unlockCanvasAndPost(JNIEnv*, jclass, jlong, jobject) {
  if (gPostable) q20screen::post();
  const char* png = getenv("Q20_DRAW_PNG");
  if (png != nullptr && png[0] != '\0') {
    ALOGI("write_png %s ok=%d", png, raster::write_png(png, gLocked));
  }
}

// Called after every post, so it must tolerate being a no op.
void Surface_release(JNIEnv*, jclass, jlong) {}
jboolean Surface_isValid(JNIEnv*, jclass, jlong h) { return h != 0 ? JNI_TRUE : JNI_FALSE; }

JNINativeMethod gSurfaceMethods[] = {
  { "nativeLockCanvas", "(JLandroid/graphics/Canvas;Landroid/graphics/Rect;)J",
    reinterpret_cast<void*>(Surface_lockCanvas) },
  { "nativeUnlockCanvasAndPost", "(JLandroid/graphics/Canvas;)V",
    reinterpret_cast<void*>(Surface_unlockCanvasAndPost) },
  { "nativeRelease", "(J)V", reinterpret_cast<void*>(Surface_release) },
  { "nativeIsValid", "(J)Z", reinterpret_cast<void*>(Surface_isValid) },
};

}  // namespace

void register_qnx_graphics(JNIEnv* env) {
  jclass paint = env->FindClass("android/graphics/Paint");
  gPaintNative = env->GetFieldID(paint, "mNativePaint", "J");
  jclass fm = env->FindClass("android/graphics/Paint$FontMetrics");
  gFm.top = env->GetFieldID(fm, "top", "F");
  gFm.ascent = env->GetFieldID(fm, "ascent", "F");
  gFm.descent = env->GetFieldID(fm, "descent", "F");
  gFm.bottom = env->GetFieldID(fm, "bottom", "F");
  gFm.leading = env->GetFieldID(fm, "leading", "F");
  jclass fmi = env->FindClass("android/graphics/Paint$FontMetricsInt");
  gFmi.top = env->GetFieldID(fmi, "top", "I");
  gFmi.ascent = env->GetFieldID(fmi, "ascent", "I");
  gFmi.descent = env->GetFieldID(fmi, "descent", "I");
  gFmi.bottom = env->GetFieldID(fmi, "bottom", "I");
  gFmi.leading = env->GetFieldID(fmi, "leading", "I");
  jclass canvas = env->FindClass("android/graphics/Canvas");
  gCanvasNative = env->GetFieldID(canvas, "mNativeCanvasWrapper", "J");
  jclass rect = env->FindClass("android/graphics/Rect");
  gRect.left = env->GetFieldID(rect, "left", "I");
  gRect.top = env->GetFieldID(rect, "top", "I");
  gRect.right = env->GetFieldID(rect, "right", "I");
  gRect.bottom = env->GetFieldID(rect, "bottom", "I");
  jniRegisterNativeMethods(env, "android/graphics/Paint", gPaintMethods, NELEM(gPaintMethods));
  jniRegisterNativeMethods(env, "android/graphics/Canvas", gCanvasMethods, NELEM(gCanvasMethods));
  jniRegisterNativeMethods(env, "android/view/Surface", gSurfaceMethods, NELEM(gSurfaceMethods));
  jniRegisterNativeMethods(env, "android/graphics/Path", gPathMethods, NELEM(gPathMethods));
  jniRegisterNativeMethods(env, "android/graphics/Matrix", gMatrixMethods, NELEM(gMatrixMethods));
  jniRegisterNativeMethods(env, "android/view/RenderNode", gRenderNodeMethods, NELEM(gRenderNodeMethods));
  jniRegisterNativeMethods(env, "android/graphics/PorterDuffColorFilter", gPorterDuffColorFilterMethods,
                           NELEM(gPorterDuffColorFilterMethods));
  jniRegisterNativeMethods(env, "android/graphics/ColorFilter", gColorFilterMethods, NELEM(gColorFilterMethods));
  jniRegisterNativeMethods(env, "android/emoji/EmojiFactory", gEmojiFactoryMethods, NELEM(gEmojiFactoryMethods));
}
