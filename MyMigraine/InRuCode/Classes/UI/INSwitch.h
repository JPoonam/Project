//
//  Created by alex on 5/28/11.
//


#import <Foundation/Foundation.h>

@interface INSwitch : UIView {
    BOOL _ios5Logic;

    BOOL _switchOn;
    CGFloat _switchPosition;
    CGFloat _switchStartPosition;

    UIView *_allSubviews;

    UIView *_grayBackgroundPart;
    UIImageView *_onImage;
    UIImageView *_offImage;
    UIImageView *_buttonImage;

    UIImageView *_shadowsImage;

    UISwitch *_innerSwitch;

    UIColor *_customBackgroundColor;
    
    id _target;
    SEL _action;
}

@property(nonatomic, retain) UIColor *customColor;
@property(nonatomic, assign, getter=isOn) BOOL on;

- (BOOL)isOn;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

- (void)addTarget:(id)aTarget action:(SEL)aSelector forControlEvents:(UIControlEvents)aControlEvents;

@end
