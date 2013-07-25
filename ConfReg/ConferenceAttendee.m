//
//  ConferenceGoer.m
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
