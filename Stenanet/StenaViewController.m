//
//  ViewController.m
//  Stenanet
//
//  Created by Miroslav on 9/1/15.
//  Copyright (c) 2015 Miroslav. All rights reserved.
//

#import "StenaViewController.h"

#define TIME_STAMP_NORMAL    0.2
#define TIME_STAMP_FAST      0.1
#define WEVIEW_LOADING_DELAY 0.7

@interface StenaViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UILabel *lblCoordinates; // temporare
@property (nonatomic, strong) IBOutlet UILabel *lblFindStena;
@property (nonatomic, strong) IBOutlet UIButton *btnRefresh;
@property (nonatomic, weak) NSTimer *timerNormal;
@property (nonatomic, weak) NSTimer *timerFast;

// Private
- (void)setNextButtonImage;
- (void)setLastButtonImage;
- (IBAction)processStenaRequest;
- (void)showStena;
- (void)hideStena;

@end


@implementation StenaViewController

@synthesize webView, lblCoordinates, lblFindStena, btnRefresh, timerFast, timerNormal;

const int percents[8] = {5,20,25,30,40,45,90,100};
const int percents_size = 8;
int cur_percents_index = 0;


#pragma mark - View lyfecycle


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://stenanet.org/ru"]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/x-www-form-urlencoded"];
    //[httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    else {
        [locationManager startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods


- (void)setNextButtonImage {
    
    if (cur_percents_index == percents_size) {
        
        [timerFast invalidate];
        return;
    }
    [btnRefresh setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d_percent.jpg", percents[cur_percents_index]]] forState:UIControlStateDisabled];
    cur_percents_index++;
}

- (void)setLastButtonImage {
    
    if (cur_percents_index != percents_size) {
        [btnRefresh setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d_percent.jpg", percents[percents_size-1]]] forState:UIControlStateDisabled];
        cur_percents_index = percents_size;
    }
}

- (IBAction)processStenaRequest {
    
    cur_percents_index = 0;
    
    btnRefresh.enabled = NO;
    lblFindStena.hidden = YES;
    [self hideStena];
    //[MBProgressHUD showHUDAddedTo:self.view animated:NO];
    self.timerNormal = [NSTimer scheduledTimerWithTimeInterval:TIME_STAMP_NORMAL target:self selector:@selector(setNextButtonImage) userInfo:nil repeats:YES];
    
//    NSDictionary* params = @{
//                             @"gpsX" : @53.9031,
//                             @"gpsY" : @27.56284
//                             };
    
    NSDictionary* params = @{
                             @"gpsX" : @(locationManager.location.coordinate.latitude),
                             @"gpsY" : @(locationManager.location.coordinate.longitude)
                             };
    [httpClient postPath:@"mobile/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //TRACE(@"%lu", (unsigned long)[responseObject length]);
         if (!responseObject || [responseObject isKindOfClass:[NSNull class]] || ![responseObject length]) {
             
             NSString *html = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"empty_template" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
             webView.scalesPageToFit = NO;
             [webView loadHTMLString:html baseURL:URL(@"http://stenanet.org")];
         }
         else {
             
             NSString* html = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             webView.scalesPageToFit = YES;
             [webView loadHTMLString:html baseURL:URL(@"http://stenanet.org")];
         }

     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSString *html = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"failure_template" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
         webView.scalesPageToFit = NO;
         [webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath]];
     }];
}

- (void)showStena {
    
    [UIView animateWithDuration:0.3 delay:WEVIEW_LOADING_DELAY options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        CGRect rect = webView.frame;
        rect.origin.y = 60;
        webView.frame = rect;
        
        btnRefresh.frame = CGRectMake(140,20,40,40);
    }completion:^(BOOL success){
        
        btnRefresh.enabled = YES;
        [btnRefresh setBackgroundImage:[UIImage imageNamed:@"initial_button.jpg"] forState:UIControlStateDisabled];
    }];
}

- (void)hideStena {
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        CGRect rect = webView.frame;
        rect.origin.y = UIScreen.mainScreen.bounds.size.height;
        webView.frame = rect;
        
        btnRefresh.frame = CGRectMake(85,70,150,150);
    }completion:nil];
}


#pragma mark - UIWebViewDelegate


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [timerNormal invalidate];
    self.timerFast = [NSTimer scheduledTimerWithTimeInterval:TIME_STAMP_FAST target:self selector:@selector(setNextButtonImage) userInfo:nil repeats:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self showStena];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [timerFast invalidate];
    [self showStena];
}


#pragma mark - CLLocationManagerDelegate


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [manager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    lblCoordinates.text = [NSString stringWithFormat:@"%.7f   %.7f", manager.location.coordinate.latitude, manager.location.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    TRACE(@"LOCATION ERROR: %@", error);
}


@end
