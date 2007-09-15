//
//  IFTypeChecker.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

typedef enum {
  IFTreeModificationInsertNode,
  IFTreeModificationDeleteNode,
  IFTreeModificationReplaceGhost,
} IFTreeModification;

@interface IFTypeChecker : NSObject {

}

+ (IFTypeChecker*)sharedInstance;

- (NSArray*)inferTypeForTree:(IFTreeNode*)root;

- (NSArray*)dagFromTopologicallySortedNodes:(NSArray*)sortedNode;
- (BOOL)checkDAG:(NSArray*)adjMatrix withPotentialTypes:(NSArray*)potentialTypes;

@end
