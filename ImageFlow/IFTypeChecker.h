//
//  IFTypeChecker.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  IFTreeModificationInsertNode,
  IFTreeModificationDeleteNode,
  IFTreeModificationReplaceGhost,
} IFTreeModification;

@interface IFTypeChecker : NSObject {

}

+ (IFTypeChecker*)sharedInstance;

- (BOOL)checkDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
- (NSArray*)configureDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
- (NSArray*)inferTypesForDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes parametersCount:(int)paramsCount;

@end
