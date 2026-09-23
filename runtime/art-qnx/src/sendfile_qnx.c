/* QNX has no sendfile(2); emulate with a copy loop. */
#include <sys/types.h>
#include <unistd.h>

ssize_t sendfile(int out_fd, int in_fd, off_t* offset, size_t count) {
  char buf[8192];
  size_t total = 0;
  size_t left;
  ssize_t n;
  if (offset != NULL) {
    if (lseek(in_fd, *offset, SEEK_SET) == -1) return -1;
  }
  left = count;
  while (left > 0) {
    size_t want = left < sizeof(buf) ? left : sizeof(buf);
    n = read(in_fd, buf, want);
    if (n <= 0) break;
    if (write(out_fd, buf, (size_t)n) != n) {
      return -1;
    }
    total += (size_t)n;
    left -= (size_t)n;
  }
  if (offset != NULL) *offset += (off_t)total;
  return (ssize_t)total;
}
