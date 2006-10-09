//
//  IFHistogramInspectorWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFHistogramInspectorWindowController.h"
#import "IFHistogramConstantExpression.h"
#import "IFExpressionEvaluatorCI.h"

@interface IFHistogramInspectorWindowController (Private)
- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
- (void)updateHistogram;
@end

@implementation IFHistogramInspectorWindowController

-(id)init;
{
  return [super initWithWindowNibName:@"IFHistogramView"];
}

- (void)dealloc;
{
  [probe removeObserver:self forKeyPath:@"mark.node.expression"];
  [super dealloc];
}

- (void)awakeFromNib;
{
  [[self window] setFrameAutosaveName:@"IFHistogramInspector"];
}

- (void)windowDidLoad;
{
  [super windowDidLoad];
  [probe addObserver:self forKeyPath:@"mark.node.expression" options:0 context:nil];
}

- (void)documentDidChange:(IFDocument*)newDocument;
{
  [super documentDidChange:newDocument];
  [self setEvaluator:[newDocument evaluator]];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert1([keyPath isEqualToString:@"mark.node.expression"] || [keyPath isEqualToString:@"workingColorSpace"],
            @"unexpected key path %@",keyPath);
  [self updateHistogram];
}

@end

@implementation IFHistogramInspectorWindowController (Private)

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
{
  if (newEvaluator == evaluator)
    return;
  
  if (evaluator != nil)
    [evaluator removeObserver:self forKeyPath:@"workingColorSpace"];
  evaluator = newEvaluator;
  if (evaluator != nil)
    [evaluator addObserver:self forKeyPath:@"workingColorSpace" options:0 context:nil];
  
  [self updateHistogram];
}

- (void)updateHistogram;
{
  IFTreeNode* node = [[probe mark] node];
  NSArray* histogramRGB = nil;
  if (node != nil && [evaluator hasValue:[node expression]]) {
    IFExpression* expr = [IFOperatorExpression histogramOf:[node expression]];
    IFHistogramConstantExpression* histogram = (IFHistogramConstantExpression*)[evaluator evaluateExpression:expr];
    histogramRGB = [histogram histogramValue];
  }
  [histogramView setHistogramsRGB:histogramRGB];
}

@end

