//
//  HYTestViewController.h
//  APPIDTest
//
//  Created by xiaohan on 14-5-14.
//  Copyright (c) 2014年 JDhudong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AdSupport/ASIdentifierManager.h>
#import <security/SecItem.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import <CoreLocation/CoreLocation.h>

@interface HYTestViewController : UIViewController<CLLocationManagerDelegate>

//IDFA

@property (weak, nonatomic) IBOutlet UITextView *myTextView;

//MAC
@property (weak, nonatomic) IBOutlet UILabel *macLabel;


@property (retain, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) CLLocationDegrees* latitude;

@property (assign, nonatomic) CLLocationDegrees* longitude;
//获取IDFA
- (NSString *) idfa;

//获取MAC地址
- (NSString *)macaddress;

- (void)setTimestamp:(NSDate *)date;
@end
