//
//  IFExpressionEvaluatorOCaml.h
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <caml/mlvalues.h>

#import "IFExpressionEvaluator.h"

@interface IFExpressionEvaluatorOCaml : IFExpressionEvaluator {
  value cache;
}

@end
