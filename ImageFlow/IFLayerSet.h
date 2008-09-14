//
//  IFLayerSet.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFLayer.h"

@interface IFLayerSet : NSObject<NSFastEnumeration> {

}

@property(readonly, retain) IFLayer* firstLayer;
@property(readonly, retain) IFLayer* lastLayer;
- (IFLayer*)layerAtIndex:(int)index;

- (CGRect)boundingBox;
- (void)translateByX:(float)dx Y:(float)dy;

- (IFLayer*)hitTest:(CGPoint)point;

// NSFastEnumeration protocol
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len;

@end
