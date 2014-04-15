//!
//! @file INPanel.h
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

#import <UIKit/UIKit.h>

/**
 @brief Background style type for INPanel
    
*/
typedef enum { 
   INPanelBGStyleDefault, 
   INPanelBGStyleVerticalGradient,
   INPanelBGStyleVerticalGradient2,
   INPanelBGStyleNavigator,
   INPanelBGStyleTabBar,
   INPanelBGStyleSolidColor,
} INPanelBGStyle;

/**
 @brief A common-used base panel view. Provides with a complex background and (in the future) many other features  
    
    Внимание!!!! По историческим причинам панель создается с self.backgroundColor = [UIColor clearColor];
    Если прозрачность не нужна, то для экономии графических ресурсов в наследниках назначай любой другой background Color, в том числе и nil!
    
*/

@interface INPanel : UIView {
@private
    INPanelBGStyle _bgStyle; 
    UIColor * _color1, * _color2, * _color3; // , * _borderColor;
    UIColor * _topEdgeColor, * _bottomEdgeColor;
    CGFloat _roundedRectRadius;
   // BOOL _drawBorder;
}

- (void)internalInit;

//! @brief Get/set background style
@property(nonatomic) INPanelBGStyle backgroundStyle;

//! @brief Top gradient color for backgroundStyle = INPanelBGStyleVerticalGradient or INPanelBGStyleVerticalGradient2, 
//         solid color for INPanelBGStyleSolidColor 
@property(nonatomic,retain) UIColor * topGradientColor;

//! @brief Bottom gradient color for backgroundStyle = INPanelBGStyleVerticalGradient or INPanelBGStyleVerticalGradient2
@property(nonatomic,retain) UIColor * bottomGradientColor;
 
//! @brief Middle gradient color for backgroundStyle = INPanelBGStyleVerticalGradient2
@property(nonatomic,retain) UIColor * middleGradientColor;


@property(nonatomic) CGFloat roundedRectRadius;

@property(nonatomic,retain) UIColor * topEdgeColor;
@property(nonatomic,retain) UIColor * bottomEdgeColor;

@end
