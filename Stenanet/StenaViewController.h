//
//  ViewController.h
//  Stenanet
//
//  Created by Miroslav on 9/1/15.
//  Copyright (c) 2015 Miroslav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StenaViewController : UIViewController <CLLocationManagerDelegate, UIWebViewDelegate>
{
    AFHTTPClient* httpClient;
    CLLocationManager *locationManager;
}

@end

