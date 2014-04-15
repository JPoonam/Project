//!
//! @file INCountPicker.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2011 InRu
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

#import "INCountPicker.h"
#import "INGraphics.h"

/* 
@interface INCountPicker() 

- (void)buttonPressed:(id)sender;

@end
*/

//==================================================================================================================================
//==================================================================================================================================

@interface INCountPickerButton : UIButton {
    INCountPicker * _picker;    
    BOOL _autopressMode;
    BOOL _lessMode;
    NSInteger _autopressCount;
}

@property (nonatomic) BOOL autopressMode;

@end

//==================================================================================================================================

@implementation INCountPickerButton 

@synthesize autopressMode = _autopressMode;

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)buttonForPicker:(INCountPicker *)picker lessMode:(BOOL)lessMode{ 
    INCountPickerButton * result = [INCountPickerButton buttonWithType:UIButtonTypeCustom];
    result->_picker = picker;
    result->_lessMode = lessMode;
    return result;
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHighlighted:(BOOL)value { 
    [super setHighlighted:value];
    if (value) { 
        [self performSelector:@selector(performAutoTouch:) withObject:nil afterDelay:0.5];
        _autopressMode = YES;
        _autopressCount = 0;
    } else { 
        _autopressMode = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performAutoTouch:) object:nil];
    }
}

 
//----------------------------------------------------------------------------------------------------------------------------------

- (void)performAutoTouch:(id)sender {
    // [_picker buttonPressed:self];
    _autopressCount++;
    NSInteger v = INNormalizeIntegerForRange(_picker.value + (_lessMode ? -1 : 1), _picker.minValue, _picker.maxValue);
    if (_picker.value != v) { 
        [_picker setValue:v  animated:NO];
        // NSLog(@"--- %d", _picker.value);
        [_picker.delegate incountPickerDidChangeValue:_picker];
        INPlayControlTockSound();
        NSTimeInterval ti = 0.4 / pow(_autopressCount, 1.0/2);
       //  NSLog(@"%f", ti);
        [self performSelector:@selector(performAutoTouch:) withObject:nil afterDelay:MAX(ti, 0.1)];
    } else { 
        _autopressMode = NO;
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================


@implementation INCountPicker

@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize value = _value;
@synthesize delegate = _delegate;

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)widthForPart:(INCountPickerPart)part { 
    CGRect r = self.bounds;
    return round(r.size.width / 3);

}
//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)imageOfType:(INCountPickerImageType)imageType {
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setMaxValue:(NSUInteger)value { 
    _maxValue = value;
    if (_value > _maxValue) {
        self.value = _maxValue;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setMinValue:(NSUInteger)value { 
    _minValue = value;
    if (_value < _minValue) {
        self.value = _minValue;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateButtons { 
    _buttonLess.enabled = _value > _minValue;
    _buttonMore.enabled = _value < _maxValue;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIColor *)signColor { 
    return [UIColor inru_colorFromRGBA:0x515151ff];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIColor *)valueColor { 
    return [UIColor inru_colorFromRGBA:0x515151ff];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIEdgeInsets)contentInset { 
    return UIEdgeInsetsZero; 
}


//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForPart:(INCountPickerPart)part {
    CGRect r = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    switch (part) { 
        case INCountPickerPartLeft:
            r.size.width = [self widthForPart:INCountPickerPartLeft];
            break;
            
        case INCountPickerPartCenter:
            r.origin.x = [self widthForPart:INCountPickerPartLeft];
            r.size.width = [self widthForPart:INCountPickerPartCenter];
            break;
            
        case INCountPickerPartRight:
            r.origin.x = [self widthForPart:INCountPickerPartLeft] + [self widthForPart:INCountPickerPartCenter];
            r.size.width = [self widthForPart:INCountPickerPartRight];
            break;
           
        default:
            NSAssert(0,@"mk_985801b6_c2b1_4e01_aaea_b6717a38fc37");
    }
    return r;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIFont *)moreLessFont { 
    return [UIFont boldSystemFontOfSize:26];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIFont *)valueFont { 
    return [UIFont boldSystemFontOfSize:22];
}
//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_internalInit { 
    _minValue = 0;
    _maxValue = 999;
    // self.clipsToBounds = YES;
    // CGRect r = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    // CGFloat w = round(r.size.width / 3);
    CGRect r1 = [self frameForPart:INCountPickerPartLeft];
    
    UIFont * fnt = self.moreLessFont;
    UIColor * btnColor = [self signColor];
    UIColor * btnColorDisabled = [btnColor colorWithAlphaComponent:0.5];
    
    _buttonLess = [INCountPickerButton buttonForPicker:self lessMode:YES];
    _buttonLess.frame = r1;
    if (fnt) { 
        [_buttonLess setTitle:@"–" forState:UIControlStateNormal];
        _buttonLess.titleLabel.font = fnt;
        _buttonLess.titleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    [_buttonLess addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown]; 

    // [_buttonLess addTarget:self action:@selector(buttonPressed123:) forControlEvents:UIControlEventTouchDownRepeat]

    [_buttonLess setTitleColor:btnColor forState:UIControlStateNormal];
    [_buttonLess setTitleColor:btnColorDisabled forState:UIControlStateDisabled];
    [_buttonLess setBackgroundImage:[self imageOfType:INCountPickerImageLeft] forState:UIControlStateNormal];
    _buttonLess.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0);
    [_buttonLess setBackgroundImage:[self imageOfType:INCountPickerImageLeftPressed] forState:UIControlStateHighlighted];
    [_buttonLess setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _buttonLess.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_buttonLess];
    
    r1 = [self frameForPart:INCountPickerPartCenter];
    UIImageView * iv = [[[UIImageView alloc] initWithFrame:r1] autorelease];
    iv.image = [self imageOfType:INCountPickerImageCenter];
    [self addSubview:iv];

    UIImageView * iv3 = [[[UIImageView alloc] initWithFrame:r1] autorelease];
    iv3.image = [self imageOfType:INCountPickerImageCenterOverlay];
    [self addSubview:iv3];

    UIView * iv2 = [[UIView alloc] initWithFrame:CGRectInset(iv.bounds,0,3)];  
    iv2.backgroundColor = [UIColor clearColor];
    iv2.tag = 324324;
    iv2.clipsToBounds = YES;
    [iv addSubview:iv2];
       
    _labelComingValue = [[UILabel alloc] initWithFrame:iv2.bounds];   
    _labelValue = [[UILabel alloc] initWithFrame:iv2.bounds];  
    _labelComingValue.textAlignment = _labelValue.textAlignment = UITextAlignmentCenter;
    _labelComingValue.backgroundColor = _labelValue.backgroundColor = [UIColor clearColor];  
    _labelComingValue.textColor = _labelValue.textColor = [self valueColor];
    _labelComingValue.font = _labelValue.font = self.valueFont;
    _labelValue.shadowOffset = _labelComingValue.shadowOffset = CGSizeMake(0, 1);
    _labelValue.shadowColor = _labelComingValue.shadowColor = [UIColor whiteColor];
    _labelValue.text = @"0";
    [iv2 addSubview:_labelValue];
    [iv2 release];
    
    r1 = [self frameForPart:INCountPickerPartRight];
    _buttonMore = [INCountPickerButton buttonForPicker:self lessMode:NO];
    if (fnt) {
        [_buttonMore setTitle:@"+" forState:UIControlStateNormal];
        _buttonMore.titleLabel.font = fnt;
        _buttonMore.titleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    _buttonMore.frame = r1;
    _buttonMore.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0);
    [_buttonMore addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown]; 
    [_buttonMore setTitleColor:btnColor forState:UIControlStateNormal];
    [_buttonMore setTitleColor:btnColorDisabled forState:UIControlStateDisabled];
    [_buttonMore setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buttonMore setBackgroundImage:[self imageOfType:INCountPickerImageRight] forState:UIControlStateNormal];
    [_buttonMore setBackgroundImage:[self imageOfType:INCountPickerImageRightPressed] forState:UIControlStateHighlighted];
    _buttonMore.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self insertSubview:_buttonMore belowSubview:iv];
    
    self.backgroundColor = [UIColor clearColor];
    
    _value = -1;
    self.value = 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

enum { 
    CHANGE_UP,
    CHANGE_DOWN,
    CHANGE_NONE
};

//----------------------------------------------------------------------------------------------------------------------------------

- (void)makeTransitionToValue:(NSInteger)newValue direction:(NSInteger)direction performPostDelegeteCall:(BOOL)callTheDelegate{
    if (direction != CHANGE_NONE) { 
        NSInteger sign = ( direction == CHANGE_UP) ? -1.0 : 1.0;
        UIView * iv2 = [self viewWithTag:324324];
        CGRect r1 = iv2.bounds;
        CGFloat ivHeight = r1.size.height;
        // r1 = CGRectInset(r1,0,2);
        CGRect r0 = CGRectOffset(r1, 0, sign * ivHeight);
        CGRect r2 = CGRectOffset(r1, 0, - sign * ivHeight);
        _labelComingValue.frame = r0;
        _labelComingValue.text = [NSString stringWithFormat:@"%d",newValue];
        _labelComingValue.tag = newValue;
        [iv2 addSubview:_labelComingValue];
    	self.userInteractionEnabled = NO;
        
        NSInteger flag = callTheDelegate;
        [UIView beginAnimations:@"counter" context:(void *)flag];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        {  
            _labelComingValue.frame = r1;
            _labelValue.frame = r2;
            _transition = YES;
        }
        [UIView commitAnimations];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)buttonPressed:(id)sender  { 
    if (_transition) { 
        return;
    }
    NSInteger newValue = 0;
    NSInteger changeDir = CHANGE_NONE; 
    if (sender == _buttonLess) { 
        if (_value > _minValue) { 
            newValue = _value - 1;
            changeDir = CHANGE_UP;
        }
    } else 
    if (sender == _buttonMore) { 
        if (_value < _maxValue) { 
            // self.value++;
            // [_delegate incountPickerDidChangeValue:self];
            newValue = _value + 1;
            changeDir = CHANGE_DOWN;
        }
    }
     
    [self makeTransitionToValue:newValue direction:changeDir performPostDelegeteCall:YES];  

    INPlayControlTockSound();
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setValue:(NSUInteger)value {
    value = INNormalizeIntegerForRange(value, _minValue, _maxValue);
    if (_value != value) {
        _value = value;
        _labelComingValue.text = _labelValue.text = [NSString stringWithFormat:@"%d",value];
        [self updateButtons];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setValue:(NSUInteger)value animated:(BOOL)animated {
    value = INNormalizeIntegerForRange(value, _minValue, _maxValue);
    if (_value != value) { 
        if (!animated || _transition) {
            [self setValue:value];
            return; 
        }
        
        NSInteger direction = CHANGE_NONE; 
        if (value < _value) { 
            direction = CHANGE_UP;
        } else 
        if (value > _value) { 
            direction = CHANGE_DOWN;
        }     
        [self makeTransitionToValue:value direction:direction performPostDelegeteCall:NO];
    }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.userInteractionEnabled = YES;
    _transition = NO;
    _value = _labelComingValue.tag;
    [self updateButtons];
    if (context) { 
        [_delegate incountPickerDidChangeValue:self];
    }
          
    //swap labels
    id v = _labelComingValue;
    _labelComingValue = _labelValue;
    _labelValue = v;
    [_labelComingValue removeFromSuperview];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self inru_internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self inru_internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_labelValue release];
    // [_titleLabel release];
    [_labelComingValue release];
    [super dealloc];
}

@end
