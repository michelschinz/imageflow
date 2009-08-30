//
//  IFExpressionContentsLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.08.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConstantExpression.h"
#import "IFArrayPath.h"
#import "IFLayoutParameters.h"
#import "IFVariable.h"

@interface IFExpressionContentsLayer : CALayer {
  IFLayoutParameters* layoutParameters;
  IFVariable* canvasBoundsVar;
  
  IFConstantExpression* expression;
  IFArrayPath* reversedPath;
}

- (IFExpressionContentsLayer*)initWithLayoutParameters:(IFLayoutParameters*)theLayoutParameters canvasBounds:(IFVariable*)theCanvasBoundsVar;

@property(retain) IFConstantExpression* expression;
@property(retain) IFArrayPath* reversedPath;

@end
