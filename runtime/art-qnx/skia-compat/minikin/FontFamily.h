// q20-android (NOD-30): the only thing the graphics JNI needs from minikin is
// the FontVariant enum (Paint carries it). The real minikin shaping and font
// collection are compiled out on QNX (patch over Paint.cpp's text natives).
#pragma once

namespace android {

enum FontVariant {
    VARIANT_DEFAULT = 0,
    VARIANT_COMPACT = 1,
    VARIANT_ELEGANT = 2,
};

}  // namespace android
