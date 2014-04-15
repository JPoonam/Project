//!
//! @file INLabel.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! Copyright © 2010-2011 InRu
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

@class INLabel;

typedef enum {
   INTextVAlignmentTop,
   INTextVAlignmentMiddle,
   INTextVAlignmentBottom
} INTextVAlignment;

/* 

Example: set INLabel as a link. 
         Long touch brings popup with Open URL, Copy URL items (works for 3.2 only!) 
         Suppose that parent UIViewController has been assigned as a delegate (INLabelDelegate).


- (void)inlabelTouched:(INLabel *)label { 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:label.tagObject]];
}

- (NSString *)inlabelTextForPasterboard:(INLabel *)label { 
    return label.tagObject;
}

- (void)inlabel:(INLabel *)label didSelectMenuItemAtIndex:(NSInteger)index { 
    // works since 3.2 only, ignored or earlier versions
     
    switch (index) {
       // Open URL menu item  
        case 0: [self inlabelTouched:label];
                 break;
                 
        // Copt URL menu item
        case 1: [label copy:nil];
                break;
    }
}

- (NSArray *)inlabelItemsForMenu:(INLabel *)label { 
    return [NSArray arrayWithObjects:@"Open URL", @"Copy URL",nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _label1.delegate = self;    
    _label1.copyAbilityEnabled = !INSystemVersionEqualsOrGreater(3, 2, 0); // for earlier OS versions just enable "Copy" menu item
    _label1.touchedTextColor = [UIColor inru_colorFromRGBA:0x336699ff];
    _label1.tagObject = @"http://www.ya.ru/";  // we use tag object to store some label-specific data (URL in the given example)
    _label1.touchTextUnderlined = YES;
    _label1.textUnderlined = YES;   
}

Note1: For scrollboxed superviews set canCancelContentTouches to NO


*/

//==================================================================================================================================
//==================================================================================================================================

@protocol INLabelDelegate<NSObject>

@optional

// default is label text
- (NSString *)inlabelTextForPasterboard:(INLabel *)label; 


- (void)inlabelTouched:(INLabel *)label;

// Only iOS 3.2 and higher
- (NSArray *)inlabelItemsForMenu:(INLabel *)label; 

// Only iOS 3.2 and higher
- (void)inlabel:(INLabel *)label didSelectMenuItemAtIndex:(NSInteger)index; 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INLabel : UILabel {
@private
    id<INLabelDelegate> _delegate;
    BOOL _touchAndHoldMenuShown;
    BOOL _touchOverLabel;
    BOOL _touched;
    BOOL _touchedAttributesApplied;
    CGPoint _longTouchAtPoint;
    id _tagObject;
    UIColor * _touchedTextColor, * _touchedShadowColor;
    INTextVAlignment _verticalAlignment;
    BOOL _copyAbilityEnabled;
    BOOL _isTextUnderlined;
    BOOL _isTouchedTextUnderlined;
    BOOL _useLegacyDrawing;
    BOOL _disableShadowOnHighlight;
    UIEdgeInsets _touchEdgeInsets;
    UIEdgeInsets _contentEdgeInsets;
    NSInteger _tag2;
    
    /* 
        mk: apr-13-2012. Традиционно вся обработка тачей была реализована через touchesBegan/touchesEnd/etc.
                         В соответствии с новыми веяниями, были добавлены распознавания жестов, но чтобы не ломать
                         все, что работает и так, в основном эти жесты нужны для того, чтобы перехватывать родительские
                         жесты (привязанные к вьюхам в более высших иерархиях). Вероятно, в дальнейшем, код будет привязан 
                         именно к жестам (когда окончательно откажемся от поддержки <3.2)
    */
    
    UITapGestureRecognizer * _tapGestureRecognizer;
    UILongPressGestureRecognizer * _longTapGestureRecognizer;
}

@property(nonatomic,assign) IBOutlet id<INLabelDelegate> delegate;
@property(nonatomic,retain) IBOutlet id tagObject;
@property(nonatomic) NSInteger tag2;

@property(nonatomic) UIEdgeInsets contentEdgeInsets;

@property(nonatomic) BOOL useLegacyDrawing;
@property(nonatomic) BOOL disableShadowOnHighlight; // YES for default - it is ok for UITableViewCells
@property(nonatomic) INTextVAlignment verticalTextAlignment;

@property(nonatomic,retain) UIColor * touchedTextColor;
@property(nonatomic,retain) UIColor * touchedShadowColor;
@property(nonatomic) BOOL isTextUnderlined;
@property(nonatomic) BOOL isTouchedTextUnderlined;

@property(nonatomic) BOOL copyAbilityEnabled;
- (void)copy:(id)sender;

- (CGRect)touchableArea;

// очень частая операция, так что выносим это сюда. можно принять за основу и после вызова кастомизировать по вкусу
- (void)setupAsLinkLabelForURLString:(NSString *)URLString;

@end
