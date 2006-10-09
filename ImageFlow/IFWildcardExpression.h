//
//  IFWildcardExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IFExpression.h"

@interface IFWildcardExpression : IFExpression {
  NSString* name;
}

+ (id)wildcardWithName:(NSString*)theName;
- (id)initWithName:(NSString*)theName;

- (NSString*)name;

@end
