/*
 * QNX graphics facade: the Paint, Path, Matrix, Region, RenderNode,
 * ColorFilter and EmojiFactory natives a View tree reaches while it is built, measured and
 * laid out (A6), the Canvas and Surface natives that then draw it (A7), and
 * the StaticLayout line breaker that multi line and editable text needs (A9).
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
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#include <algorithm>
#include <memory>
#include <string>
#include <vector>

// NOD-30: drawing is Skia now (CPU backend). The facade keeps its own Paint,
// text metrics (FreeType) and StaticLayout; the Canvas natives below forward
// onto an SkCanvas over the window buffer, building an SkPaint per draw.
#include "SkBitmap.h"
#include "SkCanvas.h"
#include "SkColor.h"
#include "SkImageInfo.h"
#include "SkInterpolator.h"
#include "SkPaint.h"
#include "SkTypeface.h"

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

// Advance in pixels of each UTF-16 unit of text[start, end), into
// out[0, end - start). A surrogate pair's advance sits on its first unit and
// the second gets 0, as minikin lays it out; control chars (the paragraph's
// newline) measure 0. The one width source for measuring (advance) and for
// StaticLayout line breaking, so the two always agree.
void charAdvances(const FPaint* p, const jchar* text, int start, int end, float* out) {
  std::vector<uint32_t> cps;
  decodeUtf16(text, start, end, &cps);
  pthread_mutex_lock(&gFontLock);
  FT_Face f = face();
  double upem = f != nullptr ? f->units_per_EM : 1;
  double scale = p->textSize * p->textScaleX;
  int u = 0;
  for (uint32_t c : cps) {
    FT_Fixed a = 0;
    if (f != nullptr && c >= 0x20) FT_Get_Advance(f, FT_Get_Char_Index(f, c), FT_LOAD_NO_SCALE, &a);
    out[u++] = c < 0x20 ? 0 : a * scale / upem + p->letterSpacing * scale;
    if (c >= 0x10000) out[u++] = 0;
  }
  pthread_mutex_unlock(&gFontLock);
}

// Advance in pixels of UTF-16 text[start, end).
float advance(const FPaint* p, const jchar* text, int start, int end) {
  std::vector<float> w(end - start);
  charAdvances(p, text, start, end, w.data());
  double sum = 0;
  for (float x : w) sum += x;
  return sum;
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

// ---- Color (stock Shader.cpp registers these under android/graphics/Color) ----

jint Color_HSVToColor(JNIEnv* env, jclass, jint alpha, jfloatArray hsvArray) {
  jfloat* hsv = env->GetFloatArrayElements(hsvArray, NULL);
  SkScalar hsv3[3] = { hsv[0], hsv[1], hsv[2] };
  jint rgb = SkHSVToColor(hsv3) & 0xFFFFFF;
  env->ReleaseFloatArrayElements(hsvArray, hsv, JNI_ABORT);
  return (alpha << 24) | rgb;
}
void Color_RGBToHSV(JNIEnv* env, jclass, jint red, jint green, jint blue, jfloatArray hsvArray) {
  SkScalar hsv3[3];
  SkRGBToHSV(red, green, blue, hsv3);
  jfloat* hsv = env->GetFloatArrayElements(hsvArray, NULL);
  hsv[0] = SkScalarToFloat(hsv3[0]);
  hsv[1] = SkScalarToFloat(hsv3[1]);
  hsv[2] = SkScalarToFloat(hsv3[2]);
  env->ReleaseFloatArrayElements(hsvArray, hsv, 0);
}
JNINativeMethod gColorMethods[] = {
  { "nativeRGBToHSV", "(III[F)V", reinterpret_cast<void*>(Color_RGBToHSV) },
  { "nativeHSVToColor", "(I[F)I", reinterpret_cast<void*>(Color_HSVToColor) },
};

// ---- Shaders ----
// Every creation native returns a fresh handle; the facade's SkPaint build
// ignores the shader, so gradients draw as plain color until CP2 wires the
// real SkShader construction. Handles stay non-zero: Shader.finalize checks.
jlong Shader_create(JNIEnv*, jclass) { return reinterpret_cast<jlong>(new int(0)); }
void Shader_destroy(JNIEnv*, jclass, jlong h) { delete reinterpret_cast<int*>(h); }
jlong Shader_setLocalMatrix(JNIEnv*, jclass, jlong h, jlong) { return h; }
JNINativeMethod gShaderMethods[] = {
  { "nativeDestructor", "(J)V", reinterpret_cast<void*>(Shader_destroy) },
  { "nativeSetLocalMatrix", "(JJ)J", reinterpret_cast<void*>(Shader_setLocalMatrix) },
};
JNINativeMethod gBitmapShaderMethods[] = {
  { "nativeCreate", "(Landroid/graphics/Bitmap;II)J", reinterpret_cast<void*>(Shader_create) },
};
JNINativeMethod gLinearGradientMethods[] = {
  { "nativeCreate1", "(FFFF[I[FI)J", reinterpret_cast<void*>(Shader_create) },
  { "nativeCreate2", "(FFFFIII)J", reinterpret_cast<void*>(Shader_create) },
};
JNINativeMethod gRadialGradientMethods[] = {
  { "nativeCreate1", "(FFF[I[FI)J", reinterpret_cast<void*>(Shader_create) },
  { "nativeCreate2", "(FFFIII)J", reinterpret_cast<void*>(Shader_create) },
};
JNINativeMethod gSweepGradientMethods[] = {
  { "nativeCreate1", "(FF[I[F)J", reinterpret_cast<void*>(Shader_create) },
  { "nativeCreate2", "(FFII)J", reinterpret_cast<void*>(Shader_create) },
};
JNINativeMethod gComposeShaderMethods[] = {
  { "nativeCreate1", "(JJJ)J", reinterpret_cast<void*>(Shader_create) },
  { "nativeCreate2", "(JJI)J", reinterpret_cast<void*>(Shader_create) },
};

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

// ---- StaticLayout: the line breaker minikin would be ----

// One paragraph between nSetupParagraph and nComputeLineBreaks, as minikin's
// LineBreaker holds it: widths per UTF-16 unit, offsets paragraph relative.
//
// ponytail: greedy only. Breaks come after runs of spaces (no UAX#14 rules, so
// no break after a hyphen or between ideographs), there is no hyphenation, and
// the high quality and balanced strategies run greedy too. A word wider than
// the line breaks at the char that overflows. Upgrade path: icu BreakIterator
// line rules (brkitr/line.brk is in the linked ICU data), or real minikin.
struct FBreaker {
  std::vector<jchar> text;
  std::vector<float> widths;
  float firstWidth = 0, restWidth = 0;
  int firstLines = 1;
  std::vector<jint> indents, tabStops;
  int defaultTab = 20;

  // minikin LineWidths::getLineWidth, line counted within the paragraph.
  float lineWidth(int line) const {
    float w = line < firstLines ? firstWidth : restWidth;
    if (!indents.empty()) w -= indents[std::min<size_t>(line, indents.size() - 1)];
    return w;
  }
  // minikin TabStops::nextTab: the first stop past x, else the next default multiple.
  float nextTab(float x) const {
    for (jint s : tabStops) {
      if (s > x) return s;
    }
    return floorf(x / defaultTab + 1) * defaultTab;
  }
  void finish() {
    text.clear();
    widths.clear();
    indents.clear();
  }
};

FBreaker* breakerAt(jlong h) { return reinterpret_cast<FBreaker*>(h); }

struct { jfieldID breaks, widths, flags; } gLineBreaks;
const jint kTabMask = 0x20000000;  // StaticLayout.TAB_MASK: the line holds a tab

// minikin's isLineEndSpace plus the control chars (tab, the trailing newline):
// they hang past the line end and a break may follow them.
bool isLineEndSpace(jchar c) {
  return c < 0x20 || c == ' ' || c == 0x1680 || (c >= 0x2000 && c <= 0x200A && c != 0x2007) ||
         c == 0x205F || c == 0x3000;
}

struct Breaks {
  std::vector<jint> offsets, flags;
  std::vector<jfloat> widths;
  void push(int offset, float width, bool tab) {
    offsets.push_back(offset);
    widths.push_back(width);
    flags.push_back(tab ? kTabMask : 0);
  }
};

// Greedy breaks for b's paragraph. Each line is scanned from its start; the
// reported width excludes trailing spaces, as minikin's postBreak does. A zero
// width char (second surrogate unit, combining mark, replacement tail) never
// overflows, so no line starts inside a char.
void computeBreaks(const FBreaker& b, Breaks* out) {
  int n = b.text.size();
  if (n == 0) {
    out->push(0, 0, false);  // minikin: an empty paragraph is one empty line
    return;
  }
  for (int start = 0, line = 0; start < n; line++) {
    float limit = b.lineWidth(line), x = 0, post = 0, candPost = 0;
    int cand = -1, end = n;
    bool tab = false, candTab = false;
    for (int i = start; i < n; i++) {
      jchar c = b.text[i];
      bool space = isLineEndSpace(c);
      float next = c == '\t' ? b.nextTab(x) : x + b.widths[i];
      if (!space && b.widths[i] > 0 && next > limit && i > start) {
        end = cand > start ? cand : i;
        if (cand > start) {
          post = candPost;
          tab = candTab;
        }
        break;
      }
      x = next;
      tab |= c == '\t';
      if (!space) post = x;
      if (space && (i + 1 == n || !isLineEndSpace(b.text[i + 1]))) {
        cand = i + 1;
        candPost = post;
        candTab = tab;
      }
    }
    out->push(end, post, tab);
    start = end;
  }
}

jlong SL_newBuilder(JNIEnv*, jclass) { return reinterpret_cast<jlong>(new FBreaker()); }
void SL_freeBuilder(JNIEnv*, jclass, jlong h) { delete breakerAt(h); }
void SL_finishBuilder(JNIEnv*, jclass, jlong h) { breakerAt(h)->finish(); }
// Hyphenator.<clinit> loads sEmptyHyphenator through here with a null buffer.
jlong SL_loadHyphenator(JNIEnv*, jclass, jobject, jint) { return 0; }
void SL_setLocale(JNIEnv*, jclass, jlong, jstring, jlong) {}

void SL_setupParagraph(JNIEnv* env, jclass, jlong h, jcharArray text, jint length, jfloat firstWidth,
                       jint firstLines, jfloat restWidth, jintArray tabStops, jint defaultTab,
                       jint /*strategy*/, jint /*hyphenationFrequency*/) {
  FBreaker* b = breakerAt(h);
  b->text.resize(length);
  env->GetCharArrayRegion(text, 0, length, b->text.data());
  b->widths.assign(length, 0);
  b->firstWidth = firstWidth;
  b->firstLines = firstLines;
  b->restWidth = restWidth;
  b->tabStops.clear();
  if (tabStops != nullptr) {
    b->tabStops.resize(env->GetArrayLength(tabStops));
    env->GetIntArrayRegion(tabStops, 0, b->tabStops.size(), b->tabStops.data());
  }
  b->defaultTab = defaultTab > 0 ? defaultTab : 20;
  b->indents.clear();  // StaticLayout sets them per paragraph, after this call
}
void SL_setIndents(JNIEnv* env, jclass, jlong h, jintArray indents) {
  FBreaker* b = breakerAt(h);
  b->indents.resize(env->GetArrayLength(indents));
  env->GetIntArrayRegion(indents, 0, b->indents.size(), b->indents.data());
}
// The native paint handle is our FPaint; the typeface is always the default.
jfloat SL_addStyleRun(JNIEnv* env, jclass, jlong h, jlong paint, jlong, jint start, jint end, jboolean) {
  FBreaker* b = breakerAt(h);
  if (!checkRange(env, start, end, b->text.size())) return 0;
  charAdvances(paintAt(paint), b->text.data(), start, end, b->widths.data() + start);
  double sum = 0;
  for (int i = start; i < end; i++) sum += b->widths[i];
  return sum;
}
void SL_addMeasuredRun(JNIEnv* env, jclass, jlong h, jint start, jint end, jfloatArray widths) {
  FBreaker* b = breakerAt(h);
  if (!checkRange(env, start, end, b->widths.size())) return;
  env->GetFloatArrayRegion(widths, start, end - start, b->widths.data() + start);
}
void SL_addReplacementRun(JNIEnv* env, jclass, jlong h, jint start, jint end, jfloat width) {
  FBreaker* b = breakerAt(h);
  if (!checkRange(env, start, end, b->widths.size()) || start == end) return;
  std::fill(b->widths.begin() + start, b->widths.begin() + end, 0.0f);
  b->widths[start] = width;
}
void SL_getWidths(JNIEnv* env, jclass, jlong h, jfloatArray widths) {
  FBreaker* b = breakerAt(h);
  env->SetFloatArrayRegion(widths, 0, b->widths.size(), b->widths.data());
}
// Fills the recycled LineBreaks arrays, replacing them when they are too short
// (stock recycleCopy), and returns the break count.
jint SL_computeLineBreaks(JNIEnv* env, jclass, jlong h, jobject recycle, jintArray breaks,
                          jfloatArray widths, jintArray flags, jint recycleLength) {
  FBreaker* b = breakerAt(h);
  Breaks out;
  computeBreaks(*b, &out);
  jint n = out.offsets.size();
  if (recycleLength < n) {
    breaks = env->NewIntArray(n);
    widths = env->NewFloatArray(n);
    flags = env->NewIntArray(n);
    env->SetObjectField(recycle, gLineBreaks.breaks, breaks);
    env->SetObjectField(recycle, gLineBreaks.widths, widths);
    env->SetObjectField(recycle, gLineBreaks.flags, flags);
  }
  env->SetIntArrayRegion(breaks, 0, n, out.offsets.data());
  env->SetFloatArrayRegion(widths, 0, n, out.widths.data());
  env->SetIntArrayRegion(flags, 0, n, out.flags.data());
  b->finish();
  return n;
}

JNINativeMethod gStaticLayoutMethods[] = {
  { "nNewBuilder", "()J", reinterpret_cast<void*>(SL_newBuilder) },
  { "nFreeBuilder", "(J)V", reinterpret_cast<void*>(SL_freeBuilder) },
  { "nFinishBuilder", "(J)V", reinterpret_cast<void*>(SL_finishBuilder) },
  { "nLoadHyphenator", "(Ljava/nio/ByteBuffer;I)J", reinterpret_cast<void*>(SL_loadHyphenator) },
  { "nSetLocale", "(JLjava/lang/String;J)V", reinterpret_cast<void*>(SL_setLocale) },
  { "nSetupParagraph", "(J[CIFIF[IIII)V", reinterpret_cast<void*>(SL_setupParagraph) },
  { "nSetIndents", "(J[I)V", reinterpret_cast<void*>(SL_setIndents) },
  { "nAddStyleRun", "(JJJIIZ)F", reinterpret_cast<void*>(SL_addStyleRun) },
  { "nAddMeasuredRun", "(JII[F)V", reinterpret_cast<void*>(SL_addMeasuredRun) },
  { "nAddReplacementRun", "(JIIF)V", reinterpret_cast<void*>(SL_addReplacementRun) },
  { "nGetWidths", "(J[F)V", reinterpret_cast<void*>(SL_getWidths) },
  { "nComputeLineBreaks", "(JLandroid/text/StaticLayout$LineBreaks;[I[F[II)I",
    reinterpret_cast<void*>(SL_computeLineBreaks) },
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
// The bounding box of the mapped corners (SkMatrix::mapRect); true while the
// matrix keeps rects as rects (no rotation or skew).
struct { jfieldID left, top, right, bottom; } gRectF;
jboolean Matrix_rectStaysRect(JNIEnv*, jclass, jlong h) {
  const float* m = matrixAt(h)->m;
  return (m[1] == 0 && m[3] == 0) || (m[0] == 0 && m[4] == 0);
}
jboolean Matrix_mapRect(JNIEnv* env, jclass, jlong h, jobject dst, jobject src) {
  const float* m = matrixAt(h)->m;
  float xs[2] = {env->GetFloatField(src, gRectF.left), env->GetFloatField(src, gRectF.right)};
  float ys[2] = {env->GetFloatField(src, gRectF.top), env->GetFloatField(src, gRectF.bottom)};
  float l = 0, t = 0, r = 0, b = 0;
  for (int i = 0; i < 4; i++) {
    float x = xs[i & 1], y = ys[i >> 1], w = m[6] * x + m[7] * y + m[8];
    if (w == 0) w = 1;
    float mx = (m[0] * x + m[1] * y + m[2]) / w, my = (m[3] * x + m[4] * y + m[5]) / w;
    l = i == 0 ? mx : std::min(l, mx);
    r = i == 0 ? mx : std::max(r, mx);
    t = i == 0 ? my : std::min(t, my);
    b = i == 0 ? my : std::max(b, my);
  }
  env->SetFloatField(dst, gRectF.left, l);
  env->SetFloatField(dst, gRectF.top, t);
  env->SetFloatField(dst, gRectF.right, r);
  env->SetFloatField(dst, gRectF.bottom, b);
  return Matrix_rectStaysRect(env, nullptr, h);
}
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
  { "native_rectStaysRect", "(J)Z", reinterpret_cast<void*>(Matrix_rectStaysRect) },
  { "native_mapRect", "(JLandroid/graphics/RectF;Landroid/graphics/RectF;)Z", reinterpret_cast<void*>(Matrix_mapRect) },
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

// View.getMatrix(), as hwui's RenderProperties::updateMatrix builds it:
// translate, then scale about the pivot. ponytail: rotation and the static
// or animation matrix are not composed; nothing on the A ladder rotates.
void nodeMatrix(const FNode* n, float* m) {
  float px = n->pivotSet ? n->pivotX : (n->right - n->left) / 2.0f;
  float py = n->pivotSet ? n->pivotY : (n->bottom - n->top) / 2.0f;
  m[0] = n->scaleX; m[1] = 0; m[2] = n->translationX + px - n->scaleX * px;
  m[3] = 0; m[4] = n->scaleY; m[5] = n->translationY + py - n->scaleY * py;
  m[6] = 0; m[7] = 0; m[8] = 1;
}
void RN_getTransformMatrix(JNIEnv*, jclass, jlong h, jlong matrix) { nodeMatrix(nodeAt(h), matrixAt(matrix)->m); }
void RN_getInverseTransformMatrix(JNIEnv*, jclass, jlong h, jlong matrix) {
  float m[9];
  nodeMatrix(nodeAt(h), m);
  // Scale and translate per axis; a zero scale (not invertible) maps to 1.
  float sx = m[0] != 0 ? 1 / m[0] : 1, sy = m[4] != 0 ? 1 / m[4] : 1;
  float* inv = matrixAt(matrix)->m;
  inv[0] = sx; inv[1] = 0; inv[2] = -m[2] * sx;
  inv[3] = 0; inv[4] = sy; inv[5] = -m[5] * sy;
  inv[6] = 0; inv[7] = 0; inv[8] = 1;
}

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
  { "nGetTransformMatrix", "(JJ)V", reinterpret_cast<void*>(RN_getTransformMatrix) },
  { "nAddAnimator", "(JJ)V", reinterpret_cast<void*>(RN_acceptJJ) },
  { "nEndAllAnimators", "(J)V", reinterpret_cast<void*>(RN_acceptJ) },
  { "nGetInverseTransformMatrix", "(JJ)V", reinterpret_cast<void*>(RN_getInverseTransformMatrix) },
};
#undef RN_PAIR

// ---- RenderNodeAnimator: hwui's animators, finished on start ----

// ViewAnimationUtils.createCircularReveal (the Calculator's clear and error
// flash) builds one. There is no RenderThread here, so an animator finishes
// the moment it starts: nStart calls back callOnFinished, the end listeners
// run (AnimatorSets chained on them carry on), then moveToRunningState
// notifies the start listeners. ponytail: no reveal clip and no motion, the
// end state shows at once.
struct FAnimator {
  int refs = 0;
  jlong duration = 300;
  jobject listener = nullptr;  // global ref to the Java RenderNodeAnimator
};
jclass gRenderNodeAnimator;
jmethodID gCallOnFinished;

FAnimator* animatorAt(jlong h) { return reinterpret_cast<FAnimator*>(h); }
jlong newAnimator() { return reinterpret_cast<jlong>(new FAnimator()); }
jlong Anim_create(JNIEnv*, jclass, jint, jfloat) { return newAnimator(); }
jlong Anim_createCanvasFloat(JNIEnv*, jclass, jlong, jfloat) { return newAnimator(); }
jlong Anim_createCanvasPaint(JNIEnv*, jclass, jlong, jint, jfloat) { return newAnimator(); }
jlong Anim_createReveal(JNIEnv*, jclass, jint, jint, jfloat, jfloat) { return newAnimator(); }
void Anim_ignoreF(JNIEnv*, jclass, jlong, jfloat) {}
void Anim_ignoreJ(JNIEnv*, jclass, jlong, jlong) {}
void Anim_ignoreZ(JNIEnv*, jclass, jlong, jboolean) {}
void Anim_ignore(JNIEnv*, jclass, jlong) {}
void Anim_setDuration(JNIEnv*, jclass, jlong h, jlong d) { animatorAt(h)->duration = d; }
jlong Anim_getDuration(JNIEnv*, jclass, jlong h) { return animatorAt(h)->duration; }
void Anim_setListener(JNIEnv* env, jclass, jlong h, jobject listener) {
  FAnimator* a = animatorAt(h);
  if (a->listener != nullptr) env->DeleteGlobalRef(a->listener);
  a->listener = listener != nullptr ? env->NewGlobalRef(listener) : nullptr;
}
// onFinished releases the Java reference, which can free the FAnimator:
// nothing reads it after the call.
void Anim_start(JNIEnv* env, jclass, jlong h) {
  if (animatorAt(h)->listener == nullptr) return;
  jobject self = env->NewLocalRef(animatorAt(h)->listener);
  env->CallStaticVoidMethod(gRenderNodeAnimator, gCallOnFinished, self);
  env->DeleteLocalRef(self);
}

JNINativeMethod gRenderNodeAnimatorMethods[] = {
  { "nCreateAnimator", "(IF)J", reinterpret_cast<void*>(Anim_create) },
  { "nCreateCanvasPropertyFloatAnimator", "(JF)J", reinterpret_cast<void*>(Anim_createCanvasFloat) },
  { "nCreateCanvasPropertyPaintAnimator", "(JIF)J", reinterpret_cast<void*>(Anim_createCanvasPaint) },
  { "nCreateRevealAnimator", "(IIFF)J", reinterpret_cast<void*>(Anim_createReveal) },
  { "nSetStartValue", "(JF)V", reinterpret_cast<void*>(Anim_ignoreF) },
  { "nSetDuration", "(JJ)V", reinterpret_cast<void*>(Anim_setDuration) },
  { "nGetDuration", "(J)J", reinterpret_cast<void*>(Anim_getDuration) },
  { "nSetStartDelay", "(JJ)V", reinterpret_cast<void*>(Anim_ignoreJ) },
  { "nSetInterpolator", "(JJ)V", reinterpret_cast<void*>(Anim_ignoreJ) },
  { "nSetAllowRunningAsync", "(JZ)V", reinterpret_cast<void*>(Anim_ignoreZ) },
  { "nSetListener", "(JLandroid/view/RenderNodeAnimator;)V", reinterpret_cast<void*>(Anim_setListener) },
  { "nStart", "(J)V", reinterpret_cast<void*>(Anim_start) },
  { "nEnd", "(J)V", reinterpret_cast<void*>(Anim_ignore) },
};

// VirtualRefBasePtr: here it only ever wraps an FAnimator.
void Ref_inc(JNIEnv*, jclass, jlong h) { animatorAt(h)->refs++; }
void Ref_dec(JNIEnv* env, jclass, jlong h) {
  FAnimator* a = animatorAt(h);
  if (--a->refs > 0) return;
  if (a->listener != nullptr) env->DeleteGlobalRef(a->listener);
  delete a;
}
JNINativeMethod gVirtualRefBasePtrMethods[] = {
  { "nIncStrong", "(J)V", reinterpret_cast<void*>(Ref_inc) },
  { "nDecStrong", "(J)V", reinterpret_cast<void*>(Ref_dec) },
};

// Native interpolators feed only the animators above, which ignore them.
jlong Interp_plain(JNIEnv*, jclass) { return 1; }
jlong Interp_factor(JNIEnv*, jclass, jfloat) { return 1; }
jlong Interp_lut(JNIEnv*, jclass, jfloatArray) { return 1; }
JNINativeMethod gInterpolatorFactoryMethods[] = {
  { "createAccelerateDecelerateInterpolator", "()J", reinterpret_cast<void*>(Interp_plain) },
  { "createAccelerateInterpolator", "(F)J", reinterpret_cast<void*>(Interp_factor) },
  { "createAnticipateInterpolator", "(F)J", reinterpret_cast<void*>(Interp_factor) },
  { "createAnticipateOvershootInterpolator", "(F)J", reinterpret_cast<void*>(Interp_factor) },
  { "createBounceInterpolator", "()J", reinterpret_cast<void*>(Interp_plain) },
  { "createCycleInterpolator", "(F)J", reinterpret_cast<void*>(Interp_factor) },
  { "createDecelerateInterpolator", "(F)J", reinterpret_cast<void*>(Interp_factor) },
  { "createLinearInterpolator", "()J", reinterpret_cast<void*>(Interp_plain) },
  { "createOvershootInterpolator", "(F)J", reinterpret_cast<void*>(Interp_factor) },
  { "createLutInterpolator", "([F)J", reinterpret_cast<void*>(Interp_lut) },
};

// ---- android.graphics.Interpolator ----

// The stock android/graphics/Interpolator.cpp over SkInterpolator, minus its
// AutoJavaFloatArray helper (lives in Graphics.cpp, which drags ashmem).
// View's ScrollabilityCache builds one per scrolling view: the blend array
// is null on the 3-arg setKeyFrame, so the JNI get calls are null-guarded.
jlong Interp_gfx_ctor(JNIEnv*, jclass, jint valueCount, jint frameCount) {
  return reinterpret_cast<jlong>(new SkInterpolator(valueCount, frameCount));
}
void Interp_gfx_dtor(JNIEnv*, jclass, jlong h) { delete reinterpret_cast<SkInterpolator*>(h); }
void Interp_gfx_reset(JNIEnv*, jclass, jlong h, jint vc, jint fc) {
  reinterpret_cast<SkInterpolator*>(h)->reset(vc, fc);
}
void Interp_gfx_setKeyFrame(JNIEnv* env, jclass, jlong h, jint index, jint msec,
                            jfloatArray valueArray, jfloatArray blendArray) {
  SkInterpolator* interp = reinterpret_cast<SkInterpolator*>(h);
  float* values = env->GetFloatArrayElements(valueArray, NULL);
  float* blend = blendArray != NULL ? env->GetFloatArrayElements(blendArray, NULL) : NULL;
  interp->setKeyFrame(index, msec, values, blend);
  env->ReleaseFloatArrayElements(valueArray, values, JNI_ABORT);
  if (blend != NULL) env->ReleaseFloatArrayElements(blendArray, blend, JNI_ABORT);
}
void Interp_gfx_setRepeatMirror(JNIEnv*, jclass, jlong h, jfloat repeatCount, jboolean mirror) {
  SkInterpolator* interp = reinterpret_cast<SkInterpolator*>(h);
  if (repeatCount > 32000) repeatCount = 32000;
  interp->setRepeatCount(repeatCount);
  interp->setMirror(mirror != 0);
}
jint Interp_gfx_timeToValues(JNIEnv* env, jclass, jlong h, jint msec, jfloatArray valueArray) {
  SkInterpolator* interp = reinterpret_cast<SkInterpolator*>(h);
  float* values = valueArray != NULL ? env->GetFloatArrayElements(valueArray, NULL) : NULL;
  SkInterpolatorBase::Result result = interp->timeToValues(msec, values);
  if (values != NULL) env->ReleaseFloatArrayElements(valueArray, values, 0);
  return static_cast<jint>(result);
}
JNINativeMethod gGraphicsInterpolatorMethods[] = {
  { "nativeConstructor", "(II)J", reinterpret_cast<void*>(Interp_gfx_ctor) },
  { "nativeDestructor", "(J)V", reinterpret_cast<void*>(Interp_gfx_dtor) },
  { "nativeReset", "(JII)V", reinterpret_cast<void*>(Interp_gfx_reset) },
  { "nativeSetKeyFrame", "(JII[F[F)V", reinterpret_cast<void*>(Interp_gfx_setKeyFrame) },
  { "nativeSetRepeatMirror", "(JFZ)V", reinterpret_cast<void*>(Interp_gfx_setRepeatMirror) },
  { "nativeTimeToValues", "(JI[F)I", reinterpret_cast<void*>(Interp_gfx_timeToValues) },
};

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
// Xfermodes (EdgeEffect's SRC_ATOP glow): the same kind of handle, never drawn.
jlong Xfermode_createPorterDuff(JNIEnv*, jclass, jint) { return reinterpret_cast<jlong>(new int(0)); }
JNINativeMethod gPorterDuffXfermodeMethods[] = {
  { "nativeCreateXfermode", "(I)J", reinterpret_cast<void*>(Xfermode_createPorterDuff) },
};
JNINativeMethod gXfermodeMethods[] = {
  { "finalizer", "(J)V", reinterpret_cast<void*>(ColorFilter_destroy) },
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

// ---- Skia paint + typeface from the facade's Paint and font ----

// Roboto as an SkTypeface, the same file face() reads for metrics, loaded
// once. Null if it cannot load (text then draws nothing, loudly once).
SkTypeface* skTypeface() {
  static SkTypeface* t = nullptr;
  static bool tried = false;
  if (!tried) {
    tried = true;
    const char* root = getenv("ANDROID_ROOT");
    std::string path = std::string(root ? root : "/system") + "/fonts/Roboto-Regular.ttf";
    t = SkTypeface::CreateFromFile(path.c_str());
    if (t == nullptr) ALOGE("SkTypeface cannot load %s, all text draws nothing", path.c_str());
  }
  return t;
}

// android.graphics.Paint style enum: 0 FILL, 1 STROKE, 2 FILL_AND_STROKE.
SkPaint skPaintOf(const FPaint* p) {
  SkPaint sp;
  sp.setColor(static_cast<SkColor>(p->color));
  sp.setAntiAlias((p->flags & kAntiAlias) != 0);
  sp.setStyle(p->style == 1 ? SkPaint::kStroke_Style
              : p->style == 2 ? SkPaint::kStrokeAndFill_Style : SkPaint::kFill_Style);
  sp.setStrokeWidth(p->strokeWidth);
  sp.setStrokeMiter(p->strokeMiter);
  sp.setStrokeCap(static_cast<SkPaint::Cap>(p->cap));
  sp.setStrokeJoin(static_cast<SkPaint::Join>(p->join));
  return sp;
}

// Text paint: unhinted and linear so Skia's advances match the facade's
// measure path (FT_LOAD_NO_SCALE advances scaled by size), and the drawn run
// stays inside its measured box.
SkPaint skTextPaintOf(const FPaint* p) {
  SkPaint sp = skPaintOf(p);
  sp.setAntiAlias(true);
  sp.setTextSize(p->textSize);
  sp.setTextScaleX(p->textScaleX);
  sp.setTypeface(skTypeface());
  sp.setTextEncoding(SkPaint::kUTF16_TextEncoding);
  sp.setHinting(SkPaint::kNo_Hinting);
  sp.setLinearText(true);
  sp.setSubpixelText(true);
  return sp;
}

SkMatrix skMatrixOf(const FMatrix* f) {
  SkMatrix m;
  m.setAll(f->m[0], f->m[1], f->m[2], f->m[3], f->m[4], f->m[5], f->m[6], f->m[7], f->m[8]);
  return m;
}

// ---- Canvas: the facade's Canvas natives forwarded onto an SkCanvas ----
//
// The handle is an FCanvas. Surface.lockCanvas points it at the window buffer
// (setSurface); every draw native builds an SkPaint from the facade's FPaint
// and calls the SkCanvas. Scale, rotate, skew, round-rect corners, layer
// alpha and rect clipping are all real now (the old raster engine had none).
struct FCanvas {
  SkBitmap bm;
  std::unique_ptr<SkCanvas> canvas;  // over bm; rebuilt each lockCanvas
  void setSurface(const raster::Surface& s) {
    if (s.px == nullptr) { canvas.reset(); return; }
    SkImageInfo info = SkImageInfo::Make(s.w, s.h, kN32_SkColorType, kPremul_SkAlphaType);
    bm.installPixels(info, s.px, static_cast<size_t>(s.stride));
    canvas.reset(new SkCanvas(bm));
  }
};
FCanvas* fcanvasAt(jlong h) { return reinterpret_cast<FCanvas*>(h); }
SkCanvas* skOf(jlong h) { return fcanvasAt(h)->canvas.get(); }

SkRect ltrb(jfloat l, jfloat t, jfloat r, jfloat b) { return SkRect::MakeLTRB(l, t, r, b); }

jlong Canvas_initRaster(JNIEnv*, jclass, jobject /*bitmap*/) {
  // Canvas() passes null here; Surface.lockCanvas points it at the window
  // buffer before any draw. Until then skOf() is null and draws no-op.
  return reinterpret_cast<jlong>(new FCanvas());
}
void Canvas_finalizer(JNIEnv*, jclass, jlong h) { delete fcanvasAt(h); }
void Canvas_setBitmap(JNIEnv*, jclass, jlong, jobject) {}
jboolean Canvas_isOpaque(JNIEnv*, jclass, jlong) { return JNI_TRUE; }
jint Canvas_getWidth(JNIEnv*, jclass, jlong h) { SkCanvas* c = skOf(h); return c ? c->imageInfo().width() : 0; }
jint Canvas_getHeight(JNIEnv*, jclass, jlong h) { SkCanvas* c = skOf(h); return c ? c->imageInfo().height() : 0; }

jint Canvas_save(JNIEnv*, jclass, jlong h, jint) { SkCanvas* c = skOf(h); return c ? c->save() : 0; }
jint Canvas_saveLayer(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b, jlong, jint) {
  SkCanvas* c = skOf(h);
  if (c == nullptr) return 0;
  SkRect rect = ltrb(l, t, r, b);
  return c->saveLayer(&rect, nullptr);
}
jint Canvas_saveLayerAlpha(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b,
                           jint alpha, jint) {
  SkCanvas* c = skOf(h);
  if (c == nullptr) return 0;
  SkRect rect = ltrb(l, t, r, b);
  return c->saveLayerAlpha(&rect, static_cast<U8CPU>(alpha));
}
void Canvas_restore(JNIEnv*, jclass, jlong h, jboolean) { SkCanvas* c = skOf(h); if (c) c->restore(); }
void Canvas_restoreToCount(JNIEnv*, jclass, jlong h, jint count, jboolean) {
  SkCanvas* c = skOf(h);
  if (c) c->restoreToCount(count);
}
jint Canvas_getSaveCount(JNIEnv*, jclass, jlong h) { SkCanvas* c = skOf(h); return c ? c->getSaveCount() : 1; }
void Canvas_translate(JNIEnv*, jclass, jlong h, jfloat dx, jfloat dy) { SkCanvas* c = skOf(h); if (c) c->translate(dx, dy); }
void Canvas_scale(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy) { SkCanvas* c = skOf(h); if (c) c->scale(sx, sy); }
void Canvas_skew(JNIEnv*, jclass, jlong h, jfloat sx, jfloat sy) { SkCanvas* c = skOf(h); if (c) c->skew(sx, sy); }
void Canvas_rotate(JNIEnv*, jclass, jlong h, jfloat deg) { SkCanvas* c = skOf(h); if (c) c->rotate(deg); }
void Canvas_concat(JNIEnv*, jclass, jlong h, jlong matrix) {
  SkCanvas* c = skOf(h);
  if (c && matrix) c->concat(skMatrixOf(matrixAt(matrix)));
}
void Canvas_setMatrix(JNIEnv*, jclass, jlong h, jlong matrix) {
  SkCanvas* c = skOf(h);
  if (c == nullptr) return;
  c->setMatrix(matrix ? skMatrixOf(matrixAt(matrix)) : SkMatrix::I());
}
void Canvas_getCTM(JNIEnv*, jclass, jlong h, jlong matrix) {
  SkCanvas* c = skOf(h);
  if (c == nullptr || matrix == 0) return;
  SkMatrix m = c->getTotalMatrix();
  float* d = matrixAt(matrix)->m;
  for (int i = 0; i < 9; i++) d[i] = m[i];
}
void Canvas_ignore_j(JNIEnv*, jclass, jlong, jlong) {}  // setDrawFilter: no filters

jboolean Canvas_clipRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b, jint op) {
  SkCanvas* c = skOf(h);
  if (c == nullptr) return JNI_FALSE;
  // android.graphics.Region.Op and SkRegion::Op share the same order.
  c->clipRect(ltrb(l, t, r, b), static_cast<SkRegion::Op>(op));
  return c->isClipEmpty() ? JNI_FALSE : JNI_TRUE;
}
// CP1: path and region clips are still no-ops (Path/Region handles are the
// facade's, not SkPath/SkRegion yet; wired in CP2 with the stock Path natives).
// Report non-empty: over-draw is visible, under-draw hides a widget.
jboolean Canvas_clipHandle(JNIEnv*, jclass, jlong, jlong, jint) { return JNI_TRUE; }

jboolean Canvas_getClipBounds(JNIEnv* env, jclass, jlong h, jobject bounds) {
  SkCanvas* c = skOf(h);
  SkRect r;
  if (c == nullptr || !c->getClipBounds(&r)) {
    env->SetIntField(bounds, gRect.left, 0);
    env->SetIntField(bounds, gRect.top, 0);
    env->SetIntField(bounds, gRect.right, 0);
    env->SetIntField(bounds, gRect.bottom, 0);
    return JNI_FALSE;
  }
  env->SetIntField(bounds, gRect.left, static_cast<int>(floorf(r.left())));
  env->SetIntField(bounds, gRect.top, static_cast<int>(floorf(r.top())));
  env->SetIntField(bounds, gRect.right, static_cast<int>(ceilf(r.right())));
  env->SetIntField(bounds, gRect.bottom, static_cast<int>(ceilf(r.bottom())));
  return JNI_TRUE;
}

jboolean Canvas_quickRejectRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b) {
  SkCanvas* c = skOf(h);
  return (c && c->quickReject(ltrb(l, t, r, b))) ? JNI_TRUE : JNI_FALSE;
}
jboolean Canvas_quickRejectPath(JNIEnv*, jclass, jlong, jlong) { return JNI_FALSE; }

void Canvas_drawColor(JNIEnv*, jclass, jlong h, jint color, jint /*mode*/) {
  SkCanvas* c = skOf(h);
  if (c) c->drawColor(static_cast<SkColor>(color));
}
void Canvas_drawPaint(JNIEnv*, jclass, jlong h, jlong paint) {
  SkCanvas* c = skOf(h);
  if (c) c->drawPaint(skPaintOf(paintAt(paint)));
}
void Canvas_drawRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b, jlong paint) {
  SkCanvas* c = skOf(h);
  if (c) c->drawRect(ltrb(l, t, r, b), skPaintOf(paintAt(paint)));
}
void Canvas_drawRoundRect(JNIEnv*, jclass, jlong h, jfloat l, jfloat t, jfloat r, jfloat b,
                          jfloat rx, jfloat ry, jlong paint) {
  SkCanvas* c = skOf(h);
  if (c) c->drawRoundRect(ltrb(l, t, r, b), rx, ry, skPaintOf(paintAt(paint)));
}
void Canvas_drawCircle(JNIEnv*, jclass, jlong h, jfloat cx, jfloat cy, jfloat radius, jlong paint) {
  SkCanvas* c = skOf(h);
  if (c) c->drawCircle(cx, cy, radius, skPaintOf(paintAt(paint)));
}

// A text run at a baseline origin, drawn straight from the UTF-16 units: Skia
// shapes and advances through the same FreeType face the measure path uses, so
// measure and draw agree. textScaleX and letterSpacing: scaleX is on the
// paint; letterSpacing is default for every run the ports draw.
void drawRun(jlong h, const jchar* text, int start, int end, jfloat x, jfloat y, jlong paint) {
  SkCanvas* c = skOf(h);
  if (c == nullptr || end <= start) return;
  c->drawText(text + start, static_cast<size_t>(end - start) * 2, x, y, skTextPaintOf(paintAt(paint)));
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
  { "native_scale", "(JFF)V", reinterpret_cast<void*>(Canvas_scale) },
  { "native_skew", "(JFF)V", reinterpret_cast<void*>(Canvas_skew) },
  { "native_rotate", "(JF)V", reinterpret_cast<void*>(Canvas_rotate) },
  { "native_concat", "(JJ)V", reinterpret_cast<void*>(Canvas_concat) },
  { "native_setMatrix", "(JJ)V", reinterpret_cast<void*>(Canvas_setMatrix) },
  { "native_getCTM", "(JJ)V", reinterpret_cast<void*>(Canvas_getCTM) },
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
  { "native_drawCircle", "(JFFFJ)V", reinterpret_cast<void*>(Canvas_drawCircle) },
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
  FCanvas* c = fcanvasAt(env->GetLongField(canvas, gCanvasNative));
  raster::Surface s;
  gPostable = q20screen::acquire(&s);
  if (!gPostable) {
    // No window to post (the open A7 compositor question). Draw into our own
    // memory anyway so the pass is still verifiable: Q20_DRAW_PNG writes it
    // out on post, which is the device evidence that does not need a
    // compositor.
    // Allocated once and cleared per frame: drawColor ignores CLEAR, so every
    // frame must still start from zero (NOD-29: the per frame vector fill at
    // -O0 cost more than some draws).
    static int n = 0;
    if (n == 0) {
      const char* sz = getenv("Q20_DRAW_SIZE");
      n = (sz != nullptr && sz[0] != '\0') ? atoi(sz) : 720;
      gFallback.resize((size_t)n * n * 4);
      ALOGI("no Screen window, drawing into a %dx%d heap surface", n, n);
    }
    memset(gFallback.data(), 0, gFallback.size());
    s = raster::Surface{gFallback.data(), n, n, n * 4};
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
  // Q20_DRAW_RAW: the same frame as tightly packed w*h*4 RGBA8888 (stride
  // padding dropped), for the root compositor to post. A8: written as
  // <raw>.tmp + rename (atomic) and a <raw>.seq bump (content is the change
  // signal; QNX st_mtime granularity is too coarse for a 30Hz watch), so the
  // resident compositor (FACADE_WATCH=1) never reads a half-written frame.
  const char* raw = getenv("Q20_DRAW_RAW");
  if (raw != nullptr && raw[0] != '\0' && gLocked.px != nullptr) {
    /* A8: direct write, then bump <raw>.seq AFTER the close - the seq is the
     * publish signal, so the compositor can never see a torn frame. No
     * tmp+rename: C rename() fails on this QNX (facade_compositor.c found 32
     * silently lost publishes; the shell mv works, the syscall does not). */
    struct timespec w0, w1;  // perf: the write cost, logged below
    clock_gettime(CLOCK_MONOTONIC, &w0);
    FILE* f = fopen(raw, "wb");
    if (f == nullptr) {
      ALOGE("Q20_DRAW_RAW fopen %s failed", raw);
    } else {
      size_t rowBytes = (size_t)gLocked.w * 4;
      size_t wrote = 0;
      for (int y = 0; y < gLocked.h; y++)
        wrote += fwrite(gLocked.px + (size_t)y * gLocked.stride, 1, rowBytes, f);
      fclose(f);
      static unsigned sSeq = 0;  // per-process; fine while each draw is a fresh launch
      char seqpath[512];
      snprintf(seqpath, sizeof(seqpath), "%s.seq", raw);
      FILE* sf = fopen(seqpath, "w");
      if (sf != nullptr) {
        fprintf(sf, "%u %llu\n", ++sSeq, (unsigned long long)time(NULL));
        fclose(sf);
      }
      clock_gettime(CLOCK_MONOTONIC, &w1);
      ALOGI("Q20_DRAW_RAW %s %dx%d wrote=%zu in %ld ms", raw, gLocked.w, gLocked.h, wrote,
            (long)((w1.tv_sec - w0.tv_sec) * 1000 + (w1.tv_nsec - w0.tv_nsec) / 1000000));
    }
  }
}

// Called after every post, so it must tolerate being a no op.
void Surface_release(JNIEnv*, jclass, jlong) {}
jboolean Surface_isValid(JNIEnv*, jclass, jlong h) { return h != 0 ? JNI_TRUE : JNI_FALSE; }

// A8 input is read in pure Java (Launcher.q20PollInput) - the JNI route
// died on the boot-loader FindClass problem and was removed. No natives here.

JNINativeMethod gSurfaceMethods[] = {
  { "nativeLockCanvas", "(JLandroid/graphics/Canvas;Landroid/graphics/Rect;)J",
    reinterpret_cast<void*>(Surface_lockCanvas) },
  { "nativeUnlockCanvasAndPost", "(JLandroid/graphics/Canvas;)V",
    reinterpret_cast<void*>(Surface_unlockCanvasAndPost) },
  { "nativeRelease", "(J)V", reinterpret_cast<void*>(Surface_release) },
  { "nativeIsValid", "(J)Z", reinterpret_cast<void*>(Surface_isValid) },
};

// ---- Region ----

// View.AttachInfo builds one (InternalInsetsInfo.touchableRegion) and the
// view tree uses them for insets and transparent areas.
// ponytail: a Region is its bounding rect. Union keeps the bounding box,
// difference and xor keep the first operand unless it is fully covered, so
// contains and quickReject can say yes where SkRegion would say no. Path,
// parcel and scale natives land when a trace reaches them.
typedef raster::Rect FRegion;
jfieldID gRegionNative;

FRegion* regionAt(jlong h) { return reinterpret_cast<FRegion*>(h); }
FRegion* regionOf(JNIEnv* env, jobject r) { return regionAt(env->GetLongField(r, gRegionNative)); }

FRegion unite(const FRegion& a, const FRegion& b) {
  if (a.empty()) return b;
  if (b.empty()) return a;
  return FRegion(std::min(a.l, b.l), std::min(a.t, b.t), std::max(a.r, b.r), std::max(a.b, b.b));
}
bool covers(const FRegion& outer, const FRegion& in) {
  return outer.l <= in.l && outer.t <= in.t && outer.r >= in.r && outer.b >= in.b;
}
// Region.Op order, as SkRegion::Op: DIFFERENCE, INTERSECT, UNION, XOR,
// REVERSE_DIFFERENCE, REPLACE. Operands by value: dst may be one of them.
jboolean regionOp(FRegion* dst, FRegion a, FRegion b, jint op) {
  switch (op) {
    case 0: *dst = covers(b, a) ? FRegion() : a; break;
    case 1: *dst = a.intersect(b); break;
    case 2: *dst = unite(a, b); break;
    case 4: *dst = covers(a, b) ? FRegion() : b; break;
    case 5: *dst = b; break;
    default: *dst = a; break;
  }
  return !dst->empty();
}
FRegion rectFrom(JNIEnv* env, jobject r) {
  FRegion x(env->GetIntField(r, gRect.left), env->GetIntField(r, gRect.top),
            env->GetIntField(r, gRect.right), env->GetIntField(r, gRect.bottom));
  return x.empty() ? FRegion() : x;
}

jlong Region_constructor(JNIEnv*, jclass) { return reinterpret_cast<jlong>(new FRegion()); }
void Region_destructor(JNIEnv*, jclass, jlong h) { delete regionAt(h); }
void Region_setRegion(JNIEnv*, jclass, jlong dst, jlong src) { *regionAt(dst) = *regionAt(src); }
jboolean Region_setRect(JNIEnv*, jclass, jlong dst, jint l, jint t, jint r, jint b) {
  return regionOp(regionAt(dst), FRegion(), FRegion(l, t, r, b), 5);
}
jboolean Region_getBounds(JNIEnv* env, jclass, jlong h, jobject rect) {
  const FRegion* g = regionAt(h);
  env->SetIntField(rect, gRect.left, g->l);
  env->SetIntField(rect, gRect.top, g->t);
  env->SetIntField(rect, gRect.right, g->r);
  env->SetIntField(rect, gRect.bottom, g->b);
  return !g->empty();
}
jboolean Region_opRect(JNIEnv*, jclass, jlong dst, jint l, jint t, jint r, jint b, jint op) {
  return regionOp(regionAt(dst), *regionAt(dst), FRegion(l, t, r, b), op);
}
jboolean Region_opRectRegion(JNIEnv* env, jclass, jlong dst, jobject rect, jlong region, jint op) {
  return regionOp(regionAt(dst), rectFrom(env, rect), *regionAt(region), op);
}
jboolean Region_opRegions(JNIEnv*, jclass, jlong dst, jlong a, jlong b, jint op) {
  return regionOp(regionAt(dst), *regionAt(a), *regionAt(b), op);
}
jboolean Region_equals(JNIEnv*, jclass, jlong a, jlong b) {
  const FRegion &x = *regionAt(a), &y = *regionAt(b);
  return x.l == y.l && x.t == y.t && x.r == y.r && x.b == y.b;
}
jboolean Region_isEmpty(JNIEnv* env, jobject o) { return regionOf(env, o)->empty(); }
jboolean Region_isRect(JNIEnv* env, jobject o) { return !regionOf(env, o)->empty(); }
jboolean Region_isComplex(JNIEnv*, jobject) { return false; }
jboolean Region_contains(JNIEnv* env, jobject o, jint x, jint y) {
  const FRegion* g = regionOf(env, o);
  return x >= g->l && x < g->r && y >= g->t && y < g->b;
}
jboolean Region_quickContains(JNIEnv* env, jobject o, jint l, jint t, jint r, jint b) {
  FRegion in(l, t, r, b);
  return !in.empty() && covers(*regionOf(env, o), in);
}
jboolean Region_quickRejectRect(JNIEnv* env, jobject o, jint l, jint t, jint r, jint b) {
  return regionOf(env, o)->intersect(FRegion(l, t, r, b)).empty();
}
jboolean Region_quickRejectRegion(JNIEnv* env, jobject o, jobject other) {
  return regionOf(env, o)->intersect(*regionOf(env, other)).empty();
}
void Region_translate(JNIEnv* env, jobject o, jint dx, jint dy, jobject dst) {
  FRegion g = *regionOf(env, o);
  if (!g.empty()) g = FRegion(g.l + dx, g.t + dy, g.r + dx, g.b + dy);
  *regionOf(env, dst != nullptr ? dst : o) = g;
}

// ---- Paint.getTextBounds (needs gRect, so it lives down here) ----

// The union of the glyphs' ink boxes with the pen advancing by the measure
// widths, rounded out as SkRect::roundOut does; baseline at 0, y down.
void textBounds(JNIEnv* env, const FPaint* p, const jchar* text, int start, int end, jobject rect) {
  std::vector<float> adv(end - start);
  charAdvances(p, text, start, end, adv.data());
  std::vector<uint32_t> cps;
  decodeUtf16(text, start, end, &cps);
  float l = 0, t = 0, r = 0, b = 0, pen = 0;
  bool any = false;
  pthread_mutex_lock(&gFontLock);
  FT_Face f = face();
  double sy = f != nullptr ? p->textSize / f->units_per_EM : 0, sx = sy * p->textScaleX;
  int u = 0;
  for (uint32_t c : cps) {
    if (f != nullptr && c >= 0x20 && FT_Load_Glyph(f, FT_Get_Char_Index(f, c), FT_LOAD_NO_SCALE) == 0) {
      const FT_Glyph_Metrics& m = f->glyph->metrics;
      if (m.width > 0 && m.height > 0) {
        float x0 = pen + m.horiBearingX * sx, x1 = x0 + m.width * sx;
        float y0 = -m.horiBearingY * sy, y1 = y0 + m.height * sy;
        l = any ? std::min(l, x0) : x0;
        t = any ? std::min(t, y0) : y0;
        r = any ? std::max(r, x1) : x1;
        b = any ? std::max(b, y1) : y1;
        any = true;
      }
    }
    pen += adv[u];
    u += c >= 0x10000 ? 2 : 1;
  }
  pthread_mutex_unlock(&gFontLock);
  env->SetIntField(rect, gRect.left, (int)floorf(l));
  env->SetIntField(rect, gRect.top, (int)floorf(t));
  env->SetIntField(rect, gRect.right, (int)ceilf(r));
  env->SetIntField(rect, gRect.bottom, (int)ceilf(b));
}
void Paint_getStringBounds(JNIEnv* env, jclass, jlong h, jlong, jstring text, jint start, jint end, jint,
                           jobject rect) {
  if (!checkRange(env, start, end, env->GetStringLength(text))) return;
  const jchar* chars = env->GetStringChars(text, nullptr);
  textBounds(env, paintAt(h), chars, start, end, rect);
  env->ReleaseStringChars(text, chars);
}
void Paint_getCharArrayBounds(JNIEnv* env, jclass, jlong h, jlong, jcharArray text, jint index, jint count,
                              jint, jobject rect) {
  if (!checkRange(env, index, index + count, env->GetArrayLength(text))) return;
  jchar* chars = env->GetCharArrayElements(text, nullptr);
  textBounds(env, paintAt(h), chars, index, index + count, rect);
  env->ReleaseCharArrayElements(text, chars, JNI_ABORT);
}

JNINativeMethod gPaintBoundsMethods[] = {
  { "nativeGetStringBounds", "(JJLjava/lang/String;IIILandroid/graphics/Rect;)V",
    reinterpret_cast<void*>(Paint_getStringBounds) },
  { "nativeGetCharArrayBounds", "(JJ[CIIILandroid/graphics/Rect;)V",
    reinterpret_cast<void*>(Paint_getCharArrayBounds) },
};

JNINativeMethod gRegionMethods[] = {
  { "nativeConstructor", "()J", reinterpret_cast<void*>(Region_constructor) },
  { "nativeDestructor", "(J)V", reinterpret_cast<void*>(Region_destructor) },
  { "nativeSetRegion", "(JJ)V", reinterpret_cast<void*>(Region_setRegion) },
  { "nativeSetRect", "(JIIII)Z", reinterpret_cast<void*>(Region_setRect) },
  { "nativeGetBounds", "(JLandroid/graphics/Rect;)Z", reinterpret_cast<void*>(Region_getBounds) },
  { "nativeOp", "(JIIIII)Z", reinterpret_cast<void*>(Region_opRect) },
  { "nativeOp", "(JLandroid/graphics/Rect;JI)Z", reinterpret_cast<void*>(Region_opRectRegion) },
  { "nativeOp", "(JJJI)Z", reinterpret_cast<void*>(Region_opRegions) },
  { "nativeEquals", "(JJ)Z", reinterpret_cast<void*>(Region_equals) },
  { "isEmpty", "()Z", reinterpret_cast<void*>(Region_isEmpty) },
  { "isRect", "()Z", reinterpret_cast<void*>(Region_isRect) },
  { "isComplex", "()Z", reinterpret_cast<void*>(Region_isComplex) },
  { "contains", "(II)Z", reinterpret_cast<void*>(Region_contains) },
  { "quickContains", "(IIII)Z", reinterpret_cast<void*>(Region_quickContains) },
  { "quickReject", "(IIII)Z", reinterpret_cast<void*>(Region_quickRejectRect) },
  { "quickReject", "(Landroid/graphics/Region;)Z", reinterpret_cast<void*>(Region_quickRejectRegion) },
  { "translate", "(IILandroid/graphics/Region;)V", reinterpret_cast<void*>(Region_translate) },
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
  jclass rectF = env->FindClass("android/graphics/RectF");
  gRectF.left = env->GetFieldID(rectF, "left", "F");
  gRectF.top = env->GetFieldID(rectF, "top", "F");
  gRectF.right = env->GetFieldID(rectF, "right", "F");
  gRectF.bottom = env->GetFieldID(rectF, "bottom", "F");
  jclass lineBreaks = env->FindClass("android/text/StaticLayout$LineBreaks");
  gLineBreaks.breaks = env->GetFieldID(lineBreaks, "breaks", "[I");
  gLineBreaks.widths = env->GetFieldID(lineBreaks, "widths", "[F");
  gLineBreaks.flags = env->GetFieldID(lineBreaks, "flags", "[I");
  jniRegisterNativeMethods(env, "android/graphics/Paint", gPaintMethods, NELEM(gPaintMethods));
  jniRegisterNativeMethods(env, "android/text/StaticLayout", gStaticLayoutMethods, NELEM(gStaticLayoutMethods));
  jniRegisterNativeMethods(env, "android/graphics/Interpolator", gGraphicsInterpolatorMethods, NELEM(gGraphicsInterpolatorMethods));
  jniRegisterNativeMethods(env, "android/graphics/Color", gColorMethods, NELEM(gColorMethods));
  jniRegisterNativeMethods(env, "android/graphics/Shader", gShaderMethods, NELEM(gShaderMethods));
  jniRegisterNativeMethods(env, "android/graphics/BitmapShader", gBitmapShaderMethods, NELEM(gBitmapShaderMethods));
  jniRegisterNativeMethods(env, "android/graphics/LinearGradient", gLinearGradientMethods, NELEM(gLinearGradientMethods));
  jniRegisterNativeMethods(env, "android/graphics/RadialGradient", gRadialGradientMethods, NELEM(gRadialGradientMethods));
  jniRegisterNativeMethods(env, "android/graphics/SweepGradient", gSweepGradientMethods, NELEM(gSweepGradientMethods));
  jniRegisterNativeMethods(env, "android/graphics/ComposeShader", gComposeShaderMethods, NELEM(gComposeShaderMethods));
  gRegionNative = env->GetFieldID(env->FindClass("android/graphics/Region"), "mNativeRegion", "J");
  jniRegisterNativeMethods(env, "android/graphics/Region", gRegionMethods, NELEM(gRegionMethods));
  jniRegisterNativeMethods(env, "android/graphics/Paint", gPaintBoundsMethods, NELEM(gPaintBoundsMethods));
  jniRegisterNativeMethods(env, "android/graphics/Canvas", gCanvasMethods, NELEM(gCanvasMethods));
  jniRegisterNativeMethods(env, "android/view/Surface", gSurfaceMethods, NELEM(gSurfaceMethods));
  jniRegisterNativeMethods(env, "android/graphics/Path", gPathMethods, NELEM(gPathMethods));
  jniRegisterNativeMethods(env, "android/graphics/Matrix", gMatrixMethods, NELEM(gMatrixMethods));
  jniRegisterNativeMethods(env, "android/view/RenderNode", gRenderNodeMethods, NELEM(gRenderNodeMethods));
  jniRegisterNativeMethods(env, "android/graphics/PorterDuffColorFilter", gPorterDuffColorFilterMethods,
                           NELEM(gPorterDuffColorFilterMethods));
  jniRegisterNativeMethods(env, "android/graphics/ColorFilter", gColorFilterMethods, NELEM(gColorFilterMethods));
  jniRegisterNativeMethods(env, "android/graphics/PorterDuffXfermode", gPorterDuffXfermodeMethods,
                           NELEM(gPorterDuffXfermodeMethods));
  jniRegisterNativeMethods(env, "android/graphics/Xfermode", gXfermodeMethods, NELEM(gXfermodeMethods));
  gRenderNodeAnimator = static_cast<jclass>(env->NewGlobalRef(env->FindClass("android/view/RenderNodeAnimator")));
  gCallOnFinished = env->GetStaticMethodID(gRenderNodeAnimator, "callOnFinished", "(Landroid/view/RenderNodeAnimator;)V");
  jniRegisterNativeMethods(env, "android/view/RenderNodeAnimator", gRenderNodeAnimatorMethods,
                           NELEM(gRenderNodeAnimatorMethods));
  jniRegisterNativeMethods(env, "com/android/internal/util/VirtualRefBasePtr", gVirtualRefBasePtrMethods,
                           NELEM(gVirtualRefBasePtrMethods));
  jniRegisterNativeMethods(env, "com/android/internal/view/animation/NativeInterpolatorFactoryHelper",
                           gInterpolatorFactoryMethods, NELEM(gInterpolatorFactoryMethods));
  jniRegisterNativeMethods(env, "android/emoji/EmojiFactory", gEmojiFactoryMethods, NELEM(gEmojiFactoryMethods));
}
