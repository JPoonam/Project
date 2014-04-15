//!
//! @file INBillboard.m
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

#import "INBillboard.h"
#import "INCommonTypes.h"
// #import <QuartzCore/QuartzCore.h>

#define ANIMATION_TIME1                    1
#define ANIMATION_SCROLL_QUANT_TIME1       3.0
#define ANIMATION_STAY_TIME                5.0
// #define ANIMATION_STAY_BEFORE_SCROLL_TIME 0
#define ANIMATION_STAY_AFTER_SCROLL_TIME   1
#define ANIMATION_GO_AWAY_TIME1            0.5

//==================================================================================================================================
//==================================================================================================================================

@implementation INBillboardMessage 

@synthesize tag = _tag;
@synthesize message = _message;
@synthesize font = _font;
@synthesize color = _color;
@synthesize opaque = _opaque;

- (void)dealloc {
    [_message release];
    [_font release];
    [_color release];
    [super dealloc];
}

+ (INBillboardMessage *)messageWithMessage:(NSString *)message tag:(NSInteger) tag { 
    INBillboardMessage * result = [[INBillboardMessage new] autorelease];
    result.message = message; 
    result.tag = tag;
    result.opaque = YES;
    return result; 
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:INBillboardMessage.class]) {
        return [NSString inru_string:[object message] isEqualTo:_message] && _tag == [object tag]; 
    }
    return NO;
}

@end

//==================================================================================================================================
//==================================================================================================================================

/*
enum {
   ANIM_HIDE, ANIM_INCOMING, ANIM_OUTGOING
};

@interface _CABasicAnimationEx : CABasicAnimation { // CAKeyframeAnimation { 
@package
    INBillboardPlateLayer * _plateLayer;
    NSTimeInterval _delay;
    CGPoint _endPoint;
    NSInteger _animType;
}

@end

//==================================================================================================================================

@implementation _CABasicAnimationEx 

- (id)copyWithZone:(NSZone *)zone { 
    _CABasicAnimationEx * result = [super copyWithZone:zone];
    result->_plateLayer = _plateLayer;
    result->_delay = _delay;
    result->_endPoint = _endPoint;
    result->_animType = _animType;
    return result;
}

@end
*/

//==================================================================================================================================
//==================================================================================================================================

@interface INBillboardPlateView : UIView { 
    BOOL _shouldScroll, _shouldGoAway;
    INBillboardMessage * _message;
    INBillboard * _billboard;
    id<INBillboardDelegate> _delegate;
    NSTimeInterval _delay;
}

@property(nonatomic) BOOL shouldScroll;
@property(nonatomic) BOOL shouldGoAway;
@property(nonatomic) NSTimeInterval delay;
@property(nonatomic,retain) INBillboardMessage * message;   
@property(nonatomic,assign) INBillboard * billboard;   
@property(nonatomic,assign) id<INBillboardDelegate> delegate; 

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INBillboardPlateView

@synthesize message = _message;
@synthesize billboard = _billboard;
@synthesize shouldScroll = _shouldScroll;
@synthesize shouldGoAway = _shouldGoAway;
@synthesize delegate = _delegate;
@synthesize delay = _delay;

// int counter = 0;

- (void)dealloc { 
    // NSLog(@"VIEW DEALLOC %d rest", --counter);
    [_message release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)aFrame {
    self = [super initWithFrame:aFrame];
    if (self != nil){
        // counter++;
        // self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // NSLog(@"draw %@", self); 
    CGRect r = self.bounds;
    BOOL shouldOwnDraw = YES;
    if ([_delegate respondsToSelector:@selector(billBoard:customDraw:rect:)]) {
        shouldOwnDraw = ![_delegate billBoard:_billboard customDraw:_message rect:r];
    }
    if (shouldOwnDraw) { 
        [_message.color set];
        CGRect rect = INRectNormalize(r);
        CGFloat h = [@"!" sizeWithFont:_message.font].height;
        rect.origin.y = rint((rect.size.height - h) / 2); 
        [_message.message drawInRect:rect withFont:_message.font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
    if ([_delegate respondsToSelector:@selector(billBoard:postDraw:rect:)]) {
        [_delegate billBoard:_billboard postDraw:_message rect:r];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INBillboard()

- (void)startNewCycle:(BOOL)fromReload;

@end

//==================================================================================================================================

@implementation INBillboard

@synthesize messages = _messages;
@synthesize font = _font;
@synthesize delegate = _delegate;
@synthesize color = _color;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)init2 { 
    _nextItemInArray = 0;
    self.backgroundColor = [UIColor blackColor];    
    self.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    self.color = [UIColor lightTextColor];
    self.clipsToBounds = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])){
        [self init2];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])){
        [self init2];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    self.font = nil;
    self.color = nil;
    [_messages release];    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

/*
uncomment then you need optional force starting instead of saferestart 
- (void)restart { 
    [_v1 removeFromSuperview]; _v1 = nil;
    [_v2 removeFromSuperview]; _v2 = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _nextItemInArray = 0;
    _state = STATE_0;
    [self processState];
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat) PADDING { 
    return 10; // rint(self.bounds.size.width / 3);    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSTimeInterval)animationTime:(NSTimeInterval)interval { 
    return interval * self.bounds.size.width / 300; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)moveAway:(INBillboardPlateView *)view {
    NSParameterAssert(view);
    [UIView beginAnimations:@"away" context:[view retain]];
    [UIView setAnimationDuration:[self animationTime:ANIMATION_GO_AWAY_TIME1]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(moveAwayAnimationDidStop:finished:context:)];
    view.alpha = 0;
    view.shouldGoAway = YES;
    [UIView commitAnimations];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)moveAwayAllCurrentItems {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNewCycle2:) object:nil];
    _nextItemInArray = 0;
    if (_vForAway) {
       [self moveAway:_vForAway];
        _vForAway = nil;
    }
    if (_v2) {
        [self moveAway:_v2];
        _v2 = nil;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tryToRestartSafely { 
    int  cnt = _messages.count;
    if (!cnt){
        [self moveAwayAllCurrentItems];
        return;
    }
    
    // try to 'attach' to the last previous item. for more smooth item switching
    INBillboardMessage * lastItem = _v2.message;
    if (lastItem) {     
        NSUInteger index = [_messages indexOfObject:lastItem];
        if (NSNotFound == index){ 
            lastItem = nil;
        } else {
            _nextItemInArray = index + 1;
            if (_nextItemInArray >= _messages.count){ 
                _nextItemInArray = 0;
            }
        }
    }
    
    /*
    if (!lastItem){ 
        [self goAwayCurrentItem];
        if (_state != STATE_OPENING_V1_A && _state != STATE_CHANGING_V1_2_V2_A && _state != STATE_ANIM_V1_SCROLL ){
            _state = STATE_0;
            [self processState];
        }
    } else {
        switch (_state){ 
            case STATE_0:
            case STATE_SHOW_V1_STATIC_SINGLE:
                [self processState];
                break;
        }
    }
    */
    
    // No previous items found. begin new animations
    if (!lastItem){ 
        [self moveAwayAllCurrentItems];
        [self startNewCycle:YES];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrame:(CGRect)aFrame { 
    BOOL changed = !CGSizeEqualToSize(aFrame.size, self.frame.size);
    [super setFrame:aFrame];
    if (changed) { 
        // NSLog(@"00");
        [self moveAwayAllCurrentItems];
        [self tryToRestartSafely];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setMessages:(NSArray *)value { 
    if (value != _messages){ 
        [_messages autorelease];
        _messages = [value retain];
        [self tryToRestartSafely];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INBillboardMessage *)nextItemInArray1123 {
    if (!_messages.count){
        return nil;
    }
    if (_nextItemInArray >= _messages.count){
        _nextItemInArray = 0;
    }
    INBillboardMessage * result = [_messages objectAtIndex:_nextItemInArray];
    _nextItemInArray++;
    if (_nextItemInArray >= _messages.count){
        _nextItemInArray = 0;
    }     
    return result; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INBillboardPlateView *)plateWithMessage:(INBillboardMessage *)message {
    CGRect r = self.bounds;
    int padding  = self.PADDING;

    // last chance setup
    if ([_delegate respondsToSelector:@selector(billBoard:wantsToCustomizeMessage:)]) { 
        [_delegate billBoard:self wantsToCustomizeMessage:message];
    }
    if (!message.font) { 
        message.font = _font;
    }
    if (!message.color) { 
        message.color = _color;
    }
        
    // calc view dimensions    
    CGFloat w = [message.message sizeWithFont:message.font].width;
    BOOL shouldScroll= NO;
    if (w > r.size.width) {
        w += 2 * padding;
        shouldScroll = YES;
    } else { 
        w = r.size.width;
    }    
    r.origin.x     = r.size.width;
    r.size.width   = rint(w / 2) * 2;
    r.size.height  = rint(r.size.height / 2) * 2; 
    
    // create view
    INBillboardPlateView * v = [[[INBillboardPlateView alloc] initWithFrame:r] autorelease];
    [self addSubview:v];
    v.shouldScroll = shouldScroll;
    v.message = message;
    v.billboard = nil;
    v.opaque = message.opaque;
    v.delegate = _delegate;
    
    return v;
}

/*
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finishedProperly {
    
    // NSLog(@"CYCLE END");
    
    assert([theAnimation isKindOfClass:_CABasicAnimationEx.class]);
    _CABasicAnimationEx * a = (_CABasicAnimationEx *)theAnimation;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; 

    switch (a->_animType) { 
        case ANIM_HIDE: 
            [a->_plateLayer removeFromSuperlayer];
            break;
            
        case ANIM_INCOMING:
            if (1 || finishedProperly) { 
                // NSLog(@"-------------- properly");
                a->_plateLayer.position = a->_endPoint;
                [self performSelector:@selector(startNewCycle2) withObject:0 afterDelay:a->_delay]; 
            } else {
                //NSLog(@"-------------- canceled");
            }
            break;
            
        case ANIM_OUTGOING:
            a->_plateLayer.position = a->_endPoint;
            break;
    }
    [CATransaction commit];
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (void)moveAwayAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(INBillboardPlateView *)contextView { 
    //NSLog(@"-------------- moveAwayAnimationDidStop %d %@",contextView.retainCount, contextView);
    [contextView removeFromSuperview];
    [contextView release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)outgoingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(INBillboardPlateView *)contextView { 
    // NSLog(@"-------------- outgoingAnimationDidStop %d %@",contextView.retainCount, contextView);
    [contextView removeFromSuperview];
    [contextView release];
    _vForAway = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)incomingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(INBillboardPlateView *)contextView { 
    // NSLog(@"-------------- incomingAnimationDidStop %d %@ delay %f %@",contextView.retainCount, contextView, contextView.delay,self);
    if (!contextView.shouldGoAway) { 
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startNewCycle2:) object:nil];
        [self performSelector:@selector(startNewCycle2:) withObject:0 afterDelay:contextView.delay];
    }
    [contextView release]; 
}

//----------------------------------------------------------------------------------------------------------------------------------
- (void)startNewCycle2:(id)sender {
    // NSLog(@"-------- NEW CYCLE---------- after delay");
    [self startNewCycle:NO];
}

- (void)startNewCycle:(BOOL)fromReload {  
    
    CGRect r = self.bounds;
    // int padding = self.PADDING;
            
    // check if we have nothing to do
    if ((!_messages.count) ||  //  no messages at all 
        (_messages.count == 1 && _v2 && !_v2.shouldScroll)) { // one short static message 
        // ...
        return; 
    }

    // old item is going away
    if (_v2) {
        if (!_v2.shouldScroll) { // if it is on the screen yet (scrolled view is outside and can be just deleted)  
            CGRect  r1 = _v2.frame;
            [UIView beginAnimations:@"outgoing" context:[_v2 retain]];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:[self animationTime:ANIMATION_TIME1]];
            [UIView setAnimationDidStopSelector:@selector(outgoingAnimationDidStop:finished:context:)];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            r1.origin.x = -r1.size.width;
            _v2.frame = r1;
            _vForAway = _v2;
            [UIView commitAnimations];
        } else {
           [_v2 removeFromSuperview];
        }
        _v2 = nil;
    }
    
    // bring up new view{ 
    UIViewAnimationCurve curve;
    NSTimeInterval duration2 = 0;
    NSTimeInterval delay = 0;
    INBillboardMessage * nextItem = [self nextItemInArray1123];
    _v2 = [self plateWithMessage:nextItem];
    CGRect r2 = _v2.frame;
    if (!_v2.shouldScroll) {
        r2.origin.x = rint((r.size.width - r2.size.width) / 2);  
        duration2 = [self animationTime:ANIMATION_TIME1];
        delay = ANIMATION_STAY_TIME;
        curve = UIViewAnimationCurveEaseOut;
    } else {
        r2.origin.x = -r2.size.width; //+ padding;
        duration2 = [self animationTime:ANIMATION_SCROLL_QUANT_TIME1] * r2.size.width / r.size.width;
        delay = ANIMATION_STAY_AFTER_SCROLL_TIME;
        curve = UIViewAnimationCurveLinear;
    }
    [UIView beginAnimations:@"incoming" context:[_v2 retain]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(incomingAnimationDidStop:finished:context:)];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration2];
    _v2.delay = delay;
    _v2.frame = r2;
    [UIView commitAnimations];

}

@end
