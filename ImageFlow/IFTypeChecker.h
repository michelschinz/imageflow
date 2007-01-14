//
//  IFTypeChecker.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeNode.h"

@interface IFTypeChecker : NSObject {

}

+ (IFTypeChecker*)sharedInstance;

- (NSArray*)inferTypeForTree:(IFTreeNode*)root;

@end
