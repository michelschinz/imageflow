//
//  IFEnvironment.h
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IFConstantExpression;

@interface IFEnvironment : NSObject {
  NSMutableDictionary* env;
}

+ (id)environment;
- (IFEnvironment*)clone;

- (void)setValue:(id)value forKey:(NSString*)key;
- (id)valueForKey:(NSString*)key;
- (NSSet*)keys;

- (void)removeValueForKey:(NSString*)key;

- (NSDictionary*)asDictionary;

@end
