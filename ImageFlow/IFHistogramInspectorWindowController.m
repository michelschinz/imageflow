//
//  IFHistogramInspectorWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 29.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFHistogramInspectorWindowController.h"
#import "IFHistogramConstantExpression.h"
#import "IFExpression.h"

@interface IFHistogramInspectorWindowController (Private)
- (void)updateHistogram;
@end

@implementation IFHistogramInspectorWindowController

-(id)init;
{
  return [super initWithWindowNibName:@"IFHistogramView"];
}

- (void)dealloc;
{
//TODO  [probe removeObserver:self forKeyPath:@"mark.node.expression"];
  [super dealloc];
}

- (void)awakeFromNib;
{
  [[self window] setFrameAutosaveName:@"IFHistogramInspector"];
}

- (void)windowDidLoad;
{
  [super windowDidLoad];
//TODO  [probe addObserver:self forKeyPath:@"mark.node.expression" options:0 context:nil];
}

- (void)documentDidChange:(IFDocument*)newDocument;
{
  [super documentDidChange:newDocument];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  NSAssert1([keyPath isEqualToString:@"mark.node.expression"] || [keyPath isEqualToString:@"workingColorSpace"],
            @"unexpected key path %@",keyPath);
  [self updateHistogram];
}

@end

@implementation IFHistogramInspectorWindowController (Private)

- (void)updateHistogram;
{
  IFTreeNode* node = nil; //TODO [[probe mark] node];
  NSArray* histogramRGB = nil;
  IFExpressionEvaluator* evaluator = [IFExpressionEvaluator sharedEvaluator];
  IFConstantExpression* evaluatedExpr = [evaluator evaluateExpression:[IFExpression histogramOf:[node expression]]];
  if (node != nil && ![evaluatedExpr isError]) {
    IFHistogramConstantExpression* histogram = (IFHistogramConstantExpression*)evaluatedExpr;
    histogramRGB = [histogram histogramValue];
  }
  [histogramView setHistogramsRGB:histogramRGB];
}

@end

