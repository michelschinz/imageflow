//
//  IFViewController.h
//  ImageFlow
//
//  Created by Michel Schinz on 14.11.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFViewController : NSObject {
  IBOutlet NSView* topLevelView;
}

- (id)initWithViewNibName:(NSString*)nibName;

- (NSView*)topLevelView;

@end
