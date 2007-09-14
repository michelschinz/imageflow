//
//  IFPrintSinkController.m
//  ImageFlow
//
//  Created by Michel Schinz on 18.11.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFPrintSinkController.h"
#import "IFFilter.h"

@implementation IFPrintSinkController

- (void)awakeFromNib;
{
  NSArray* printerNames = [NSPrinter printerNames];
  [printersArrayController setContent:printerNames];
}

- (IBAction)browseFile:(id)sender;
{
  IFEnvironment* env = [(IFFilter*)[filterController content] environment];
  
  NSArray* fileNameComponents = [[env valueForKey:@"fileName"] pathComponents];
  NSString* dirName = [NSString pathWithComponents:[fileNameComponents subarrayWithRange:NSMakeRange(0,[fileNameComponents count] - 1)]];
  NSString* fileName = [fileNameComponents lastObject];
  
  NSSavePanel* panel = [NSSavePanel savePanel];
  [panel setCanCreateDirectories:YES];
  [panel runModalForDirectory:dirName file:fileName];
  
  [env setValue:[panel filename] forKey:@"fileName"];
}

- (IBAction)managePrinters:(id)sender;
{
  CFURLRef appURL;
  LSFindApplicationForInfo(kLSUnknownCreator,(CFStringRef)@"com.apple.print.PrintCenter",NULL,NULL,&appURL);
  LSOpenCFURLRef(appURL,NULL);
  CFRelease(appURL);
}

@end
