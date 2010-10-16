#import <assert.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/bigarray.h>

#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <QuartzCore/QuartzCore.h>

#import "IFConstantExpression.h"
#import "corefoundation.h"
#import "objc.h"

value export_action_create(value URLString, value image, value exportAreaA) {
  CAMLparam3(URLString, image, exportAreaA);

  NSString* URLStringNS = [NSString stringWithUTF8String:String_val(URLString)];
  NSURL* URL = [NSURL URLWithString:URLStringNS];
  CIImage* imageCI = objc_unwrap(image);
  CGRect exportArea = CGRectMake(Double_field(exportAreaA, 0),
                                 Double_field(exportAreaA, 1),
                                 Double_field(exportAreaA, 2),
                                 Double_field(exportAreaA, 3));

  IFConstantExpression* exportAction =
    [IFConstantExpression exportActionWithFileURL:URL
                          image:imageCI
                          exportArea:exportArea];

  CAMLreturn(objc_wrap(exportAction));
}
