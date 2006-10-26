//
//  IFImageConstantExpression.h
//  ImageFlow
//
//  Created by Michel Schinz on 25.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFImage.h"
#import "IFConstantExpression.h"

@interface IFImageConstantExpression : IFConstantExpression {

}

+ (id)imageConstantExpressionWithIFImage:(IFImage*)theImage;
+ (id)imageConstantExpressionWithCIImage:(CIImage*)theImage;
+ (id)imageConstantExpressionWithCGImage:(CGImageRef)theImage;

- (IFImage*)image;
- (CIImage*)imageValueCI;
- (CGImageRef)imageValueCG;

@end
