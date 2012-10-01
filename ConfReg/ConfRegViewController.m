//
//  KCSViewController.m
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
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
    
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* restart = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restart", @"Restart") style:UIBarButtonItemStyleBordered target:self action:@selector(newAttendee)];
    
    [self.toolbar setItems:[NSArray arrayWithObjects: flexSpace, restart, nil]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kKCSReachabilityChangedNotification object:nil];
    
    KCSClient* client = [(ConfRegAppDelegate*)[[UIApplication sharedApplication] delegate] client];
    KCSReachability* reachability = client.kinveyReachability;
    [reachability startNotifier];
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
        NSLog(@"%@", result.description);
    }];
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
        
        if ([segue.identifier isEqualToString:@"Job-Roles"]) {
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
        
        if ([query isEqualToString:@"Job-Roles"]) {
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
    
    KCSCollection *attendees = [[KCSClient sharedClient]
                                  collectionFromString:@"conferenceAttendees" //data collection name
                                  withClass:[_attendee class]];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Saving to Kinvey backend", @"Saving spinner message");
    
    // Save our instance to the collection
    [_attendee saveToCollection:attendees withDelegate:self];
}

// This is called when the save completes successfully
- (void)entity:(id)entity operationDidCompleteWithResult:(NSObject *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Saved to Kinvey Backend", @"Save complete message")
                                                    message:nil
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                          otherButtonTitles:nil];
    alert.tag = ALERT_TAG_OK;
    [alert show];
}

// This is called when a save fails
- (void)entity:(id)entity operationDidFailWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save failed", @"Save failed message")
                                                    message:[error description]
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok")
                                          otherButtonTitles:nil];
    alert.tag = ALERT_TAG_FAILED;
    [alert show];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *headerImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, HEADER_IMAGE];
    [KCSResourceService downloadResource:HEADER_IMAGE toFile:headerImage withResourceDelegate:self];
    
    NSString *bodyImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, BODY_IMAGE];
    [KCSResourceService downloadResource:BODY_IMAGE toFile:bodyImage withResourceDelegate:self];
}

- (void) setImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *headerImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, HEADER_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:headerImage] ) {
        self.headerImageView.image = [UIImage imageWithContentsOfFile:headerImage];
    } else {
        self.headerImageView.image = [UIImage imageNamed:HEADER_IMAGE];
    }
    
    NSString *bodyImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, BODY_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bodyImage] ) {
        ((UIImageView*)self.tableView.backgroundView).image = [UIImage imageWithContentsOfFile:bodyImage];
    } else {
        ((UIImageView*)self.tableView.backgroundView).image = [UIImage imageNamed:BODY_IMAGE];
    }
}

- (void) clearImages
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *headerImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, HEADER_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:headerImage] ) {
        [[NSFileManager defaultManager] removeItemAtPath:headerImage error:NULL];
    } 
    
    NSString *bodyImage = [NSString stringWithFormat:@"%@/%@", documentsDirectory, BODY_IMAGE];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bodyImage] ) {
         [[NSFileManager defaultManager] removeItemAtPath:bodyImage error:NULL];
    }
}

- (void)resourceServiceDidCompleteWithResult:(KCSResourceResponse *)result
{
    [self setImages];
}

- (void) resourceServiceDidFailWithError:(NSError *)error
{
    [self setImages];
}

@end
