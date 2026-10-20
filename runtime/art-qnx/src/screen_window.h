/*
 * The Q20 window: a QNX Screen window whose CPU mapped RGBA8888 buffer is
 * handed to the raster engine as a Surface, then posted to the panel.
 *
 * The sequence is the one A4 proved on hardware (runtime/qnx-shims/
 * screen_probe.c): application context, window, one buffer, map its pointer
 * and stride, fill, post, flush. Whether the compositor then DRAWS that
 * window is the open A7 question, so the group and z order are env knobs:
 *
 *   Q20_SCREEN_GROUP   join this existing window group instead of creating
 *                      our own (the A4 baseline creates "q20-facade", which
 *                      the BB10 Navigator does not composite)
 *   Q20_SCREEN_ZORDER  window z order, default 200 (the Navigator publishes
 *                      its own as navzorder:n:100)
 */
#ifndef Q20_SCREEN_WINDOW_H_
#define Q20_SCREEN_WINDOW_H_

#include "raster.h"

namespace q20screen {

// Create the window on first call and fill *out with its mapped buffer.
// False when Screen refuses: the caller then renders to its own memory.
bool acquire(raster::Surface* out);

// Post the acquired buffer to the display. False if there is no window.
bool post();

}  // namespace q20screen

#endif  // Q20_SCREEN_WINDOW_H_
