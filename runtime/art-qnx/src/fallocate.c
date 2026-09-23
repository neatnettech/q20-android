/* posix_fallocate64_large: QNX has no fallocate; emulate via ftruncate */
#include <sys/types.h>
#include <unistd.h>
int posix_fallocate64_large(int fd, off64_t offset, off64_t length) {
  off64_t end;
  if (offset < 0 || length <= 0) return -1;
  end = lseek64(fd, 0, 2);
  if (end < 0) return -1;
  if (offset + length > end) {
    if (ftruncate64(fd, offset + length) != 0) return -1;
  }
  return 0;
}
