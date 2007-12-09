//
//  IFTreeView.h
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFNodesView.h"
#import "IFDocument.h"
#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutSingle.h"
#import "IFTreeNode.h"
#import "IFTreeMark.h"
#import "IFTreeLayoutStrategy.h"
#import "IFTreeLayoutParameters.h"
#import "IFTreeCursorPair.h"

@interface IFTreeView : IFNodesView {
  IFTreeLayoutStrategy* layoutStrategy;

  NSArray* marks;
  IFTreeCursorPair* cursors;
  NSSet* unreachableNodes;
  NSMutableSet* selectedNodes;
  IFTreeNode* copiedNode;

  NSMutableArray* trackingRectTags;
  IFTreeLayoutElement* pointedElement;
  NSBezierPath* highlightingPath;
  NSDragOperation currentDragOperation;
  BOOL isCurrentDragLocal;
}

- (IFTreeLayoutStrategy*)layoutStrategy;

- (NSSize)idealSize;

- (IBAction)makeNodeAlias:(id)sender;
- (IBAction)toggleNodeFoldingState:(id)sender;

- (IFTreeCursorPair*)cursors;

- (IBAction)setBookmark:(id)sender;
- (IBAction)removeBookmark:(id)sender;
- (IBAction)goToBookmark:(id)sender;

@end
