//
//  IFGhostFilterController.m
//  ImageFlow
//
//  Created by Michel Schinz on 24.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFGhostFilterController.h"
#import "IFTreeLayoutGhost.h"

@interface IFGhostFilterController (Private)
- (void)setArrayController:(NSArrayController*)newArrayController;
@end

@implementation IFGhostFilterController

- (void)awakeFromNib;
{
  [filterController addObserver:self forKeyPath:@"content" options:0 context:nil];
  [self setArrayController:[IFTreeLayoutGhost arrayControllerForNode:[filterController content]]];
}

- (void) dealloc;
{
  OBJC_RELEASE(arrayController);
  [filterController removeObserver:self forKeyPath:@"content"];
  [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
  [self setArrayController:[IFTreeLayoutGhost arrayControllerForNode:[filterController content]]];
}

- (NSArrayController*)arrayController;
{
  return arrayController;
}

@end

@implementation IFGhostFilterController (Private)

- (void)setArrayController:(NSArrayController*)newArrayController;
{
  if (newArrayController == arrayController)
    return;
  [arrayController release];
  arrayController = [newArrayController retain];
}

@end

