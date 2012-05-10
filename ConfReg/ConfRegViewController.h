//
//  KCSViewController.h
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConferenceAttendee;

@interface ConfRegViewController : UITableViewController <KCSPersistableDelegate, KCSResourceDelegate, UITextFieldDelegate, UIAlertViewDelegate> {
    __weak UIPopoverController* _popover;
    ConferenceAttendee* _attendee;
}
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *industry;
@property (weak, nonatomic) IBOutlet UITextField *twitter;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *company;
@property (weak, nonatomic) IBOutlet UITextField *role;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (void) hidePopoverWithSelectedObject:(id)entity query:(NSString*)query;

- (IBAction)saveAttendee;

@end
