/*
 * QNX port stub for <sys/system_properties.h>: cutils/properties.h needs it.
 * Property lookup is a no-op on QNX (no property service); property_get
 * returns the default value.
 */
#ifndef _SYS_SYSTEM_PROPERTIES_H
#define _SYS_SYSTEM_PROPERTIES_H

#include <sys/cdefs.h>

#define PROP_VALUE_MAX 92
#define PROP_NAME_MAX 32

__BEGIN_DECLS
int __system_property_get(const char* name, char* value);
int __system_property_set(const char* key, const char* value);
int __system_property_read(const void* pi, char* name, char* value);
__END_DECLS

#endif  // _SYS_SYSTEM_PROPERTIES_H
