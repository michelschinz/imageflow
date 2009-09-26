//
//  IFVariableExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"

@interface IFVariableExpression : IFExpression {
  NSString* name;
}

- (id)initWithName:(NSString*)theName;

@property(readonly) NSString* name;

@end
