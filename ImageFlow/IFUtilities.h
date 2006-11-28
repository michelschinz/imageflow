//
//  IFUtilities.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.09.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define OBJC_RELEASE(o) { [o release]; o = nil; }

typedef enum { IFUp, IFDown, IFLeft, IFRight } IFDirection;

NSMutableDictionary* createMutableDictionaryWithRetainedKeys();

CGSize CGSizeFromNSSize(NSSize s);
NSSize NSSizeFromCGSize(CGSize s);

CGRect CGRectFromNSRect(NSRect r);
NSRect NSRectFromCGRect(CGRect r);

NSRect NSRectFromCIVector(CIVector* v);

NSRect NSRectInfinite();
NSRect NSRectScale(NSRect r, float f);

CGColorSpaceRef CreateColorSpaceFromSystemICCProfileName(NSString* profileName);

// Work around a bug in GCC which prevents the use of some parts of MPWFoundation otherwise.
@protocol WorkAroundFakeProtocol
- (id) __isKindOfClass:(Class)class;
@end

