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

#import <UIKit/UIKit.h>

@class INCountPicker;

//==================================================================================================================================
//==================================================================================================================================

@protocol INCountPickerDelegate<NSObject>

- (void)incountPickerDidChangeValue:(INCountPicker *)picker; 

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum { 
   INCountPickerPartLeft,
   INCountPickerPartCenter,
   INCountPickerPartRight
} INCountPickerPart;

typedef enum { 
   INCountPickerImageLeft,
   INCountPickerImageLeftPressed,
   INCountPickerImageCenter,
   INCountPickerImageCenterOverlay,
   INCountPickerImageRight,
   INCountPickerImageRightPressed,
   INCountPickerImageLast
   
} INCountPickerImageType;

@interface INCountPicker : UIView {
@private
    NSUInteger _value, _minValue, _maxValue;
    UILabel * _labelValue;
    UILabel * _labelComingValue;
    UIButton * _buttonLess;
    UIButton * _buttonMore;
    BOOL _transition;
    id<INCountPickerDelegate> _delegate;
}


@property(nonatomic) NSUInteger minValue;
@property(nonatomic) NSUInteger maxValue;
@property(nonatomic) NSUInteger value;


- (void)setValue:(NSUInteger)value animated:(BOOL)animated;

// @property(nonatomic,readonly) UILabel * titleLabel;
// без особо нужды наружу не выносить - возможно, по мере развития контрола, это уже будут не кнопки
// @property(nonatomic,readonly) UIButton * leftButton;
// @property(nonatomic,readonly) UIButton * rightLabel;

@property(nonatomic,assign) IBOutlet id<INCountPickerDelegate> delegate;


// to override
// это надо переопределять, чтобы подогнать все под конкретные картинки + отдать все эти картинки  
- (CGFloat)widthForPart:(INCountPickerPart)part;
- (CGRect)frameForPart:(INCountPickerPart)part; // использует widthForPart, если нужно нестандартное размещение - то переопределять здесь
- (UIImage *)imageOfType:(INCountPickerImageType)imageType;
- (UIEdgeInsets)contentInset;
- (UIFont *)moreLessFont;
- (UIFont *)valueFont;
- (UIColor *)valueColor;

// - (UIColor *)signColor; 

/* 

пример

- (UIImage *)imageOfType:(INCountPickerImageType)imageType {
   static NSString * images[INCountPickerImageLast] = { 
       @"counter_left.png",
       @"counter_left_pressed.png",
       @"counter_center.png",
       nil,
       @"counter_right.png",
       @"counter_right_pressed.png"
   };
   return [UIImage imageNamed:images[imageType]]; // или stretchedImage....
}

- (CGFloat)widthForPart:(INCountPickerPart)part { 
    switch(part) { 
        case INCountPickerPartCenter:
           return 48;
           
        case INCountPickerPartLeft:
        case INCountPickerPartRight:
           return 46;    
    }
    NSAssert(0,@"mk_e6dd86b9_56c4_41fe_862e_3b7e2a940373");

    return 0;
}

*/

@end
