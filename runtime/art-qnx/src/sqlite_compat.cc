// SQLiteConnection.cpp asks whether a read-write open came back read only
// (SQLite 3.7.11+); the sysroot's 3.7.9 lacks the call.
#include "sqlite3_compat.h"

// ponytail: always writable; implement over sqlite3_file_control if a read only
// mount ever opens a database.
extern "C" int sqlite3_db_readonly(sqlite3*, const char*) { return 0; }
