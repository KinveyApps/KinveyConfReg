//
//  ConferenceGoer.h
//  ConfReg
//
//  Created by Michael Katz on 5/8/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
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
