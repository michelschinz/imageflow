//
//  IFFileSinkDelegate.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSinkDelegate.h"
#import "IFDocument.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"

@implementation IFFileSinkDelegate

- (NSArray*)potentialTypesWithEnvironment:(IFEnvironment*)env;
{
  static NSArray* types = nil;
  if (types == nil) {
    types = [[NSArray arrayWithObject:
      [IFFunType funTypeWithArgumentTypes:[NSArray arrayWithObject:[IFImageType imageRGBAType]]
                               returnType:[IFBasicType actionType]]] retain];
  }
  return types;
}

- (NSString*)exporterKind;
{
  return @"file";
}

- (void)exportImage:(IFImageConstantExpression*)imageExpr environment:(IFEnvironment*)environment document:(IFDocument*)document;
{
  NSString* fileName = [environment valueForKey:@"fileName"];
  NSString* fileType = [environment valueForKey:@"fileType"];
  NSURL* url = [NSURL fileURLWithPath:fileName];
  
  CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((CFURLRef)url,(CFStringRef)fileType,1,NULL);
  if (imageDestination != NULL) {
    CGImageRef image = [imageExpr imageValueCG];
    NSMutableDictionary* imageProperties = [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithFloat:[document resolutionX]], kCGImagePropertyDPIWidth,
      [NSNumber numberWithFloat:[document resolutionY]], kCGImagePropertyDPIHeight,
      [environment valueForKey:@"quality"], kCGImageDestinationLossyCompressionQuality,
      [NSDictionary dictionaryWithObject:[environment valueForKey:@"TIFFCompression"]
                                  forKey:(id)kCGImagePropertyTIFFCompression], kCGImagePropertyTIFFDictionary,
      nil]; // TODO add other metadata
    CGImageDestinationAddImage(imageDestination,image,(CFDictionaryRef)imageProperties);
    CGImageDestinationFinalize(imageDestination);
    CGImageRelease(image);
    CFRelease(imageDestination);
  }
}

- (NSString*)labelWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"save %@",[[env valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;
{
  return [NSString stringWithFormat:@"save %@",[env valueForKey:@"fileName"]];
}

@end
