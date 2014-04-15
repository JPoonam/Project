
#import "BHAppDelegate.h"
#import "BH.h"
#import "BHUIComponents.h"
#import "BHCategoryItemPicker.h"

//==================================================================================================================================
//==================================================================================================================================

BHAppDelegate * g_AppDelegate = nil;

@implementation BHAppDelegate

@synthesize rootTabBarController = _rootTabBarController;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateShadowsWithController:(UIViewController *)controller { 
    CGRect r = INRectInset(_window.bounds,0,[UIApplication sharedApplication].statusBarFrame.size.height,0,0);
    if (controller.navigationController && !controller.navigationController.navigationBarHidden) { 
        r = INRectInset(r, 0, INNavBarHeight, 0, 0);
    }

    BOOL bh_style_shouldShowSideShadows = NO;
    if ([controller respondsToSelector:@selector(bh_style_shouldShowSideShadows)]) { 
        bh_style_shouldShowSideShadows = [(id)controller bh_style_shouldShowSideShadows];
    }
    if (!bh_style_shouldShowSideShadows) { 
        _leftShadow.hidden = YES;
        _rightShadow.hidden = YES;
    } else {
        // left shadow
        if (!_leftShadow) { 
            UIImageView * iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_left.png"]]autorelease];
            [_window addSubview:iv];
            _leftShadow = iv;
            iv.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        }
        CGRect r1 = r;
        r1.size.width = _leftShadow.bounds.size.width;
        _leftShadow.frame = r1;

        // right shadow
        if (!_rightShadow) { 
            UIImageView * iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_right.png"]]autorelease];
            [_window addSubview:iv];
            _rightShadow = iv;
            iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        }
        // right shadow 
        r.origin.x = r.size.width - _rightShadow.bounds.size.width; 
        r.size.width = _rightShadow.bounds.size.width;
        _rightShadow.frame = r;
        _leftShadow.hidden = NO;
        _rightShadow.hidden = NO;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateShadows { 
    UINavigationController * ctrl = (id)_rootTabBarController.selectedViewController;
    [self updateShadowsWithController:ctrl.topViewController];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

//    Temp flurry account
//    [FlurryAnalytics startSession:@"YT4PQ2GJD6SC44978S37"];
    [Flurry startSession:@"XV57Z46PWMFHNC3KJWBJ"];
//       [Flurry startSession:@"XV57Z46PWMFHNC3KJWBJ"];
  
    g_AppDelegate = self;
    INInstallAlertedAssertionHandlerForCurrentThread();
    INEnableAlertedAssertionHandlerForInternalINLibThreads(YES);
    
    [INDateFormatter sharedFormatter].locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]; 
    [[INDateFormatter sharedFormatter] registerFormatterWithString:@"cccc, LLL d" key:BH_SIMPLE_DATE];
    [[INDateFormatter sharedFormatter] registerFormatterWithDateStyle:NSDateFormatterNoStyle  timeStyle:kCFDateFormatterShortStyle key:BH_HOURS];
    [[INDateFormatter sharedFormatter] registerFormatterWithString:@"cccc, LLLL d" key:BH_LONG_DATE];
    [[INDateFormatter sharedFormatter] registerFormatterWithString:@"d" key:BH_DAY];
    [[INDateFormatter sharedFormatter] registerFormatterWithString:@"LLLL" key:BH_MONTH];
    [[INDateFormatter sharedFormatter] registerFormatterWithString:@"LLLL yyyy" key:BH_MONTH_YEAR];
    [[INDateFormatter sharedFormatter] registerFormatterWithString:@"MM/dd/yyyy" key:BH_SHORT_DATE];
    
    // create and load from preferences main app engine
    g_BH = [BH new];
    [g_BH loadPreferences];
    
    // create the window
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    _window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    //DMI ios7 Change
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
//        _window.tintColor=[UIColor clearColor];
//        _window.tintColor=[UIColor inru_colorFromRGBA:0x227B40FF];
        [[UIButton appearance] setTintColor:[UIColor inru_colorFromRGBA:0x227B40FF]];
        [[UITabBar appearance] setTintColor:[UIColor inru_colorFromRGBA:0x227B40FF]];
        [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];

    }
    
 
    
    // UI
    NSAssert(!INIPadInterface(),@"not implemented for iPAD yet mk_e8800a3d_12cf_40ad_83cf_07ba9701bac7");

    UIViewController * _page1 = [BHMyDiaryViewController bh_tabPageControllerWithTitle:@"My Diary" imageName:@"diary.png"];
    UIViewController * _page2 = [BHChartsViewController bh_tabPageControllerWithTitle:@"Charts" imageName:@"charts.png"];
    UIViewController * _page3 = [BHDiaryLogViewController bh_tabPageControllerWithTitle:@"Diary Log" imageName:@"diary_log.png"];
    UIViewController * _page4 = [BHTryExcedrinViewController bh_tabPageControllerWithTitle:@"Try Excedrin" imageName:@"pills.png"];
    _pageLearn = [BHLearnTabViewController bh_tabPageControllerWithTitle:@"Learn" imageName:@"info.png"];

    _rootTabBarController = [UITabBarController new];
    _rootTabBarController.delegate = self;
    _rootTabBarController.viewControllers = [NSArray arrayWithObjects:
                 _page1.navigationController, 
                 _page2.navigationController, 
                 _page3.navigationController, 
                 _page4.navigationController, 
                 _pageLearn.navigationController, 
                  nil];
    _rootTabBarController.selectedIndex = 0;
    [self tabBarController:nil /* must be nil! */ shouldSelectViewController:_rootTabBarController.selectedViewController];
    
    // start working
    [g_BH onAppStart];
    
    // [self performSelector:@selector(testStart:) withObject:nil afterDelay:0.3];
    if (!g_BH.termsAccepted) {
        _introViewController = [[BHIntroViewController controllerWithDocument:@"terms"] retain];
        CGRect  r1 = INRectInset(screenBounds,0,[UIApplication sharedApplication].statusBarFrame.size.height,0,0);
        _introViewController.view.frame = r1;
        [_window addSubview:_introViewController.view];
        [self updateShadowsWithController:_introViewController];
    } else { 
        [_window addSubview:_rootTabBarController.view];
        [self updateShadows];
    }
    
    // show window
    [_window makeKeyAndVisible];
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [g_BH onAppDeactivating];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [g_BH onAppTerminateOrGoingBackground:NO];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BH_SHARED_SETTINGCHANGED_NOTIFICATION object:nil];
    [g_BH onAppGoingForeground];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [g_BH onAppActivating];     
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [g_BH onAppTerminateOrGoingBackground:YES]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)oldStatusBarFrame { 
    [self updateShadows];   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)introDidHide:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context { 
    [_introViewController.view removeFromSuperview];
    [_introViewController release];
    _introViewController = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleTermsAccepted {
    NSAssert(_introViewController,@"mk_3f8b87c4_b436_4a91_918b_cf7f7f602596"); 
    g_BH.termsAccepted = YES;
    [_window insertSubview:_rootTabBarController.view atIndex:0];

    [UIView beginAnimations:@"acceptTerms" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDidStopSelector:@selector(introDidHide:finished:context:)];
    {
        _introViewController.view.alpha = 0;
    }
    [UIView commitAnimations];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [g_BH release];
    [_rootTabBarController release]; 
    [_window release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)testStart:(id)sender { 
//}

#pragma mark -
#pragma mark UINavigationController delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController 
           animated:(BOOL)animated {
           
    BOOL hidden = NO;
    if ([viewController respondsToSelector:@selector(bh_style_shouldHideHeader)]) {  
        hidden = [(id)viewController bh_style_shouldHideHeader];
    }

    if ([viewController respondsToSelector:@selector(bh_style_setupHeader)]) {  
        [(id)viewController bh_style_setupHeader];
    } else { 
        [viewController bh_setStandardCaptionForNavItem];
    }

    [navigationController setNavigationBarHidden:hidden animated:YES];
    [self updateShadowsWithController:viewController];
}

//----------------------------------------------------------------------------------------------------------------------------------


#pragma mark -
#pragma mark UITabBarController delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UINavigationController *)viewController { 
    NSParameterAssert([viewController isKindOfClass:UINavigationController.class]);
    UIViewController * rootVC = [viewController.viewControllers objectAtIndex:0];
    if (tabBarController.selectedViewController != viewController) {
        BOOL firstTime = rootVC.bh_tabFirstTimeOpened;
        #ifdef DEBUG_LOG
            NSLog(@"NEW TAB: '%@', first time: %d", rootVC.title, firstTime);         
        #endif 
        if ([rootVC respondsToSelector:@selector(bh_becomeActiveTab:)]) { 
            [(id)rootVC bh_becomeActiveTab:firstTime]; 
        }
    } else {
        #ifdef DEBUG_LOG
            NSLog(@"RESELECT TAB: '%@'", rootVC.title);         
        #endif 
        if ([rootVC respondsToSelector:@selector(bh_reselectActiveTab)]) { 
            [(id)rootVC bh_reselectActiveTab]; 
        }
    }
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController { 
   [self updateShadows];
}

@end
