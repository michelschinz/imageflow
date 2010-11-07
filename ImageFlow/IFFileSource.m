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
#import "IFFileData.h"

@interface IFFileSource ()
@property(readonly) NSURL* fileURL;
@property(readonly) BOOL storeImageInDocument;
@property(retain) IFImage* cachedImage;
@end

@implementation IFFileSource

- (id)initWithSettings:(IFEnvironment*)theSettings;
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

  if (cachedImage == nil) {
    if (self.storeImageInDocument)
      self.cachedImage = [IFImage imageWithData:[[settings valueForKey:@"fileData"] fileData]];
    else
      self.cachedImage = [IFImage imageWithContentsOfURL:self.fileURL];
  }
  return (cachedImage.imageCI == nil)
  ? [IFConstantExpression errorConstantExpressionWithMessage:@"unable to load file"]
  : [IFConstantExpression imageConstantExpressionWithIFImage:cachedImage];
}

- (NSString*)computeLabel;
{
  return [NSString stringWithFormat:@"%C%@", 0x2193, [self.fileURL lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"import %@", [self.fileURL path]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
  if ([keyPath isEqualToString:@"storeImageInDocument"]) {
    if (self.storeImageInDocument) {
      cachedImage = nil;
      [settings setValue:[IFFileData fileDataWithURL:self.fileURL] forKey:@"fileData"];
    } else {
      [settings removeValueForKey:@"fileData"];
    }
  } else if ([keyPath isEqualToString:@"fileURL"]) {
    cachedImage = nil;
    if (self.storeImageInDocument)
      [settings setValue:[IFFileData fileDataWithURL:self.fileURL] forKey:@"fileData"];
  }
  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

// MARK: -
// MARK: PRIVATE

- (NSURL*)fileURL;
{
  return [settings valueForKey:@"fileURL"];
}

- (BOOL)storeImageInDocument;
{
  return [[settings valueForKey:@"storeImageInDocument"] boolValue];
}

@synthesize cachedImage;

@end
