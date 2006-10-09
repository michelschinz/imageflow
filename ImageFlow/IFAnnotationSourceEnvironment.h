//
//  IFAnnotationSourceEnvironment.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.08.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFAnnotationSource.h"
#import "IFEnvironment.h"

@interface IFAnnotationSourceEnvironment : IFAnnotationSource {
  IFEnvironment* environment;
  NSString* variableName;
}

+ (id)annotationSourceWithEnvironment:(IFEnvironment*)theEnvironment variableName:(NSString*)theVariableName;
- (id)initWithEnvironment:(IFEnvironment*)theEnvironment variableName:(NSString*)theVariableName;

@end
