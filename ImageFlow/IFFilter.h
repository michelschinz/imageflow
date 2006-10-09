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

@class IFDocument;
@class IFTreeNode;

@protocol IFFilterDelegate
// Tree view support
- (NSString*)nameOfParentAtIndex:(int)index;  // mandatory if more than one parents, ignored otherwise
- (NSString*)labelWithEnvironment:(IFEnvironment*)env;  // optional
- (NSString*)toolTipWithEnvironment:(IFEnvironment*)env;  // optional

// Image view support
- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view; // optional
- (NSArray*)variantNamesForViewing; // optional (defaults to only one variant: the filter's output)
- (NSArray*)variantNamesForEditing; // optional (defaults to only one variant: the filter's output)
- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env; // mandatory, except for sources and sinks

- (void)mouseDown:(NSEvent*)event atPoint:(NSPoint)point withEnvironment:(IFEnvironment*)env; // optional
- (void)mouseDragged:(NSEvent*)event atPoint:(NSPoint)point withEnvironment:(IFEnvironment*)env; // optional
- (void)mouseUp:(NSEvent*)event atPoint:(NSPoint)point withEnvironment:(IFEnvironment*)env; // optional

// Export support (these methods must either be all present or all absent)
- (NSString*)exporterKind;
- (void)exportImage:(IFImageConstantExpression*)imageExpr environment:(IFEnvironment*)environment document:(IFDocument*)document;
@end

@interface IFFilter : NSObject {
  NSString* name;
  IFOperatorExpression* expression;
  NSRange parentsRange, childRange;
  NSString* settingsNibName;
  NSNib* settingsNib;
  
  NSObject<IFFilterDelegate>* delegate;
  unsigned int delegateCapabilities;
}

+ (IFFilter*)filterForName:(NSString*)name;

+ (id)filterWithName:(NSString*)theName
          expression:(IFExpression*)theExpression
        parentsArity:(NSRange)theParentsRange
          childArity:(NSRange)theChildRange
     settingsNibName:(NSString*)theSettingsNibName
            delegate:(NSObject<IFFilterDelegate>*)theDelegate;
- (id)initWithName:(NSString*)theName
        expression:(IFExpression*)theExpression
      parentsArity:(NSRange)theParentsRange
        childArity:(NSRange)theChildRange
   settingsNibName:(NSString*)theSettingsNibName
          delegate:(NSObject<IFFilterDelegate>*)theDelegate;

- (NSString*)name;
- (NSObject<IFFilterDelegate>*)delegate;

- (BOOL)isGhost;
- (BOOL)acceptsParents:(int)parentsCount;
- (BOOL)acceptsChildren:(int)childsCount;

- (BOOL)hasSettingsNib;
- (NSArray*)instantiateSettingsNibWithOwner:(NSObject*)owner;

- (NSString*)nameOfParentAtIndex:(int)index;
- (NSString*)labelWithEnvironment:(IFEnvironment*)environment;
- (NSString*)toolTipWithEnvironment:(IFEnvironment*)environment;
- (NSArray*)editingAnnotationsForNode:(IFTreeNode*)node view:(NSView*)view; // optional

- (NSArray*)variantNamesForViewing;
- (NSArray*)variantNamesForEditing;
- (IFExpression*)variantNamed:(NSString*)variantName ofExpression:(IFExpression*)originalExpression;

- (NSAffineTransform*)transformForParentAtIndex:(int)index withEnvironment:(IFEnvironment*)env;

- (NSString*)exporterKind;
- (void)exportImage:(IFImageConstantExpression*)imageExpr environment:(IFEnvironment*)environment document:(IFDocument*)document;

- (IFExpression*)expression;
- (IFExpression*)expressionWithEnvironment:(IFEnvironment*)environment;

@end
