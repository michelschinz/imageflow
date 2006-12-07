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

@interface IFBlendFilterAnnotationSource : IFVariable {
  IFTreeNode* node;
}

+ (id)blendAnnotationSourceForNode:(IFTreeNode*)theNode;
- (id)initWithNode:(IFTreeNode*)theNode;

@end
