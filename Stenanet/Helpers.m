//
//  Helpers.m
//  a4transit
//
//  Created by Miroslav on 18.03.14.
//  Copyright (c) 2014 XATA. All rights reserved.
//

#import "Helpers.h"

void showAlertWithOKButton (NSString *title, NSString *message) {
    
	BOOL show = YES;
	for (UIWindow *win in [UIApplication sharedApplication].windows) {
		NSArray *subviews = [win subviews];
		if ([subviews count]) {
			for (UIView *view in subviews) {
				if ([view isKindOfClass:[UIAlertView class]]) {
					show = NO;
					break;
				}
			}
		}
	}
	
	if (show) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
	}
}

NSInteger daysInMonth (NSInteger month, BOOL leap){
    
    NSInteger days[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
    if (leap) days[1]++;
    return days[month-1];
}

BOOL leapYear (NSInteger year) {
    
    return year%400 == 0 || (year%4 == 0 && year%100);
}

NSString *stringFromMonth (NSInteger month, BOOL basicCase) {
    
    NSString *monthWords[12] = {@"январь",@"февраль",@"март",@"апрель",@"май",@"июнь",@"июль",@"август",@"сентябрь",@"октябрь",@"ноябрь",@"декабрь"};
    NSString *monthWordsRCase[12] = {@"января",@"февраля",@"марта",@"апреля",@"мая",@"июня",@"июля",@"августа",@"сентября",@"октября",@"ноября",@"декабря"};
    
    if (basicCase) return monthWords[month-1];
    return monthWordsRCase[month-1];
}

NSString *stringWithMonthFromDate (NSDate *date) {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
    [formatter setDateFormat: @"dd MM yyyy"]; // HH:mm
    return [formatter stringFromDate:date];
}
