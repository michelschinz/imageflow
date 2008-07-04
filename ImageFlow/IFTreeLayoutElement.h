//
//  IFTreeLayoutElement.h
//  ImageFlow
//
//  Created by Michel Schinz on 17.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"
#import "IFDocument.h"

typedef enum {
  IFTreeLayoutElementKindNode,
  IFTreeLayoutElementKindInputConnector,
  IFTreeLayoutElementKindOutputConnector
} IFTreeLayoutElementKind;

@class IFTreeLayoutSingle;
@class IFNodesView;
@interface IFTreeLayoutElement : NSObject {
  IFNodesView* containingView; // not retained
  NSPoint translation;
  NSRect bounds;
}

- (id)initWithContainingView:(IFNodesView*)theContainingView;

- (IFNodesView*)containingView;

@property NSRect bounds;
@property NSPoint translation;
- (void)translateBy:(NSPoint)thePoint;
@property(readonly) NSRect frame;

@property(readonly, assign) IFTreeNode* node;

- (void)activate;
- (void)activateWithMouseDown:(NSEvent*)event;
- (void)deactivate;
- (void)setNeedsDisplay;
- (void)drawForRect:(NSRect)rect;

- (NSImage*)dragImage;

- (NSSet*)leavesOfKind:(IFTreeLayoutElementKind)kind;

- (IFTreeLayoutSingle*)layoutElementForNode:(IFTreeNode*)node kind:(IFTreeLayoutElementKind)kind;
- (NSSet*)layoutElementsForNodes:(NSSet*)nodes kind:(IFTreeLayoutElementKind)kind;
- (IFTreeLayoutElement*)layoutElementAtPoint:(NSPoint)thePoint;
- (NSSet*)layoutElementsIntersectingRect:(NSRect)rect kind:(IFTreeLayoutElementKind)kind;

// protected
- (void)drawForLocalRect:(NSRect)localRect;
- (void)collectLayoutElementsForNodes:(NSSet*)nodes kind:(IFTreeLayoutElementKind)kind inSet:(NSMutableSet*)resultSet;

@end
