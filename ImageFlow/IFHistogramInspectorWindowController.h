//
//  IFHistogramInspectorWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFInspectorWindowController.h"
#import "IFHistogramView.h"

@interface IFHistogramInspectorWindowController : IFInspectorWindowController {
  IBOutlet IFHistogramView* histogramView;
  IBOutlet NSProgressIndicator* progressIndicator;
  IFExpressionEvaluator* evaluator;
}

@end
