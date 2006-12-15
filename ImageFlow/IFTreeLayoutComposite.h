//
//  IFTreeLayoutComposite.h
//  ImageFlow
//
//  Created by Michel Schinz on 20.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutElement.h"

@interface IFTreeLayoutComposite : IFTreeLayoutElement {
  NSSet* elements;
}

+ (IFTreeLayoutComposite*)layoutComposite;
+ (IFTreeLayoutComposite*)layoutCompositeWithElements:(NSSet*)theElements containingView:(IFNodesView*)theContainingView;

- (id)initWithElements:(NSSet*)theElements containingView:(IFNodesView*)theContainingView;

@end
