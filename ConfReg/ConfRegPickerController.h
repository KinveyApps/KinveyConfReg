//
//  ConfRegIndustryViewController.h
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfRegViewController.h"

@class ConfRegViewController;

@interface ConfRegPickerController : UIViewController <KCSCollectionDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    NSMutableArray* _items;
}

@property (weak, nonatomic) id selection;
@property (weak, nonatomic) IBOutlet UIPickerView *industryPicker;
@property (weak, nonatomic) ConfRegViewController* mainViewController;
@property (nonatomic) NSString* query;

@end
