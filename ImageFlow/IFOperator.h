//
//  IFOperator.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IFOperator : NSObject<NSCopying> {
  NSString* name;
}

+ (IFOperator*)operatorForName:(NSString*)name;
- (id)copyWithZone:(NSZone *)zone;

- (NSString*)name;

@end
