//
//  IFOrientedGraphEdge.h
//  ImageFlow
//
//  Created by Michel Schinz on 04.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFOrientedGraphEdge : NSObject<NSCoding> {
  id data;
  id fromNode, toNode;
}

+ (id)edgeFromNode:(id)theFromNode toNode:(id)theToNode data:(id)theData;
- (id)initWithFromNode:(id)theFromNode toNode:(id)theToNode data:(id)theData;

- (id)fromNode;
- (id)toNode;
- (id)data;

@end
