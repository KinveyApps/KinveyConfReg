//
//  ConfRegIndustryViewController.m
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "ConfRegPickerController.h"


#import "MBProgressHUD.h"


@interface ConfRegPickerController ()

@end

@implementation ConfRegPickerController
@synthesize industryPicker;
@synthesize mainViewController;
@synthesize query;
@synthesize selection;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _items = [NSMutableArray array];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
}

- (void)viewDidUnload
{
    [self setIndustryPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    KCSCollection* industries = [[KCSClient sharedClient] collectionFromString:self.query withClass:[KCSEntityDict class]];
    [industries fetchAllWithDelegate:self];
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mainViewController setSelectedPopoverObject:self.selection query:self.query];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissPopover) object:nil];
    return [[_items objectAtIndex:row] getValueForProperty:@"name"];
}

- (void) dismissPopover
{
    [self.mainViewController hidePopover];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selection = [_items objectAtIndex:row];
    [self performSelector:@selector(dismissPopover) withObject:nil afterDelay:2];
}

#pragma mark - loader
- (void) collection:(KCSCollection *)collection didCompleteWithResult:(NSArray *)result
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [_items removeAllObjects];
    [_items addObjectsFromArray:result];
    [self.industryPicker reloadComponent:0];
    NSUInteger idx = 0;
    for (KCSEntityDict* d in result) {
        if ([[d objectId] isEqualToString:self.selection]) {
            break;
        }
        idx++;
    }
    if (idx == [result count]) {
        //for the not found case, start at top
        idx = 0;
    }
    [self.industryPicker selectRow:idx inComponent:0 animated:NO];
}

- (void) collection:(KCSCollection *)collection didFailWithError:(NSError *)error 
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
