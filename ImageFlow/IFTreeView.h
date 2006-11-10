//
//  IFTreeView.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutSingle.h"
#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFGrabableViewMixin.h"
#import "IFTreeLayoutStrategy.h"
#import "IFTreeLayoutParameters.h"

extern NSString* IFMarkPboardType;

@interface IFTreeView : NSControl {
  IFGrabableViewMixin* grabableViewMixin;
  IFTreeLayoutStrategy* layoutStrategy;
  IFTreeLayoutParameters* layoutParameters;

  IFDocument* document;
  NSMutableSet* selectedNodes;
  IFTreeNode* copiedNode;

  IFTreeNode* viewLockedNode;
  NSSet* unreachableNodes;
  
  unsigned int upToDateLayers;
  NSMutableArray* layoutLayers;
  NSMutableArray* trackingRectTags;
  IFTreeLayoutElement* pointedElement;
  NSBezierPath* highlightingPath;
}

- (void)setDocument:(IFDocument*)document;
- (IFDocument*)document;

- (IFTreeLayoutStrategy*)layoutStrategy;
- (IFTreeLayoutParameters*)layoutParameters;

- (NSSize)idealSize;

- (void)invalidateLayout;

- (IBAction)makeNodeAlias:(id)sender;
- (IBAction)toggleNodeFoldingState:(id)sender;

- (IBAction)lockViewOnCurrentNode:(id)sender;
- (void)setViewLockedNode:(IFTreeNode*)newViewLockedNode;
- (IFTreeNode*)viewLockedNode;
- (NSSet*)unreachableNodes;

- (IBAction)setBookmark:(id)sender;
- (IBAction)removeBookmark:(id)sender;
- (IBAction)goToBookmark:(id)sender;

@end
