//
//  IFErrorConstantExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 12.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConstantExpression.h"

@interface IFErrorConstantExpression : IFConstantExpression {

}

+ (id)errorConstantExpressionWithMessage:(NSString*)theMessage;

- (NSString*)message;

@end
