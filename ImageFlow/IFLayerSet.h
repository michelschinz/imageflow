//
//  IFLayerSet.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFLayerSet : NSObject<NSFastEnumeration> {

}

@property(readonly) CALayer* firstLayer;
@property(readonly) CALayer* lastLayer;
- (CALayer*)layerAtIndex:(int)index;

@property(readonly) unsigned count;

@property(readonly) CGRect boundingBox;
- (void)translateByX:(float)dx Y:(float)dy;

- (CALayer*)hitTest:(CGPoint)point;

// NSFastEnumeration protocol
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id*)stackbuf count:(NSUInteger)len;

@end
