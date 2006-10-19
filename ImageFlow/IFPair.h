//
//  IFPair.h
//  ImageFlow
//
//  Created by Michel Schinz on 18.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFPair : NSObject {
  id fst, snd;
}

+ (id)pairWithFst:(id)first snd:(id)second;
- (id)initWithFst:(id)first snd:(id)second;

- (id)fst;
- (id)snd;

@end
