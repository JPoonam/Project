//!
//! @file INGraphics.h
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

#import <Foundation/Foundation.h>
#import "INCommonTypes.h"

/**
 @brief A collection of all Core Graphics - based useful code  
    
*/
@interface INCoreGraphics : NSObject {
    
}
//! @brief Creates a rectangle path for the given context 
+ (void)pathForRect:(CGRect)rect context:(CGContextRef)context;

//! @brief Creates a rounded-rect path for the goven context
+ (void)pathForRoundedRect:(CGRect)rect radius:(CGFloat)radius context:(CGContextRef)context; 

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief Some useful category extensions for UIImage class 
*/

@interface UIImage (INRU)
    
//! @brief Splits receiver into 3 pisces:left, center and right ones
//- (void)inru_splitTo3Images:(UIImage **)arrayOf3Images
//                   withLeftWidth:(CGFloat)leftWidth
//                   andRightWidth:(CGFloat)rightWidth;
    
//! @brief Splits receiver into 3 pisces:left, center and right ones
//- (void)inru_splitToLeftImage:(UIImage **)leftImage
//                      centerImage :(UIImage **)centerImage
//                     andRightImage:(UIImage **)rightImage
//                     withLeftWidth:(CGFloat)leftWidth
//                     andRightWidth:(CGFloat)rightWidth;
                 
//! @brief Часто бывает нужно для отладки, чтобы не тратить время на поиски                        
- (BOOL)inru_saveAsPNG:(NSString *)filePath;
    
@end

//==================================================================================================================================
//==================================================================================================================================

//! @brief Converts 0xRRGGBBAA integer into array of 4 CGFloats for passing into CG* functions. Not thread-safe version.
extern CGFloat * INColor2Components(NSUInteger rgba);

//! @brief Converts 0xRRGGBBAA integer into array of 4 CGFloats for passing into CG* functions. Thread-safe version.
extern CGFloat * INColor2Components_r(NSUInteger rgba, CGFloat * result);

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief Some useful category extensions for UIColor class 
 */
@interface UIColor (INRU)

/* 

    lightGrayColor :  0x999999FF
*/

//! @brief Creates an autoreleased UIColor from the integer in 0xRRGGBBAA format
+ (UIColor *)inru_colorFromRGBA:(NSUInteger)rgba;

//! @brief Creates an autoreleased UIColor from the array of 4 CGFloats
+ (UIColor *)inru_colorFromComponents:(const CGFloat *)components4;
  
//! @brief Put the nil-terminated array of UIColors into the array of CGFloat. Suitable for gradients creating, etc.
//!        No result dimensions checked. Provide at least 4 CGFloat for each color in the array
+ (CGFloat *)inru_colorsToComponents:(CGFloat *)result, UIColor * color1, ... NS_REQUIRES_NIL_TERMINATION;

+ (UIColor *)inru_defaultIPhoneNavBarTintColor;

@end

#define IN_DEC2RGBA(_R,_G,_B,_A) (((_R & 0xFF) << 24) | ((_G & 0xFF) << 16) | ((_B & 0xFF) << 8) | (_A & 0xFF))

//==================================================================================================================================
//==================================================================================================================================

extern void    INGraphicsBeginImageContext(CGSize size);
extern CGFloat INGraphicsScreenScale();
