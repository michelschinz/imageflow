//
//  IFTreeLayoutOutputConnector.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutSingle.h"

@interface IFTreeLayoutOutputConnector : IFTreeLayoutSingle {
  NSAttributedString* tag;
  float leftReach, rightReach;
}

+ (id)layoutConnectorWithNode:(IFTreeNode*)theNode
               containingView:(IFTreeView*)theContainingView
                          tag:(NSString*)theTag
                    leftReach:(float)theLeftReach
                   rightReach:(float)theRightReach;

- (id)initWithNode:(IFTreeNode*)theNode
    containingView:(IFTreeView*)theContainingView
               tag:(NSString*)theTag
         leftReach:(float)theLeftReach
        rightReach:(float)theRightReach;

@end
