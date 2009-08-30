//
//  IFArrayPathElement.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFExpression.h"
#import "IFType.h"

@interface IFArrayPath : NSObject {
  unsigned index;
  IFArrayPath* next;
}

+ (IFArrayPath*)emptyPath;

+ (IFArrayPath*)leftmostPathForType:(IFType*)type;

+ (IFArrayPath*)pathElementWithIndex:(unsigned)theIndex next:(IFArrayPath*)theNext;
- (IFArrayPath*)initWithIndex:(unsigned)theIndex next:(IFArrayPath*)theNext;

@property(readonly) unsigned index;
@property(readonly) IFArrayPath* next;

- (IFArrayPath*)reversed;

- (IFExpression*)accessorExpressionFor:(IFExpression*)arrayExpression;

@end
