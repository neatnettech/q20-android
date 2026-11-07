// q20-android (NOD-30): hwui Caches stub for the stock graphics JNI.
//
// The stock Bitmap, Path, Graphics and Shader JNI purge the GPU texture and
// path caches in their finalizers, guarded by Caches::hasInstance(). There is
// no GPU and no hwui here, so hasInstance() is always false and getInstance()
// is never reached at run time; it exists only so the dead branches link.
#pragma once
#include <stdint.h>

class SkPath;

namespace android {
namespace uirenderer {

struct TextureCache { void releaseTexture(uint32_t) {} };
struct PathCache { void removeDeferred(SkPath*) {} };

class Caches {
public:
    static bool hasInstance() { return false; }
    static Caches& getInstance() { static Caches c; return c; }
    TextureCache textureCache;
    PathCache pathCache;
};

}  // namespace uirenderer
}  // namespace android
