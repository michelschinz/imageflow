//
//  IFCacheInspectorWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFCacheInspectorWindowController.h"

@implementation IFCacheInspectorWindowController

-(id)init {
  if (![super initWithWindowNibName:@"IFCacheViewer"])
    return nil;
  return self;
}

- (void)documentDidChange:(IFDocument*)newDocument;
{
  [super documentDidChange:newDocument];
  [cacheObjectController setContent:[newDocument evaluator]];
}

@end
