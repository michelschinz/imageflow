//
//  IFAnnotationRect.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFAnnotation.h"

@interface IFAnnotationRect : IFAnnotation {
}

+ (id)annotationRectWithView:(NSView*)theView source:(IFAnnotationSource*)theSource;

@end
