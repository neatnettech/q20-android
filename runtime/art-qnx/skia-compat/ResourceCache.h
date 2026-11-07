// q20-android (NOD-30): hwui ResourceCache stub for the stock NinePatch JNI.
//
// NinePatch's finalizer routes its free through the hwui ResourceCache when
// one exists; here none does, so hasInstance() is false and the finalizer
// takes its plain delete[] path. getInstance() exists only to link.
#pragma once

namespace android {

// The real one (androidfw/ResourceTypes.h) lives in namespace android; a
// global forward decl would make the name ambiguous in NinePatch.cpp.
struct Res_png_9patch;

namespace uirenderer {

class ResourceCache {
public:
    static bool hasInstance() { return false; }
    static ResourceCache& getInstance() { static ResourceCache c; return c; }
    void destructor(Res_png_9patch*) {}
};

}  // namespace uirenderer
}  // namespace android

