//!
//! @file INGraphics.m
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

#import "INGraphics.h"

@implementation INCoreGraphics

+ (void)pathForRect:(CGRect)rect context:(CGContextRef)context { 
    CGContextBeginPath(context);
    CGContextAddRect(context, rect);
    CGContextClosePath(context);
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)pathForRoundedRect:(CGRect)rect radius:(CGFloat)radius context:(CGContextRef)context { 
    CGContextBeginPath(context);
	CGContextMoveToPoint(context, CGRectGetMinX(rect)+ radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect)- radius, CGRectGetMinY(rect)+ radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect)- radius, CGRectGetMaxY(rect)- radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect)+ radius, CGRectGetMaxY(rect)- radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect)+ radius, CGRectGetMinY(rect)+ radius, radius, M_PI, 3 * M_PI / 2, 0);
    CGContextClosePath(context);
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation UIImage (INRU)

- (BOOL)inru_saveAsPNG:(NSString *)filePath { 
    NSData * data = UIImagePNGRepresentation(self);
    if (data) { 
        return [data writeToFile:filePath atomically:NO];
    }
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

/*
- (void)inru_splitTo3Images:(UIImage **)arrayOf3Images
                 withLeftWidth:(CGFloat)leftWidth
                 andRightWidth:(CGFloat)rightWidth {
    
    [self inru_splitToLeftImage:&arrayOf3Images[0]
                    centerImage:&arrayOf3Images[1]
                  andRightImage:&arrayOf3Images[2]
                  withLeftWidth:leftWidth
                  andRightWidth:rightWidth];
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

/*
- (void)inru_splitToLeftImage:(UIImage **)leftImage
        centerImage :(UIImage **)centerImage
       andRightImage:(UIImage **)rightImage
       withLeftWidth:(CGFloat)leftWidth
       andRightWidth:(CGFloat)rightWidth {
    
    CGImageRef c1 = NULL, c2 = NULL, c3 = NULL;
    [INCoreGraphics splitCGImage:self.CGImage 
           toLeftImage:leftImage   ? &c1 :NULL
           centerImage:centerImage ? &c2 :NULL
         andRightImage:rightImage  ? &c3 :NULL
         withLeftWidth:leftWidth
         andRightWidth:rightWidth];
    
    if (c1){
        if (leftImage){ 
            *leftImage = [UIImage imageWithCGImage:c1];
        }
        CGImageRelease(c1);
    }
    if (c2){
        if (centerImage){ 
            *centerImage = [UIImage imageWithCGImage:c2];
        }
        CGImageRelease(c2);
    }
    if (c3){
        if (rightImage){ 
            *rightImage = [UIImage imageWithCGImage:c3];
        }
        CGImageRelease(c3);
    }
}
*/
@end

//==================================================================================================================================
//==================================================================================================================================

@implementation UIColor (INRU)

+ (UIColor *)inru_colorFromRGBA:(NSUInteger)rgba { 
    return [self colorWithRed:((rgba >> 24)& 0x0ff)/ 255.0
                        green:((rgba >> 16)& 0x0ff)/ 255.0
                         blue:((rgba >> 8)& 0x0ff)/ 255.0
                        alpha:((rgba >> 0)& 0x0ff)/ 255.0];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (UIColor *)inru_colorFromComponents:(const CGFloat *)components4 {
    return [self colorWithRed:components4[0]
                        green:components4[1]
                         blue:components4[2]
                        alpha:components4[3]];
}

//----------------------------------------------------------------------------------------------------------------------------------
// getRed:green:blue:alpha:

int _ColorToComponents(UIColor * color, CGFloat * components) { 
    if (INSystemVersionEqualsOrGreater(5, 0, 0)) { 
        if (![color getRed:components green:components+1 blue:components+2 alpha:components+3]) {
            bzero(components, sizeof(CGFloat) * 4);
        }
             
    } else { 
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char resultingPixel[4] = {};
        CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                     1,
                                                     1,
                                                     8,
                                                     4,
                                                     rgbColorSpace,
                                                     // kCGImageAlphaPremultipliedLast
                                                     kCGImageAlphaNoneSkipLast
                                                     );
        CGContextSetFillColorWithColor(context, [color CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
        CGContextRelease(context);
        CGColorSpaceRelease(rgbColorSpace);
        for (int component = 0; component < 4; component++) {
            components[component] = resultingPixel[component] / 255.0f;
        }
    }
    
    return 4;
}


+ (CGFloat *)inru_colorsToComponents:(CGFloat *)result, UIColor * color1, ... {
    va_list ap;
        UIColor * color = nil;
        BOOL firstObjProcessing = YES;
        int resultOffset = 0; // , countOfComponents;
        // CGColorSpaceRef colorSpace;
    va_start(ap, color1);
        // fill from set
        while (1){
            if (firstObjProcessing){
                color = color1;
                firstObjProcessing = NO;
            } else {
                color = va_arg(ap, UIColor *);
            }
            if (color == nil){
                break;
            }
            resultOffset += _ColorToComponents(color, result + resultOffset);
            /* 
            model = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)); // CGColorSpaceGetColorTable
            
            countOfComponents = CGColorSpaceGetNumberOfComponents(CGColorGetColorSpace(color.CGColor));
            memcpy(result + resultOffset, CGColorGetComponents(color.CGColor), sizeof(CGFloat)* (countOfComponents + 1));
            if (countOfComponents == 1){ // monochrome?
                // if (CGColorSpaceModel == kCGColorSpaceModelMonochrome){
                // 
                // }
                NSLog(@"%d",CGColorEqualToColor(color.CGColor, [UIColor whiteColor].CGColor));
                CGColorSpaceGetColorTable(CGColorGetColorSpace(color.CGColor), table);

                
                
                result[resultOffset + 3] = result[resultOffset + 1]; // move alpha to 4th position
                result[resultOffset + 1] = result[resultOffset];
                result[resultOffset + 2] = result[resultOffset];
                countOfComponents = 3;
            } 
            resultOffset += countOfComponents + 1;
            */
        }
    va_end(ap);
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (UIColor *)inru_defaultIPhoneNavBarTintColor { 
    // http://stackoverflow.com/questions/905158/what-is-the-default-color-for-navigation-bar-buttons-on-the-iphone/906682#906682
    return [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
}

@end

//==================================================================================================================================
//==================================================================================================================================

CGFloat * INColor2Components(NSUInteger rgba){
    static CGFloat notThreadSafe[4]; 
    return INColor2Components_r(rgba, notThreadSafe);  
}

//----------------------------------------------------------------------------------------------------------------------------------


CGFloat * INColor2Components_r(NSUInteger rgba, CGFloat * result){ 
    result[0] = ((rgba >> 24)& 0x0ff)/ 255.0;
    result[1] = ((rgba >> 16)& 0x0ff)/ 255.0;
    result[2] = ((rgba >> 8)& 0x0ff)/ 255.0;
    result[3] = ((rgba >> 0)& 0x0ff)/ 255.0;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

void INGraphicsBeginImageContext(CGSize size) { 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if (INSystemVersionEqualsOrGreater(4,0,0)) { 
        UIGraphicsBeginImageContextWithOptions(size,NO,0);
    } else
#endif 
    {
        UIGraphicsBeginImageContext(size);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

CGFloat INGraphicsScreenScale() {
    static CGFloat cachedValue = 0;
    if (!cachedValue) { 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000	
        if (INSystemVersionEqualsOrGreater(4,0,0) ){  
            cachedValue = [[UIScreen mainScreen] scale];
        } else 
#endif
        {
            cachedValue = 1.0;
        }
    }
    return cachedValue; 
}
