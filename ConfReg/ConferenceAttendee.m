//
//  ConferenceGoer.m
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "ConferenceAttendee.h"

@implementation ConferenceAttendee
@synthesize objectId;
@synthesize name;
@synthesize email;
@synthesize twitter;
@synthesize industryId;
@synthesize roleId;
@synthesize company;

// Required to be overridden for Kinvey
- (NSDictionary *)hostToKinveyPropertyMapping
{
    // Only define the dictionary once
    static NSDictionary *mapping = nil;
    // If it's not initialized, initialize here
    if (mapping == nil){
        // Assign the mapping
        mapping = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"_id", @"objectId", 
                   @"name", @"name",
                   @"email", @"email",
                   @"twitter", @"twitter",
                   @"industryId", @"industryId",
                   @"company", @"company",
                   @"roleId", @"roleId",
                   nil];
    }
    return mapping;
}

@end
