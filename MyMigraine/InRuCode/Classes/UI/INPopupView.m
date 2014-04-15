//!
//! @file INPopupView.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! Copyright 2010 InRu
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

#import "INPopupView.h"
#import "INView.h"
#import "INGraphics.h"

#define RADIUS 12

//==================================================================================================================================
//==================================================================================================================================

@implementation INPopupView

@synthesize touchMode = _touchMode;
@synthesize animationDuration = _animationDuration;
// @synthesize drawRoundedRect = _drawRoundedRect;
@synthesize autoDestroyOnHide = _autoDestroyOnHide;
@synthesize delegate = _delegate;
@synthesize popupState = _popupState;

//----------------------------------------------------------------------------------------------------------------------------------

/*
- (void)setDrawRoundedRect:(BOOL)value { 
    if (value != _drawRoundedRect){ 
        _drawRoundedRect = value;
        self.roundedRectRadius = _drawRoundedRect ? RADIUS :0;
    }
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (void)initPopupView {
    [UIView setAnimationsEnabled:NO];
    _animationDuration = 0.4;
    self.alpha = 0;
    self.roundedRectRadius = RADIUS;
    _autoDestroyOnHide = NO;
    _touchMode = INPopupViewTouchModeNone;
    _popupState = INPopupViewHidden;

    //self.contentMode = UIViewContentModeRedraw;
    //self.backgroundColor = [UIColor clearColor];
    self.backgroundStyle = INPanelBGStyleSolidColor;
    self.topGradientColor = [UIColor colorWithWhite:0.3 alpha:0.8]; 
    self.autoresizingMask =             
        UIViewAutoresizingFlexibleLeftMargin  |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin   |
        UIViewAutoresizingFlexibleBottomMargin;
    [UIView setAnimationsEnabled:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)decoder { 
    self = [super initWithCoder:decoder];
    if (self != nil){
        [self initPopupView];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self != nil){
        [self initPopupView];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stopTimer { 
    [_timer invalidate];
    [_timer release];
    _timer = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [self stopTimer]; 
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)drawRect:(CGRect)rect {
//	if (_drawRoundedRect){ 
        /*
        CGRect boxRect = CGRectInset(self.bounds, 1.0f, 1.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();	
        [INCoreGraphics pathForRoundedRect:boxRect radius:RADIUS context:context];
        CGContextSetGrayFillColor(context, 0.3, 0.8);
        CGContextFillPath(context);
        */
//        [super drawRect:rect];
//    }
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger numTaps = [[touches anyObject] tapCount];
	if (numTaps == 1){
        if ([_delegate respondsToSelector:@selector(handleTouchForPopupView:)]){
            if ([_delegate handleTouchForPopupView:self]){ 
                return;
            }
        }
        
        switch (_touchMode){ 
            case INPopupViewTouchModeFade:
                [self setHidden:YES withAnimation:YES];
                break; 
            
            case INPopupViewTouchModeHide:
                [self setHidden:YES withAnimation:NO];
                break;
                
            case INPopupViewTouchModeTransparent:
            case INPopupViewTouchModeNone:
                // do nothing
                break;
        }
	}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // BOOL result = [super pointInside:point withEvent:event];
    // NSLog(@"--- pi %d", result);
    if (CGRectContainsPoint(self.bounds, point)) { 
        return _touchMode != INPopupViewTouchModeTransparent;
    }
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHidden:(BOOL)isHidden { 
    [self setHidden:isHidden withAnimation:NO];    
}

//----------------------------------------------------------------------------------------------------------------------------------
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    BOOL hidingAnimation = [(NSNumber *)context boolValue];
    if (finished) { 
        _popupState = hidingAnimation ? INPopupViewHidden : INPopupViewVisible;
    }
                  
    if (hidingAnimation){ // is hidden
        if (_autoDestroyOnHide){
            [[self retain] autorelease];
            [self removeFromSuperview];
        }
    }
    
    /* 
    if (finished) {
        if (_popupState == INPopupViewHidden) { 
            if ([_delegate respondsToSelector:@"    
        }
    }
    */
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHidden:(BOOL)isHidden withAnimation:(BOOL)animation andAutoHideIn:(NSTimeInterval)seconds { 
    // _autoHideMode = NO;

    [self stopTimer];

    if (animation){
        [UIView beginAnimations:@"INPopupView" context:[NSNumber numberWithBool:isHidden]];
        [UIView setAnimationDuration:_animationDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    }
    
    if (isHidden){
        self.alpha = 0;
    } else {
        self.alpha = 1;
        if (seconds > 0){ 
            if (animation){
                seconds += self.animationDuration;
            }
            // _autoHideMode = YES;
            _timer = [[NSTimer timerWithTimeInterval:seconds 
                                              target:self 
                                            selector:@selector(timerFired:)
                                            userInfo:animation ? self :nil // just as flag
                                             repeats:NO] retain];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        }    
    } 
    
    if (animation){       
        _popupState = isHidden ? INPopupViewHiding : INPopupViewShowing;
        [UIView commitAnimations];
    } else {
        _popupState = isHidden ? INPopupViewHidden : INPopupViewVisible;

        if (_autoDestroyOnHide){ 
            [[self retain] autorelease];
            [self removeFromSuperview];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)timerFired:(NSTimer *)timer {
	[self setHidden:YES withAnimation:timer.userInfo != nil andAutoHideIn:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHidden:(BOOL)isHidden withAnimation:(BOOL)animation {
    [self setHidden:isHidden withAnimation:animation andAutoHideIn:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)popupWithAnimation:(BOOL)animation andAutoHideOnDelay:(NSTimeInterval)seconds { 
    [self setHidden:NO withAnimation:animation andAutoHideIn:seconds];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGPoint)adjustedCenter { 
    CGPoint result = self.center;
    result.x = rint(result.x);
    result.y = rint(result.y);
    return result; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setAdjustedCenter:(CGPoint)aCenter { 
    self.center = CGPointMake(rint(aCenter.x),rint(aCenter.y));    
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)viewWithCenter:(CGPoint)aCenter fromNib:(NSString *)nibFileName {
    INPopupView * result = (id)[[INNibLoader sharedLoader] loadViewFromNib:nibFileName];
    result.adjustedCenter = aCenter;
    return result;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INPopupViewLabel

@synthesize messageLabel = _messageLabel;
@synthesize messageLabelInsets = _messageLabelInsets;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setMessageLabelInsets:(UIEdgeInsets)insets { 
    _messageLabelInsets = insets;
    _messageLabel.frame = UIEdgeInsetsInsetRect(self.bounds, _messageLabelInsets);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)initPopupView {
    [super initPopupView];
    
    _messageLabelInsets = UIEdgeInsetsMake(RADIUS + 8, RADIUS + 8, RADIUS + 8, RADIUS + 8);
    
    _messageLabel = [[UILabel alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, _messageLabelInsets)];
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _messageLabel.textAlignment = UITextAlignmentCenter;
    _messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _messageLabel.numberOfLines = 0;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont boldSystemFontOfSize:14];
    _messageLabel.textColor = [UIColor whiteColor];
    // does not work for multiline label _messageLabel.adjustsFontSizeToFitWidth = YES;
    // _messageLabel.minimumFontSize = 5; // [UIFont smallSystemFontSize]-1;
    [self addSubview:_messageLabel];  
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (INPopupViewLabel *)viewWithCenter:(CGPoint)aCenter andSize:(CGSize)size { 
    INPopupViewLabel * v = [[[self.class alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)] 
                            autorelease];
    v.adjustedCenter = aCenter;
    return v;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_messageLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)adjustHeightToFitMessage { 
    CGRect r  = _messageLabel.frame;
    CGSize sz = [_messageLabel.text sizeWithFont:_messageLabel.font 
                               constrainedToSize:CGSizeMake(r.size.width, 10000)];
    
    if (sz.height < 20){ 
        sz.height = 20; // ot baldy
    }
    
    CGRect r1   = self.frame;
    CGFloat delta2 = rint((sz.height - r.size.height)/ 2);
    r1.origin.y -= delta2;
    r1.size.height += delta2 * 2;
    self.frame = r1;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INPopupViewActivity

//----------------------------------------------------------------------------------------------------------------------------------

- (void)initPopupView {
    [super initPopupView];
    if (!_activityIndicator) { 
        _activityIndicator = [[UIActivityIndicatorView alloc] 
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleBottomMargin; 
        _activityIndicator.center = self.inru_centerOfContent;
        [self addSubview:_activityIndicator];        
    }
    [_activityIndicator startAnimating];
//     self.layer.shadowColor 
// content.alpha = 0.8f;
// content.layer.cornerRadius = 8.0f;
// self.layer.shadowRadius = 1;
// self.layer.masksToBounds = NO;
// self.layer.shadowOffset = CGSizeMake(0, 3);
// self.layer.shadowOpacity = 1.0f;
// self.layer.shadowColor =  [UIColor blackColor].CGColor; 
// self.layer.borderWidth = 1.0f; 
// self.layer.borderColor = [UIColor redColor].CGColor; //colorWithRed:(128.0f/255.0f) green:(128.0f/255.0f) blue:(128.0f/255.0f) alpha:1.0f] CGColor];
// content.layer.shadowPath = [UIBezierPath bezierPathWithRect:contentRect].CGPath;
    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_activityIndicator release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)viewWithCenter:(CGPoint)aCenter {
    INPopupViewActivity * v = [[self new] autorelease];
    v.bounds = CGRectMake(0, 0, 70, 70);
    v->_activityIndicator.center = v.inru_centerOfContent;
    v.center = aCenter;
    return v;
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)layoutSubviews {
//   _activityIndicator.center = self.inru_centerOfContent;
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) setTitle:(NSString*)title {
	if (_title) {
		[_title release];
	}
	_title = [title retain];
}

- (NSString*) title {
	return _title;
}

@end

