// SQLite 3.7.9 (sysroot) vs the 3.8 the 6.0.1 JNI targets.
#include <sqlite3.h>
// 3.7.11: SQLiteConnection.cpp asks whether a read-write open came back read only.
extern "C" int sqlite3_db_readonly(sqlite3* db, const char* name);
// 3.7.15 log codes SQLiteGlobal.cpp filters; 3.7.9 never emits them.
#define SQLITE_NOTICE 27
#define SQLITE_WARNING 28
#define SQLITE_WARNING_AUTOINDEX (SQLITE_WARNING | (1 << 8))
