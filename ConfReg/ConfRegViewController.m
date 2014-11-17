//
//  KCSViewController.m
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


#import "ConfRegViewController.h"
#import <KinveyKit/KinveyKit.h>

#import "ConfRegAppDelegate.h"

#import "ConferenceAttendee.h"
#import "ConfRegPickerController.h"

#import "MBProgressHUD.h"

#define ALERT_TAG_OK 3000
#define ALERT_TAG_FAILED 3001
#define HEADER_IMAGE @"header.png" 
#define BODY_IMAGE @"body.png" 


@interface ConfRegViewController ()

@end

@implementation ConfRegViewController
@synthesize toolbar;
@synthesize headerImageView;
@synthesize userName;
@synthesize industry;
@synthesize twitter;
@synthesize email;
@synthesize company;
@synthesize role;
@synthesize saveButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:BODY_IMAGE]];
    
    [self clearImages]; //clear images each time the app loads to get fresh ones from the server
    [self downloadImages];
    
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"clear_image"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.toolbar.clipsToBounds = YES;
    
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* restart = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restart", @"Restart") style:UIBarButtonItemStyleBordered target:self action:@selector(newAttendee)];
    
    [self.toolbar setItems:[NSArray arrayWithObjects: flexSpace, restart, nil]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:KCSReachabilityChangedNotification object:nil];
}

- (void)viewDidUnload
{
    [self setUserName:nil];
    [self setIndustry:nil];
    [self setTwitter:nil];
    [self setEmail:nil];
    [self setToolbar:nil];
    [self setCompany:nil];
    [self setRole:nil];
    [self setSaveButton:nil];
    [self setHeaderImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self newAttendee];

    [self setReachingOverlay];
}

- (void) viewDidAppear:(BOOL)animated
{
    // Ping Kinvey
    [KCSPing pingKinveyWithBlock:^(KCSPingResult *result) {
        // This block gets executed when the ping completes
        NSString *title;
        if (result.pingWasSuccessful){
            title = @"Kinvey Ping Success :)";
        } else {
            title = @"Kinvey Ping Failed :(";
        }
        // Log the result
        NSLog(@"%@", title);
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

#pragma mark - segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
        _popover = [(UIStoryboardPopoverSegue *)segue popoverController];
        [(ConfRegPickerController*) segue.destinationViewController setMainViewController:self];
        //To make this work the segue identifier (set in the storyboard) must be the same as the Collection names in the Kinvey app console.
        //This sample app uses the Job-Roles and Industries collections to populate the spinner
        [(ConfRegPickerController*) segue.destinationViewController setQuery:segue.identifier];
        
        if ([segue.identifier isEqualToString:@"jobRoles"]) {
            [(ConfRegPickerController*) segue.destinationViewController setSelection:_attendee.roleId];
        } else {
            [(ConfRegPickerController*) segue.destinationViewController setSelection:_attendee.industryId];
        }


    }
    [self.view endEditing:YES];
}

- (void) hidePopover
{
     [_popover dismissPopoverAnimated:YES];
}

- (void) setSelectedPopoverObject:(id)entityObj query:(NSString*)query
{
    if ([entityObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* entity = (NSDictionary*)entityObj;
        NSString* value = [entity valueForKey:@"name"];
        NSString* valId = [entity kinveyObjectId];
        
        if ([query isEqualToString:@"jobRoles"]) {
            self.role.text = value;
            _attendee.roleId = valId;
        } else {//TODO: check for other query values
            self.industry.text = value;
            _attendee.industryId = valId;
        }
    }
}

#pragma mark - Reachability
- (void) setReachingOverlay
{
    KCSClient* client = [(ConfRegAppDelegate*)[[UIApplication sharedApplication] delegate] client];
    KCSReachability* reachability = client.kinveyReachability;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if (reachability.isReachable == NO) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = NSLocalizedString(@"Cannot talk to Kinvey", @"Can't Reach Text");
        hud.detailsLabelText = NSLocalizedString(@"Retrying", @"Can't Reach details");
    } else {
        [self downloadImages];

    }

}

- (void) reachabilityChanged:(NSNotification*) note
{
    [self setReachingOverlay];
}

#pragma mark - text field delegate

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    //enable the save button when username and email are filled out
    //add other validation logic here
    self.saveButton.enabled = (self.userName.text.length > 0 && self.email.text.length >0);
}

- (UITextField*) textFieldAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
    ///If the next cell in the table has a textview - return that noe
    for (UIView* v in currentCell.contentView.subviews) {
        if ([v isKindOfClass:[UITextField class]]) {
            if (v.userInteractionEnabled == YES) {
                return (UITextField*) v;
            }
        }
    }
    return nil;
}

- (BOOL) textFieldShouldReturn:(UITextField *)tf {
    //go to next text field, if there is one, otherwise dismiss the keyboard
    NSIndexPath* selectedRow = [self.tableView indexPathForCell:(UITableViewCell*)[[tf superview] superview]];
    if (selectedRow.row == [self tableView:self.tableView numberOfRowsInSection:selectedRow.section] - 1) {
        [tf resignFirstResponder];
    }
    
    UITextField* nextField = [self textFieldAtIndexPath:[NSIndexPath indexPathForRow:selectedRow.row+1 inSection:selectedRow.section]];
    if (nextField != nil) {
        [nextField becomeFirstResponder];
    } else {
        [tf resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

#pragma mark - Kinvey Handling methods
- (void) newAttendee
{
    _attendee = [[ConferenceAttendee alloc] init];
    
    self.userName.text = nil;
    self.email.text = nil;
    self.twitter.text = nil;
    self.industry.text = nil;
    self.role.text = nil;
    self.company.text = nil;
    
    self.saveButton.enabled = NO;
}

- (void) saveAttendee
{
    // This is the data we'll save
    _attendee.name = self.userName.text;
    _attendee.email = self.email.text;
    _attendee.company = self.company.text;
    
    NSString* twitterHandle = self.twitter.text;
    //remove any @'s added by mistake
    [twitterHandle stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@"]];
    _attendee.twitter = twitterHandle;
    
    KCSCollection *attendees = [KCSCollection collectionFromString:@"conferenceAttendees" ofClass:[_attendee class]];
    KCSCachedStore* store = [KCSCachedStore storeWithCollection:attendees options:@{ KCSStoreKeyCachePolicy : @(KCSCachePolicyLocalFirst)}];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Saving to Kinvey backend", @"Saving spinner message");
    
    // Save our instance to the store
    void (^addAttendeeBlock)(void) = ^{
        [store saveObject:_attendee withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            if (errorOrNil == nil && objectsOrNil != nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Saved to Kinvey Backend", @"Save complete message")
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                alert.tag = ALERT_TAG_OK;
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save failed", @"Save failed message")
                                                                message:[errorOrNil localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                                      otherButtonTitles:nil];
                alert.tag = ALERT_TAG_FAILED;
                [alert show];
            }
        } withProgressBlock:^(NSArray *objects, double percentComplete) {
            
        }];
    };
    
    if (![KCSUser activeUser]) {
        [KCSUser createAutogeneratedUser:nil completion:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
            if (errorOrNil != nil) {
                //failed to autocreate user
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User creation failed"
                                                                message:[errorOrNil localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                
                [alert show];
            } else {
                addAttendeeBlock();
            }
        }];
    } else {
        addAttendeeBlock();
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_TAG_OK) {
        [self newAttendee];
    }
}

#pragma mark - Kinvey Resource Delegate
//downloadImages fetches the body and header from Kinvey's resource service, allowing them to be customized on the fly without having to 
//rebuild the application. Header file must be named "header.png" and the body background is "body.png"
- (void) downloadImages
{
    void (^downloadBlock)(void) = ^{
        [KCSFileStore downloadFileByName:@[HEADER_IMAGE,BODY_IMAGE] completionBlock:^(NSArray *downloadedResources, NSError *error) {
            [self setImages];
        } progressBlock:^(NSArray *objects, double percentComplete) {
            
        }];
    };
    
    if (![KCSUser activeUser]) {
        [KCSUser createAutogeneratedUser:nil completion:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
            if (errorOrNil != nil) {
                //failed to autocreate user
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User creation failed"
                                                                message:[errorOrNil localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                
                [alert show];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    downloadBlock();
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadBlock();
        });
    }
}


// file path to cached image is NSCachesDirectory /kinvey/files/ <filename>
- (void) setImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *headerImage = [NSString stringWithFormat:@"%@/kinvey/files/%@", cacheDirectory, HEADER_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:headerImage] ) {
        self.headerImageView.image = [UIImage imageWithContentsOfFile:headerImage];
    } else {
        self.headerImageView.image = [UIImage imageNamed:HEADER_IMAGE];
    }
    
    NSString *bodyImage = [NSString stringWithFormat:@"%@/kinvey/files/%@", cacheDirectory, BODY_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bodyImage] ) {
        ((UIImageView*)self.tableView.backgroundView).image = [UIImage imageWithContentsOfFile:bodyImage];
    } else {
        ((UIImageView*)self.tableView.backgroundView).image = [UIImage imageNamed:BODY_IMAGE];
    }
}

- (void) clearImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *headerImage = [NSString stringWithFormat:@"%@/kinvey/files/%@", cacheDirectory, HEADER_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:headerImage] ) {
        [[NSFileManager defaultManager] removeItemAtPath:headerImage error:NULL];
    } 
    
    NSString *bodyImage = [NSString stringWithFormat:@"%@/kinvey/files/%@", cacheDirectory, BODY_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bodyImage] ) {
         [[NSFileManager defaultManager] removeItemAtPath:bodyImage error:NULL];
    }
}

@end
