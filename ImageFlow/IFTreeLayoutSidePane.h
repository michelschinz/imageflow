//
//  IFTreeLayoutSidePane.h
//  ImageFlow
//
//  Created by Michel Schinz on 16.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutOrnament.h"
#import "IFTreeLayoutStrategy.h"

@interface IFTreeLayoutSidePane : IFTreeLayoutOrnament {
  IFTreeLayoutStrategy* layoutStrategy;
  NSRect deleteButtonFrame, foldButtonFrame, menuButtonFrame;
}

+ (id)layoutSidePaneWithBase:(IFTreeLayoutSingle*)theBase;

@end
