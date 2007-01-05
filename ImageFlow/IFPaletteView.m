//
//  IFPaletteView.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFPaletteView.h"
#import "IFTreeLayoutNode.h"
#import "IFTreeLayoutComposite.h"
#import "IFDocumentTemplateManager.h"
#import "IFVariableExpression.h"

@interface IFPaletteView (Private)
+ (NSArray*)surrogateFilters;
+ (NSArray*)templateNodesWithSurrogateParentFilters:(NSArray*)surrogateFilters;
- (void)updateBounds;
- (IFTreeLayoutElement*)layoutForNode:(IFTreeNode*)node;
- (IFTreeLayoutElement*)layoutForNodes:(NSArray*)allNodes;
@end

@implementation IFPaletteView

enum IFLayoutLayer {
  IFLayoutLayerNodes,
  IFLayoutLayer
};

- (id)initWithFrame:(NSRect)frame;
{
  if (![super initWithFrame:frame layersCount:1])
    return nil;
  surrogateParentFilters = [[[self class] surrogateFilters] retain];
  templateNodes = [[[self class] templateNodesWithSurrogateParentFilters:surrogateParentFilters] retain];
  [self updateBounds];
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(templateNodes);
  OBJC_RELEASE(surrogateParentFilters);
  [super dealloc];
}

- (IFTreeLayoutParameters*)layoutParameters;
{
  return layoutParameters;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize;
{
  [self updateBounds];
  [self setNeedsDisplay:YES];
}

- (IFTreeLayoutElement*)layoutForLayer:(int)layer;
{
  switch (layer) {
    case IFLayoutLayerNodes:
      return [self layoutForNodes:templateNodes];
    default:
      NSAssert(NO, @"unexpected layer");
      return nil;
  }
}

@end

@implementation IFPaletteView (Private)

+ (NSArray*)surrogateFilters;
{
  NSMutableArray* surrogates = [NSMutableArray array];
  for (int i = 0; /*no condition*/; ++i) {
    NSString* fileName = [NSString stringWithFormat:@"surrogate_parent_%d",(i+1)];
    NSString* maybeSurrogatePath = [[NSBundle mainBundle] pathForImageResource:fileName];
    if (maybeSurrogatePath == nil)
      break;
    
    IFFilter* filter = [IFFilter filterWithName:@"<surrogate>"
                                     expression:[IFVariableExpression expressionWithName:@"expression"]
                                settingsNibName:nil
                                       delegate:nil];
    IFEnvironment* env = [IFEnvironment environment];
    [env setValue:[IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"load"]
                                                      operands:[NSArray arrayWithObjects:
                                                        [IFConstantExpression expressionWithString:maybeSurrogatePath],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        [IFConstantExpression expressionWithInt:0],
                                                        nil]]
           forKey:@"expression"];
    [surrogates addObject:[IFConfiguredFilter configuredFilterWithFilter:filter environment:env]];
  }
  return surrogates;
}

+ (NSArray*)templateNodesWithSurrogateParentFilters:(NSArray*)surrogateFilters;
{
  NSMutableArray* nodes = [NSMutableArray array];
  NSArray* templates = [[IFDocument documentTemplateManager] templates];
  for (int i = 0, count = 3/*TODO [templates count]*/; i < count; ++i) {
    IFTreeNode* clonedNode = [[[templates objectAtIndex:i] node] cloneNode];
    int parentsCount = [clonedNode inputArity];
    for (int p = 0; p < parentsCount; ++p)
      [clonedNode insertObject:[IFTreeNode nodeWithFilter:[surrogateFilters objectAtIndex:p]]
              inParentsAtIndex:p];
    [nodes addObject:clonedNode];
  }  
  return nodes;
}

- (void)updateBounds;
{
  IFTreeLayoutElement* nodesLayer = [self layoutLayerAtIndex:IFLayoutLayerNodes];
  NSSize containingFrameSize = [[self superview] frame].size;
  NSSize selfFrameSize = [nodesLayer frame].size;
  [self setFrameSize:NSMakeSize(containingFrameSize.width,fmax(selfFrameSize.height,containingFrameSize.height))];
  [self invalidateLayout];
}

- (IFTreeLayoutElement*)layoutForNode:(IFTreeNode*)node;
{
  return [IFTreeLayoutNode layoutNodeWithNode:node containingView:self];
}

- (IFTreeLayoutElement*)layoutForNodes:(NSArray*)allNodes;
{
  if ([allNodes count] == 0)
    return [IFTreeLayoutComposite layoutComposite];

  float columnWidth = [layoutParameters columnWidth];
  float minGutter = [layoutParameters gutterWidth];

  float totalWidth = NSWidth([[self superview] frame]);
  float columns = (int)floor((totalWidth - minGutter) / (columnWidth + minGutter));
  float gutter = round((totalWidth - (columns * columnWidth)) / (columns + 1));
  const float yMargin = 4.0;

  NSMutableSet* rows = [NSMutableSet set];
  float x = gutter, y = 0, maxHeight = 0.0;
  NSMutableSet* currentRow = [NSMutableSet new];
  for (int i = 0, count = [allNodes count]; i < count; ++i) {
    IFTreeLayoutElement* layoutElement = [self layoutForNode:[allNodes objectAtIndex:i]];
    [layoutElement translateBy:NSMakePoint(x,0)];
    [currentRow addObject:layoutElement];
    maxHeight = fmax(maxHeight, NSHeight([layoutElement frame]));

    if ((i + 1) % (int)columns == 0 || i + 1 == count) {
      [[rows do] translateBy:NSMakePoint(0,maxHeight + yMargin)];
      [rows addObject:[IFTreeLayoutComposite layoutCompositeWithElements:currentRow containingView:self]];
      currentRow = [NSMutableSet set];
  
      x = gutter;
      y += maxHeight;
      maxHeight = 0.0;
    } else {
      x += columnWidth + gutter;
    }
  }
  
  return [IFTreeLayoutComposite layoutCompositeWithElements:rows containingView:self];
}

@end
