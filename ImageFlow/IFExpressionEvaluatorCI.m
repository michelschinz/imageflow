//
//  IFExpressionEvaluatorCI.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFExpressionEvaluatorCI.h"
#import "IFOperatorExpression.h"
#import "IFHistogramConstantExpressionCI.h"
#import "IFColorProfile.h"
#import "IFUtilities.h"

#import "IFThresholdCIFilter.h"
#import "IFMaskCIFilter.h"
#import "IFSetAlphaCIFilter.h"
#import "IFSingleColorCIFilter.h"
#import "IFEmptyCIFilter.h"

#import <QuartzCore/CIFilter.h>

@interface IFExpressionEvaluatorCI (Private)
@end

@implementation IFExpressionEvaluatorCI

- (id)init;
{
  if (![super init])
    return nil;

  [self registerSelector:@selector(evaluateLoad:) forOperatorNamed:@"load"];
  [self registerSelector:@selector(evaluateSink:) forOperatorNamed:@"save-file"];
  [self registerSelector:@selector(evaluateSink:) forOperatorNamed:@"print"];
  [self registerSelector:@selector(evaluateConstantColor:) forOperatorNamed:@"constant-color"];

  [self registerSelector:@selector(evaluateExtent:) forOperatorNamed:@"extent"];
  [self registerSelector:@selector(evaluateFileExtent:) forOperatorNamed:@"file-extent"];
  [self registerSelector:@selector(evaluateResample:) forOperatorNamed:@"resample"];
  [self registerSelector:@selector(evaluateInvert:) forOperatorNamed:@"invert"];
  [self registerSelector:@selector(evaluateCrop:) forOperatorNamed:@"crop"];
  [self registerSelector:@selector(evaluateCropImageWithMask:) forOperatorNamed:@"crop-overlay"];
  [self registerSelector:@selector(evaluateGaussianBlur:) forOperatorNamed:@"gaussian-blur"];
  [self registerSelector:@selector(evaluateBlend:) forOperatorNamed:@"blend"];
  [self registerSelector:@selector(evaluateMask:) forOperatorNamed:@"mask"];
  [self registerSelector:@selector(evaluateQuickMask:) forOperatorNamed:@"quick-mask"];
  [self registerSelector:@selector(evaluateThreshold:) forOperatorNamed:@"threshold"];
  [self registerSelector:@selector(evaluateTranslate:) forOperatorNamed:@"translate"];
  [self registerSelector:@selector(evaluateSetAlpha:) forOperatorNamed:@"opacity"];
  [self registerSelector:@selector(evaluateSingleColor:) forOperatorNamed:@"single-color"];
  [self registerSelector:@selector(evaluateEmpty:) forOperatorNamed:@"empty"];
  [self registerSelector:@selector(evaluateBrush:) forOperatorNamed:@"brush"];
  [self registerSelector:@selector(evaluatePaint:) forOperatorNamed:@"paint"];
  [self registerSelector:@selector(evaluateColorControls:) forOperatorNamed:@"color-controls"];

  [self registerSelector:@selector(evaluateHistogramRGB:) forOperatorNamed:@"histogram-rgb"];

  [self registerSelector:@selector(evaluateUnsharpMask:) forOperatorNamed:@"unsharp-mask"];

  return self;
}

@end

@implementation IFExpressionEvaluatorCI (Private)

#define CHECK_OPERANDS(o,n) NSAssert3([(o) count] == (n), @"%@: incorrect number of operands (got %d, expected %d)",NSStringFromSelector(_cmd),[(o) count],(n));

- (IFConstantExpression*)evaluateExtent:(NSArray*)operands;
{
  // Rect extent(image: Image)
  CHECK_OPERANDS(operands, 1);
  CIImage* image = [(IFImageConstantExpression*)[operands objectAtIndex:0] imageValueCI];
  return [IFConstantExpression expressionWithRectCG:[image extent]];
}

- (IFConstantExpression*)evaluateFileExtent:(NSArray*)operands;
{
  // Rect extent(fileName: String)
  CHECK_OPERANDS(operands, 1);
  NSURL* url = [NSURL fileURLWithPath:[(IFConstantExpression*)[operands objectAtIndex:0] stringValue]];
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, (CFDictionaryRef)[NSDictionary dictionary]);
  if (imageSource == NULL)
    return [IFConstantExpression expressionWithRectNS:NSZeroRect];

  NSDictionary* properties = [(NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource,0,(CFDictionaryRef)[NSDictionary dictionary]) autorelease];
  CFRelease(imageSource);
  float width = [(NSNumber*)[properties objectForKey:(id)kCGImagePropertyPixelWidth] floatValue];
  float height = [(NSNumber*)[properties objectForKey:(id)kCGImagePropertyPixelHeight] floatValue];
  return [IFConstantExpression expressionWithRectNS:NSMakeRect(0,0,width,height)];
}

- (IFConstantExpression*)evaluateLoad:(NSArray*)operands;
{
  // Image load(fileName: String,
  //            useEmbeddedProfile: Boolean,
  //            defaultRGBProfileFileName: String,
  //            defaultGrayProfileFileName: String,
  //            defaultCMYKProfileFileName: String,
  //            useEmbeddedResolution: Boolean,
  //            useDocumentResolutionAsDefault: Boolean,
  //            defaultResolutionX: Number,
  //            defaultResolutionY: Number)
  CHECK_OPERANDS(operands, 9);
  NSString* fileName = [(IFConstantExpression*)[operands objectAtIndex:0] stringValue];
  if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    return [IFExpressionEvaluator invalidValue];

  BOOL useEmbeddedProfile = [(IFConstantExpression*)[operands objectAtIndex:1] boolValue];
  NSArray* defaultProfileFileNames = [NSArray arrayWithObjects:
    [(IFConstantExpression*)[operands objectAtIndex:2] stringValue],
    [(IFConstantExpression*)[operands objectAtIndex:3] stringValue],
    [(IFConstantExpression*)[operands objectAtIndex:4] stringValue],
    nil];
  BOOL useEmbeddedResolution = [(IFConstantExpression*)[operands objectAtIndex:5] boolValue];
  BOOL useDocumentResolutionAsDefault = [(IFConstantExpression*)[operands objectAtIndex:6] boolValue];
  float defaultResolutionX = [(IFConstantExpression*)[operands objectAtIndex:7] floatValue];
  float defaultResolutionY = [(IFConstantExpression*)[operands objectAtIndex:8] floatValue];

  NSURL* url = [NSURL fileURLWithPath:fileName];
  CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)url, (CFDictionaryRef)[NSDictionary dictionary]);
  NSDictionary* properties = [(NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSource,0,(CFDictionaryRef)[NSDictionary dictionary]) autorelease];

  // Handle profile
  NSArray* profileIndices = [NSArray arrayWithObjects: (id)kCGImagePropertyColorModelRGB, (id)kCGImagePropertyColorModelGray, (id)kCGImagePropertyColorModelCMYK, nil];
  int profileIndex = [profileIndices indexOfObject:[properties objectForKey:(id)kCGImagePropertyColorModel]];
  BOOL hasEmbeddedProfile = ([properties objectForKey:(id)kCGImagePropertyProfileName] != nil);
  CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)[NSDictionary dictionary]);
  CGImageRef imageWithNewProfile = (hasEmbeddedProfile && useEmbeddedProfile)
    ? CGImageRetain(image)
    : CGImageCreateCopyWithColorSpace(image, [[IFColorProfile profileWithPath:[defaultProfileFileNames objectAtIndex:profileIndex]] colorspace]);
  CIImage* ciImage = [CIImage imageWithCGImage:imageWithNewProfile];

  // Handle resolution
  BOOL hasEmbeddedResolution = ([properties objectForKey:(id)kCGImagePropertyDPIWidth] != nil);
  float finalResolutionX, finalResolutionY;
  if (hasEmbeddedResolution && useEmbeddedResolution) {
    finalResolutionX = [[properties objectForKey:(id)kCGImagePropertyDPIWidth] floatValue];
    finalResolutionY = [[properties objectForKey:(id)kCGImagePropertyDPIHeight] floatValue];
  } else if (useDocumentResolutionAsDefault) {
    finalResolutionX = resolutionX;
    finalResolutionY = resolutionY;
  } else {
    finalResolutionX = defaultResolutionX;
    finalResolutionY = defaultResolutionY;
  }
  const float epsilon = 0.001;
  float scalingX = resolutionX / finalResolutionX;
  float scalingY = resolutionY / finalResolutionY;
  if (fabs(scalingX - 1) <= epsilon)
    scalingX = 1;
  if (fabs(scalingY - 1) <= epsilon)
    scalingY = 1;
  if (scalingX != 1 || scalingY != 1) {
    CGAffineTransform scaling = CGAffineTransformMakeScale(scalingX,scalingY);
    ciImage = [ciImage imageByApplyingTransform:scaling];
  }

  CGImageRelease(imageWithNewProfile);
  CGImageRelease(image);
  if (imageSource != NULL)
    CFRelease(imageSource);
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:ciImage];
}

- (IFConstantExpression*)evaluateSink:(NSArray*)operands;
{
  return [IFExpressionEvaluator invalidValue];
}

- (IFConstantExpression*)evaluateConstantColor:(NSArray*)operands;
{
  // Image constant-color(color: Color)
  CHECK_OPERANDS(operands, 1);
  CIFilter* generator = [CIFilter filterWithName:@"CIConstantColorGenerator" keysAndValues:
    @"inputColor", [[operands objectAtIndex:0] colorValueCI],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[generator valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateResample:(NSArray*)operands;
{
  // Image resample(image: Image, scale: Float)
  CHECK_OPERANDS(operands, 2);
  CIImage* image = [[operands objectAtIndex:0] imageValueCI];
  float scale = [[operands objectAtIndex:1] floatValue];
  CIImage* resampledImage = [image imageByApplyingTransform:CGAffineTransformMakeScale(scale,scale)];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:resampledImage];
}

- (IFConstantExpression*)evaluateInvert:(NSArray*)operands;
{
  // Image invert(image: Image)
  CHECK_OPERANDS(operands, 1);
  CIFilter* filter = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateCrop:(NSArray*)operands;
{
  // Image crop(image: Image, rect: Rect)
  CHECK_OPERANDS(operands, 2);
  NSRect r = [[operands objectAtIndex:1] rectValueNS];
  CIFilter* filter = [CIFilter filterWithName:@"CICrop" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputRectangle",[CIVector vectorWithX:NSMinX(r) Y:NSMinY(r) Z:NSWidth(r) W:NSHeight(r)],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateCropImageWithMask:(NSArray*)operands;
{
  // Image crop-overlay(image: Image, rect: Rect)
  CHECK_OPERANDS(operands, 2);
  NSRect r = [[operands objectAtIndex:1] rectValueNS];
  CIFilter* filter = [CIFilter filterWithName:@"IFCropOverlay" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputRectangle",[CIVector vectorWithX:NSMinX(r) Y:NSMinY(r) Z:NSWidth(r) W:NSHeight(r)],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateGaussianBlur:(NSArray*)operands;
{
  // Image gaussian-blur(image: Image, radius: float)
  CHECK_OPERANDS(operands, 2);
  CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputRadius",[NSNumber numberWithFloat:[[operands objectAtIndex:1] floatValue]],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateBlend:(NSArray*)operands;
{
  // Image blend(background: Image, foreground: Image, mode: String)
  CHECK_OPERANDS(operands, 3);

  static NSDictionary* modeToFilter = nil;
  if (modeToFilter == nil)
    modeToFilter = [[NSDictionary dictionaryWithObjectsAndKeys:
      @"CISourceOverCompositing", @"over",
      @"CIColorBurnBlendMode", @"color burn",
      @"CIColorDodgeBlendMode", @"color dodge",
      @"CIDarkenBlendMode", @"darken",
      @"CILightenBlendMode", @"lighten",
      @"CIDifferenceBlendMode", @"difference",
      @"CIExclusionBlendMode", @"exclusion",
      @"CIHardLightBlendMode", @"hard light",
      @"CISoftLightBlendMode", @"soft light",
      @"CIHueBlendMode", @"hue",
      @"CISaturationBlendMode", @"saturation",
      @"CIColorBlendMode", @"color",
      @"CILuminosityBlendMode", @"luminosity",
      @"CIMultiplyBlendMode", @"multiply",
      @"CIOverlayBlendMode", @"overlay",
      @"CIScreenBlendMode", @"screen",
      nil] retain];

  CIFilter* filter = [CIFilter filterWithName:[modeToFilter objectForKey:[[operands objectAtIndex:2] stringValue]] keysAndValues:
    @"inputBackgroundImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputImage", [[operands objectAtIndex:1] imageValueCI],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateMask:(NSArray*)operands;
{
  // Image mask(image: Image, mask: Image, channel: Integer)
  CHECK_OPERANDS(operands, 3);
  [IFMaskCIFilter class];

  CIFilter* filter = [CIFilter filterWithName:@"IFMask" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputMaskImage", [[operands objectAtIndex:1] imageValueCI],
    @"inputMaskChannel", [NSNumber numberWithInt:[[operands objectAtIndex:2] intValue]],
    @"inputMode", [NSNumber numberWithInt:0],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateQuickMask:(NSArray*)operands;
{
  // Image quick-mask(image: Image, mask: Image, channel: Integer)
  CHECK_OPERANDS(operands, 3);
  [IFMaskCIFilter class];

  CIFilter* filter = [CIFilter filterWithName:@"IFMask" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputMaskImage", [[operands objectAtIndex:1] imageValueCI],
    @"inputMaskChannel", [NSNumber numberWithInt:[[operands objectAtIndex:2] intValue]],
    @"inputMode", [NSNumber numberWithInt:1],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateThreshold:(NSArray*)operands;
{
  // Image threshold(image: Image, threshold: float)
  CHECK_OPERANDS(operands, 2);
  [IFThresholdCIFilter class];
  CIFilter* filter = [CIFilter filterWithName:@"IFThreshold" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputThreshold",[NSNumber numberWithFloat:[[operands objectAtIndex:1] floatValue]],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateTranslate:(NSArray*)operands;
{
  // Image translate(image: Image, translation: Point)
  CHECK_OPERANDS(operands, 2);
  NSPoint tr = [[operands objectAtIndex:1] pointValueNS];
  CGAffineTransform translation = CGAffineTransformMakeTranslation(tr.x,tr.y);
  CIImage* translatedImage = [[[operands objectAtIndex:0] imageValueCI] imageByApplyingTransform:translation];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:translatedImage];
}

- (IFConstantExpression*)evaluateSetAlpha:(NSArray*)operands;
{
  // Image opacity(image: Image, alpha: float)
  CHECK_OPERANDS(operands, 2);
  [IFSetAlphaCIFilter class];
  CIFilter* filter = [CIFilter filterWithName:@"IFSetAlpha" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputAlpha",[NSNumber numberWithFloat:[[operands objectAtIndex:1] floatValue]],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateSingleColor:(NSArray*)operands;
{
  // Image single-color(image:Image, color: Color)
  CHECK_OPERANDS(operands, 2);
  [IFSingleColorCIFilter class];
  CIFilter* filter = [CIFilter filterWithName:@"IFSingleColor" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputColor", [[operands objectAtIndex:1] colorValueCI],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateBrush:(NSArray*)operands;
{
  // Image brush(style: String, color: Color, size: float)
  CHECK_OPERANDS(operands, 3);
  CIFilter* filter = [CIFilter filterWithName:@"CIRadialGradient" keysAndValues:
    @"inputCenter", [CIVector vectorWithX:0 Y:0],
    @"inputRadius0",[NSNumber numberWithFloat:0],
    @"inputRadius1",[NSNumber numberWithFloat:[[operands objectAtIndex:2] floatValue]],
    @"inputColor0",[CIColor colorWithRed:0 green:0 blue:0 alpha:1],
    @"inputColor1",[CIColor colorWithRed:0 green:0 blue:0 alpha:0],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateEmpty:(NSArray*)operands;
{
  // Image empty()
  CHECK_OPERANDS(operands, 0);

  static IFImageConstantExpression* emptyExpr = nil;
  if (emptyExpr == nil) {
    CIFilter* emptyGenerator = [CIFilter filterWithName:@"IFEmpty"];
    emptyExpr = [[IFImageConstantExpression imageConstantExpressionWithCIImage:[emptyGenerator valueForKey:@"outputImage"]] retain];
  }
  return emptyExpr;
}

- (IFConstantExpression*)evaluatePaint:(NSArray*)operands;
{
  // Image paint(brush: Image, points: List[Point])
  CHECK_OPERANDS(operands, 2);
  NSArray* points = [[operands objectAtIndex:1] arrayValue];
  CIImage* brushImage = [[operands objectAtIndex:0] imageValueCI];

  if ([points count] == 0)
    return [self evaluateEmpty:[NSArray array]];

  if ([points count] == 1) {
    NSPoint p = [[points objectAtIndex:0] pointValueNS];
    return [IFImageConstantExpression imageConstantExpressionWithCIImage:[brushImage imageByApplyingTransform:CGAffineTransformMakeTranslation(p.x,p.y)]];
  }

  CGContextRef graphicContext = [[NSGraphicsContext currentContext] graphicsPort]; // TODO use correct one

  CGPoint brushOrigin = [brushImage extent].origin;
  CGSize brushSize = [brushImage extent].size;
  CGLayerRef brushLayer = CGLayerCreateWithContext(graphicContext,brushSize,NULL);
  CIContext* brushCIContext = [CIContext contextWithCGContext:CGLayerGetContext(brushLayer) options:[NSDictionary dictionary]]; // TODO color space
  [brushCIContext drawImage:brushImage atPoint:CGPointZero fromRect:[brushImage extent]];

  // Compute bounding rectangle (in image coordinates)
  NSEnumerator* pointsEnum = [points objectEnumerator];
  IFConstantExpression* point = [pointsEnum nextObject];
  CGRect boundingRect = CGRectMake([point pointValueNS].x,[point pointValueNS].y,brushSize.width,brushSize.height);
  while (point = [pointsEnum nextObject])
    boundingRect = CGRectUnion(boundingRect,CGRectMake([point pointValueNS].x,[point pointValueNS].y,brushSize.width,brushSize.height));
  boundingRect = CGRectOffset(boundingRect,brushOrigin.x,brushOrigin.y);

  CGLayerRef strokeLayer = CGLayerCreateWithContext(graphicContext,boundingRect.size,NULL);
  CGContextTranslateCTM(CGLayerGetContext(strokeLayer),
                        -(CGRectGetMinX(boundingRect) - brushOrigin.x),
                        -(CGRectGetMinY(boundingRect) - brushOrigin.y));

  pointsEnum = [points objectEnumerator];
  point = [pointsEnum nextObject];
  float x = [point pointValueNS].x, y = [point pointValueNS].y;
  while (point = [pointsEnum nextObject]) {
    float deltaX = [point pointValueNS].x - x, deltaY = [point pointValueNS].y - y;
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

  CGAffineTransform translation = CGAffineTransformMakeTranslation(CGRectGetMinX(boundingRect),CGRectGetMinY(boundingRect));
  CIImage* strokeImage = [[CIImage imageWithCGLayer:strokeLayer] imageByApplyingTransform:translation];
  CGLayerRelease(strokeLayer);
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:strokeImage];
}

- (IFConstantExpression*)evaluateColorControls:(NSArray*)operands;
{
  // Image color-controls(image: Image, contrast: Float, brightness: Float, saturation: Float)
  CHECK_OPERANDS(operands, 4);
  CIFilter* filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
    @"inputSaturation",[NSNumber numberWithFloat:[[operands objectAtIndex:3] floatValue]],
    @"inputBrightness",[NSNumber numberWithFloat:[[operands objectAtIndex:2] floatValue]],
    @"inputContrast",[NSNumber numberWithFloat:[[operands objectAtIndex:1] floatValue]],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

- (IFConstantExpression*)evaluateHistogramRGB:(NSArray*)operands;
{
  // Histogram histogram-rgb(image: Image)
  CHECK_OPERANDS(operands, 1);
  return [IFHistogramConstantExpressionCI histogramWithImageExpression:[operands objectAtIndex:0] colorSpace:workingColorSpace];
}

- (IFConstantExpression*)evaluateUnsharpMask:(NSArray*)operands;
{
  // Image unsharp-mask(image: Image, intensity: float, radius: float)
  CHECK_OPERANDS(operands, 3);
  CIFilter* filter = [CIFilter filterWithName:@"CIUnsharpMask" keysAndValues:
    @"inputImage", [[operands objectAtIndex:0] imageValueCI],
	@"inputIntensity", [NSNumber numberWithFloat:[[operands objectAtIndex:1] floatValue]],
	@"inputRadius", [NSNumber numberWithFloat:[[operands objectAtIndex:2] floatValue]],
    nil];
  return [IFImageConstantExpression imageConstantExpressionWithCIImage:[filter valueForKey:@"outputImage"]];
}

@end
