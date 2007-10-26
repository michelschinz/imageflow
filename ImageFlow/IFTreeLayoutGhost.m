//
//  IFTreeLayoutGhost.m
//  ImageFlow
//
//  Created by Michel Schinz on 14.07.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFDocument.h"
#import "IFTreeLayoutGhost.h"
#import "IFTreeViewWindowController.h"
#import "IFDirectoryManager.h"
#import "IFTreeTemplateManager.h"

@interface IFTreeLayoutGhost (Private)
- (void)updateLayout;
- (NSRect)textCellFrame;
@end

@implementation IFTreeLayoutGhost

static NSMutableDictionary* filterArrayControllers = nil;

+ (void)initialize;
{
  if (self != [IFTreeLayoutGhost class])
    return; // avoid repeated initialisation

  filterArrayControllers = [NSMutableDictionary new];
}

+ (NSArrayController*)arrayControllerForFilter:(IFFilter*)filter;
{
  NSArrayController* controller = [filterArrayControllers objectForKey:[NSValue valueWithNonretainedObject:filter]];
  if (controller == nil) {
    controller = [NSArrayController new];
    [controller setContent:[[IFTreeTemplateManager sharedManager] templates]];
    [filterArrayControllers setObject:controller forKey:[NSValue valueWithNonretainedObject:filter]];
  }
  return controller;
}

- (id)initWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)theContainingView;
{
  if (![super initWithNode:theNode containingView:theContainingView]) return nil;
  
  activated = NO;

  arrayController = [[IFTreeLayoutGhost arrayControllerForFilter:[theNode filter]] retain];
  
  textCell = [[NSTextFieldCell alloc] initTextCell:@""];
  [textCell setFont:[[theContainingView layoutParameters] labelFont]];
  [textCell setDrawsBackground:YES];
  [textCell setEditable:YES];
  [textCell setEnabled:YES];
  [textCell setPlaceholderString:@"filter name"];
  
  [self updateLayout];
  [containingView addObserver:self forKeyPath:@"layoutParameters.columnWidth" options:0 context:nil];

  return self;
}

- (void) dealloc;
{
  [containingView removeObserver:self forKeyPath:@"layoutParameters.columnWidth"];
  OBJC_RELEASE(textCell);
  OBJC_RELEASE(arrayController);
  [super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  [self updateLayout];
}

- (IFTreeLayoutElementKind)kind;
{
  return IFTreeLayoutElementKindNode;
}

- (void)activate;
{
  if (activated)
    return;

  [textCell selectWithFrame:[self textCellFrame]
                     inView:containingView
                     editor:[[containingView window] fieldEditor:YES forObject:self]
                   delegate:self
                      start:0
                     length:[[textCell stringValue] length]];
  activated = YES;
}

- (void)activateWithMouseDown:(NSEvent*)event;
{
  if (activated)
    return;
  
  [textCell editWithFrame:[self textCellFrame]
                   inView:containingView
                   editor:[[containingView window] fieldEditor:YES forObject:self]
                 delegate:self
                    event:event];
  activated = YES;
}

- (void)deactivate;
{
  if (!activated)
    return;
  
  const NSWindow* window = [containingView window];
  [window makeFirstResponder:containingView];  

  NSText* fieldEditor = [window fieldEditor:YES forObject:self];
  [textCell setStringValue:[fieldEditor string]];
  [textCell endEditing:fieldEditor];
  activated = NO;
}

- (void)toggleIsUnreachable;
{
  NSLog(@"TODO toggleIsUnreachable for ghosts");
}

- (void)drawForRect:(NSRect)rect;
{
  NSBezierPath* backgroundRect = [NSBezierPath bezierPathWithRect:[self frame]];
  [[NSColor whiteColor] set];
  [backgroundRect fill];
  
  [textCell drawWithFrame:[self textCellFrame] inView:containingView];
}

// NSTextView delegate methods

- (NSArray*)textView:(NSTextView*)textView completions:(NSArray*)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(int *)index
{
  return (NSArray*)[[[arrayController arrangedObjects] collect] name];
}

- (BOOL)textView:(NSTextView*)textView doCommandBySelector:(SEL)selector;
{
  if (selector == @selector(cancelOperation:)) {
    [self deactivate];
    return YES;
  }
  return NO;
}

- (void)textDidChange:(NSNotification *)aNotification;
{
  NSText* textEditor = [aNotification object];
  NSPredicate* filterPred;
  NSString* name = [textEditor string];
  if ((name == nil) || [name isEqualToString:@""])
    filterPred = nil;
  else
    filterPred = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@",name];
  [arrayController setFilterPredicate:nil]; // TODO why is this necessary?
  [arrayController setFilterPredicate:filterPred];
  if ([arrayController selectionIndex] == NSNotFound)
    [arrayController setSelectionIndex:0];
}

- (BOOL)textDidEndEditing:(NSNotification*)aNotification;
{
  [self deactivate];
  
  if ([(NSNumber*)[[aNotification userInfo] valueForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
    [[NSApplication sharedApplication] sendAction:[textCell action]
                                               to:[textCell target]
                                             from:self];
    NSArray* selected = [arrayController selectedObjects];
    if ([selected count] > 0) {
      IFDocument* doc = [containingView document];
      IFTreeTemplate* template = [selected objectAtIndex:0];
      IFTreeNode* clonedTemplateNode = [[template node] cloneNode];
      if ([doc canReplaceGhostNode:node usingNode:clonedTemplateNode]) {
        [doc replaceGhostNode:node usingNode:clonedTemplateNode];
      } else
        NSBeep();
    }
  }
  return true;
}

@end

@implementation IFTreeLayoutGhost (Private)

- (void)updateLayout;
{
  [self deactivate];
  NSSize textCellSize = [textCell cellSize];
  const float margin = 3.0;
  [self setOutlinePath:[NSBezierPath bezierPathWithRect:NSMakeRect(0,0,[[containingView layoutParameters] columnWidth],textCellSize.height + 2.0*margin)]];
}

- (NSRect)textCellFrame;
{
  const float margin = 3.0;
  return NSInsetRect([self frame],margin,margin);
}

@end
