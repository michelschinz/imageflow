//
//  IFCompositeTreeCursorPair.m
//  ImageFlow
//
//  Created by Michel Schinz on 06.11.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import "IFCompositeTreeCursorPair.h"

@interface IFCompositeTreeCursorPair ()
@property(retain) IFTree* tree;
@property(retain) IFTreeNode* node;
@property unsigned index;
@property(retain) IFTree* viewLockedTree;
@property(retain) IFTreeNode* viewLockedNode;
@property unsigned viewLockedIndex;
@end

@implementation IFCompositeTreeCursorPair

static NSString* IFEditTreeDidChange = @"IFEditTreeDidChange";
static NSString* IFEditNodeDidChange = @"IFEditNodeDidChange";
static NSString* IFEditIndexDidChange = @"IFEditIndexDidChange";
static NSString* IFViewTreeDidChange = @"IFViewTreeDidChange";
static NSString* IFViewNodeDidChange = @"IFViewNodeDidChange";
static NSString* IFViewIndexDidChange = @"IFViewIndexDidChange";

+ (IFCompositeTreeCursorPair*)compositeWithEditCursor:(IFTreeCursorPair*)theEditCursor viewCursor:(IFTreeCursorPair*)theViewCursor;
{
  return [[[self alloc] initWithEditCursor:theEditCursor viewCursor:theViewCursor] autorelease];
}

- (IFCompositeTreeCursorPair*)initWithEditCursor:(IFTreeCursorPair*)theEditCursor viewCursor:(IFTreeCursorPair*)theViewCursor;
{
  if (![super init])
    return nil;
  
  editCursor = [theEditCursor retain];
  viewCursor = [theViewCursor retain];

  [editCursor addObserver:self forKeyPath:@"tree" options:NSKeyValueObservingOptionInitial context:IFEditTreeDidChange];  
  [editCursor addObserver:self forKeyPath:@"node" options:NSKeyValueObservingOptionInitial context:IFEditNodeDidChange];
  [editCursor addObserver:self forKeyPath:@"index" options:NSKeyValueObservingOptionInitial context:IFEditIndexDidChange];
  [viewCursor addObserver:self forKeyPath:@"tree" options:NSKeyValueObservingOptionInitial context:IFViewTreeDidChange];  
  [viewCursor addObserver:self forKeyPath:@"node" options:NSKeyValueObservingOptionInitial context:IFViewNodeDidChange];
  [viewCursor addObserver:self forKeyPath:@"index" options:NSKeyValueObservingOptionInitial context:IFViewIndexDidChange];
  
  return self;
}

- (void)dealloc;
{
  [viewCursor removeObserver:self forKeyPath:@"index"];
  [viewCursor removeObserver:self forKeyPath:@"node"];
  [viewCursor removeObserver:self forKeyPath:@"tree"];
  [editCursor removeObserver:self forKeyPath:@"index"];
  [editCursor removeObserver:self forKeyPath:@"node"];
  [editCursor removeObserver:self forKeyPath:@"tree"];
  
  OBJC_RELEASE(viewLockedNode);
  OBJC_RELEASE(viewLockedTree);
  OBJC_RELEASE(viewCursor);
  
  OBJC_RELEASE(node);
  OBJC_RELEASE(tree);
  OBJC_RELEASE(editCursor);
  [super dealloc];
}


@synthesize tree, node, index;
@synthesize viewLockedTree, viewLockedNode, viewLockedIndex;

- (BOOL)isViewLocked;
{
  return NO;
}

- (NSAffineTransform*)editViewTransform;
{
  return [NSAffineTransform transform];
}

- (NSAffineTransform*)viewEditTransform;
{
  return [NSAffineTransform transform];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
  if (context == IFEditTreeDidChange)
    self.tree = editCursor.tree;
  else if (context == IFEditNodeDidChange)
    self.node = editCursor.node;
  else if (context == IFEditIndexDidChange)
    self.index = editCursor.index;
  else if (context == IFViewTreeDidChange)
    self.viewLockedTree = viewCursor.tree;
  else if (context == IFViewNodeDidChange)
    self.viewLockedNode = viewCursor.node;
  else if (context == IFViewIndexDidChange)
    self.viewLockedIndex = viewCursor.index;
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
