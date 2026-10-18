/*
 * QNX port: ICU's internal common/ureslocs.h, which libcore_icu_ICU.cpp
 * includes for U_ICUDATA_CURR. The QNX sysroot ships only the public ICU
 * headers. Same definitions as ICU 4.6.
 */
#ifndef Q20_URESLOCS_H
#define Q20_URESLOCS_H

#include <unicode/udata.h>
#include <unicode/utypes.h>

#define U_ICUDATA_LANG   U_ICUDATA_NAME U_TREE_SEPARATOR_STRING "lang"
#define U_ICUDATA_REGION U_ICUDATA_NAME U_TREE_SEPARATOR_STRING "region"
#define U_ICUDATA_CURR   U_ICUDATA_NAME U_TREE_SEPARATOR_STRING "curr"
#define U_ICUDATA_ZONE   U_ICUDATA_NAME U_TREE_SEPARATOR_STRING "zone"

#endif  // Q20_URESLOCS_H
