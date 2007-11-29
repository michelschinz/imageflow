//
//  IFFileSink.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSink.h"
#import "IFDocument.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFOperatorExpression.h"

@implementation IFFileSink

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFBasicType actionType]]] retain];
  }
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:[IFOperatorExpression expressionWithOperatorNamed:@"save" operands:nil]] retain];
  }
  return exprs;
}

- (NSString*)exporterKind;
{
  return @"file";
}

// TODO obsolete
- (void)exportImage:(IFImageConstantExpression*)imageExpr document:(IFDocument*)document;
{
  NSString* fileName = [settings valueForKey:@"fileName"];
  NSString* fileType = [settings valueForKey:@"fileType"];
  NSURL* url = [NSURL fileURLWithPath:fileName];
  
  CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)url,(CFStringRef)fileType,1,NULL);
  if (imageDestination != NULL) {
    CGImageRef image = [imageExpr imageValueCG];
    NSMutableDictionary* imageProperties = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithFloat:[document resolutionX]], kCGImagePropertyDPIWidth,
      [NSNumber numberWithFloat:[document resolutionY]], kCGImagePropertyDPIHeight,
      [settings valueForKey:@"quality"], kCGImageDestinationLossyCompressionQuality,
      [NSDictionary dictionaryWithObject:[settings valueForKey:@"TIFFCompression"]
                                  forKey:(id)kCGImagePropertyTIFFCompression], kCGImagePropertyTIFFDictionary,
      nil]; // TODO add other metadata
    CGImageDestinationAddImage(imageDestination,image,(CFDictionaryRef)imageProperties);
    CGImageDestinationFinalize(imageDestination);
    CGImageRelease(image);
    CFRelease(imageDestination);
  }
}

- (NSString*)label;
{
  return [NSString stringWithFormat:@"save %@",[[settings valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"save %@",[settings valueForKey:@"fileName"]];
}

@end
