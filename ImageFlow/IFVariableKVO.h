//
//  IFVariableKVO.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFVariable.h"

@interface IFVariableKVO : IFVariable {
  NSObject* object;
  NSString* key;
}

+ (id)variableWithKVOCompliantObject:(NSObject*)theObject key:(NSString*)theKey;
- (id)initWithKVOCompliantObject:(NSObject*)theObject key:(NSString*)theKey;

@end
