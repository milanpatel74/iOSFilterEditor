//
//  ShareViewController.m
//  IOSNoCrop
//
//  Created by herui on 2/7/14.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "ShareViewController.h"
#import "UIButton+helper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PRJ_DataRequest.h"
#import <Social/Social.h>
#import "GADInterstitial.h"
#import "RC_ShareTableViewCell.h"
#import "AppDelegate.h"
#import "UIImage+SubImage.h"
#import "CMethods.h"
#import "PRJ_Global.h"
#import "RC_moreAPPsLib.h"

#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define kToInstagramPath [kDocumentPath stringByAppendingPathComponent:@"NoCrop_Share_Image.igo"]
#define kToMorePath [kDocumentPath stringByAppendingPathComponent:@"NoCrop_Share_Image.jpg"]

@interface ShareViewController () <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    UIDocumentInteractionController *_documetnInteractionController;
    SLComposeViewController *slComposerSheet;
    
    NSInteger count;
    UIScrollView *scrollView;
    BOOL saved;
}

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToInstaBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToFac;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UILabel *watermarkLabel;

@property (weak, nonatomic) IBOutlet UIView *noCropBgView;
@property (weak, nonatomic) IBOutlet UILabel *lblNoCrop;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoCrop;
@property (weak, nonatomic) IBOutlet UIButton *btnNoCrop;
@property (weak, nonatomic) IBOutlet UISwitch *waterMarkSwitch;

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)leftBarButtonItemClick{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)rightBarButtonItemClick{
    if(saved)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:LocalizedString(@"alert_pic_have_not_save", nil) message:nil delegate:self cancelButtonTitle:LocalizedString(@"cancel", nil) otherButtonTitles:LocalizedString(@"confirm", nil), nil];
        alert.tag = 111;
        [alert show];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _saveBtn.enabled = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInteger:count+1] forKey:showCount];
    [userDefault synchronize];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self createImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = colorWithHexString(@"#2f2f2f");

    _noCropBgView.layer.borderWidth = 3;
    _noCropBgView.layer.borderColor = colorWithHexString(@"#3b3b3b").CGColor;
    _noCropBgView.layer.cornerRadius = 10;
    _noCropBgView.backgroundColor = colorWithHexString(@"#2f2f2f");
    
    [_lblNoCrop setTextColor:colorWithHexString(@"#f8f8f8")];
    [_lblNoCrop setText:LocalizedString(@"btn_downLoadNoCrop_title", nil)];
    _lblNoCrop.numberOfLines = 0;
    [_watermarkLabel setTextColor:colorWithHexString(@"#a5a5a5")];
    _watermarkLabel.text = LocalizedString(@"show_app_watermark", nil);
    
    [_btnNoCrop setImage:[UIImage imageNamed:@"fe_icon_fg_normal"] forState:UIControlStateNormal];
    [_btnNoCrop setImage:[UIImage imageNamed:@"fe_icon_fg_pressed"] forState:UIControlStateHighlighted];
    [_btnNoCrop setTitle:LocalizedString(@"btn_downLoadNoCrop_title", nil) forState:UIControlStateNormal];
    [_btnNoCrop setTitleColor:colorWithHexString(@"#f8f8f8") forState:UIControlStateNormal];
    [_btnNoCrop setTitleColor:colorWithHexString(@"#ffffff") forState:UIControlStateHighlighted];
    _btnNoCrop.titleLabel.font = [UIFont systemFontOfSize:11];
    _btnNoCrop.titleLabel.numberOfLines = 0;
    _btnNoCrop.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    NSString *imageName = @"fe_btn_Share_facebook_normal";
    NSString *imageNameSel = @"fe_btn_Share_facebook_pressed";
    SEL action = @selector(shareToFacebook);
    
    [_shareToFac setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [_shareToFac setImage:[UIImage imageNamed:imageNameSel] forState:UIControlStateHighlighted];
    [_shareToFac addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    //nav init
    CGFloat itemWH = kNavBarH;
    UIButton *navBackItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemWH, itemWH)];
    [navBackItem setImage:[UIImage imageNamed:@"fe_icon_back_normal"] forState:UIControlStateNormal];
    [navBackItem setImage:[UIImage imageNamed:@"fe_icon_back_pressed"] forState:UIControlStateHighlighted];
    [navBackItem addTarget:self action:@selector(leftBarButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
    navBackItem.imageView.contentMode = UIViewContentModeCenter;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBackItem];
    
    UIButton *navRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemWH, itemWH)];
    [navRightBtn setImage:[UIImage imageNamed:@"fe_icon_home_normal"] forState:UIControlStateNormal];
    [navRightBtn setImage:[UIImage imageNamed:@"fe_icon_home_pressed"] forState:UIControlStateHighlighted];
    [navRightBtn addTarget:self action:@selector(rightBarButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
    navRightBtn.imageView.contentMode = UIViewContentModeCenter;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];
    
    UILabel *fontLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    fontLabel.text = LocalizedString(@"share", @"");
    fontLabel.font = [UIFont fontWithName:kNavTitleFontName size:kNavTitleSize];
    fontLabel.textColor = [UIColor whiteColor];
    fontLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = fontLabel;
    
    NSString *waterMark = [[NSUserDefaults standardUserDefaults] objectForKey:UDKEY_WATERMARKSWITCH];
    if(!waterMark ||(waterMark && [waterMark intValue]) )
    {
        [_waterMarkSwitch setOn:YES];
    }
    else
    {
        [_waterMarkSwitch setOn:NO];
    }
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(_watermarkLabel.frame)+20, kWinSize.width, kWinSize.height-CGRectGetMaxY(_watermarkLabel.frame)-20-kNavBarH);
    saved = NO;
    
    UIView *cellView = [[RC_moreAPPsLib shareAdManager] getShareView];
    cellView.center = CGPointMake(scrollView.frame.size.width/2.f, scrollView.frame.size.height/2.f);
    [scrollView addSubview:cellView];
}

#pragma mark -
#pragma mark 获取用户最新编辑完毕的图片
- (UIImage *)getTheBaseImage
{
    UIImage *theBestImage = [PRJ_Global shareStance].theBestImage;
    
    //是否加水印
    UIImageView *waterMarkImageView = nil;
    NSString *waterMark = [[NSUserDefaults standardUserDefaults] objectForKey:UDKEY_WATERMARKSWITCH];
    if(!waterMark ||(waterMark && [waterMark intValue]) )
    {
        CGFloat imageViewW = 261;
        CGFloat imageViewH = 41;
        
        CGFloat imageViewX = theBestImage.size.width - imageViewW-20;
        CGFloat imageViewY = theBestImage.size.height - imageViewH-20;
        waterMarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH)];
        waterMarkImageView.image = [UIImage imageNamed:@"Watermark_big"];
        
        UIGraphicsBeginImageContext(theBestImage.size);
        [theBestImage drawInRect:CGRectMake(0,0,theBestImage.size.width,theBestImage.size.height)]; // scales image to rect
        [waterMarkImageView.image drawInRect:waterMarkImageView.frame];
        theBestImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return theBestImage;
}

#pragma mark - action methods
#pragma mark 水印开关
- (IBAction)watermarkChange:(UISwitch *)sender
{
    _saveBtn.enabled = YES;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",sender.isOn] forKey:UDKEY_WATERMARKSWITCH];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 保存本地相册
-(void)createImage
{
    @autoreleasepool {
        //计算outputSize
        CGSize outputSize = CGSizeZero;
        
        switch ([PRJ_Global shareStance].outputResolutionType) {
            case kOutputResolutionType1080_1080:
            {
                switch (_aspectRatio)
                {
                    case kAspectRatioFree:
                        outputSize = CGSizeMake(1080 * [PRJ_Global shareStance].freeScale, 1080);
                        break;
                        
                    case kAspectRatio1_1:
                        outputSize = CGSizeMake(1080, 1080);
                        break;
                        
                    case kAspectRatio2_3:
                        outputSize = CGSizeMake(720, 1080);
                        break;
                        
                    case kAspectRatio3_2:
                        outputSize = CGSizeMake(1080, 720);
                        break;
                        
                    case kAspectRatio3_4:
                        outputSize = CGSizeMake(960, 1280);
                        break;
                        
                    case kAspectRatio4_3:
                        outputSize = CGSizeMake(1280, 960);
                        break;
                        
                    case kAspectRatio9_16:
                        outputSize = CGSizeMake(720, 1280);
                        break;
                        
                    case kAspectRatio16_9:
                        outputSize = CGSizeMake(1280, 720);
                        break;
                    default:
                        break;
                }
            }
                break;
            case kOutputResolutionType1660_1660:
            {
                switch (_aspectRatio) {
                    case kAspectRatioFree:
                        outputSize = CGSizeMake(1660 * [PRJ_Global shareStance].freeScale , 1660);
                        break;
                        
                    case kAspectRatio1_1:
                        outputSize = CGSizeMake(1660, 1660);
                        break;
                        
                    case kAspectRatio2_3:
                        outputSize = CGSizeMake(1280, 1920);
                        break;
                        
                    case kAspectRatio3_2:
                        outputSize = CGSizeMake(1920, 1280);
                        break;
                        
                    case kAspectRatio3_4:
                        outputSize = CGSizeMake(1440, 1920);
                        break;
                        
                    case kAspectRatio4_3:
                        outputSize = CGSizeMake(1920, 1440);
                        break;
                        
                    case kAspectRatio9_16:
                        outputSize = CGSizeMake(1080, 1920);
                        break;
                        
                    case kAspectRatio16_9:
                        outputSize = CGSizeMake(1920, 1080);
                        break;
                    default:
                        break;
                }
            }
                break;
            case kOutputResolutionType2160_2160:
            {
                outputSize = CGSizeMake(2160, 2160);
            }
                break;
            default:
                break;
        }
        
        CGSize contextSize = CGSizeMake(kOutputViewWH, kOutputViewWH);
        UIGraphicsBeginImageContextWithOptions(contextSize, YES, 1.0);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //去黑框
        {
            CGFloat scaleW = 1;
            CGFloat scaleH = 1;
            
            switch (_aspectRatio) {
                case kAspectRatioFree:
                    scaleW = [PRJ_Global shareStance].freeScale;
                    scaleH = 1;
                    break;
                    
                case kAspectRatio1_1:
                    break;
                    
                case kAspectRatio2_3:
                    scaleW = 2;
                    scaleH = 3;
                    break;
                    
                case kAspectRatio3_4:
                    scaleW = 3;
                    scaleH = 4;
                    break;
                    
                case kAspectRatio9_16:
                    scaleW = 9;
                    scaleH = 16;
                    break;
                    
                default:
                    break;
            }
            
            CGFloat w = image.size.width;
            CGFloat h = image.size.height;
            if(scaleW > scaleH){
                h = w / (scaleW / scaleH);
            }else{
                w = h * (scaleW / scaleH);
            }
            CGFloat x = (image.size.width - w ) * 0.5;
            CGFloat y = (image.size.height - h ) * 0.5;
            image = [image subImageWithRect:CGRectMake(x, y, w - 1, h)];
        }
        
        //指定像素
        image = [image rescaleImageToSize:outputSize];
        [PRJ_Global shareStance].theBestImage = image;
    }
}

- (IBAction)save
{
    showLoadingView(nil);
    [PRJ_Global event:@"share_save" label:@"Share"];
    [PRJ_Global shareStance].showBackMsg = NO;
    
    UIImage *theBestImage = [self getTheBaseImage];
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"library_not_availabel", @"")
                                                        message:LocalizedString(@"user_library_step", @"")
                                                       delegate:nil
                                              cancelButtonTitle:LocalizedString(@"confirm", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIImageWriteToSavedPhotosAlbum(theBestImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark 分享到instagram
- (IBAction)shareToInsta
{
    [PRJ_Global event:@"share_instagram" label:@"Share"];
    
    [PRJ_Global shareStance].showBackMsg = NO;
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:LocalizedString(@"instagram_not_installed", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:LocalizedString(@"confirm", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    //保存本地 如果已存在，则删除
    if([[NSFileManager defaultManager] fileExistsAtPath:kToInstagramPath]){
        [[NSFileManager defaultManager] removeItemAtPath:kToInstagramPath error:nil];
    }
    
    NSData *imageData = UIImageJPEGRepresentation([self getTheBaseImage], 0.8);
    [imageData writeToFile:kToInstagramPath atomically:YES];
    
    //分享
    NSURL *fileURL = [NSURL fileURLWithPath:kToInstagramPath];
    _documetnInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    _documetnInteractionController.delegate = self;
    _documetnInteractionController.UTI = @"com.instagram.exclusivegram";
    _documetnInteractionController.annotation = @{@"InstagramCaption":kShareHotTags};
    [_documetnInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

#pragma mark 分享到Line
- (void)shareToLine
{
    [PRJ_Global event:@"share_Line" label:@"Share"];
}

#pragma mark 分享到微信
- (void)shareToWeiXing
{
    [PRJ_Global event:@"share_winxin" label:@"Share"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"微信分享"
                                                             delegate:self
                                                    cancelButtonTitle:@"cancel"
                                               destructiveButtonTitle:@"朋友圈"
                                                    otherButtonTitles:@"会话", nil];
    [actionSheet showInView:self.view];
}

#pragma mark 分享到facebook
- (IBAction)shareToFacebook
{
    [PRJ_Global event:@"share_facebook" label:@"Share"];
    [PRJ_Global shareStance].showBackMsg = NO;

    slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    if([[NSFileManager defaultManager] fileExistsAtPath:kToMorePath]){
        [[NSFileManager defaultManager] removeItemAtPath:kToMorePath error:nil];
    }
    NSData *imageData = UIImageJPEGRepresentation([self getTheBaseImage], 0.8);
    [imageData writeToFile:kToMorePath atomically:YES];
    UIImage *image = [UIImage imageWithContentsOfFile:kToMorePath];
    
    [slComposerSheet setInitialText:kShareHotTags];
    [slComposerSheet addImage:image];

    __weak SLComposeViewController *bSlComposerSheet = slComposerSheet;
    [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
          [bSlComposerSheet dismissViewControllerAnimated:YES completion:Nil];
     }];
    
    if(slComposerSheet != nil){
        [self presentViewController:slComposerSheet animated:YES completion:nil];
    }else{
         [[[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings" delegate: nil cancelButtonTitle:LocalizedString(@"confirm", nil) otherButtonTitles:nil, nil] show];
    }

}


#pragma mark 分享到更多
- (IBAction)shareToMore
{
    [PRJ_Global event:@"share_more" label:@"Share"];
    [PRJ_Global shareStance].showBackMsg = NO;
    //保存本地 如果已存在，则删除
    if([[NSFileManager defaultManager] fileExistsAtPath:kToMorePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:kToMorePath error:nil];
    }
    
    NSData *imageData = UIImageJPEGRepresentation([self getTheBaseImage], 0.8);
    [imageData writeToFile:kToMorePath atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:kToMorePath];
    _documetnInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    _documetnInteractionController.delegate = self;
    _documetnInteractionController.UTI = @"com.instagram.photo";
    _documetnInteractionController.annotation = @{@"InstagramCaption":@"来自NoCrop"};
    [_documetnInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
}

#pragma mark 分享到NoCrop
- (IBAction)shareToNoCrop
{
    [PRJ_Global event:@"share_nocrop" label:@"Share"];
    NSURL *url = [NSURL URLWithString:@"RCFilterGrid://"];
    if(![[UIApplication sharedApplication] canOpenURL:url])
    {
        //弹下载提示框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LocalizedString(@"alert_downLoadNoCrop", nil) delegate:self cancelButtonTitle:LocalizedString(@"cancel",nil) otherButtonTitles:LocalizedString(@"download_and_install",nil), nil];
        [alert show];
        return;
    }
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 111) {
        if (buttonIndex == 0) {
            return;
        }
        else
        {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
    }
    if(buttonIndex == 0)    return;
    
    [PRJ_Global event:@"share_nocrop_download" label:@"Share"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kNoCropAppStoreURL]];
}

#pragma mark - 保存相册反馈
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    hideLoadingView();
    if(error == nil)
    {
        _saveBtn.enabled = NO;
        saved = YES;
        MBProgressHUD *hud = showMBProgressHUD(LocalizedString(@"save_success", nil), NO);
        hud.removeFromSuperViewOnHide = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            hideMBProgressHUD();
        });
    }
}

@end