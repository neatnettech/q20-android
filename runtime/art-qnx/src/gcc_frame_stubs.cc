/*
 * QNX port: old libgcc frame registration stubs.
 *
 * GCC 9's libgcc_s no longer exports __register_frame_info (replaced by
 * .eh_frame_hdr) and the QNX loader resolves everything at load time.
 * These are no-ops: nothing in our tree uses the old frame API.
 */

struct object;

extern "C" void __register_frame_info(const void* begin, struct object* ob) {
  (void)begin;
  (void)ob;
}

extern "C" void __deregister_frame_info(const void* begin) {
  (void)begin;
}

extern "C" void* __register_frame_info_bases(const void*, struct object*,
                                             void*, void*) {
  return nullptr;
}

extern "C" void _ITM_registerTMCloneTable(void* table, size_t size) {
  (void)table;
  (void)size;
}

extern "C" void _ITM_deregisterTMCloneTable(void* table) {
  (void)table;
}
