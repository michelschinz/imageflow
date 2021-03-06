//
//  IFTypeChecker.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.01.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFTypeChecker : NSObject {

}

+ (IFTypeChecker*)sharedInstance;

- (BOOL)checkDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;
- (NSArray*)configureDAG:(NSArray*)dag withPotentialTypes:(NSArray*)potentialTypes;

@end
