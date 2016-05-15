//
//  Helpers.h
//  a4transit
//
//  Created by Miroslav on 18.03.14.
//  Copyright (c) 2014 XATA. All rights reserved.
//

void showAlertWithOKButton (NSString *title, NSString *message);
NSInteger daysInMonth (NSInteger month, BOOL leap);
BOOL leapYear (NSInteger year);
NSString *stringFromMonth (NSInteger month, BOOL basicCase);
NSString *stringWithMonthFromDate (NSDate *date);