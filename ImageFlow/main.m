//
//  main.m
//  ImageFlow
//
//  Created by Michel Schinz on 15.06.05.
//  Copyright Michel Schinz 2005 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <caml/callback.h>

int main(int argc, char *argv[])
{
  NSAutoreleasePool* pool = [NSAutoreleasePool new];
  caml_startup(argv);
  [pool release];
  return NSApplicationMain(argc, (const char **) argv);
}
