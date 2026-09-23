/*
 * QNX port: zip_archive C API stubs.
 *
 * ponytail: real libziparchive needs FileMap/libutils/liblog; defer until
 * APK support is needed. The interpreter milestone only reads bare DEX
 * files, so return -1 (failure) from everything.
 */

#include <ziparchive/zip_archive.h>

int32_t OpenArchive(const char* fileName, ZipArchiveHandle* handle) {
  (void)fileName;
  (void)handle;
  return -1;
}

int32_t OpenArchiveFd(const int fd, const char* debugFileName,
                      ZipArchiveHandle* handle, bool assume_ownership) {
  (void)fd;
  (void)debugFileName;
  (void)handle;
  (void)assume_ownership;
  return -1;
}

void CloseArchive(ZipArchiveHandle handle) {
  (void)handle;
}

int32_t ExtractEntryToFile(ZipArchiveHandle handle, ZipEntry* entry, int fd) {
  (void)handle;
  (void)entry;
  (void)fd;
  return -1;
}

int32_t ExtractToMemory(ZipArchiveHandle handle, ZipEntry* entry,
                        uint8_t* begin, uint32_t size) {
  (void)handle;
  (void)entry;
  (void)begin;
  (void)size;
  return -1;
}

int32_t FindEntry(const ZipArchiveHandle handle, const ZipEntryName& entryName,
                  ZipEntry* entry) {
  (void)handle;
  (void)entryName;
  (void)entry;
  return -1;
}

const char* ErrorCodeString(int32_t error_code) {
  (void)error_code;
  return "zip stub";
}

int GetFileDescriptor(const ZipArchiveHandle handle) {
  (void)handle;
  return -1;
}
