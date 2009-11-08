#import <assert.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/bigarray.h>

#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <QuartzCore/QuartzCore.h>

#import "IFFileExportConstantExpression.h"
#import "corefoundation.h"
#import "objc.h"

value export_action_create(value filePath, value image, value exportAreaA) {
  CAMLparam3(filePath, image, exportAreaA);

  NSString* filePathNS = [NSString stringWithUTF8String:String_val(filePath)];
  NSURL* fileURL = [NSURL fileURLWithPath:filePathNS];
  CIImage* imageCI = objc_unwrap(image);
  CGRect exportArea = CGRectMake(Double_field(exportAreaA, 0),
                                 Double_field(exportAreaA, 1),
                                 Double_field(exportAreaA, 2),
                                 Double_field(exportAreaA, 3));

  IFFileExportConstantExpression* exportAction =
    [IFExpression exportActionWithFileURL:fileURL
                  image:imageCI
                  exportArea:exportArea];

  CAMLreturn(objc_wrap(exportAction));
}
