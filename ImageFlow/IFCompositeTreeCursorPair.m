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
@property(retain) IFArrayPath* path;
@property(retain) IFTree* viewLockedTree;
@property(retain) IFTreeNode* viewLockedNode;
@property(retain) IFArrayPath* viewLockedPath;
@end

@implementation IFCompositeTreeCursorPair

static NSString* IFEditTreeDidChange = @"IFEditTreeDidChange";
static NSString* IFEditNodeDidChange = @"IFEditNodeDidChange";
static NSString* IFEditPathDidChange = @"IFEditPathDidChange";
static NSString* IFViewTreeDidChange = @"IFViewTreeDidChange";
static NSString* IFViewNodeDidChange = @"IFViewNodeDidChange";
static NSString* IFViewPathDidChange = @"IFViewPathDidChange";

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
  [editCursor addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionInitial context:IFEditPathDidChange];
  [viewCursor addObserver:self forKeyPath:@"tree" options:NSKeyValueObservingOptionInitial context:IFViewTreeDidChange];  
  [viewCursor addObserver:self forKeyPath:@"node" options:NSKeyValueObservingOptionInitial context:IFViewNodeDidChange];
  [viewCursor addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionInitial context:IFViewPathDidChange];
  
  return self;
}

- (void)dealloc;
{
  [viewCursor removeObserver:self forKeyPath:@"path"];
  [viewCursor removeObserver:self forKeyPath:@"node"];
  [viewCursor removeObserver:self forKeyPath:@"tree"];
  [editCursor removeObserver:self forKeyPath:@"path"];
  [editCursor removeObserver:self forKeyPath:@"node"];
  [editCursor removeObserver:self forKeyPath:@"tree"];
  
  OBJC_RELEASE(viewLockedPath);
  OBJC_RELEASE(viewLockedNode);
  OBJC_RELEASE(viewLockedTree);
  OBJC_RELEASE(viewCursor);
  
  OBJC_RELEASE(path);
  OBJC_RELEASE(node);
  OBJC_RELEASE(tree);
  OBJC_RELEASE(editCursor);
  [super dealloc];
}


@synthesize tree, node, path;
@synthesize viewLockedTree, viewLockedNode, viewLockedPath;

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
  else if (context == IFEditPathDidChange)
    self.path = editCursor.path;
  else if (context == IFViewTreeDidChange)
    self.viewLockedTree = viewCursor.tree;
  else if (context == IFViewNodeDidChange)
    self.viewLockedNode = viewCursor.node;
  else if (context == IFViewPathDidChange)
    self.viewLockedPath = viewCursor.path;
  else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
