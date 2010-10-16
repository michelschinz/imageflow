//
//  IFFileSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSource.h"

#import "IFEnvironment.h"
#import "IFType.h"
#import "IFExpression.h"

@interface IFFileSource ()
@property(readonly) NSURL* fileURL;
@property(retain) IFImage* cachedImage;
@end

static void* IFFileURLChangedContext = nil;

@implementation IFFileSource

- (id)initWithSettings:(IFEnvironment *)theSettings;
{
  if (![super initWithSettings:theSettings])
    return nil;
  cachedImage = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(cachedImage);
}

- (NSArray*)computePotentialTypesForArity:(unsigned)arity;
{
  if (arity == 0)
    return [NSArray arrayWithObject:[IFType imageRGBAType]];
  else
    return [NSArray array];
}

- (IFExpression*)rawExpressionForArity:(unsigned)arity typeIndex:(unsigned)typeIndex;
{
  NSAssert(arity == 0 && typeIndex == 0, @"invalid arity or type index");
  if (cachedImage == nil || ![cachedImage.fileURL isEqual:self.fileURL])
    self.cachedImage = [IFImage imageWithContentsOfURL:self.fileURL];
  return (cachedImage.imageCI == nil) ? [IFConstantExpression errorConstantExpressionWithMessage:@"unable to load file"] : [IFConstantExpression imageConstantExpressionWithIFImage:cachedImage];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"%C%@", 0x2193, [self.fileURL lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"import %@", [self.fileURL path]];
}

// MARK: NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder;
{
  if (![super initWithCoder:decoder])
    return nil;
  self.cachedImage = [decoder decodeObjectForKey:@"cachedImage"];
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
  [super encodeWithCoder:encoder];
  [encoder encodeObject:cachedImage forKey:@"cachedImage"];
}

// TODO: encode image data to XML file if saveImageData is true

// MARK: -
// MARK: PRIVATE

- (NSURL*)fileURL;
{
  return [settings valueForKey:@"fileURL"];
}

@synthesize cachedImage;

@end
