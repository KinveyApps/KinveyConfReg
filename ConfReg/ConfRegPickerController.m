//
//  ConfRegIndustryViewController.m
//  ConfReg
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


#import "ConfRegPickerController.h"
#import "ConfRegViewController.h"
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
    [super viewWillAppear:animated];
    KCSCollection* industries = [KCSCollection collectionFromString:self.query ofClass:[NSMutableDictionary class]];
    KCSCachedStore* store = [KCSCachedStore storeWithCollection:industries options:@{ KCSStoreKeyCachePolicy : @(KCSCachePolicyLocalFirst)}];
    [store queryWithQuery:[KCSQuery query] withCompletionBlock:^(NSArray *result, NSError *errorOrNil) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [_items removeAllObjects];
        [_items addObjectsFromArray:result];
        [self.industryPicker reloadAllComponents];
        NSUInteger idx = 0;
        for (NSDictionary* d in result) {
            if ([[d kinveyObjectId] isEqualToString:self.selection]) {
                break;
            }
            idx++;
        }
        if (idx == [result count]) {
            //for the not found case, start at top
            idx = 0;
        }
        if (idx < [result count]) {
            [self.industryPicker selectRow:idx inComponent:0 animated:NO];
        }
        
    } withProgressBlock:nil];
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
    return 1; //_items.count > 0 ? 1 : 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    assert(_items);
    return [_items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissPopover) object:nil];
    return [[_items objectAtIndex:row] valueForKey:@"name"];
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

@end
