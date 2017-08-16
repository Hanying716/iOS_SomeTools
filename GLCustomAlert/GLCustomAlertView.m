

//
//  GLCustomAlertView.m
//  自定义提示框
//
//  Created by hy_les on 15/4/13.
//  Copyright (c) 2015年 JD. All rights reserved.
//

#import "GLCustomAlertView.h"
#import "CustomButton.h"
#import "CustomTextField.h"

#import <QuartzCore/QuartzCore.h>

#define KLeftBtnImageName  @"case_go_bt1"
#define KRightBtnImageName @"case_go_bt2"

#import "AppDelegate.h"


static GLCustomAlertView * instance;

@interface GLCustomAlertView ()
{
    UILabel       * _titleLabel;//标题
    UILabel       * _detailLabel;//详情
    CustomButton  * _sendHint;//发送验证码按钮
CustomTextField   * _hintTextField;//输入验证码输入框
GLAlertImageState    alertImageState; //背景状态（决定背景图的类型）
    
    NSTimer       * _timer; //定时器
    NSInteger       _surplus; //验证码发送时间
    
            
}
@property (nonatomic, strong) UIView * bgView;//灰色背景图片
@property (nonatomic, assign) BOOL    respondDismiss;//标记是否响应点击事件
@property (nonatomic, assign) BOOL    isPhoneVerCodeType;//标记是否是手机验证码类型
/*
 *隐藏方法
 */
- (void)dismiss;

/*
 *隐藏方法可以自定义动画类型
 */
- (void)dismissWithTransitionStyle:(GLAlertTransitionStyle)style;

@end

@implementation GLCustomAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.bounds = CGRectMake(0, 0, KAlertWidth, KAlertHeight);
    }
    return self;
}

#pragma mark -
#pragma mark - 获取单利对象方法
+ (GLCustomAlertView *)shareInstance;
{
    if (instance==nil)
    {
        instance = [[GLCustomAlertView alloc]init];
        instance.bgView = [[UIView alloc]init];
        UIWindow *shareWindow = [UIApplication sharedApplication].keyWindow;
        [instance.bgView setFrame:shareWindow.frame];
        instance.bgView.alpha = .8;
        instance.bgView.userInteractionEnabled = YES;
        instance.bgView.backgroundColor =[UIColor grayColor];
        instance.respondDismiss = NO;
        instance.isPhoneVerCodeType = NO;
        [shareWindow addSubview:instance.bgView];
        [shareWindow addSubview:instance];
    }
    return instance;
}

#pragma mark -
#pragma mark - 普通类型的初始化方法
- (void)initWithImageState:(GLAlertImageState)imageState
                     title:(NSString *)title
             detailMessage:(NSString *)detailMessage
           leftButtonTitle:(NSString *)leftTitle
          rightButtonTitle:(NSString *)rightTitle
        transitionStyle:(GLAlertTransitionStyle)transitionStyle;
{
    
    //0.删除子views
    for (UIView * view  in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    self.bgView.userInteractionEnabled = YES;
    self.respondDismiss = NO;
    self.isPhoneVerCodeType = NO;
    
    //1.灰色背景图添加点击手势
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBgView:)];
    tap.numberOfTapsRequired = 1;
    [self.bgView addGestureRecognizer:tap];
    
    //2.alert的背景设置
    self.layer.cornerRadius = 5.0f;
    self.backgroundColor = [UIColor whiteColor];//设置默认的白色背景
    
    imageState = imageState;
    switch (imageState)
    {
        case 0:
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Public_popup background"]];
            break;
        case 1:
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Public_popup background2"]];
            break;
        default:
        {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Public_popup backgroundNone"]];
        }
            break;
    }
    
    //设置按钮的参考坐标
    CGRect btnRefRect = CGRectZero;
   
    //一：充值提现状态
    if (imageState == GLAlertImageStateRecharge || imageState == GLAlertImageStateWithdraw)
    {
        NSArray *titleArray = @[@{@"title":@"本次充值信息核实",@"firstTitle":@"储蓄卡:",@"secondTitle":@"充值金额:"},
                                @{@"title":@"本次提现信息核实",@"firstTitle":@"储蓄卡:",@"secondTitle":@"提现金额:"}];
        NSDictionary *titleDic = titleArray[0];
        if (imageState==3)
        {
            titleDic = titleArray[1];//提现
        }
        
        //创建label
        float gapX = 10;//距离左右侧间隔
        float gapY = 70;//距离上侧间隔
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(gapX, gapY, CGRectGetWidth(self.bounds)-2*gapX, 30)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = 1;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = titleDic[@"title"];
        
        //两个橘色背景view
        float lableGapY = 2;//label间间距
        CGRect firstRect   = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), KAlertWidth, 20);
        CGRect secondRect  = CGRectMake(0, CGRectGetMaxY(firstRect)+lableGapY, KAlertWidth, 20);
        
        UIView *firstView = [[UIView alloc]initWithFrame:firstRect];
        firstView.backgroundColor = [UIColor colorWithHue:0.06 saturation:0.73 brightness:1 alpha:1];
        
        UIView *secondView = [[UIView alloc]initWithFrame:secondRect];
        secondView.backgroundColor = [UIColor colorWithHue:0.06 saturation:0.73 brightness:1 alpha:1];
        
        //左侧两个信息label
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_titleLabel.frame),  60,  20)];
        firstLabel.text = titleDic[@"firstTitle"];
        firstLabel.font = [UIFont systemFontOfSize:12.0f];
        firstLabel.textColor = [UIColor whiteColor];
        firstLabel.backgroundColor = [UIColor clearColor];
        
        
        UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(firstLabel.frame)+lableGapY,  60,  20)];
        secondLabel.text = titleDic[@"secondTitle"];
        secondLabel.font = [UIFont systemFontOfSize:12.0f];
        secondLabel.textColor = [UIColor whiteColor];
        secondLabel.backgroundColor = [UIColor clearColor];
        
        //右侧传入参数label
        CGRect bankLabelFrame = firstLabel.frame;
        bankLabelFrame.origin.x = 120;
        bankLabelFrame.size.width = KAlertWidth-120-20;
    
        UILabel *bankLabel = [[UILabel alloc]initWithFrame:bankLabelFrame];
        bankLabel.backgroundColor = firstLabel.backgroundColor;
        bankLabel.font = [UIFont systemFontOfSize:12.0f];
        bankLabel.textColor = [UIColor whiteColor];
        bankLabel.text = title;
        
        CGRect moneyLabelFrame = secondLabel.frame;
        moneyLabelFrame.origin.x = 120;
        moneyLabelFrame.size.width = KAlertWidth -120-20;
        _detailLabel = [[UILabel alloc]initWithFrame:moneyLabelFrame];
        _detailLabel.backgroundColor = secondLabel.backgroundColor;
        _detailLabel.font = [UIFont systemFontOfSize:12.0f];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.text = detailMessage;
        
        
        [self addSubview:_titleLabel];
        [self addSubview:firstView];
        [self addSubview:secondView];
        [self addSubview:firstLabel];
        [self addSubview:secondLabel];
        [self addSubview:bankLabel];
        [self addSubview:_detailLabel];
        
        btnRefRect = _detailLabel.frame;//按钮参考坐标赋值
        
        _titleLabel = nil;
        firstView  = nil;
        secondView = nil;
        firstLabel = nil;
        bankLabel  = nil;
        _detailLabel = nil;
        
        
        //5、两个按钮的设置
        CGSize btSize = CGSizeMake(116, 34);
        
        float  gapToAboveY = (KAlertHeight - (CGRectGetHeight(btnRefRect)+btnRefRect.origin.y) - btSize.height)/2;//距离上面labelY轴上的距离
        float  gapBtX = (KAlertWidth - btSize.width*2)/3;//距离两侧以及按钮间的间隔
        CGRect leftBtnFrame  = CGRectMake(gapBtX,btnRefRect.origin.y+CGRectGetHeight(btnRefRect)+gapToAboveY,btSize.width,btSize.height);
        CGRect rightBtnFrame = CGRectMake(KAlertWidth-gapBtX-btSize.width,leftBtnFrame.origin.y,btSize.width,btSize.height);
        
        //两个按钮的文字都有
        if (leftTitle !=nil && rightTitle !=nil)
        {
            //a.两个按钮都被赋值的情况
            //左侧按钮
            _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftBtn setFrame:leftBtnFrame];
            [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
            [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //右侧按钮
            _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightBtn setFrame:rightBtnFrame];
            [_rightBtn setTitle:rightTitle forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            _leftBtn.layer.masksToBounds = _rightBtn.layer.masksToBounds = YES;
            _leftBtn.layer.cornerRadius = _rightBtn.layer.cornerRadius = 5.0f;
            
            [self addSubview:_leftBtn];
            [self addSubview:_rightBtn];
        }
        //仅有一个按钮或者没有按钮
        else
        {
            //b.两个按钮中只给一个按钮赋值
            if ((leftTitle==nil&&rightTitle!=nil)||(leftTitle!=nil&&rightTitle==nil))
            {
                if (leftTitle==nil)
                {
                    leftTitle = rightTitle;
                }
                CGSize singleBtnSize = CGSizeMake(200, 40);//单个按钮的大小的设置
                float  gapX = (KAlertWidth -singleBtnSize.width)/2;
                CGRect sigleBtnFrame = CGRectMake(gapX, leftBtnFrame.origin.y, singleBtnSize.width, singleBtnSize.height);
                _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [_leftBtn setFrame:sigleBtnFrame];
                _leftBtn.layer.masksToBounds = YES;
                _leftBtn.layer.cornerRadius = 5.0f;
                [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
                [self addSubview:_leftBtn];
                
            }
            //c.两个按钮都不存在的情况
        }
        
        //设置背景图片和文字颜色
        [_leftBtn  setBackgroundImage:[UIImage imageNamed:KLeftBtnImageName] forState:UIControlStateNormal];
        [_rightBtn setBackgroundImage:[UIImage imageNamed:KRightBtnImageName]forState:UIControlStateNormal];
        //设置按钮的方法
        [_leftBtn  addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //6.设置弹出类型
        self.transitionStyle = transitionStyle;
        
        
        //7.将view置为空
        _leftBtn  = nil;
        _rightBtn = nil;
        _titleLabel = nil;
        _detailLabel = nil;
        self.leftBlock = nil;
        self.rightBlock = nil;

        
        
    }
    
    //up by mengxin
    //分享弹出框
    else if (imageState == GLAlertImageStateShare)
    {
        //3.标题设置
        float leftGap  = 10;//距离左侧间隔
        float rightGap = 10;//距离右侧间隔
        float gapToTitleY = 2;//两个label的间距
        
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftGap, 80, CGRectGetWidth(self.bounds)-leftGap-rightGap, 30)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:17.0f];
        _detailLabel.numberOfLines = 0;
        _detailLabel.textAlignment = 1;
        _detailLabel.adjustsFontSizeToFitWidth = YES;
        _detailLabel.minimumScaleFactor = 0.8;
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.text = detailMessage;
        [self addSubview:_detailLabel];
        
        
        UIButton *wxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        wxBtn.frame = CGRectMake(30, 130, 52, 70);
        wxBtn.tag = 191;
        [wxBtn addTarget:self action:@selector(ShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [wxBtn setImage:[UIImage imageNamed:@"wxhy"] forState:UIControlStateNormal];
        [self addSubview:wxBtn];
        
        UIButton *wxPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        wxPBtn.frame = CGRectMake(115, 130, 52, 70);
        wxPBtn.tag = 192;
        [wxPBtn addTarget:self action:@selector(ShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [wxPBtn setImage:[UIImage imageNamed:@"wxpyq"] forState:UIControlStateNormal];
        [self addSubview:wxPBtn];
        
        UIButton *sinaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sinaBtn.frame = CGRectMake(200, 130, 52, 70);
        sinaBtn.tag = 193;
        [sinaBtn addTarget:self action:@selector(ShareAction:) forControlEvents:UIControlEventTouchUpInside];
        [sinaBtn setImage:[UIImage imageNamed:@"sinaShare"] forState:UIControlStateNormal];
        [self addSubview:sinaBtn];
        
        _detailLabel  = nil;
        wxBtn = nil;
        wxPBtn = nil;
        sinaBtn = nil;
        self.wxfBlock = nil;
        self.wxcBlock = nil;
        self.sinaBlock = nil;
        self.grayBgBlock = nil;

        
    }

    //二：成功失败或者通用的状态
    else
    {
        //3.标题设置
        float leftGap  = 75;//距离左侧间隔
        float rightGap = 10;//距离右侧间隔
        float gapToTitleY = 2;//两个label的间距
        
        CGRect titleLabelFrame = CGRectMake(leftGap, 70, CGRectGetWidth(self.bounds)-leftGap-rightGap, 30);
        if (title!=nil)
        {
            _titleLabel = [[UILabel alloc]initWithFrame:titleLabelFrame];
            _titleLabel.backgroundColor =[UIColor clearColor];
            _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
            _titleLabel.textAlignment = 0;
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.text = title;
            [self addSubview:_titleLabel];
        }
        
        //4.详情设置
        CGRect  detailLabelFrame = CGRectZero;
        if (!_titleLabel)
        {
            //titleLabel 不存在的情况
            CGRect temFrame = titleLabelFrame;
            temFrame.size.height += 45;
            temFrame.origin.y = 70;
            detailLabelFrame = temFrame;
            
        }
        else
        {
            //titleLabel 存在的情况
            detailLabelFrame = CGRectMake(leftGap,CGRectGetMaxY(_titleLabel.frame)+gapToTitleY, CGRectGetWidth(self.bounds)-leftGap-rightGap, 50);
        }
        
        if (detailMessage!=nil)
        {
            _detailLabel = [[UILabel alloc]initWithFrame:detailLabelFrame];
            _detailLabel.backgroundColor = [UIColor clearColor];
            _detailLabel.font = [UIFont systemFontOfSize:17.0f];
            _detailLabel.numberOfLines = 0;
            _detailLabel.textAlignment = 0;
            _detailLabel.adjustsFontSizeToFitWidth = YES;
            _detailLabel.minimumScaleFactor = 0.8;
            _detailLabel.textColor = [UIColor whiteColor];
            _detailLabel.text = detailMessage;
            [self addSubview:_detailLabel];
        }
        
        //如果是公用的状态下需要将label设为中心
        if (imageState == GLAlertImageStatePublic)
        {
            if (_titleLabel)
            {
                CGPoint titleCenter = _titleLabel.center;
                titleCenter.x = KAlertWidth/2;
                _titleLabel.center = titleCenter;
                _titleLabel.textAlignment = 1;
            }
            if (_detailLabel)
            {
                CGPoint titleCenter = _detailLabel.center;
                titleCenter.x = KAlertWidth/2;
                _detailLabel.center = titleCenter;
                _detailLabel.textAlignment = 1;
            }
        }
        //按钮参考坐标赋值
        btnRefRect = _detailLabel == nil?_titleLabel.frame:_detailLabel.frame;
    
    
    //5、两个按钮的设置
    CGSize btSize = CGSizeMake(116, 34);
    
    float  gapToAboveY = (KAlertHeight - (CGRectGetHeight(btnRefRect)+btnRefRect.origin.y) - btSize.height)/2;//距离上面labelY轴上的距离
    float  gapBtX = (KAlertWidth - btSize.width*2)/3;//距离两侧以及按钮间的间隔
    CGRect leftBtnFrame  = CGRectMake(gapBtX,btnRefRect.origin.y+CGRectGetHeight(btnRefRect)+gapToAboveY,btSize.width,btSize.height);
    CGRect rightBtnFrame = CGRectMake(KAlertWidth-gapBtX-btSize.width,leftBtnFrame.origin.y,btSize.width,btSize.height);
    
    //两个按钮的文字都有
    if (leftTitle !=nil && rightTitle !=nil)
    {
        //a.两个按钮都被赋值的情况
        //左侧按钮
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:leftBtnFrame];
        [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //右侧按钮
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:rightBtnFrame];
        [_rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _leftBtn.layer.masksToBounds = _rightBtn.layer.masksToBounds = YES;
        _leftBtn.layer.cornerRadius = _rightBtn.layer.cornerRadius = 5.0f;
        
        [self addSubview:_leftBtn];
        [self addSubview:_rightBtn];
    }
    //仅有一个按钮或者没有按钮
    else
    {
        //b.两个按钮中只给一个按钮赋值
        if ((leftTitle==nil&&rightTitle!=nil)||(leftTitle!=nil&&rightTitle==nil))
        {
            if (leftTitle==nil)
            {
                leftTitle = rightTitle;
            }
            CGSize singleBtnSize = CGSizeMake(200, 40);//单个按钮的大小的设置
            float  gapX = (KAlertWidth -singleBtnSize.width)/2;
            CGRect sigleBtnFrame = CGRectMake(gapX, leftBtnFrame.origin.y, singleBtnSize.width, singleBtnSize.height);
            _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftBtn setFrame:sigleBtnFrame];
            _leftBtn.layer.masksToBounds = YES;
            _leftBtn.layer.cornerRadius = 5.0f;
            [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
            [self addSubview:_leftBtn];
            
        }
        //c.两个按钮都不存在的情况
    }
    
    //设置背景图片和文字颜色
    [_leftBtn  setBackgroundImage:[UIImage imageNamed:KLeftBtnImageName] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:[UIImage imageNamed:KRightBtnImageName]forState:UIControlStateNormal];
    //设置按钮的方法
    [_leftBtn  addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //6.设置弹出类型
    self.transitionStyle = transitionStyle;
    
    
    //7.将view置为空
    _leftBtn  = nil;
    _rightBtn = nil;
    _titleLabel = nil;
    _detailLabel = nil;
    self.leftBlock = nil;
    self.rightBlock = nil;

    }
}

#pragma mark - 
#pragma mark - ShareAction分享点击事件
- (void)ShareAction:(UIButton *)button
{
    switch (button.tag) {
        case 191:{
            [self dismiss];
            if (self.wxfBlock) {
                
                self.wxfBlock();
            }
            
            NSLog(@"点击微信好友");}
            break;
            
        case 192:
            [self dismiss];
            if (self.wxcBlock) {
                
                self.wxcBlock();
                
                NSLog(@"点击朋友圈");
            }
            break;
            
        case 193:
            [self dismiss];
            if (self.sinaBlock) {
                
                self.sinaBlock();
                
                NSLog(@"点击新浪微博");
            }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 含有textField的手机验证码类型的alert的初始化方法
- (void)initWithImageStatePhoneCodeWithPhoneNum:(NSString *)phoneNun
                                       cardType:(NSString *)cardType
                                  useDisposeStr:(NSString *)disStr
                                    cardInfoStr:(NSString *)cardInfoStr
                                           fund:(NSString *)fund
                                leftButtonTitle:(NSString *)leftTitle
                               rightButtonTitle:(NSString *)rightTitle
                                transitionStyle:(GLAlertTransitionStyle)transitionStyle;
{
    NSLog(@"subviews:%@",self.window.subviews);
    //0.删除子views
    for (UIView * view  in self.subviews)
    {
        [view removeFromSuperview];
    }
    

    self.bgView.userInteractionEnabled = YES;
    self.respondDismiss = YES;
    self.isPhoneVerCodeType = YES;
    
    //1.灰色背景图添加点击手势
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBgView:)];
    tap.numberOfTapsRequired = 1;
    [_bgView addGestureRecognizer:tap];
    
    //2.alert的背景设置
    self.layer.cornerRadius = 5.0f;

    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Public_popup backgroundNone"]];
    
    //3.设置按钮的参考坐标
    CGRect btnRefRect = CGRectZero;
    
    //4、布局
    //创建label
    float gapX = 10;//距离左右侧间隔
    float gapY = 70;//距离上侧间隔
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(gapX, gapY, CGRectGetWidth(self.bounds)-2*gapX, 30)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = 1;
    _titleLabel.numberOfLines = 2;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = [NSString stringWithFormat:@"验证码将发送至手机号：%@",phoneNun];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    
    //两个橘色背景view
    float lableGapY = 2;//label间间距
    CGRect firstRect   = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), KAlertWidth, 20);
    CGRect secondRect  = CGRectMake(0, CGRectGetMaxY(firstRect)+lableGapY, KAlertWidth, 20);
    
    UIView *firstView = [[UIView alloc]initWithFrame:firstRect];
    firstView.backgroundColor = [UIColor colorWithHue:0.06 saturation:0.73 brightness:1 alpha:1];
    
    UIView *secondView = [[UIView alloc]initWithFrame:secondRect];
    secondView.backgroundColor = [UIColor colorWithHue:0.06 saturation:0.73 brightness:1 alpha:1];
    
    //左侧两个信息label
    UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_titleLabel.frame),  60,  20)];
    firstLabel.text = [NSString stringWithFormat:@"%@:",cardType];//银行卡类型
    firstLabel.font = [UIFont systemFontOfSize:12.0f];
    firstLabel.textColor = [UIColor whiteColor];
    firstLabel.backgroundColor = [UIColor clearColor];
    
    
    UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(firstLabel.frame)+lableGapY,  60,  20)];
    secondLabel.text = disStr;//用途描述
    secondLabel.font = [UIFont systemFontOfSize:12.0f];
    secondLabel.textColor = [UIColor whiteColor];
    secondLabel.backgroundColor = [UIColor clearColor];
    
    //右侧传入参数label
    CGRect bankLabelFrame = firstLabel.frame;
    bankLabelFrame.origin.x = 120;
    bankLabelFrame.size.width = KAlertWidth-120-20;
    
    UILabel *bankLabel = [[UILabel alloc]initWithFrame:bankLabelFrame];
    bankLabel.backgroundColor = firstLabel.backgroundColor;
    bankLabel.font = [UIFont systemFontOfSize:12.0f];
    bankLabel.textColor = [UIColor whiteColor];
    bankLabel.text = cardInfoStr;//银行信息
    
    CGRect moneyLabelFrame = secondLabel.frame;
    moneyLabelFrame.origin.x = 120;
    moneyLabelFrame.size.width = KAlertWidth -120-20;
    _detailLabel = [[UILabel alloc]initWithFrame:moneyLabelFrame];
    _detailLabel.backgroundColor = secondLabel.backgroundColor;
    _detailLabel.font = [UIFont systemFontOfSize:12.0f];
    _detailLabel.textColor = [UIColor whiteColor];
    _detailLabel.text = fund;//还款金额数据
    
    //密码输入框
    if (_hintTextField) {
        
        [_hintTextField removeFromSuperview];
        _hintTextField = nil;
    }
    _hintTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(30, _detailLabel.bottom+5, 120, 20) withLeftImage:nil withTextPlaceHorder:@"请输入验证码" withImageFrame:CGRectMake(0, 0, 0, 0)];
    [_hintTextField setValue:[UIColor colorWithHue:0.13 saturation:0.08 brightness:0.93 alpha:1] forKeyPath:@"_placeholderLabel.color"];
    _hintTextField.background = [UIImage imageNamed:@"textFiled"];
    _hintTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_hintTextField setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    _hintTextField.delegate = self;
    [self addSubview:_hintTextField];
    
    //发送验证码
    float frameX = CGRectGetMaxX(_hintTextField.frame)+10;
    
    if (_sendHint) {
        [_sendHint removeFromSuperview];
        _sendHint = nil;
    }
    _sendHint = [CustomButton buttonWithType:UIButtonTypeCustom WithFrame:CGRectMake(frameX, _detailLabel.bottom+5, KAlertWidth-frameX-30, 20) withTitle:@"发送验证码" withAction:@selector(verCodeBtnClicked:) withTarget:self withbackGroundImage:nil];
    
    _sendHint.layer.masksToBounds = YES;
    _sendHint.layer.cornerRadius = 5.0f;

    _sendHint.backgroundColor = [UIColor whiteColor];
    [_sendHint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _sendHint.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_sendHint];
    
    
    [self addSubview:_titleLabel];
    [self addSubview:firstView];
    [self addSubview:secondView];
    [self addSubview:firstLabel];
    [self addSubview:secondLabel];
    [self addSubview:bankLabel];
    [self addSubview:_detailLabel];
    [self addSubview:_hintTextField];
    [self addSubview:_sendHint];
    
    btnRefRect = _sendHint.frame;//按钮参考坐标赋值

    _titleLabel = nil;
    firstView  = nil;
    secondView = nil;
    firstLabel = nil;
    bankLabel  = nil;
    _detailLabel = nil;

    self.verCodeBlock = nil;
    
    
    //5、两个按钮的设置
    CGSize btSize = CGSizeMake(116, 34);
    
    float  gapToAboveY = (KAlertHeight - (CGRectGetHeight(btnRefRect)+btnRefRect.origin.y) - btSize.height)/2;//距离上面labelY轴上的距离
    float  gapBtX = (KAlertWidth - btSize.width*2)/3;//距离两侧以及按钮间的间隔
    CGRect leftBtnFrame  = CGRectMake(gapBtX,btnRefRect.origin.y+CGRectGetHeight(btnRefRect)+gapToAboveY,btSize.width,btSize.height);
    CGRect rightBtnFrame = CGRectMake(KAlertWidth-gapBtX-btSize.width,leftBtnFrame.origin.y,btSize.width,btSize.height);
    
    //两个按钮的文字都有
    if (leftTitle !=nil && rightTitle !=nil)
    {
        //a.两个按钮都被赋值的情况
        //左侧按钮
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftBtn setFrame:leftBtnFrame];
        [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //右侧按钮
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setFrame:rightBtnFrame];
        [_rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _leftBtn.layer.masksToBounds = _rightBtn.layer.masksToBounds = YES;
        _leftBtn.layer.cornerRadius = _rightBtn.layer.cornerRadius = 5.0f;
        
        [self addSubview:_leftBtn];
        [self addSubview:_rightBtn];
    }
    //仅有一个按钮或者没有按钮
    else
    {
        //b.两个按钮中只给一个按钮赋值
        if ((leftTitle==nil&&rightTitle!=nil)||(leftTitle!=nil&&rightTitle==nil))
        {
            if (leftTitle==nil)
            {
                leftTitle = rightTitle;
            }
            CGSize singleBtnSize = CGSizeMake(200, 40);//单个按钮的大小的设置
            float  gapX = (KAlertWidth -singleBtnSize.width)/2;
            CGRect sigleBtnFrame = CGRectMake(gapX, leftBtnFrame.origin.y, singleBtnSize.width, singleBtnSize.height);
            _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftBtn setFrame:sigleBtnFrame];
            _leftBtn.layer.masksToBounds = YES;
            _leftBtn.layer.cornerRadius = 5.0f;
            [_leftBtn setTitle:leftTitle forState:UIControlStateNormal];
            [self addSubview:_leftBtn];
            
        }
        //c.两个按钮都不存在的情况
    }
    
    //设置背景图片和文字颜色
    [_leftBtn  setBackgroundImage:[UIImage imageNamed:KLeftBtnImageName] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:[UIImage imageNamed:KRightBtnImageName]forState:UIControlStateNormal];
    //设置按钮的方法
    [_leftBtn  addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //6.设置弹出类型
    self.transitionStyle = transitionStyle;
    
    //7.设置时间
    [_timer invalidate];
    _surplus = 60;
    _sendHint.userInteractionEnabled=YES;
    
    //8.将view置为空
    _leftBtn  = nil;
    _rightBtn = nil;
    _titleLabel = nil;
    _detailLabel = nil;
    self.leftBlock = nil;
    self.rightBlock = nil;
    

}



#pragma mark -
#pragma mark - 设置灰色背景的是否可触发点击事件
- (void)setBgViewRespondDismiss:(BOOL)bgViewRespondDismiss;
{
    self.respondDismiss = bgViewRespondDismiss;
}


#pragma mark -
#pragma mark - 点击灰色背景图的方法
- (void)tapBgView:(UITapGestureRecognizer *)tap
{
    //验证码状态
    if (self.isPhoneVerCodeType)
    {
         if (self.respondDismiss == YES)
         {
             if (_hintTextField!=nil) {
                 [_hintTextField resignFirstResponder];
             }
         }
    }
    else
    {
        if (self.respondDismiss == YES)
        {
            if (self.grayBgBlock) {
                
                self.grayBgBlock();
            }
            [self dismiss];
        }
    }
   
}


#pragma mark -
#pragma mark - 左侧按钮方法
- (void)leftBtnClicked:(UIButton *)sender
{
    if (_hintTextField!=nil) {
        [_hintTextField resignFirstResponder];
    }
    
    if (self.hasView) {
        
        [self dismiss];
        [self.hasView dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    //验证码状态的情况
    if (self.isPhoneVerCodeType)
    {
//        [self resetTimer];
        
        NSLog(@"验证码输入框：%@",_hintTextField.text);
        
        //字符串为空
        if ([Global isBlankString:_hintTextField.text])
        {
            //显示提示信息
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.userInteractionEnabled = NO;
            // Configure for text only and offset down
            hud.labelText = @"请输入验证码";
            hud.mode = MBProgressHUDModeText;
            hud.margin = 5.0f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:2];
            
        }
        else
        {
            //左侧确定按钮点击事件
            if (self.leftBlock) {
                
                self.leftBlock();
            }

        }
    }
    
    //不是验证码的情况
    else
    {
        [self dismiss];
        
        if (self.leftBlock)
        {
            self.leftBlock();
        }
    }
    
   
}

- (void)hidenView
{
    
}

#pragma mark -
#pragma mark - 右侧按钮方法
- (void)rightBtnClicked:(id)sender
{
    if (_hintTextField!=nil) {
        [_hintTextField resignFirstResponder];
    }
    
    //验证码状态
    if (self.isPhoneVerCodeType)
    {
        //重置时间
        [self resetTimer];
        [self handDismiss];
        
        if (self.rightBlock)
        {
            self.rightBlock();
        }
    }
    
    else
    {
        [self dismiss];
        if (self.rightBlock)
        {
            self.rightBlock();
        }
    }
    
}


#pragma mark -
#pragma mark - 验证码按钮方法
- (void)verCodeBtnClicked:(id)sender
{

    if (_hintTextField!=nil) {
        [_hintTextField resignFirstResponder];
    }
    
    //是验证码状态下
    if (self.isPhoneVerCodeType)
    {
        
        if(_surplus < 60){
            return;
        }
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(codeTimerMethod)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer fire];
        
        
        if (self.verCodeBlock)
        {
            self.verCodeBlock();
        }
        
    }

}


#pragma mark -
#pragma mark -  发送验证码按钮回调获取验证码
-(void)phoneVerGet:(PhoneVerCodeBlock)block;
{
    
    //是验证码状态下
    if (self.isPhoneVerCodeType)
    {
        self.phoneVerCodeCallBack = block;
        
        if (self.phoneVerCodeCallBack)
        {
            self.phoneVerCodeCallBack(_hintTextField.text);
        }

    }
    
}

#pragma  mark -定时器绑定的方法
- (void)codeTimerMethod
{
    _surplus--;
    _sendHint.titleLabel.font=[UIFont systemFontOfSize:13];
    //改变发送验证码按钮的标题
    [_sendHint setTitle:[NSString stringWithFormat:@"%ld秒再次发送",_surplus]
               forState:UIControlStateNormal];
    [_sendHint sizeToFit];
    _sendHint.userInteractionEnabled = NO;
    if (_surplus == 0) {
        
        [self resetTimer];
    }
    
}

#pragma mark -
#pragma mark - 时间重置
-(void)resetTimer
{
    [_timer invalidate];
    _surplus = 60;
    _sendHint.userInteractionEnabled=YES;
    [_sendHint setTitle:@"再次发送"
               forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - 显示方法
- (void)show;
{
    [self showWithTransitionStyle:self.transitionStyle];
}

#pragma mark -
#pragma mark - 隐藏方法
- (void)dismiss
{
    [self dismissWithTransitionStyle:self.transitionStyle];
}


#pragma mark -
#pragma mark - 隐藏方法
- (void)handDismiss
{
    if (self.isPhoneVerCodeType)
    {
        if (_hintTextField) {
            NSLog(@"删除输入框");
            [_hintTextField removeFromSuperview];
            _hintTextField = nil;
        }
        if (_sendHint) {
            
            NSLog(@"删除按钮");
            [_sendHint removeFromSuperview];
            _sendHint = nil;
        }
        
        if (self.phoneVerCodeCallBack)
        {
            NSLog(@"删除block");
             self.phoneVerCodeCallBack = nil;
        }
    
        [self dismiss];
    }
    
}

#pragma mark -
#pragma mark - 显示方法 可自定义动画类型
- (void)showWithTransitionStyle:(GLAlertTransitionStyle)style
{
    _bgView.hidden = NO;
    UIWindow *shareWindow = [UIApplication sharedApplication].keyWindow;
    self.center =CGPointMake(shareWindow.center.x, shareWindow.center.y);
    self.hidden = NO;
    switch (style)
    {
        case GLAlertTransitionStyleNone:
        {
            self.hidden = NO;
        }
            break;
        case GLAlertTransitionStyleFromBottom:
        {
            self.center = CGPointMake(shareWindow.center.x,CGRectGetHeight(shareWindow.bounds)+CGRectGetHeight(self.bounds));
            [UIView animateWithDuration:.35 animations:^{
               self.center = CGPointMake(shareWindow.center.x, shareWindow.center.y);
            }completion:^(BOOL finished)
             {
             }];
        }
            break;

        case GLAlertTransitionStyleFromTop:
        {
            self.center = CGPointMake(shareWindow.center.x, -CGRectGetHeight(self.bounds));
            [UIView animateWithDuration:.35 animations:^{
                 self.center = CGPointMake(shareWindow.center.x, shareWindow.center.y);
            }completion:^(BOOL finished)
             {
             }];
            
        }
            break;
        case GLAlertTransitionStyleFromCenter:
        {
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            [UIView animateWithDuration:.35 animations:^{
                self.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
               
            }];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 隐藏方法 可自定义动画类型
- (void)dismissWithTransitionStyle:(GLAlertTransitionStyle)style
{
    _bgView.hidden = YES;
    UIWindow *shareWindow = [UIApplication sharedApplication].keyWindow;
    switch (style)
    {
        case GLAlertTransitionStyleNone:
        {
            self.hidden = YES;
        }
            break;
        case GLAlertTransitionStyleFromBottom:
        {
            [UIView animateWithDuration:.35 animations:^{
                self.center = CGPointMake(shareWindow.center.x, shareWindow.center.y+shareWindow.frame.size.height);
            }completion:^(BOOL finished)
             {
             }];
        }
            break;
        case GLAlertTransitionStyleFromTop:
        {
            [UIView animateWithDuration:.35 animations:^{
                self.center = CGPointMake(shareWindow.center.x, shareWindow.center.y-shareWindow.frame.size.height);
            }completion:^(BOOL finished)
             {
             }];
            
        }
            break;
        case GLAlertTransitionStyleFromCenter:
        {
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [UIView animateWithDuration:.35 animations:^{
                self.transform = CGAffineTransformMakeScale(0.1, 0.1);
                
            } completion:^(BOOL finished) {
                if (finished)
                {
                    self.hidden = YES;
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }
            }];
            
        }
            break;
        default:
            break;
    }
    
}



#pragma mark -
#pragma mark - textField 代理方法开始
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    NSLog(@"开始输入");
    UIWindow *shareWindow = [UIApplication sharedApplication].keyWindow;
    self.center =CGPointMake(shareWindow.center.x, shareWindow.center.y-100);
    
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
{
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    UIWindow *shareWindow = [UIApplication sharedApplication].keyWindow;
    self.center =CGPointMake(shareWindow.center.x, shareWindow.center.y);
}

@end
