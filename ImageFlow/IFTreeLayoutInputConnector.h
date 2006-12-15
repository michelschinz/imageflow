//
//  IFTreeLayoutInputConnector.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutSingle.h"

@interface IFTreeLayoutInputConnector : IFTreeLayoutSingle {

}

+ (id)layoutConnectorWithNode:(IFTreeNode*)theNode containingView:(IFNodesView*)theContainingView;

@end
