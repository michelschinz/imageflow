//
//  IFViewController.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFViewController.h"


@implementation IFViewController

- (id)initWithViewNibName:(NSString*)nibName;
{
  if (![super init])
    return nil;
  NSNib* nibFile = [[NSNib alloc] initWithNibNamed:nibName bundle:nil];
  NSArray* nibObjects = nil;
  [nibFile instantiateNibWithOwner:self topLevelObjects:&nibObjects];
  [nibFile release];
  return self;
}  

- (NSView*)topLevelView;
{
  return topLevelView;
}

@end
