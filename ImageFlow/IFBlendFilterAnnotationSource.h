//
//  IFBlendFilterAnnotationSource.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.09.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFVariable.h"
#import "IFTreeNode.h"
#import "IFBlendFilter.h"

@interface IFBlendFilterAnnotationSource : IFVariable {
  IFBlendFilter* node;
}

+ (id)blendAnnotationSourceForNode:(IFBlendFilter*)theNode;
- (id)initWithNode:(IFBlendFilter*)theNode;

@end
