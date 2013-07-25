//
//  KCSViewController.h
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//
//  Copyright 2013 Kinvey, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

- (void) hidePopover;
- (void) setSelectedPopoverObject:(id)entityObj query:(NSString*)query;

- (IBAction)saveAttendee;

@end
