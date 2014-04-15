//!
//! @file INView.m
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


#import "INView.h"
#import "INCommonTypes.h"
#import "INGraphics.h"

@implementation CALayer (INRU)

- (void)inru_setMaxContentScale {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000	
    if (INSystemVersionEqualsOrGreater(4,0,0) ){  
        self.contentsScale = INGraphicsScreenScale();
    }
#endif
}

- (NSString *)inru_dumpString { 
    Class cl = [self class];
    NSString * classDescription = [cl description];
    while (1) {
        if (cl == CALayer.class) { 
            break;    
        }
        cl = [cl superclass];
        if (cl) { 
            classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
        } else {
            break;    
        }
    }
    NSString * result = [NSString stringWithFormat:@"%@%@ %@ Opq:%d",
                            (self.name ? [NSString stringWithFormat:@"'%@'",self.name] : @""),
                            classDescription, NSStringFromCGRect(self.frame),
                         self.opaque];
    return result;
}

- (void)inru_dumpSublayersWithIndent:(NSInteger)indent { 
    NSMutableString * indentStr = [NSMutableString string];
    for (int i =0; i < indent; i++) { 
        [indentStr appendString:@"   "];    
    }
    int i = 0;
    if (self.sublayers.count == 1) { 
        NSLog(@"%@%@",indentStr,[[self.sublayers objectAtIndex:0] inru_dumpString]);
        [[self.sublayers objectAtIndex:0] inru_dumpSublayersWithIndent:indent + 1];
    } else
    for (CALayer * l in self.sublayers) {     
        NSLog(@"%@%d. %@",indentStr,i++,[l inru_dumpString]);
        [l inru_dumpSublayersWithIndent:indent + 1 ];
    }
}

@end


@implementation UIView (INRU)

- (CGPoint)inru_centerOfContent { 
    CGSize sz = self.bounds.size;
    return CGPointMake(sz.width / 2, sz.height / 2);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_setTopLeftPosition:(CGPoint)position {
	CGSize size = self.bounds.size;
	self.center = CGPointMake(position.x + size.width/2, position.y + size.height/2);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_singleTouchInArea:(CGRect)viewArea withTouches:(NSSet *)touches 
                        atPoint:(CGPoint *)touchedPoint { 
    NSUInteger numTaps = [[touches anyObject] tapCount];
    if (numTaps == 1){
        UITouch * touch = [touches anyObject];
        CGPoint l = [touch locationInView:self];
        if (CGRectContainsPoint(viewArea, l)){
            if (touchedPoint){ 
                *touchedPoint = l;    
            }
            return YES;
        }
    }
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)inru_viewWithClass:(Class)viewClass { 
    for (UIView * v in self.subviews){ 
       if ([v isKindOfClass:viewClass]){
           return v;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)inru_viewWithClass:(Class)viewClass tag:(NSInteger)tag { 
    for (UIView * v in self.subviews){ 
        if ((v.tag == tag) && [v isKindOfClass:viewClass]){
            return v;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_dumpString { 
    Class cl = [self class];
    NSString * classDescription = [cl description];
    while (1) {
        if (cl == UIView.class || cl == UIWindow.class || cl == UIScrollView.class) { 
            break;    
        }
        cl = [cl superclass];
        if (cl) { 
            classDescription = [classDescription stringByAppendingFormat:@":%@", [cl description]];
        } else {
            break;    
        }
    }
    
    // static const char * YN[] = { "N", "Y" }; 
    NSString * moreDesription = @"";
    if ([self isKindOfClass:UIScrollView.class]) {
        moreDesription = [NSString stringWithFormat:@" (Content size: %@)", NSStringFromCGSize(((UIScrollView*)self).contentSize)];
    }
    
    NSString * result = [NSString stringWithFormat:@"%@ Tag:%d Opq:%d AutoRM:0x%X Visible:%d ExlTouch:%d UserInteraction:%d %@%@",classDescription,
                         self.tag, self.opaque, self.autoresizingMask, !self.hidden, self.exclusiveTouch, self.userInteractionEnabled, 
                         NSStringFromCGRect(self.frame),moreDesription];
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_dumpSuperviews {
    NSLog(@"<<< Superview hierarchy>>>");
    UIView * v = self;
    int i = 0;
    do {
        NSLog(@"%d. %@",i++,[v inru_dumpString]);
        v = v.superview;
    } while (v);
    NSLog(@" ");
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_dumpSubviewsWithIndent:(NSInteger)indent dumpLayers:(BOOL)dumpLayers{
    NSMutableString * indentStr = [NSMutableString string];
    for (int i =0; i < indent; i++) {
        [indentStr appendString:@"   "];
    }
    int i = 0;
    for (UIView * v in self.subviews) {
        NSLog(@"%@%d. %@",indentStr,i++,[v inru_dumpString]);
        if (dumpLayers) {
            NSLog(@"%@      %@",indentStr,[v.layer inru_dumpString]);
            [v.layer inru_dumpSublayersWithIndent:indent+3];
        }
        [v inru_dumpSubviewsWithIndent:indent + 1 dumpLayers:(BOOL)dumpLayers];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_dumpSubviewsWithLayers:(BOOL)dumpLayers {
    NSLog(@"<<< Subviews hierarchy>>>");
    NSLog(@"%@",[self inru_dumpString]);
    if (dumpLayers) {
        NSLog(@"   %@",[self.layer inru_dumpString]);
        [self.layer inru_dumpSublayersWithIndent:2];
    }
    [self inru_dumpSubviewsWithIndent:1 dumpLayers:dumpLayers];
    NSLog(@" ");
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_dumpSubviewsWithLayers {
    [self inru_dumpSubviewsWithLayers:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_dumpSubviews {
    [self inru_dumpSubviewsWithLayers:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_removeAllSubviews {
    NSArray * s = self.subviews;
    for (int i = s.count-1; i >=0; i--) {
        [[s objectAtIndex:i] removeFromSuperview];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_removeAllSubviewsWithTag:(NSInteger)tag {
    NSArray * s = self.subviews;
    for (int i = s.count-1; i >=0; i--) {
        UIView * v = [s objectAtIndex:i];
        if (v.tag == tag) {
            [v removeFromSuperview];
        }
    }
}


@end


/*==================================================================================================================================*/
/*==================================================================================================================================*/

@implementation UIResponder (INRU)

- (UIViewController*) inru_findParentController {
	UIResponder *responder = self;
	
	if ([self isKindOfClass:[UIViewController class]] && [(UIViewController*)self navigationController]) {
		NSArray *stackOfControllers = [[(UIViewController*)self navigationController] viewControllers];
		
		UIViewController *prevController = nil;
		for (UIViewController *c in stackOfControllers) {
			if (c == self) {
				return prevController;
			}
			
			prevController = c;
		}
	}
	else {
		while ((responder = [responder nextResponder])) {
			if ([responder isKindOfClass:[UIViewController class]]) {
				return (UIViewController*)responder;
			}
		}		
	}
	
	return (UIViewController*)nil;
}

@end



//==================================================================================================================================
//==================================================================================================================================

@implementation UIWebView (INRU)

+ (NSURL *)inru_fakeLocalURLWithContent:(NSString *)content fileName:(NSString *)fileName { 
   NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSError * error = nil;
    [content ? content :@"" writeToFile:path atomically:NO encoding:NSUnicodeStringEncoding error:&error];
    return [NSURL fileURLWithPath:path];
}

+ (NSURL *)inru_fakeLocalURLWithContent:(NSString *)content {
    return [self inru_fakeLocalURLWithContent:content fileName:@"inru.html"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_clearHistory {
    [self stringByEvaluatingJavaScriptFromString:@"history.clear()"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_currentPageURL {
    NSString * current = [self stringByEvaluatingJavaScriptFromString:@"location.href"];
    return current;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_documentTitle {
    NSString * title = [self stringByEvaluatingJavaScriptFromString:@"document.title"];
    return title;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_disableScrolling {
    for (id subview in self.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).scrollEnabled = NO;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_disableScrollingGradient {
    for (UIView * subview in self.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            for (UIView * subview2 in subview.subviews) { 
                if ([subview2 isKindOfClass:[UIImageView class]]) { 
                    subview2.hidden = YES;
                }
            }
            break;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------
// решение взято отсюда  http://www.mphweb.com/en/blog/easily-set-user-agent-uiwebview
// Комментарий там же: I have this code working, however when I call the function again, to change the UserAgent to something else, 
// UIWebView's do not update. In order to successfully update the UserAgent I need to remove/release the UIWebView and alloc/show it again.
//

+ (void)inru_setUserAgent:(NSString *)userAgent {  
    // Set user agent (the only problem is that we can't modify the User-Agent later in the program)
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    [dict release];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation UIBarButtonItem (INRU)

+ (UIBarButtonItem * )inru_buttonWithActivity { 
    return [[[UIBarButtonItem alloc] initWithCustomView:
                  [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease]
            ] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIActivityIndicatorView *)inru_activityIndicator { 
     return (UIActivityIndicatorView *)self.customView;   
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)inru_backButtonWithTitle:(NSString *)title { 
    return [[[UIBarButtonItem alloc] initWithTitle:title
                                             style: UIBarButtonItemStylePlain 
                                            target: nil
                                            action: nil] autorelease];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INButton

@synthesize tag2 = _tag2;
@synthesize tagObject = _tagObject;
@synthesize groupIndex = _groupIndex;
@synthesize highlightedTitleAndImageOffset = _highlightedTitleAndImageOffset;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_tagObject release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelected:(BOOL)value { 
    [super setSelected:value];
    if (self.selected && _groupIndex != 0) { 
         for (INButton * btn in self.superview.subviews) { 
              if ([btn isKindOfClass:INButton.class] && btn != self && btn.groupIndex == _groupIndex) { 
                  btn.selected = NO;
              }
         }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INButton *)selectedGroupButton { 
    if (self.selected) { 
        return self;
    }
    
    for (INButton * btn in self.superview.subviews) { 
        if ([btn isKindOfClass:INButton.class] && btn != self && btn.groupIndex == _groupIndex) { 
            if (btn.selected) { 
                return btn; 
            }
        }
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)titleRectForContentRect:(CGRect)contentRect { 
    CGRect r = [super titleRectForContentRect:contentRect];
    if (self.highlighted) { 
        r.origin.x += _highlightedTitleAndImageOffset.width;
        r.origin.y += _highlightedTitleAndImageOffset.height;
    }    
    return r;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)imageRectForContentRect:(CGRect)contentRect { 
    CGRect r = [super imageRectForContentRect:contentRect];
    if (self.highlighted) { 
        r.origin.x += _highlightedTitleAndImageOffset.width;
        r.origin.y += _highlightedTitleAndImageOffset.height;
    }    
    return r;
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation UIAlertView (INRU)

+ (id) inru_showAlertWithTitle:(NSString*)title message:(NSString*)message {
	UIAlertView *alertmsg = [[[UIAlertView alloc] initWithTitle:title 
														message:message 
													   delegate:nil 
											  cancelButtonTitle:nil 
											  otherButtonTitles:@"OK", nil] autorelease];
	[alertmsg show];
	return alertmsg;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id) inru_showAlertWithMessage:(NSString*)message {
	return [UIAlertView inru_showAlertWithTitle:nil message:message];
}

@end

/*==================================================================================================================================*/
/*==================================================================================================================================*/

@implementation INAlertView
@synthesize userInfo = _userInfo;

- (void) dealloc {
    [_userInfo release];
    [super dealloc];
}

@end

/*==================================================================================================================================*/
/*==================================================================================================================================*/

@implementation INCustomNavigationBar

@synthesize backgroundImage = _backgroundImage;
@synthesize backgroundStyle = _backgroundStyle;

//----------------------------------------------------------------------------------------------------------------------------------

- (id) initWithBackgroundImage:(UIImage*)image {
	if ((self = [super initWithFrame:CGRectZero])) {
		_backgroundImage = [image retain];
        _backgroundStyle = INNavigationBarBGStyleImage;
	}
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
	[_backgroundImage release];
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBackgroundImage:(UIImage *)value { 
    if (value != _backgroundImage) { 
        [_backgroundImage release];
        _backgroundImage = [value retain];
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBackgroundStyle:(INNavigationBarBGStyle)value {
    if (value!= _backgroundStyle) { 
        _backgroundStyle = value;
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) drawRect:(CGRect)rect {
    switch (_backgroundStyle) { 
        case INNavigationBarBGStyleImage:
            [_backgroundImage drawInRect:self.bounds];	
            break;
             
        case INNavigationBarBGStyleSolidColor:
            break;
        
        case INNavigationBarBGStyleNative:
            // not break here!!!
        default:
            [super drawRect:rect];
            break;
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation UINavigationController (INRU)

- (void) inru_setNavBarBackgroundImage:(UIImage*)image {
    [self setValue:[[[INCustomNavigationBar alloc] initWithBackgroundImage:image] autorelease] forKey:@"navigationBar"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_setNavBarBackgroundColor:(UIColor*)color {
    INCustomNavigationBar * navBar = [[INCustomNavigationBar alloc] initWithFrame:CGRectZero];
    navBar.backgroundStyle = INNavigationBarBGStyleSolidColor;
    navBar.backgroundColor = color;
    [self setValue:[navBar autorelease] forKey:@"navigationBar"];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INOverlayViewController 

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _overlayAnimationDuration = 0.4; // UINavigationControllerHideShowBarDuration;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHiddenToSubviews:(BOOL)hidden { 
    for (UIView * sv in self.view.subviews) { 
        sv.hidden = hidden;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor inru_colorFromRGBA:0xC0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    _parentOverlayViewController1 = nil;
    if (self.isViewLoaded) { 
        [self.view removeFromSuperview];
    }
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)popupAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context { 
    [self setHiddenToSubviews:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)layOverViewController:(UIViewController<INOverlayViewControllerDelegate> *)parentViewController { 
    [self layOverViewController:parentViewController delegate:parentViewController animated:YES];
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (void)layOverViewController:(UIViewController *)parentViewController delegate:(id<INOverlayViewControllerDelegate>)delegate animated:(BOOL)animated { 
    _overlayDelegate = delegate;
    self.view.frame = parentViewController.view.bounds;
    self.view.autoresizingMask = INFlexibleWidthHeight;
    [parentViewController.view addSubview:self.view];
    if (animated) {
        self.view.alpha = 0;
        [self setHiddenToSubviews:YES];
        [UIView beginAnimations:@"overlay" context:nil];
        [UIView setAnimationDuration:_overlayAnimationDuration];
        [UIView setAnimationDidStopSelector:@selector(popupAnimationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        {
            self.view.alpha = 1;
        }
        [UIView commitAnimations];
    }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)hideSwitchUserControllerDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(NSNumber *)context { 
    [self.view removeFromSuperview];
    [_overlayDelegate inoverlayController:self dismissedWithCode:context.intValue];
    [context release];     
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dismissWithCode:(INOverlayDismissCode)code animated:(BOOL)animated { 
    if (self.isViewLoaded) { 
        if (animated) { 
            [UIView beginAnimations:@"overlay" context:[[NSNumber numberWithInt:code] retain]];
            [UIView setAnimationDidStopSelector:@selector(hideSwitchUserControllerDidStop:finished:context:)];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:_overlayAnimationDuration];
            [self setHiddenToSubviews:YES];
            {
                self.view.alpha = 0;
            }
            [UIView commitAnimations];
        } else { 
            [self.view removeFromSuperview];
            [_overlayDelegate inoverlayController:self dismissedWithCode:code];    
        }
    } else {
        [_overlayDelegate inoverlayController:self dismissedWithCode:code];    
    }
}

@end
