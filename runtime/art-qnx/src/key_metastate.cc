/*
 * normalizeMetaState / updateMetaState for the KeyCharacterMap JNI (NOD-33).
 * libinput's KeyCharacterMap.cpp calls these to fold modifier state while
 * mapping keys; they live in Keyboard.cpp, which otherwise drags in the whole
 * keymap loader (KeyLayoutMap, EventHub config paths). These two (plus their
 * static helpers) are self-contained metastate bit logic - copied verbatim
 * from frameworks/native/libs/input/Keyboard.cpp so the behaviour matches.
 */
#include <android/input.h>
#include <android/keycodes.h>
#include <stdint.h>

namespace android {

static int32_t setEphemeralMetaState(int32_t mask, bool down, int32_t oldMetaState);

int32_t normalizeMetaState(int32_t oldMetaState) {
    int32_t newMetaState = oldMetaState;
    if (newMetaState & (AMETA_ALT_LEFT_ON | AMETA_ALT_RIGHT_ON)) newMetaState |= AMETA_ALT_ON;
    if (newMetaState & (AMETA_SHIFT_LEFT_ON | AMETA_SHIFT_RIGHT_ON)) newMetaState |= AMETA_SHIFT_ON;
    if (newMetaState & (AMETA_CTRL_LEFT_ON | AMETA_CTRL_RIGHT_ON)) newMetaState |= AMETA_CTRL_ON;
    if (newMetaState & (AMETA_META_LEFT_ON | AMETA_META_RIGHT_ON)) newMetaState |= AMETA_META_ON;
    return newMetaState;
}

static int32_t setEphemeralMetaState(int32_t mask, bool down, int32_t oldMetaState) {
    int32_t newMetaState;
    if (down) {
        newMetaState = oldMetaState | mask;
    } else {
        newMetaState = oldMetaState &
                ~(mask | AMETA_ALT_ON | AMETA_SHIFT_ON | AMETA_CTRL_ON | AMETA_META_ON);
    }
    return normalizeMetaState(newMetaState);
}

static int32_t toggleLockedMetaState(int32_t mask, bool down, int32_t oldMetaState) {
    return down ? oldMetaState : (oldMetaState ^ mask);
}

int32_t updateMetaState(int32_t keyCode, bool down, int32_t oldMetaState) {
    switch (keyCode) {
    case AKEYCODE_ALT_LEFT:    return setEphemeralMetaState(AMETA_ALT_LEFT_ON, down, oldMetaState);
    case AKEYCODE_ALT_RIGHT:   return setEphemeralMetaState(AMETA_ALT_RIGHT_ON, down, oldMetaState);
    case AKEYCODE_SHIFT_LEFT:  return setEphemeralMetaState(AMETA_SHIFT_LEFT_ON, down, oldMetaState);
    case AKEYCODE_SHIFT_RIGHT: return setEphemeralMetaState(AMETA_SHIFT_RIGHT_ON, down, oldMetaState);
    case AKEYCODE_SYM:         return setEphemeralMetaState(AMETA_SYM_ON, down, oldMetaState);
    case AKEYCODE_FUNCTION:    return setEphemeralMetaState(AMETA_FUNCTION_ON, down, oldMetaState);
    case AKEYCODE_CTRL_LEFT:   return setEphemeralMetaState(AMETA_CTRL_LEFT_ON, down, oldMetaState);
    case AKEYCODE_CTRL_RIGHT:  return setEphemeralMetaState(AMETA_CTRL_RIGHT_ON, down, oldMetaState);
    case AKEYCODE_META_LEFT:   return setEphemeralMetaState(AMETA_META_LEFT_ON, down, oldMetaState);
    case AKEYCODE_META_RIGHT:  return setEphemeralMetaState(AMETA_META_RIGHT_ON, down, oldMetaState);
    case AKEYCODE_CAPS_LOCK:   return toggleLockedMetaState(AMETA_CAPS_LOCK_ON, down, oldMetaState);
    case AKEYCODE_NUM_LOCK:    return toggleLockedMetaState(AMETA_NUM_LOCK_ON, down, oldMetaState);
    case AKEYCODE_SCROLL_LOCK: return toggleLockedMetaState(AMETA_SCROLL_LOCK_ON, down, oldMetaState);
    default:                   return oldMetaState;
    }
}

}  // namespace android
