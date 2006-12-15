//
//  IFTreeLayoutStrategy.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutNode.h"
#import "IFTreeLayoutParameters.h"

@class IFNodesView;

@interface IFTreeLayoutStrategy : NSObject {
  IFNodesView* view; // not retained
  IFTreeLayoutParameters* layoutParams;
  NSMutableDictionary* layoutNodes;
  
  NSButtonCell* deleteButtonCell;
  NSButtonCell* foldButtonCell;
  NSButtonCell* menuButtonCell;
  NSBezierPath* sidePanePath;
}

- (id)initWithView:(IFNodesView*)theView parameters:(IFTreeLayoutParameters*)theLayoutParams;
- (IFTreeLayoutElement*)layoutTree:(IFTreeNode*)root;
- (IFTreeLayoutNode*)layoutNodeForTreeNode:(IFTreeNode*)theNode;
- (IFTreeLayoutElement*)layoutInputConnectorForTreeNode:(IFTreeNode*)node;
- (IFTreeLayoutElement*)layoutOutputConnectorForTreeNode:(IFTreeNode*)node tag:(NSString*)tag leftReach:(float)lReach rightReach:(float)rReach;
- (IFTreeLayoutElement*)layoutSidePaneForElement:(IFTreeLayoutSingle*)base;
- (IFTreeLayoutElement*)layoutSelectedNodes:(NSSet*)nodes
                                     cursor:(IFTreeNode*)cursorNode
                              forTreeLayout:(IFTreeLayoutElement*)rootLayout;
- (IFTreeLayoutElement*)layoutMarks:(NSArray*)marks forTreeLayout:(IFTreeLayoutElement*)rootLayout;

// side pane
- (NSBezierPath*)sidePanePath;
- (NSButtonCell*)deleteButtonCell;
- (NSButtonCell*)foldButtonCell;
- (NSButtonCell*)menuButtonCell;

@end
