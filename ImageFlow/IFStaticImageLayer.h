//
//  IFStaticImageLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.12.08.
//  Copyright 2008 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFStaticImageLayer : CALayer {

}

+ (id)layerWithImageNamed:(NSString*)theImageName;
- (id)initWithImageNamed:(NSString*)theImageName;

@end
