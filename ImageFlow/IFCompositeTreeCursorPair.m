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

static NSString* IFEditCursorDidChange = @"IFEditCursorDidChange";
static NSString* IFViewCursorDidChange = @"IFViewCursorDidChange";

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
  static NSSet* manualKeys = nil;
  if (manualKeys == nil)
    manualKeys = [[NSSet setWithObjects:@"tree", @"node", @"path", @"viewLockedTree", @"viewLockedNode", @"viewLockedPath", nil] retain];
  return ![manualKeys containsObject:key];
}

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

  [editCursor addObserver:self forKeyPath:@"tree" options:NSKeyValueObservingOptionInitial context:IFEditCursorDidChange];  
  [editCursor addObserver:self forKeyPath:@"node" options:NSKeyValueObservingOptionInitial context:IFEditCursorDidChange];
  [editCursor addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionInitial context:IFEditCursorDidChange];
  [viewCursor addObserver:self forKeyPath:@"tree" options:NSKeyValueObservingOptionInitial context:IFViewCursorDidChange];  
  [viewCursor addObserver:self forKeyPath:@"node" options:NSKeyValueObservingOptionInitial context:IFViewCursorDidChange];
  [viewCursor addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionInitial context:IFViewCursorDidChange];
  
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
  // The complex code below is necessary to preserve the atomicity of the changes.
  if (context == IFEditCursorDidChange) {
    BOOL treeChanged = (editCursor.tree != tree);
    BOOL nodeChanged = (editCursor.node != node);
    BOOL pathChanged = ![editCursor.path isEqual:path];

    if (treeChanged) {
      [self willChangeValueForKey:@"tree"];
      self.tree = editCursor.tree;
    }
    if (nodeChanged) {
      [self willChangeValueForKey:@"node"];
      self.node = editCursor.node;
    }
    if (pathChanged) {
      [self willChangeValueForKey:@"path"];
      self.path = editCursor.path;
      [self didChangeValueForKey:@"path"];
    }
    if (nodeChanged)
      [self didChangeValueForKey:@"node"];
    if (treeChanged)
      [self didChangeValueForKey:@"tree"];    
  } else if (context == IFViewCursorDidChange) {
    BOOL treeChanged = (viewCursor.tree != viewLockedTree);
    BOOL nodeChanged = (viewCursor.node != viewLockedNode);
    BOOL pathChanged = ![viewCursor.path isEqual:viewLockedPath];
    
    if (treeChanged) {
      [self willChangeValueForKey:@"viewLockedTree"];
      self.viewLockedTree = viewCursor.tree;
    }
    if (nodeChanged) {
      [self willChangeValueForKey:@"viewLockedNode"];
      self.viewLockedNode = viewCursor.node;
    }
    if (pathChanged) {
      [self willChangeValueForKey:@"viewLockedPath"];
      self.viewLockedPath = viewCursor.path;
      [self didChangeValueForKey:@"viewLockedPath"];
    }
    if (nodeChanged)
      [self didChangeValueForKey:@"viewLockedNode"];
    if (treeChanged)
      [self didChangeValueForKey:@"viewLockedTree"];
  } else
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
