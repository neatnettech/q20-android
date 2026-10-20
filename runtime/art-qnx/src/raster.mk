# Host build + verification for the raster engine (A7 first pixels).
#
# The engine (raster.cc) is portable C++ + FreeType with no JNI or ART, so it
# builds here and runs against a PNG-diff test; the same source compiles into
# the device facade when the on-device A7 step wires android.graphics.Canvas
# onto it. This makefile is host-only (system g++ + FreeType); it does not
# touch art-qnx.mk or the device build.
#
#   make -f raster.mk test     build and run the pixel assertions
#   make -f raster.mk png      same, and leave raster_out.png to eyeball
#   make -f raster.mk clean
#
# Override FONT=/path/to.ttf to render with a specific face (the test's
# assertions are structural and pass with any TrueType font).

CXX ?= c++
CXXFLAGS ?= -std=c++14 -Wall -Wextra -O2
FT_CFLAGS := $(shell pkg-config --cflags freetype2)
FT_LIBS := $(shell pkg-config --libs freetype2)
FONT ?=
OUT ?= raster_out.png

.PHONY: test png clean

raster_test: raster.cc raster_test.cc raster.h
	$(CXX) $(CXXFLAGS) $(FT_CFLAGS) raster.cc raster_test.cc -o $@ $(FT_LIBS)

test: raster_test
	./raster_test "$(FONT)" "$(OUT)"

png: test
	@echo "wrote $(OUT)"

clean:
	rm -f raster_test raster_out.png
