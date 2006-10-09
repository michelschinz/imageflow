#include <caml/mlvalues.h>
#include <caml/memory.h>

#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include <QuartzCore/QuartzCore.h>

#include "corefoundation.h"
#include "objc.h"

static int _saveCG(CGImageRef image, char* fileName, char* fileType) {
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

  CFStringRef cfFileType =
    CFStringCreateWithCString(kCFAllocatorDefault,
                              fileType,
                              kCFStringEncodingUTF8);

  CGImageDestinationRef imageDst =
    CGImageDestinationCreateWithURL(url, cfFileType, 1, NULL);
  CFRelease(url);
  CFRelease(cfFileType);

  if (imageDst == NULL)
    return 0;

  CGImageDestinationAddImage(imageDst, image, emptyDict); /* TODO properties */
  CGImageDestinationFinalize(imageDst);
  CFRelease(imageDst);

  return 1;
}

static int _saveCI(CIImage* image, char* fileName, char* fileType) {
  CGRect extent = [image extent];
  size_t width = CGRectGetWidth(extent), height = CGRectGetHeight(extent);
  size_t bitsPerComponent = 8;
  size_t bytesPerRow = width * 4;

  CGColorSpaceRef cs =
    CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); // TODO
  CGContextRef cgContext = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, cs, kCGImageAlphaPremultipliedLast);
  CGColorSpaceRelease(cs);
  CIContext* ciContext =
    [CIContext contextWithCGContext:cgContext options:nil]; // TODO options?
  CGContextRelease(cgContext);

  CGImageRef cgImage = [ciContext createCGImage:image fromRect:[image extent]];
  int res = _saveCG(cgImage, fileName, fileType);
  CGImageRelease(cgImage);
  return res;
}

value cg_save(value image, value fileName, value fileType) {
  CAMLparam3(image, fileName, fileType);
  CAMLreturn(Val_bool(_saveCI(objc_unwrap(image),
                              String_val(fileName),
                              String_val(fileType))));
}
