//
//  IFFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 22.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFOperatorExpression.h"
#import "IFImageConstantExpression.h"
#import "IFEnvironment.h"
#import "IFImageView.h"

@class IFTreeNode;

@interface IFFilter : NSObject {
  IFEnvironment* environment;
  int activeTypeIndex;
  IFExpression* expression;
  NSNib* settingsNib;
}

+ (id)filterWithName:(NSString*)filterName environment:(IFEnvironment*)theEnvironment;
- (id)initWithEnvironment:(IFEnvironment*)theEnvironment;

- (IFFilter*)clone;

- (NSString*)name;
- (IFEnvironment*)environment;

- (BOOL)isGhost;
- (NSArray*)potentialTypes;
- (NSArray*)potentialRawExpressions;
- (int)activeTypeIndex;
- (void)setActiveTypeIndex:(int)newIndex;
- (IFExpression*)expression;

- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;

- (NSString*)nameOfParentAtIndex:(int)index;
- (NSString*)label;
- (NSString*)toolTip;
- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view;

- (void)mouseDown:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (void)mouseDragged:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;
- (void)mouseUp:(NSEvent*)event inView:(IFImageView*)imageView viewFilterTransform:(NSAffineTransform*)viewFilterTransform;

- (NSArray*)variantNamesForViewing;
- (NSArray*)variantNamesForEditing;
- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;

- (NSAffineTransform*)transformForParentAtIndex:(int)index;

@end

