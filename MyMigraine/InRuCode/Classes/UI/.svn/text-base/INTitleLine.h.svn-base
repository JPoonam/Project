//!
//! @file INTitleLine.h
//!
//! @author Alexander Babaev (alex.babaev@me.com)
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

/**
  @brief A nice gradiented line with a animated slider. Used currently by NSTabbebNavigationController  
    
*/
@interface INTitleLine : UIImageView {
@private
	NSString * _texture;
	CGFloat _startX;
	CGFloat _endX;
	UIImageView * _coloredImageView;
}

//! @brief Changes slider color and chane it's position   
- (void)updateSliderWithTexture:(NSString *)aTextureName 
                              startX:(CGFloat)aStartX 
                             andEndX:(CGFloat)aEndX
                            animated:(BOOL)animated;

//! @brief Changes slider color and change it's position   
- (void)updateSliderWithTexture:(NSString *)aTextureName animated:(BOOL)animated;

//! @brief Returns prepared image for line background. Default is a gray one (do not forget titleLineGray.png in the resources)
- (UIImage *)textureForBackground; 

//! @brief Tesxure image for colored line pieces
- (UIImage *)textureWithName:(NSString *)aTextureName;
@end

//==================================================================================================================================
//==================================================================================================================================

//! @brief Predefined 'red' color line texture for INTitleLine
extern NSString * INTitleLineTextureRed;    

//! @brief Predefined 'green' color line texture for INTitleLine
extern NSString * INTitleLineTextureGreen;  

//! @brief Predefined 'blue' color line texture for INTitleLine
extern NSString * INTitleLineTextureBlue;   

//! @brief Predefined 'purple' color line texture for INTitleLine
extern NSString * INTitleLineTexturePurple; 

//! @brief Predefined 'yellow' color line texture for INTitleLine
extern NSString * INTitleLineTextureYellow; 

//! @brief Predefined 'lime' color line texture for INTitleLine
extern NSString * INTitleLineTextureGreenYellow; 

