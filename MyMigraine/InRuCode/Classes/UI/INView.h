//!
//! @file INView.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! @copyright Copyright © 2010-2011 InRu
//! 
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//! 
//!     http://www.apache.org/licenses/LICENSE-2.0
//! 
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.
//!
//++

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

//! @brief JavaScript function for rescaling all web-document images to fit certain width 
#define IN_WEBVIEW_SCRIPT_SCALE_IMG_WIDTH \
    @"function inru_setImageWidths(_maxWidth_){\n"\
    @"    var width = 0, height = 0, aspect = 1;\n"\
    @"    var allImages = document.getElementsByTagName(\"img\");\n"\
    @"    for (var i = 0; i < allImages.length; i++){\n"\
    @"        width = allImages[i].width;\n"\
    @"        height = allImages[i].height;\n"\
    @"        if (width > _maxWidth_){\n"\
    @"            aspect = _maxWidth_/width;\n"\
    @"            width *= aspect;\n"\
    @"            height *= aspect;\n"\
    @"            allImages[i].style.maxWidth = width + \"px\";\n"\
    @"            allImages[i].style.maxHeight = height + \"px\";\n"\
    @"        }\n"\
    @"    }\n"\
    @"}\n"

//! @brief  JavaScript function for removing all target=blank href specifiers
#define IN_WEBVIEW_SCRIPT_SET_TARGET_BLANKED \
    @"function inru_setTargetBlanks(){\n"\
    @"    var allAnchors = document.getElementsByTagName(\"a\");\n"\
    @"    for (var i = 0; i < allAnchors.length; i++){\n"\
    @"        allAnchors[i].target = \"\";\n"\
    @"    }\n"\
    @"}\n"

//
// Usage
// 
// <script type="text/javascript">
// ... func bodies
// </script></head>
// <body onload="inru_setImageWidths();">
// 

//==================================================================================================================================
//==================================================================================================================================

@interface CALayer (INRU)

- (void)inru_setMaxContentScale;

@end


//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A set of common useful extensions for UIView class 
    
*/
@interface UIView (INRU)

//! @brief Center of self.bounds rect
@property (nonatomic,readonly) CGPoint inru_centerOfContent;

//! @brief Position view by specifying left top coordinate of it's frame
- (void)inru_setTopLeftPosition:(CGPoint)position;
  
//! @brief Returns YES if \c touches represent a single touch in the given area
- (BOOL)inru_singleTouchInArea:(CGRect)viewArea withTouches:(NSSet *)touches atPoint:(CGPoint *)touchedPoint;

//! @brief Returns the first found subview of the given class 
- (UIView *)inru_viewWithClass:(Class)viewClass;

//! @brief Returns the first found subview of the given class and the tag 
- (UIView *)inru_viewWithClass:(Class)viewClass tag:(NSInteger)tag;

//! @brief debug stuff
- (NSString *)inru_dumpString;

//! @brief debug stuff
- (void)inru_dumpSuperviews;

//! @brief debug stuff
- (void)inru_dumpSubviews; 

//! @brief debug stuff
- (void)inru_dumpSubviewsWithLayers; 
    
- (void)inru_removeAllSubviews;

- (void)inru_removeAllSubviewsWithTag:(NSInteger)tag;
    
@end

/*==================================================================================================================================*/
/*==================================================================================================================================*/

@interface UIResponder (INRU)

- (UIViewController*) inru_findParentController;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A set of common useful extensions for UIWebView class 
 
 */
@interface UIWebView (INRU)

//! @brief Creates a temporary file, saved here \c content and returns URL for that. It helps process history back-forward navigation
+ (NSURL *)inru_fakeLocalURLWithContent:(NSString *)content;
+ (NSURL *)inru_fakeLocalURLWithContent:(NSString *)content fileName:(NSString *)fileName;



//! @brief Clears the navigation history (via JavaScript)
- (void)inru_clearHistory;

/**
  @brief Returns current page url
 
  returns '/' for brand new created UIWebView, applewebdata://SOME_GUID/ for pages
  loaded with loadHTMlString and an URL for all others. 
 
  Note that inru_clearHistory does not clear it!
*/
- (NSString *)inru_currentPageURL;

- (NSString *)inru_documentTitle;

- (void)inru_disableScrolling;

- (void)inru_disableScrollingGradient;


//  вызывать при старте приложения! см имплементацию для большей информации 
+ (void)inru_setUserAgent:(NSString *)userAgent;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A set of common useful extensions for UIBarButtonItem class 
 
 */

@interface UIBarButtonItem (INRU)
    
//! @brief Creates a button with a small activity indicator
+ (UIBarButtonItem *)inru_buttonWithActivity;

//! @brief Access method to activity indicator for button created with the inru_buttonWithActivity call 
- (UIActivityIndicatorView *)inru_activityIndicator;

+ (id)inru_backButtonWithTitle:(NSString *)title;


@end


//==================================================================================================================================
//==================================================================================================================================

@interface INButton : UIButton { 
    NSInteger _tag2;
    NSInteger _groupIndex;
    CGSize _highlightedTitleAndImageOffset;
    id _tagObject;
}

// ничего особенного, но очень часто это бывает нужно. Первый таг используется для поиска с viewWithTag, второй - для привязки контента
@property(nonatomic) NSInteger tag2;

// любой контент, аналог userInfo
@property(nonatomic, retain) id tagObject;

// если groupIndex != 0 тогда кнопку можно использовать как радиобаттон - установка selected в YES переключает остальные кнопки группы в selected = NO
// поиск группы осуществляется в среди соседей по вьюхе (self.superview.subviews)
@property(nonatomic) NSInteger groupIndex;

// первая кнопка с тем же groupIndex и selected == YES (в том числе и данная кнопка)
// поиск группы осуществляется в среди соседей по вьюхе (self.superview.subviews)
- (INButton *)selectedGroupButton;

@property(nonatomic) CGSize highlightedTitleAndImageOffset;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface UIAlertView (INRU)

+ (id) inru_showAlertWithMessage:(NSString *)message;
+ (id) inru_showAlertWithTitle:(NSString*)title message:(NSString*)message;

@end

/*==================================================================================================================================*/
/*==================================================================================================================================*/

@interface INAlertView : UIAlertView {
@private
    id  _userInfo;
}

/* Бывает удобно передавать некую контекстную информацию делегату */
@property (nonatomic, retain) id userInfo;

@end

/*==================================================================================================================================*/
/*==================================================================================================================================*/

typedef enum { 
    INNavigationBarBGStyleNative,    // as OS does
    INNavigationBarBGStyleImage,     // use backgroundImage property
    INNavigationBarBGStyleSolidColor // use UINavigationBar.backgroundColor property
} INNavigationBarBGStyle;

@interface INCustomNavigationBar : UINavigationBar {
	UIImage *_backgroundImage;
    INNavigationBarBGStyle _backgroundStyle;
}

- (id)initWithBackgroundImage:(UIImage*)image;

@property(nonatomic) INNavigationBarBGStyle backgroundStyle;
@property(nonatomic,retain) UIImage * backgroundImage;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface UINavigationController (INRU)

- (void)inru_setNavBarBackgroundImage:(UIImage*)image;
- (void)inru_setNavBarBackgroundColor:(UIColor*)color;

@end

//==================================================================================================================================
//==================================================================================================================================

@class INOverlayViewController;

typedef enum { 
    INOverlayCancelExitCode = 0,
    INOverlayCustomExitCode = 1000, // добавлять свои коды начиная с этого
} INOverlayDismissCode;

//==================================================================================================================================
//==================================================================================================================================

@protocol INOverlayViewControllerDelegate 

- (void)inoverlayController:(INOverlayViewController *)overlayController dismissedWithCode:(INOverlayDismissCode)code;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INOverlayViewController : UIViewController { 
    UIViewController * _parentOverlayViewController1;
    id<INOverlayViewControllerDelegate> _overlayDelegate;
    NSTimeInterval _overlayAnimationDuration;
    // INOverlayDismissCode _exitCode;
}

// nо же самое, но для совместимости оставлено (случай, когда parentViewController == delegate)
- (void)layOverViewController:(UIViewController<INOverlayViewControllerDelegate> *)parentViewController;

- (void)layOverViewController:(UIViewController *)parentViewController delegate:(id<INOverlayViewControllerDelegate>)delegate animated:(BOOL)animated;
- (void)dismissWithCode:(INOverlayDismissCode)code animated:(BOOL)animated;

@end

