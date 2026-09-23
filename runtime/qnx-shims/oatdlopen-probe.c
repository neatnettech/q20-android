#include <dlfcn.h>
#include <stdio.h>

int main(int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: %s <path>\n", argv[0]);
    return 1;
  }
  void* h = dlopen(argv[1], RTLD_NOW);
  if (h == NULL) {
    fprintf(stderr, "dlopen failed: %s\n", dlerror());
    return 1;
  }
  void* oatdata = dlsym(h, "oatdata");
  void* oatexec = dlsym(h, "oatexec");
  printf("dlopen ok, oatdata=%p oatexec=%p\n", oatdata, oatexec);
  dlclose(h);
  return 0;
}
