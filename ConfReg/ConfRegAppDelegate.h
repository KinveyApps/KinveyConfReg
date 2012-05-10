//
//  KCSAppDelegate.h
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfRegAppDelegate : UIResponder <UIApplicationDelegate> {
    KCSClient* _client;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) KCSClient* client;

@end
