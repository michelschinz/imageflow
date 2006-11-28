//
//  IFThumbnailViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 13.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFViewController.h"
#import "IFImageView.h"
#import "IFExpressionEvaluator.h"
#import "IFTreeCursorPair.h"

@interface IFThumbnailViewController : IFViewController {
  IBOutlet IFImageView* imageView;

  IFExpressionEvaluator* evaluator;
  IFTreeCursorPair* cursors;
  IFExpression* expression;
}

- (void)setEvaluator:(IFExpressionEvaluator*)newEvaluator;
- (void)setCursorPair:(IFTreeCursorPair*)newCursors;

@end
