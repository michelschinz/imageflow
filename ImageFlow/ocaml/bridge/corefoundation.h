#ifndef _COREFOUNDATION_H
#define _COREFOUNDATION_H

#include <CoreFoundation/CoreFoundation.h>
#include <caml/mlvalues.h>

value cf_wrap(CFTypeRef cf_value);

#define cf_unwrap(w) *((CFTypeRef*)Data_custom_val(w))

#endif
