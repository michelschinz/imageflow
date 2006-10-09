//
//  IFDocumentXMLDecoder.h
//  ImageFlow
//
//  Created by Michel Schinz on 28.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFXMLCoder.h"

@interface IFDocumentXMLDecoder : NSObject {
  IFXMLCoder* xmlCoder;
}

+ (id)decoder;

- (IFDocument*)documentFromXML:(NSXMLDocument*)xml;

@end
