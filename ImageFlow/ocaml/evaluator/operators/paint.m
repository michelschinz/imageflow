#import <assert.h>

#import <caml/mlvalues.h>
#import <caml/memory.h>
#import <caml/bigarray.h>

#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <QuartzCore/QuartzCore.h>

#import "IFImage.h"
#import "corefoundation.h"
#import "objc.h"

#define PX(i) points[2*(i)]
#define PY(i) points[2*(i)+1]

IFImage* _cg_paint(IFImage* brush, float points[], int pointsLen) {
  assert(pointsLen >= 2 && pointsLen % 2 == 0);
  int pointsCount = pointsLen / 2;

  CIImage* brushImage = [brush imageCI];
  CGContextRef graphicContext =
    [[NSGraphicsContext currentContext] graphicsPort]; // TODO use correct one

  CGPoint brushOrigin = [brushImage extent].origin;
  CGSize brushSize = [brushImage extent].size;
  CGLayerRef brushLayer = CGLayerCreateWithContext(graphicContext,brushSize,NULL);
  CIContext* brushCIContext = [CIContext contextWithCGContext:CGLayerGetContext(brushLayer) options:[NSDictionary dictionary]]; // TODO color space
  [brushCIContext drawImage:brushImage atPoint:CGPointZero fromRect:[brushImage extent]];

  // Compute bounding rectangle (in image coordinates)
  CGRect boundingRect = CGRectMake(PX(0),PY(0),brushSize.width,brushSize.height);
  for (int i = 1; i < pointsCount; ++i)
    boundingRect = CGRectUnion(boundingRect,
                               CGRectMake(PX(i), PY(i),
                                          brushSize.width, brushSize.height));
  boundingRect = CGRectOffset(boundingRect,brushOrigin.x,brushOrigin.y);

  CGLayerRef strokeLayer = CGLayerCreateWithContext(graphicContext,boundingRect.size,NULL);
  CGContextTranslateCTM(CGLayerGetContext(strokeLayer),
                        -(CGRectGetMinX(boundingRect) - brushOrigin.x),
                        -(CGRectGetMinY(boundingRect) - brushOrigin.y));
  CGContextSetBlendMode(CGLayerGetContext(strokeLayer), kCGBlendModeDarken);

  float x = PX(0), y = PY(0);
  for (int i = 1; i < pointsCount; ++i) {
    float deltaX = PX(i) - x, deltaY = PY(i) - y;
    float delta = sqrt(deltaX*deltaX + deltaY*deltaY);
    int steps = (int)floor(delta / 3.0);
    const float dx = deltaX / (float)steps, dy = deltaY / (float)steps;
    while (steps-- > 0) {
      CGContextDrawLayerAtPoint(CGLayerGetContext(strokeLayer),CGPointMake(x,y),brushLayer);
      x += dx;
      y += dy;
    }
  }
  CGLayerRelease(brushLayer);

  IFImage* res = [IFImage imageWithCGLayer:strokeLayer origin:boundingRect.origin];
  CGLayerRelease(strokeLayer);
  return res;
}

value cg_paint(value brush, value points, value pointsLen) {
  CAMLparam3(brush, points, pointsLen);
  CAMLreturn(objc_wrap(_cg_paint(objc_unwrap(brush),
                                 Caml_ba_data_val(points),
                                 Caml_ba_array_val(points)->dim[0])));
}
