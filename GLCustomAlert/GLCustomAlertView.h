//
//  GLCustomAlertView.h
//  自定义提示框
//
//  Created by hy_les on 15/4/13.
//  Copyright (c) 2015年 JD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

#define KAlertWidth   282.0f
#define KAlertHeight  214.0f

#define  GLAlert [GLCustomAlertView shareInstance]


typedef void (^PhoneVerCodeBlock)(NSString *verCode);


@interface GLCustomAlertView : UIView

//弹出视图的动画(0、没有动画 1、从底部 2、从顶部 3、从中心)
typedef NS_ENUM(NSInteger, GLAlertTransitionStyle)
{
    GLAlertTransitionStyleNone = 0,
    GLAlertTransitionStyleFromBottom,
    GLAlertTransitionStyleFromTop,
    GLAlertTransitionStyleFromCenter,
    
};


//弹出视图的背景类型(0、成功的状态 1、失败的状态 2、充值 3、提现  4、公用的)
typedef NS_ENUM(NSInteger, GLAlertImageState)
{
    GLAlertImageStateSucceed = 0,
    GLAlertImageStateFailure,
    GLAlertImageStateRecharge,
    GLAlertImageStateWithdraw,
    GLAlertImageStateShare,
    GLAlertImageStatePublic,
};

@property (nonatomic, strong) dispatch_block_t leftBlock; //左侧按钮方法回调
@property (nonatomic, strong) dispatch_block_t rightBlock;//右侧按钮方法回调
@property (nonatomic, strong) dispatch_block_t verCodeBlock;//验证码按钮方法回调

@property (nonatomic, strong) dispatch_block_t wxfBlock; //分享微信好友
@property (nonatomic, strong) dispatch_block_t wxcBlock; //分享微信朋友圈
@property (nonatomic, strong) dispatch_block_t sinaBlock; //分享新浪微博
@property (nonatomic, strong) dispatch_block_t grayBgBlock; //灰色背景点击事件


@property (nonatomic, strong) PhoneVerCodeBlock phoneVerCodeCallBack;//验证码block

@property (nonatomic, assign) GLAlertTransitionStyle transitionStyle; //动画类型
@property (nonatomic, strong) UIButton * leftBtn;//左侧按钮
@property (nonatomic, strong) UIButton * rightBtn;//右侧按钮
@property (nonatomic, strong) BaseViewController * hasView;        //判断是否用左侧按钮的block
/*
 *获取单例对象方法
 */
+ (GLCustomAlertView *)shareInstance;

- (void)leftBtnClicked:(UIButton *)sender;

/*
 *初始化方法
 */
- (void)initWithImageState:(GLAlertImageState)imageState
                  title:(NSString *)title
          detailMessage:(NSString *)detailMessage
        leftButtonTitle:(NSString *)leftTitle
       rightButtonTitle:(NSString *)rightTitle
       transitionStyle:(GLAlertTransitionStyle)transitionStyle;

/*
 *含有textField的手机验证码类型的alert的初始化方法
 */
- (void)initWithImageStatePhoneCodeWithPhoneNum:(NSString *)phoneNun
                                      cardType:(NSString *)cardType
                                 useDisposeStr:(NSString *)disStr
                                   cardInfoStr:(NSString *)cardInfoStr
                                          fund:(NSString *)fund
                               leftButtonTitle:(NSString *)leftTitle
                              rightButtonTitle:(NSString *)rightTitle
                               transitionStyle:(GLAlertTransitionStyle)transitionStyle;

/*
 *显示方法
 */
- (void)show;

/*
 *手动隐藏方法
 */
- (void)handDismiss;

/*
 *显示方法可以自定义动画类型
 */
- (void)showWithTransitionStyle:(GLAlertTransitionStyle)style;


/*
 *设置灰色背景的是否可触发点击事件 默认是不可以
 */
- (void)setBgViewRespondDismiss:(BOOL)bgViewRespondDismiss;


/*
 *左侧按钮回调获取验证码（为验证码的情况下）
 */
-(void)phoneVerGet:(PhoneVerCodeBlock)block;

@end
















