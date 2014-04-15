//
//  Created by alex on 5/28/11.
//


#import <QuartzCore/QuartzCore.h>
#import "INSwitch.h"

// размеры. Ширина 95. Кнопка ширина 40. Всего видимо 150. Высота — 26.

@interface INSwitch ()

- (void)buttonReleased:(id)aSender;

@end

@implementation INSwitch

- (BOOL)isOn {
    if (_ios5Logic) {
        return [_innerSwitch isOn];
    } else {
        return _switchOn;
    }
}

- (BOOL)on {
    if (_ios5Logic) {
        return [_innerSwitch isOn];
    } else {
        return _switchOn;
    }
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    _innerSwitch.tag = tag;
}

- (void)setOn:(BOOL)on {
    if (_ios5Logic) {
        [_innerSwitch setOn:on animated:YES];
    } else {
        if (_switchOn != on) {
            [self buttonReleased:nil];
        }
    }
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if (_ios5Logic) {
        [_innerSwitch setOn:on animated:animated];
    } else {
        if (_switchOn != on) {
            [self buttonReleased:nil];
        }
    }
}

- (UIColor *)customColor {
    if (_ios5Logic) {
        return [_innerSwitch onTintColor];
    } else {
        return _customBackgroundColor;
    }
}

- (void)setCustomColor:(UIColor *)customColor {
    if (_ios5Logic) {
        [_innerSwitch setOnTintColor:customColor];
    } else {
        if (_customBackgroundColor != customColor && ![_customBackgroundColor isEqual:customColor]) {
            [_customBackgroundColor autorelease];
            _customBackgroundColor = [customColor retain];
            _allSubviews.backgroundColor = _customBackgroundColor;
            _allSubviews.layer.cornerRadius = 4;
            self.layer.cornerRadius = 4;
            [self setNeedsDisplay];
        }
    }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    _innerSwitch = [[UISwitch alloc] init];

    CGRect rect = self.frame;
    rect.size.width =_innerSwitch.bounds.size.width;
    rect.size.height =_innerSwitch.bounds.size.height;
    self.frame = rect;

    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;

    _ios5Logic = [_innerSwitch respondsToSelector:@selector(onTintColor)];

    if (_ios5Logic) {
        self.clipsToBounds = NO;
        _innerSwitch.frame = CGRectMake(0.5, 0.5, _innerSwitch.frame.size.width, _innerSwitch.frame.size.height);
        [self addSubview:_innerSwitch];
        self.userInteractionEnabled = YES;
    } else {
        self.clipsToBounds = YES;

        _shadowsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_bg.png"]];
        _onImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_symbol_I.png"]];
        _offImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_symbol_o.png"]];
        _buttonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_btn.png"]];

        _grayBackgroundPart = [[UIView alloc] init];
        _grayBackgroundPart.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        _grayBackgroundPart.userInteractionEnabled = NO;

        UIImage *image = [UIImage imageNamed:@"switch_bg.png"];
        CGFloat height = image.size.height;
        CGFloat width = image.size.width*2 - _buttonImage.bounds.size.width;

        _onImage.center = CGPointMake(28, (CGFloat) round(height/2));
        _offImage.center = CGPointMake(width - 28, (CGFloat) round(height/2));
        
        {
            CGRect r1 = _buttonImage.frame;
            r1.origin = CGPointMake(round((width - r1.size.width) /2), round((height - r1.size.height) /2));
            _buttonImage.frame = r1;
        }
        // _buttonImage.center = CGPointMake((CGFloat) round(width/2), (CGFloat) round(height/2));
        
        _grayBackgroundPart.frame = CGRectMake(width/2, 0, width/2, height);

        _allSubviews = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];

        _allSubviews.userInteractionEnabled = NO;

        [_allSubviews addSubview:_grayBackgroundPart];
        [_allSubviews addSubview:_shadowsImage];
        [_allSubviews addSubview:_onImage];
        [_allSubviews addSubview:_offImage];
        [_allSubviews addSubview:_buttonImage];

        [self addSubview:_allSubviews];
        [self buttonReleased:nil];

        _allSubviews.backgroundColor = [UIColor clearColor];
        _shadowsImage.backgroundColor = [UIColor clearColor];

//            [self addTarget:self action:@selector(buttonPressed:event:) forControlEvents:UIControlEventTouchDown];
//            [self addTarget:self action:@selector(buttonReleased:) forControlEvents:UIControlEventTouchUpInside];
//            [self addTarget:self action:@selector(buttonCancelled:) forControlEvents:UIControlEventTouchCancel];
//            [self addTarget:self action:@selector(buttonMoved:event:) forControlEvents:UIControlEventTouchDragInside];
//            [self addTarget:self action:@selector(buttonMoved:event:) forControlEvents:UIControlEventTouchDragOutside];
        self.customColor = [UIColor colorWithRed:0.212 green:0.498 blue:0.973 alpha:1.000];

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

- (void)addTarget:(id)aTarget action:(SEL)aSelector forControlEvents:(UIControlEvents)aControlEvents {
    if (_ios5Logic) {
        [_innerSwitch addTarget:aTarget action:aSelector forControlEvents:aControlEvents];
    } else {
        _target = aTarget;
        _action = aSelector;
    }
}

- (void)buttonPressed:(id)aSender event:(UIEvent*)aEvent {
    _buttonImage.image = [UIImage imageNamed:@"switch_btn_press.png"];
    UITouch *touch = [[aEvent allTouches] anyObject];
    _switchPosition = [touch locationInView:self].x;
    _switchStartPosition = _allSubviews.frame.origin.x;
}

- (void)buttonCancelled:(id)aSender {
    _buttonImage.image = [UIImage imageNamed:@"switch_btn.png"];
}

- (void)buttonReleased:(id)aSender {
    _switchOn = !_switchOn;

    [UIView beginAnimations:@"toggle" context:nil];

    CGFloat position = _switchOn ? 0 : -_allSubviews.bounds.size.width/2 + _buttonImage.bounds.size.width/2;
    _allSubviews.frame = CGRectMake(position, 0, _allSubviews.bounds.size.width, _allSubviews.bounds.size.height);
    _shadowsImage.frame = CGRectMake(-position, 0, _shadowsImage.bounds.size.width, _shadowsImage.bounds.size.height);

    [UIView commitAnimations];

    [self buttonCancelled:aSender];

    if (!_ios5Logic) {
        [_target performSelector:_action withObject:self];
//        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)buttonMoved:(id)aSender event:(UIEvent*)aEvent {
    UITouch *touch = [[aEvent allTouches] anyObject];
    CGFloat switchPosition = [touch locationInView:self].x;

    CGFloat position = _switchStartPosition + (switchPosition - _switchPosition);
    position = MAX(position, -_allSubviews.bounds.size.width/2 + _buttonImage.bounds.size.width/2);
    position = MIN(position, 0);
    _allSubviews.frame = CGRectMake(position, 0, _allSubviews.bounds.size.width, _allSubviews.bounds.size.height);
    _shadowsImage.frame = CGRectMake(-position, 0, _shadowsImage.bounds.size.width, _shadowsImage.bounds.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super touchesBegan:touches withEvent:event];
//        [_innerSwitch touchesBegan:touches withEvent:event];
    } else {
        [super touchesBegan:touches withEvent:event];
        [self buttonPressed:self event:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super touchesMoved:touches withEvent:event];
//        [_innerSwitch touchesMoved:touches withEvent:event];
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super touchesEnded:touches withEvent:event];
//        [_innerSwitch touchesEnded:touches withEvent:event];
    } else {
        [super touchesEnded:touches withEvent:event];
        [self buttonReleased:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super touchesCancelled:touches withEvent:event];
//        [_innerSwitch touchesCancelled:touches withEvent:event];
    } else {
        [super touchesCancelled:touches withEvent:event];
        [self buttonCancelled:self];
    }
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super motionBegan:motion withEvent:event];
//        [_innerSwitch motionBegan:motion withEvent:event];
    } else {
        [super motionBegan:motion withEvent:event];
        [self buttonPressed:self event:event];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super motionEnded:motion withEvent:event];
//        [_innerSwitch motionEnded:motion withEvent:event];
    } else {
        [super motionEnded:motion withEvent:event];
        [self buttonReleased:self];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_ios5Logic) {
        [super motionCancelled:motion withEvent:event];
//        [_innerSwitch motionCancelled:motion withEvent:event];
    } else {
        [super motionCancelled:motion withEvent:event];
        [self buttonCancelled:self];
    }
}

- (void)drawRect:(CGRect)rect event:(UIEvent*)aEvent {
    if (_ios5Logic) {
        [super drawRect:rect];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, self.bounds, [[UIImage imageNamed:@"switch_mask.png"] CGImage]);

        [_customBackgroundColor setFill];
        CGContextFillRect(context, self.bounds);

        [super drawRect:rect];
    }
}

- (void)dealloc {
    [_innerSwitch release];

    [_onImage release];
    [_offImage release];
    [_buttonImage release];

    [_customBackgroundColor release];

    [_grayBackgroundPart release];
    [_allSubviews release];
    [_shadowsImage release];
    [super dealloc];
}

@end
