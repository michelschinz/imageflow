#include <caml/mlvalues.h>
#include <caml/memory.h>

#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>

#include "corefoundation.h"

static CGImageRef _load(char* fileName) {
  CFDictionaryRef emptyDict =
    CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, NULL, NULL);

  CFStringRef cfFileName =
    CFStringCreateWithCString(kCFAllocatorDefault,
                              fileName,
                              kCFStringEncodingUTF8);
  CFURLRef url =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  cfFileName,
                                  kCFURLPOSIXPathStyle,
                                  false);
  CFRelease(cfFileName);

  CGImageRef image = NULL;
  if (url != NULL) {
    CGImageSourceRef imageSrc = CGImageSourceCreateWithURL(url, emptyDict);
    CFRelease(url);

    if (imageSrc != NULL) {
      image = CGImageSourceCreateImageAtIndex(imageSrc, 0, emptyDict);
      CFRelease(imageSrc);
    }
  }
  CFRelease(emptyDict);

  return image;
}

value cg_load(value fileName) {
  CAMLparam1(fileName);
  CGImageRef cgImage = _load(String_val(fileName));
  CAMLlocal1(camlImage);
  camlImage = cf_wrap(cgImage);
  CGImageRelease(cgImage);
  CAMLreturn(camlImage);
}
