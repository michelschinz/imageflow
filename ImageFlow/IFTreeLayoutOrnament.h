//
//  IFTreeLayoutOrnament.h
//  ImageFlow
//
//  Created by Michel Schinz on 06.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFTreeLayoutElement.h"
#import "IFTreeLayoutSingle.h"

@interface IFTreeLayoutOrnament : IFTreeLayoutElement {
  IFTreeLayoutSingle* base;
}

- (id)initWithBase:(IFTreeLayoutSingle*)base;

@end
