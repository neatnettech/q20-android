/*
 * QNX port: minimal ICU and charset natives for libjavacore.
 *
 * Runtime::Start -> InitNativeMethods -> WellKnownClasses::LateInit caches
 * Runtime.nativeLoad, which runs Runtime.<clinit> and then System.<clinit>.
 * initUnchangeableSystemProperties calls three ICU version natives, and any
 * System.out.println reaches Charset.forName("UTF-8") ->
 * NativeConverter.charsetForName. Unregistered, each throws
 * UnsatisfiedLinkError, CacheMethod then gets a null method id and LOG(FATAL)s,
 * so the runtime never reaches main().
 *
 * ponytail: version strings are constants, and only the charsets that
 * String.getBytes encodes with its own ART natives (CharsetUtils.toUtf8Bytes
 * and friends) are recognised, so no ICU converter is ever opened. A decode
 * (newDecoder) or any other charset still fails with UnsatisfiedLinkError.
 * Upgrade path: delete this file and register the real libcore ICU natives
 * once external/icu 55 plus icudt55l.dat are cross built for QNX.
 *
 * Runnable check: Hello printing "Hello from ART 6 on QNX! gc ok" on device
 * exercises all four natives (three properties plus the UTF-8 lookup).
 */

#define LOG_TAG "icu-stubs"

#include <strings.h>

#include "JNIHelp.h"
#include "JniConstants.h"
#include "ScopedUtfChars.h"

// What libcore M expects to find (it hard codes icudt55l). Stored as system
// properties only; nothing on the boot path parses them.
static const char* const kIcuVersion = "55.1";
static const char* const kUnicodeVersion = "7.0";
static const char* const kCldrVersion = "27.0.1";

static jstring ICU_getIcuVersion(JNIEnv* env, jclass) {
  return env->NewStringUTF(kIcuVersion);
}

static jstring ICU_getUnicodeVersion(JNIEnv* env, jclass) {
  return env->NewStringUTF(kUnicodeVersion);
}

static jstring ICU_getCldrVersion(JNIEnv* env, jclass) {
  return env->NewStringUTF(kCldrVersion);
}

// Accepted names and the canonical name each maps to. Matched case
// insensitively, so only spellings that differ by more than case are listed.
// Every canonical name here has a native encoder in String.getBytes.
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

static JNINativeMethod gIcuMethods[] = {
  NATIVE_METHOD(ICU, getCldrVersion, "()Ljava/lang/String;"),
  NATIVE_METHOD(ICU, getIcuVersion, "()Ljava/lang/String;"),
  NATIVE_METHOD(ICU, getUnicodeVersion, "()Ljava/lang/String;"),
};

static JNINativeMethod gNativeConverterMethods[] = {
  NATIVE_METHOD(NativeConverter, charsetForName, "(Ljava/lang/String;)Ljava/nio/charset/Charset;"),
};

void register_qnx_icu_stubs(JNIEnv* env) {
  jniRegisterNativeMethods(env, "libcore/icu/ICU", gIcuMethods, NELEM(gIcuMethods));
  jniRegisterNativeMethods(env, "libcore/icu/NativeConverter", gNativeConverterMethods,
                           NELEM(gNativeConverterMethods));
}
