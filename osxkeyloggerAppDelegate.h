//
//  osxkeyloggerAppDelegate.h
//  osxkeylogger
//
//  Created by Juha Koivisto on 27.2.2011.
//  Copyright 2011 J. Koivisto S.A.C. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface osxkeyloggerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
