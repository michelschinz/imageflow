#ifndef _OBJC_H
#define _OBJC_H

#include <caml/mlvalues.h>

value objc_wrap(id objc_object);
value objc_wrap_no_retain(id objc_object);

#define objc_unwrap(w) *((id*)Data_custom_val(w))

#endif
