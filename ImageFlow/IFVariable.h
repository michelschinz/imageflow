//
//  IFVariable.h
//  ImageFlow
//
//  Created by Michel Schinz on 07.12.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFVariable : NSObject {
  id value;
}

+ (id)variable;

@property(retain) id value;

@end
