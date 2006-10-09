#ifndef _OBJC_H
#define _OBJC_H

#include <caml/mlvalues.h>

value objc_wrap(void* objc_object);
value objc_wrap_no_retain(void* objc_object);

#define objc_unwrap(w) *((void**)Data_custom_val(w))

#endif
