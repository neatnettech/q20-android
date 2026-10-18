/*
 * QNX port: minimal charset natives for libjavacore. The libcore.icu.ICU
 * natives are the real ones (libcore_icu_ICU.cpp on the sysroot ICU 4.6,
 * patch 0100).
 *
 * Any System.out.println reaches Charset.forName("UTF-8") ->
 * NativeConverter.charsetForName. Unregistered, it throws
 * UnsatisfiedLinkError, CacheMethod then gets a null method id and LOG(FATAL)s,
 * so the runtime never reaches main().
 *
 * ponytail: only the charsets that String.getBytes encodes with its own ART
 * natives (CharsetUtils.toUtf8Bytes and friends) are recognised, plus UTF-16
 * and UTF-16LE so StandardCharsets.<clinit> (reached from Resources.getSystem)
 * can build its constants. No ICU converter is ever opened: a decode
 * (newDecoder), a UTF-16/UTF-16LE encode or any other charset still fails with
 * UnsatisfiedLinkError. Upgrade path: delete this file and register the real
 * libcore_icu_NativeConverter.cpp.
 *
 * Runnable check: Hello printing "Hello from ART 6 on QNX! gc ok" on device
 * exercises the UTF-8 lookup.
 */

#define LOG_TAG "icu-stubs"

#include <strings.h>

#include "JNIHelp.h"
#include "JniConstants.h"
#include "ScopedUtfChars.h"

// Accepted names and the canonical name each maps to. Matched case
// insensitively, so only spellings that differ by more than case are listed.
// Every canonical name here except UTF-16 and UTF-16LE has a native encoder
// in String.getBytes.
struct CharsetName {
  const char* name;
  const char* canonical;
};

static const CharsetName kCharsets[] = {
  { "UTF-8",             "UTF-8" },
  { "UTF8",              "UTF-8" },
  { "ISO-8859-1",        "ISO-8859-1" },
  { "ISO8859-1",         "ISO-8859-1" },
  { "ISO_8859-1",        "ISO-8859-1" },
  { "8859_1",            "ISO-8859-1" },
  { "LATIN1",            "ISO-8859-1" },
  { "US-ASCII",          "US-ASCII" },
  { "ASCII",             "US-ASCII" },
  { "UTF-16BE",          "UTF-16BE" },
  { "UnicodeBigUnmarked", "UTF-16BE" },
  { "UTF-16LE",          "UTF-16LE" },
  { "UTF-16",            "UTF-16" },
};

static jobject NativeConverter_charsetForName(JNIEnv* env, jclass, jstring javaName) {
  ScopedUtfChars name(env, javaName);
  if (name.c_str() == NULL) {
    return NULL;
  }

  const char* canonical = NULL;
  for (int i = 0; i < NELEM(kCharsets); ++i) {
    if (strcasecmp(name.c_str(), kCharsets[i].name) == 0) {
      canonical = kCharsets[i].canonical;
      break;
    }
  }
  if (canonical == NULL) {
    // Charset.forName turns this into UnsupportedCharsetException, which is
    // the right answer for a charset we cannot convert.
    return NULL;
  }

  jstring canonicalName = env->NewStringUTF(canonical);
  if (canonicalName == NULL) {
    return NULL;
  }
  jobjectArray noAliases = env->NewObjectArray(0, JniConstants::stringClass, NULL);
  if (noAliases == NULL) {
    return NULL;
  }
  static jmethodID charsetConstructor = env->GetMethodID(JniConstants::charsetICUClass,
      "<init>", "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;)V");
  if (charsetConstructor == NULL) {
    return NULL;
  }
  return env->NewObject(JniConstants::charsetICUClass, charsetConstructor,
                        canonicalName, canonicalName, noAliases);
}

static JNINativeMethod gNativeConverterMethods[] = {
  NATIVE_METHOD(NativeConverter, charsetForName, "(Ljava/lang/String;)Ljava/nio/charset/Charset;"),
};

void register_qnx_icu_stubs(JNIEnv* env) {
  jniRegisterNativeMethods(env, "libcore/icu/NativeConverter", gNativeConverterMethods,
                           NELEM(gNativeConverterMethods));
}
