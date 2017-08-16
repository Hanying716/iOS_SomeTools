//
//  HYTestViewController.m
//  APPIDTest
//
//  Created by xiaohan on 14-5-14.
//  Copyright (c) 2014年 JDhudong. All rights reserved.
//

#import "HYTestViewController.h"

@interface HYTestViewController ()

@end

@implementation HYTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.]]]
    
    [[UIApplication sharedApplication]setApplicationSupportsShakeToEdit:YES];
    
    [self becomeFirstResponder];
    
    
    
}


- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    //检测到
    
 
    
    NSLog(@"开始");
}



- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    
    NSLog(@"取消");
    
}



- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event

{
    
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        
        //something happens
        
        NSLog(@"结束");
        
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    self.macLabel.text =  [self macaddress];

    self.myTextView.text = [self idfa];
    
    NSLog(@"idfa:%@",self.myTextView.text);
    
    [self setTimestamp:[NSDate date]];
    
    [self wek];
    
    
    //获取距离
    
    CLLocationManager *location;
    if ([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc]init];
        
        self.locationManager.delegate = self;
    }
    else
    {
        //提示用户无法进行定位操作
    }
    
    // 开始定位
    [location startUpdatingLocation];
    
    
    
    //第一个坐标
    CLLocation *current=[[CLLocation alloc] initWithLatitude:32.178722 longitude:119.508619];
    //第二个坐标
    CLLocation *before=[[CLLocation alloc] initWithLatitude:32.785834 longitude:122.406417];
    // 计算距离
    CLLocationDistance meters=[current distanceFromLocation:before];
    
    
    NSLog(@"获取的距离是：%f",meters);
    
    
    
}




-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    CLLocationCoordinate2D coor = currentLocation.coordinate;
    self.latitude =  &(coor.latitude);
    self.longitude = &(coor.longitude);
    
    //[self.locationManager stopUpdatingLocation];
    
    
    
    NSLog(@"%d", [locations count]);


    CLLocation *newLocation = locations[0];
  
    CLLocationCoordinate2D oldCoordinate = newLocation.coordinate;
  
    NSLog(@"旧的经度：%f,旧的纬度：%f",oldCoordinate.longitude,oldCoordinate.latitude);

    
 
    //    CLLocation *newLocation = locations[1];
 
    //    CLLocationCoordinate2D newCoordinate = newLocation.coordinate;
 
    //    NSLog(@"经度：%f,纬度：%f",newCoordinate.longitude,newCoordinate.latitude);

    

    // 计算两个坐标距离

    //    float distance = [newLocation distanceFromLocation:oldLocation];

    //    NSLog(@"%f",distance);

    

    [manager stopUpdatingLocation];
 
    

    //------------------位置反编码---5.0之后使用-----------------

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder reverseGeocodeLocation:newLocation

                   completionHandler:^(NSArray *placemarks, NSError *error){
                  
                       
              
                       for (CLPlacemark *place in placemarks)
                       {
               
                   
                           NSLog(@"name,%@",place.name);                       // 位置名
                      
                                             NSLog(@"thoroughfare,%@",place.thoroughfare);       // 街道
               
                                            NSLog(@"subThoroughfare,%@",place.subThoroughfare); // 子街道
                        
                                         NSLog(@"locality,%@",place.locality);               // 市
                   
                                           NSLog(@"subLocality,%@",place.subLocality);         // 区
                        
                                               NSLog(@"country,%@",place.country);                 // 国家
                       
                       }
                    
                       
                   
                   }];

    

    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}




#pragma mark IDFA
- (NSString *) idfa;
{
    return [[[ASIdentifierManager sharedManager]advertisingIdentifier]UUIDString];
}

#pragma mark MAC
- (NSString *) macaddress
{
    
    int                    mib[6];
    
    size_t                len;
    
    char                *buf;
    
    unsigned char        *ptr;
    
    struct if_msghdr    *ifm;
    
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    
    mib[1] = AF_ROUTE;
    
    mib[2] = 0;
    
    mib[3] = AF_LINK;
    
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0)
    {
        
        printf("Error: if_nametoindex error/n");
        
        return NULL;
        
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
    {
        
        printf("Error: sysctl, take 1/n");
        
        return NULL;
        
    }
    
    if ((buf = malloc(len)) == NULL)
    {
        
        printf("Could not allocate memory. error!/n");
        
        return NULL;
        
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
    {
        
        printf("Error: sysctl, take 2");
        
        return NULL;
        
    }
    
    ifm = (struct if_msghdr *)buf;
    
    sdl = (struct sockaddr_dl *)(ifm + 1);
    
    ptr = (unsigned char *)LLADDR(sdl);
    
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    
    return [outstring uppercaseString];
    
}


//判断今天还是昨天
- (void)setTimestamp:(NSDate *)date
{

    NSString *dateString=[NSDateFormatter localizedStringFromDate:date
                                                        dateStyle:kCFDateFormatterMediumStyle
                                                        timeStyle:NSDateFormatterShortStyle];
    
    
    NSLog(@"may%@",dateString);
    NSString *timesString=[NSDateFormatter localizedStringFromDate:date
                                                         dateStyle:kCFDateFormatterNoStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
    NSLog(@"%@",timesString);
 

    
    NSTimeInterval late=[date timeIntervalSince1970]*1;
    NSDate *dat=[NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSTimeInterval cha=now-late;
    NSString *astr;
    
    int a=86400;
    int addTime = 28800;
    

    long int data0 =(long int)late;
    long int data1 =(long int)now;
    long int data2 =(long int)cha;
    
    
    data0 = data0+addTime;
    data1 = data1+addTime;
    data2 = data2+addTime;
    
    
    
    int b0 = data0/a;//商
    float c0 = data0%a;//余数
    
    int b1 = data1/a;//商
    float c1 = data1%a;//余数
    

    
    NSLog(@"商_%d 余数_%f",b0,c0);
    
    NSLog(@"%ld:%ld:%ld",data0,data1,data2);
    
    
    int dif = b1-b0;//现在的减去之前的
    
    
    NSLog(@"差：%d",dif);
    
    
    if (dif==0)
    {
        NSLog(@"同一天");
        
        
//        astr=[NSString stringWithFormat:@"%f",cha/60];
//        
//        NSLog(@"__%@",timesString);
//        
//        astr = [astr substringToIndex:astr.length-7];
//        
//        
        
        astr = [NSString stringWithFormat:@"今天  %@",timesString];
        
//    
//        // int num= [timeString intValue];
//        astr = [NSString stringWithFormat:@"今天   %@",astr];
        
        NSLog(@"___%@",astr);

    }
    if (dif==1)
    {
        
        
        astr = [NSString stringWithFormat:@"昨天  %@",timesString];
        
        
        NSLog(@"昨天");
    }
    if (dif==2)
    {
        NSLog(@"前天");
        
        astr = [NSString stringWithFormat:@"前天  %@",timesString];
    }
    else
    {
        
        
        NSLog(@"显示详细时间:%d",dif);
        
        astr = [NSString stringWithFormat:@"%@",timesString];
        
        NSLog(@"%@",astr);
    }
    
//    
//    if (cha/3600<1)
//    {
    
        
//        if (num <= 1) {
//         
//         timeString = [NSString stringWithFormat:@"%@",timesString];
//         
//         }
//        
//        if (num <= 1) {
//         
//         timeString = [NSString stringWithFormat:@"刚刚"];
//         
//         }else{
//         
//         timeString = [NSString stringWithFormat:@"%@分钟前", timeString];
//         
//         }
        
        
//    }
//    
//    if (cha/3600 > 1 && cha/86400 < 1)
//    {
//        
//        if ([refDateString isEqualToString:todayString])
//        {
//            astr = [NSString stringWithFormat:@"%f", cha/3600];
//            
//            astr = [astr substringToIndex:astr.length-7];
//            
//            astr = [NSString stringWithFormat:@"今天   %@", astr];
//        }
//        else if ([refDateString isEqualToString:yesterdayString])
//        {
//            astr = [NSString stringWithFormat:@"%f", cha/3600];
//            
//            astr = [astr substringToIndex:astr.length-7];
//            
//            astr = [NSString stringWithFormat:@"昨天   %@", astr];
//        }
//        
//        
//        
//    }
//    
//    if (cha/86400 > 1)
//        
//    {
//        astr = [NSString stringWithFormat:@"%f", cha/86400];
//        
//        astr = [astr substringToIndex:astr.length-7];
//        
//        int num = [astr intValue];
//        
//        if (num < 2) {
//            
//            astr = [NSString stringWithFormat:@"昨天   %@",astr];
//            
//        }else if(num == 2){
//            
//            astr = [NSString stringWithFormat:@"前天   %@",astr];
//            
//        }
//        /*else if (num > 2 && num <7){
//         
//         timeString = [NSString stringWithFormat:@"%@天前", timeString];
//         
//         }else if (num >= 7 && num <= 10) {
//         
//         timeString = [NSString stringWithFormat:@"1周前"];
//         
//         }*/
//        else if(num > 2){
//            
//            astr = [NSString stringWithString:dateString];
//            
//        }
//        
//    }
//    
//    NSLog(@"当前时间：%@",astr);

}

-(void)wek
{
    //得到当前的日期
    NSDate *date = [NSDate date];
    NSLog(@"date:%@",date);
    
//    //得到(24 * 60 * 60)即24小时之前的日期，dateWithTimeIntervalSinceNow:
//    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow: -(24* 60* 60)];
//    NSLog(@"yesterday:%@",yesterday);
    
    
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init] ;
    //NSDate *date_ = [NSDate date];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    //int week=0;week1是星期天,week7是星期六;
    
    comps = [calendar components:unitFlags fromDate:date];
    int week = [comps weekday];
    
    NSString*weekStr=nil;
    
    switch (week)
    {
        case 1:
        {
            weekStr=@"星期天";
        }
            break;
        case 2:
        {
            weekStr=@"星期一";
        }
            break;
        case 3:
        {
            weekStr=@"星期二";
        }
            break;
        case 4:
        {
            weekStr=@"星期三";
        }
            break;
        case 5:
        {
            weekStr=@"星期四";
        }
            break;
        case 6:
        {
            weekStr=@"星期五";
        }
            break;
        case 7:
        {
            weekStr=@"星期六";
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"今天%@",weekStr);
    
    
    
    
    int year=[comps year];
    int month = [comps month];
    int day = [comps day];
    //[formatter setDateStyle:NSDateFormatterMediumStyle];
    //This sets the label with the updated time.
    int hour = [comps hour];
    int min = [comps minute];
    int sec = [comps second];
    NSLog(@"week%d",week);
    NSLog(@"year%d",year);
    NSLog(@"month%d",month);
    NSLog(@"day%d",day);
    NSLog(@"hour%d",hour);
    NSLog(@"min%d",min);
    NSLog(@"sec%d",sec);
    
    
    
    //得到毫秒
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    //[dateFormatter setDateFormat:@"hh:mm:ss"]
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSLog(@"Date%@", [dateFormatter stringFromDate:[NSDate date]]);
   
    
}



-(NSString*)week:(NSInteger)week
{
    NSString*weekStr=nil;
    if(week==1)
    {
        weekStr=@"星期天";
    }else if
        (week==2)
    {
        weekStr=@"星期一";
        
    }
    else if(week==3)
    {
        weekStr=@"星期二";
        
    }
    else if(week==4)
    {
        weekStr=@"星期三";
        
    }
    else if(week==5)
    {
        weekStr=@"星期四";
        
    }
    else if(week==6)
    {
        weekStr=@"星期五";
        
    }
    else if(week==7)
    {
        weekStr=@"星期六";
        
    }
    
    NSLog(@"%@",weekStr);
    return weekStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
