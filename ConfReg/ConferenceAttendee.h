//
//  ConferenceGoer.h
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


#import <Foundation/Foundation.h>

@interface ConferenceAttendee : NSObject <KCSPersistable>

@property (retain, nonatomic) NSString *objectId;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *email;
@property (retain, nonatomic) NSString *twitter;
@property (retain, nonatomic) NSString *industryId;
@property (retain, nonatomic) NSString *roleId;
@property (retain, nonatomic) NSString *company;

@end
