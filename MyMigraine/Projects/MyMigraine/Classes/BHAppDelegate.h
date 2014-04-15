
#import <UIKit/UIKit.h>
#import "BHGlobals.h"
#import "BHUIComponents.h"
#import "BHWebViewController.h"
#import "BHLearnTabViewController.h"
#import "BHMyDiaryViewController.h"
#import "BHIntroViewController.h"
#import "BHChartsViewController.h"
#import "BHTryExcedrinViewController.h"
#import "BHDiaryLogViewController.h"
#import "Flurry.h"
//#import "FlurryAnalytics.h"

@interface BHAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate> {
    UIWindow * _window;
    UITabBarController * _rootTabBarController;
    BHIntroViewController * _introViewController;
    UIImageView * _leftShadow;
    UIImageView * _rightShadow;
    
    BHLearnTabViewController * _pageLearn;
}

@property(nonatomic,readonly) UITabBarController * rootTabBarController; 

- (void)handleTermsAccepted;

@end

extern BHAppDelegate * g_AppDelegate;
