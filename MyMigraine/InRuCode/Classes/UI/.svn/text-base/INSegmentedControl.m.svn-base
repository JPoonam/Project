//!
//! @file INSegmentedControl.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright ©  2011 InRu
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


#import "INSegmentedControl.h"


@interface INSegmentedControlButton : INButton {

}

@end

//==================================================================================================================================

@implementation INSegmentedControlButton 

- (void)setHighlighted:(BOOL)value { 
    [super setHighlighted:NO];
}

@end

//==================================================================================================================================
//==================================================================================================================================

enum { 
   MODE_EQUAL,
   MODE_TEXT_WIDTH
};

@implementation INSegmentedControl

@synthesize delegate = _delegate;
@synthesize backgroundImage = _backgroundImage;
@synthesize buttonCount = _buttonCount;
@synthesize selectedSegmentIndex = _selectedSegment;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBackgroundImage:(UIImage *)image { 
    if (image != _backgroundImage) { 
        [_backgroundImage release];
        _backgroundImage = [image retain];
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_backgroundImage release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIEdgeInsets)contentInset {
    return UIEdgeInsetsMake(0,0,0,0);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)contentRect {
    CGRect r = UIEdgeInsetsInsetRect(self.bounds,self.contentInset);
    return r;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)buttonGap { 
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect { 
     [_backgroundImage drawInRect:self.bounds];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIButton *)buttonAtIndex:(NSInteger)index { 
    UIButton * btn = (id)[self viewWithTag:index+100];
    return btn;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedSegmentIndex:(NSInteger)index {
    [self setSelectedSegmentIndex:index animated:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated {
    // в базовой вьюхе никакой анимации  
    // NSParameterAssert(index >=0 && index < _buttonCount);
    // if (animated) { 
    //    [UIView beginAnimations:@"setSelectedIndexAnimation" context:nil];
    //}
    _selectedSegment = index;
    for (int i = 0; i < _buttonCount; i++) { 
        UIButton * btn = [self buttonAtIndex:i];
        btn.selected = _selectedSegment == i;
        btn.userInteractionEnabled = _selectedSegment != i; 
    }
    //if (animated) { 
    //    [UIView commitAnimations];
    //}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)segmentButtonPressed:(UIButton *)sender { 
    [self setSelectedSegmentIndex:sender.tag - 100 animated:YES];
    [_delegate insegmentedControl:self didSelectedSegmentAtIndex:_selectedSegment];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeButtons { 
    for (int i = 0; i < _buttonCount; i++) { 
        [[self buttonAtIndex:i] removeFromSuperview];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateWidth:(BOOL)forceUpdate {
    CGRect r1 = self.contentRect;
    CGRect r = r1;
    CGFloat space = self.buttonGap;
    
    if (_buttonCount && (forceUpdate || !CGSizeEqualToSize(_prevSize,r.size))) { 
        _prevSize = r.size;
        switch (_buttonWidthMode) { 
            case MODE_EQUAL:
                {
                    r.size.width = round((r.size.width - _buttonCount * space) / _buttonCount);
                    for (int i = 0; i < _buttonCount; i++) { 
                        UIButton * btn = [self buttonAtIndex:i];
                        if (i == _buttonCount - 1) { 
                            r.size.width = r1.size.width - r.origin.x /* - 1*/ + r1.origin.x;
                            // #warning убрать единицу???
                        }
                        btn.frame = r;
                        r.origin.x += r.size.width + space;
                    }
                }
                break;
                
            case MODE_TEXT_WIDTH:
               {
                    NSAssert(_buttonCount <= 50,@"mk_e508f204_cbd7_4d89_b992_52048e7f39ae");
                    CGFloat w[50]; // достаточно для всех случаев
                    CGFloat bcaptionPadding = 4;    
                    
                    NSMutableArray * btns = [NSMutableArray array];
                    for (int i = 0; i < _buttonCount; i++) { 
                        UIButton * btn = [self buttonAtIndex:i];
                        [btns addObject:btn];
                    }
                    
                    CGFloat tw = 0;
                    for (int i = 0; i < _buttonCount; i++) {
                        UIButton * btn = [btns objectAtIndex:i]; 
                        w[i] = 2 * bcaptionPadding + [[btn titleForState:UIControlStateNormal] sizeWithFont:btn.titleLabel.font].width;     
                        tw += w[i];
                    }
                    
                    // если у нас получилась меньшая ширина, то надо рассчитать еще раз
                    if (tw < r.size.width) {
                        bcaptionPadding = round((r.size.width - tw) / _buttonCount / 2);
                        tw = 0;
                        for (int i = 0; i < _buttonCount; i++) {
                            UIButton * btn = [btns objectAtIndex:i]; 
                            w[i] = 2 * bcaptionPadding + [[btn titleForState:UIControlStateNormal] sizeWithFont:btn.titleLabel.font].width;     
                            tw += w[i];
                        }
                    }
                    
                    for (int i = 0; i < _buttonCount; i++) {
                        w[i] = round((r.size.width - (_buttonCount - 1) * space) * (w[i] / tw));      
                    }

                    for (int i = 0; i < _buttonCount; i++) { 
                        UIButton * btn = [btns objectAtIndex:i];
                        
                       // btn.backgroundColor = [UIColor redColor];
                        r.size.width = w[i];
                        if (i == _buttonCount - 1) { 
                            r.size.width =  r1.size.width - r.origin.x /* - 1*/ + r1.origin.x; // self.bounds.size.width - r.origin.x - 1;
                        }                  
                        
                        btn.frame = r;
                        r.origin.x += w[i] + space;
                    }
               }
               break;
               
            default:
               NSAssert(0,@"mk_acaf73f4_a537_4bd1_8c11_ca85526abf94");
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrame:(CGRect)frame { 
    [super setFrame:frame];
    [self updateWidth:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setButtonCount:(NSInteger)buttonCount initialSelection:(NSInteger)initialSelection { 
    NSParameterAssert(buttonCount > 0 && initialSelection >=0 && initialSelection < buttonCount);
    
    _buttonWidthMode = MODE_EQUAL;
    
    [self removeButtons];
    
    _buttonCount = buttonCount;    
    for (int i = 0; i < buttonCount; i++) { 
        INSegmentedControlButton * btn = [INSegmentedControlButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 100;
        [self setupButton:btn atIndex:i];        
        [self addSubview:btn];
        [btn addTarget:self action:@selector(segmentButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
    [self updateWidth:YES]; 
    [self setSelectedSegmentIndex:initialSelection animated:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)getButtonForPoint:(CGPoint)point buttonArea:(CGRect *)buttonArea { 
    for (int i = 0; i < _buttonCount; i++) { 
        UIButton * btn = (id)[self viewWithTag:i+100];
        CGRect r = btn.frame;
        if (CGRectContainsPoint(r,point) || (point.x < r.origin.x) || (i == _buttonCount -1)) { 
            *buttonArea = r;
            return i;
        }
    }
    NSAssert(0,@"mk_b73d1d56_57e1_4078_94e7_81997cf7694c");
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setupButton:(INButton *)btn atIndex:(NSInteger)index {
    // btn.adjustsImageWhenHighlighted = NO; 
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    btn.titleLabel.shadowOffset = CGSizeMake(0,-1);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setButtons:(NSArray *)buttonCaptions initialSelection:(NSInteger)initialSelection proportionalWidth:(BOOL)proportionalWidthMode { 
    
    [self removeButtons];
    
    _buttonWidthMode = proportionalWidthMode ? MODE_TEXT_WIDTH : MODE_EQUAL;
    
    NSInteger buttonCount = buttonCaptions.count;
    NSParameterAssert(buttonCaptions.count < 50);
    NSParameterAssert(buttonCount > 0 && initialSelection >=0 && initialSelection < buttonCount);

    _buttonCount = buttonCount;
    
    for (int i = 0; i < buttonCount; i++) { 
        INSegmentedControlButton * btn = [INSegmentedControlButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i + 100;
        [btn setTitle:[[buttonCaptions objectAtIndex:i] description]  forState:UIControlStateNormal];
        [self setupButton:btn atIndex:i];        
        [self addSubview:btn];
        [btn addTarget:self action:@selector(segmentButtonPressed:) forControlEvents:UIControlEventTouchDown];
    }
    
    [self updateWidth:YES]; 
    [self setSelectedSegmentIndex:initialSelection animated:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setButtons:(NSArray *)buttonCaptions initialSelection:(NSInteger)initialSelection { 
    [self setButtons:buttonCaptions initialSelection:initialSelection proportionalWidth:YES]; 
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INSegmentedSliderControl()

- (void)playSound;

@end 

//==================================================================================================================================
//==================================================================================================================================


@interface _INSegmentedSliderTrackControl : UIControl { 
    CGFloat _startMidX;
    CGFloat _startTouchDistanceFromMidX;
    CGFloat _startTouchX;
    NSInteger _startSegment, _currentSegment;
}

@end

//==================================================================================================================================

@implementation _INSegmentedSliderTrackControl;

//----------------------------------------------------------------------------------------------------------------------------------

- (INSegmentedSliderControl *)parentView { 
    return (id)self.superview;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect {
   [self.parentView.sliderImage drawInRect:self.bounds];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event { 
    CGRect rb = self.frame;    
    _startMidX = CGRectGetMidX(rb);
    _startTouchX = [touch locationInView:self.superview].x;
    _startTouchDistanceFromMidX = _startTouchX - _startMidX;
    _currentSegment = _startSegment = self.parentView.selectedSegmentIndex;
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat touchX = [touch locationInView:self.superview].x;
     
    CGFloat deltaX = touchX - _startTouchX;
    CGFloat midX = _startMidX + deltaX;
    CGRect r = self.frame;
     
    CGRect bArea;
    NSInteger newSegment = [self.parentView getButtonForPoint:CGPointMake(midX,10) buttonArea: &bArea];
    r.size.width = bArea.size.width;
    r.origin.x = round(midX - r.size.width / 2);
    
    CGRect sr = self.parentView.contentRect;  
    if (r.origin.x < sr.origin.x) { 
        r.origin.x = sr.origin.x;
    } else 
    if (r.origin.x + r.size.width > sr.origin.x + sr.size.width /*  -1*/) { 
        r.origin.x = sr.size.width + sr.origin.x /* - 1*/ - r.size.width;
    } 
    self.frame = r;
    
    if (newSegment != _currentSegment) { 
        _currentSegment = newSegment;
        [self.parentView playSound];
    }           
                                     
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGRect bArea;
    // NSInteger newSegment = // _startSegment;
    //if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) { 
    NSInteger newSegment = [self.parentView getButtonForPoint:CGPointMake(CGRectGetMidX(self.frame),10) buttonArea: &bArea];
    // }
    [self.parentView setSelectedSegmentIndex:newSegment animated:YES];
    if (newSegment != _startSegment) { 
        [self.parentView.delegate insegmentedControl:self.parentView didSelectedSegmentAtIndex:newSegment];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)cancelTrackingWithEvent:(UIEvent *)event { 
    [self.parentView setSelectedSegmentIndex:_startSegment animated:YES];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INSegmentedSliderControl 

@synthesize sliderImage = _sliderImage;


//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSliderImage:(UIImage *)image { 
    if (image != _sliderImage) { 
        [_sliderImage release];
        _sliderImage = [image retain];
        [_trackControl setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit {
    [super internalInit];  
    _trackControl = [[_INSegmentedSliderTrackControl alloc] initWithFrame:CGRectMake(0,0,36,100)];
    _trackControl.opaque = NO;  
    _trackControl.contentMode = UIViewContentModeRedraw;
    [self addSubview:_trackControl];
    [_trackControl release];   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_sliderImage release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated {
    NSParameterAssert(index >=0 && index < _buttonCount);
    if (animated) { 
        [UIView beginAnimations:@"setSelectedIndexAnimation" context:nil];
    }
    _selectedSegment = index;
    for (int i = 0; i < _buttonCount; i++) { 
        UIButton * btn = [self buttonAtIndex:i];
        btn.selected = _selectedSegment == i;
        btn.userInteractionEnabled = _selectedSegment != i; 
        if (_selectedSegment == i) { 
            _trackControl.frame = btn.frame;
        }
    }
    if (animated) { 
        [UIView commitAnimations];
    }
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)playSound { 
    INPlayControlTockSound();
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)segmentButtonPressed:(UIButton *)sender { 
    [super segmentButtonPressed:sender];
    [self playSound];
}

@end
