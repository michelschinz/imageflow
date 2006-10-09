//
//  IFDocumentXMLEncoder.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFXMLCoder.h"

@interface IFDocumentXMLEncoder : NSObject {
  IFXMLCoder* xmlCoder;
}

+ (id)encoder;

- (NSXMLDocument*)documentToXML:(IFDocument*)document identities:(NSDictionary*)identities;

@end
