//
//  IFTreeIdentifier.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTree.h"
#import "IFTreeNode.h"

@interface IFTreeIdentifier : NSObject {

}

+ (id)treeIdentifier;

- (NSDictionary*)identifyTree:(IFTree*)tree startingAt:(IFTreeNode*)root hints:(NSDictionary*)hints;

@end
