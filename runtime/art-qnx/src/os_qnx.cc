/*
 * QNX OS port for ART 6.0.1. Identical to the Linux implementation: all
 * these calls are plain POSIX and QNX provides them.
 */

#include "os.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <cstddef>
#include <memory>

#include "base/logging.h"
#include "base/unix_file/fd_file.h"

namespace art {

File* OS::OpenFileForReading(const char* name) {
  return OpenFileWithFlags(name, O_RDONLY);
}

File* OS::OpenFileReadWrite(const char* name) {
  return OpenFileWithFlags(name, O_RDWR);
}

File* OS::CreateEmptyFile(const char* name) {
  return OpenFileWithFlags(name, O_RDWR | O_CREAT | O_TRUNC);
}

File* OS::OpenFileWithFlags(const char* name, int flags) {
  CHECK(name != nullptr);
  std::unique_ptr<File> file(new File);
  if (!file->Open(name, flags, 0666)) {
    return nullptr;
  }
  return file.release();
}

bool OS::FileExists(const char* name) {
  struct stat st;
  if (stat(name, &st) == 0) {
    return S_ISREG(st.st_mode);  // TODO: Deal with symlinks?
  } else {
    return false;
  }
}

bool OS::DirectoryExists(const char* name) {
  struct stat st;
  if (stat(name, &st) == 0) {
    return S_ISDIR(st.st_mode);  // TODO: Deal with symlinks?
  } else {
    return false;
  }
}

}  // namespace art
