//!
//! @file INPopupView.h
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

#import <UIKit/UIKit.h>
#import "INPanel.h"

/**
 @brief Touch modes for INPopupView touchMode property 
    
*/
typedef enum {
    INPopupViewTouchModeNone, // никакой реакции на нажатие - это поведение по умолчанию
    INPopupViewTouchModeFade, // При нажатии вьюшка скрывается с анимацией
    INPopupViewTouchModeHide, // При нажатии вьюшка скрывается мгновенно
    INPopupViewTouchModeTransparent, // Прозрачно для нажатия, т.е. перенаправляет все нажатия нижележащим контролам
} INPopupViewTouchMode;  


typedef enum  { 
   INPopupViewHidden,
   INPopupViewShowing,
   INPopupViewHiding,
   INPopupViewVisible
} INPopupViewState;
   
@class INPopupView;

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A delegate for \c INPopupViewDelegate class 
    
*/

@protocol INPopupViewDelegate<NSObject> 
@optional

//! @brief User taps on popup view
//         если имплементация возвращает YES то никакой дальнейшей обработки касания не ведется, т.е.  touchMode полностью игнорируется
- (BOOL)handleTouchForPopupView:(INPopupView *)popupView;
  
@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A base class for all popup-with-animation-then-hide subclasses. 
        Provides a base engine to popup, show, hide itself, with animation (optionally)
             
        Панелька со скругленными краями, предназначенная для отображения индикаторов закрузки и всплывающих сообщений.
        По умолчанию полупрозрачная, серая, со скругленными краями, но поскольку наследуется от INPanel, то фон может 
        быть раскрашен как угодно ну или почти как угодно.
*/

@interface INPopupView : INPanel {
@private
    INPopupViewTouchMode _touchMode;
    NSTimer * _timer;
    NSTimeInterval _animationDuration;
    // BOOL _drawRoundedRect;
    BOOL _autoDestroyOnHide;
    // BOOL _autoHideMode;
    id<INPopupViewDelegate> _delegate;
    INPopupViewState _popupState;
}

//! @brief Designited initializer
- (void)initPopupView;

//! @brief Для тех извращенцев, как я, что любят interface builder. не забыть: 1) FileOwner is INNibLoader 2) FileOwner.view -> view 3) view.class is INPopupView или его наследник! 
+ (id)viewWithCenter:(CGPoint)aCenter fromNib:(NSString *)nibFileName;


//! @brief Defines a reaction for user taps on the popup view
//         См. описание  INPopupViewTouchMode
@property(nonatomic) INPopupViewTouchMode touchMode; 
 
//! @brief A duration of animated poping up/hiding. Default is 0.4 sec.
@property(nonatomic) NSTimeInterval animationDuration;

@property(nonatomic,readonly) INPopupViewState popupState;

//! @brief if YES then draws semi-transparent gray rounded rect as it's own background. default is YES 
// @property(nonatomic) BOOL drawRoundedRect;

//! @brief If YES then destroys itself (remove itself from superview)on hiding. 
//  No [self release] is called! make sure that superview is the only retainer for that popup 
@property(nonatomic) BOOL autoDestroyOnHide;

//! @brief A delegate 
@property(nonatomic,assign) IBOutlet id<INPopupViewDelegate>  delegate;

//! @brief Shows/hides popup with animation (optional)
- (void)setHidden:(BOOL)isHidden withAnimation:(BOOL)animation;

//! @brief Shows popup and possible animation and autohides it in \c seconds seconds. 
//         Pass 0 or negative seconds value to prevent autohiding 
- (void)popupWithAnimation:(BOOL)animation andAutoHideOnDelay:(NSTimeInterval)seconds;

//! @brief Почти тоде самое, что и self.center, только с выравненными в целое координатами. Удобно использовать это вместо .center для того. чтобы контрол всегда был риальным, чотким и резким 
@property CGPoint adjustedCenter; 

@end

//==================================================================================================================================
//==================================================================================================================================

/**
   @brief A descendant of INPopupView. Adds a centered label for message displaying
          
      Типичное использование:
          
      - (void)someAction:(id)sender { 
          INPopupViewLabel * popupLabel = [INPopupViewLabel viewWithCenter:[self.view inru_centerOfContent] size:CGSizeMake(200,100)];
          [self.view addSubview:popupLabel];
          popupLabel.messageLabel.text = @"Очень, очень важное сообщение. Но если она вас раздражает, просто коснитесь пальцем и оно исчезнет раньше положенных 5 секунд";
          [popupLabel adjustHeightToFitMessage]; // теперь попап имеет адекватную тексту высоту.
          popupLabel.autoDestroyOnHide = YES;
          popupLabel.touchMode = INPopupViewTouchModeFade; // Теперь можно тыкать пальцем для убыстрения сворачивания или иной акции (если назначить еще и делегат)
          [popupLabel popupWithAnimation:YES andAutoHideOnDelay:5]; // 0 или меньше нуля - будет висеть пока не коснешься пальцем
      } 
      
      (хотя лично я (mk) предпочитаю иметь его сразу созданным и позиционированным в IB - 
      так можно отследить единичность инстанса. ну или как вариант использовать что-то с tags, типа 
      [[self.view subviewWithTag:12345] removeFromSuperview]... newPopup.tag = 12345; )
   
*/
@interface INPopupViewLabel : INPopupView {
@private
    UILabel * _messageLabel;
    UIEdgeInsets _messageLabelInsets;
}

//! @brief A label. Assign all of your messages here
@property(nonatomic,readonly) UILabel * messageLabel;
 
@property(nonatomic) UIEdgeInsets messageLabelInsets;    
          
//! @brief Adjust height (and possible vertical origin)to lay out the message label for displaying the message without croppings
- (void)adjustHeightToFitMessage;

//! @brief Creates a  labeled popup view. 
+ (INPopupViewLabel *)viewWithCenter:(CGPoint)aCenter andSize:(CGSize)size;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
   @brief A descendant of INPopupView. Adds an activity indicator for progress displaying
          Просто индикатор активности. Размеры - 70 на 70.
          Надо бы добавить туда еще и UILabel, но как-то все руки не доходят, а плодить еще одного наследника INPopupView тоже неправильно. 
 */
@interface INPopupViewActivity : INPopupView {
@private
	NSString				* _title;
    UIActivityIndicatorView * _activityIndicator;
}
@property (nonatomic, retain) NSString *title;

//! @brief Creates a  progress indicator popup view. Animation is started immediately
+ (id)viewWithCenter:(CGPoint)aCenter;

@end



