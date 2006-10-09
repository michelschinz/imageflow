//
//  IFFilterXMLDecoder.h
//  ImageFlow
//
//  Created by Michel Schinz on 16.01.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IFFilter.h"

@interface IFFilterXMLDecoder : NSObject {

}

+ (id)decoder;

- (IFFilter*)filterWithXMLFile:(NSString*)xmlFile;
- (IFFilter*)filterWithXML:(NSXMLElement*)xmlTree;

@end
