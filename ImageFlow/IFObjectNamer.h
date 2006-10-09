//
//  IFObjectNamer.h
//  ImageFlow
//
//  Created by Michel Schinz on 24.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFObjectNamer : NSObject {
  NSMutableDictionary* nameToObject;
  NSMutableDictionary* objectToName;
}

- (void)registerObject:(NSObject*)object nameHint:(NSString*)nameHint;

- (NSString*)uniqueNameForObject:(id)object;
- (id)objectForUniqueName:(NSString*)name;

@end
