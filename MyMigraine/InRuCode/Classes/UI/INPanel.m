//!
//! @file INPanel.m
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

#import "INPanel.h"
#import "INGraphics.h"

@implementation INPanel

@synthesize backgroundStyle = _bgStyle;
@synthesize topGradientColor = _color1;
@synthesize bottomGradientColor = _color2;
@synthesize middleGradientColor = _color3;
@synthesize roundedRectRadius = _roundedRectRadius;
@synthesize topEdgeColor = _topEdgeColor;
@synthesize bottomEdgeColor = _bottomEdgeColor;

//----------------------------------------------------------------------------------------------------------------------------------

#define LASY_PROP_IMP(__var,__setProp) \
    - (void)__setProp:(UIColor *)value { \
        if (value != __var) { \
            [__var release]; \
            __var = [value retain]; \
            [self setNeedsDisplay]; \
        }\
    }


LASY_PROP_IMP(_topEdgeColor,setTopEdgeColor)
LASY_PROP_IMP(_bottomEdgeColor,setBottomEdgeColor)
LASY_PROP_IMP(_color1,setTopGradientColor)
LASY_PROP_IMP(_color2,setBottomGradientColor)
LASY_PROP_IMP(_color3,setMiddleGradientColor)

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setRoundedRectRadius:(CGFloat)value { 
    _roundedRectRadius = value;
    [self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)setDrawBorder:(BOOL)value {
//    if (_drawBorder != value){ 
//        _drawBorder = value;
//        [self setNeedsDisplay];
//    }
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBackgroundStyle:(INPanelBGStyle)newStyle { 
    if (newStyle != _bgStyle){ 
        _bgStyle = newStyle;
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    _bgStyle = INPanelBGStyleDefault;
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder { 
    self = [super initWithCoder:aDecoder];
    if (self != nil){
        [self internalInit];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)aFrame { 
    self = [super initWithFrame:aFrame];
    if (self != nil){
        [self internalInit];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_color1 release];
    [_color2 release];
    [_color3 release];
    // [_borderColor release];
    [_topEdgeColor release];
    [_bottomEdgeColor release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)setFrame:(CGRect)aRect { 
//    [super setFrame:aRect];
// }

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect r = self.bounds;
    [INCoreGraphics pathForRect:r context:context];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (_roundedRectRadius){ 
        [INCoreGraphics pathForRoundedRect:CGRectInset(r, 1, 1) radius:_roundedRectRadius context:context];
        CGContextClip(context);
    }
    
    UIColor * teColor = _topEdgeColor;
    UIColor * te2Color = nil;
    UIColor * beColor = _bottomEdgeColor;
    
    switch (_bgStyle){ 
        case INPanelBGStyleSolidColor:
            [_color1 set];
            CGContextFillRect(context, r);
            break;
            
        case INPanelBGStyleDefault:
            break;
            
        case INPanelBGStyleVerticalGradient2:
            {
                CGFloat c[30];
                [UIColor inru_colorsToComponents:c, _color1, _color3, _color2, nil];
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, c, nil, 3);
                CGContextDrawLinearGradient(context, gradient, 
                                            CGPointMake(0, 0), // 50  
                                            CGPointMake(0, r.size.height), 
                                            kCGGradientDrawsAfterEndLocation | 
                                            kCGGradientDrawsBeforeStartLocation);
                CGGradientRelease(gradient);
            }
            break;
            
        case INPanelBGStyleVerticalGradient:
            {
                CGFloat c[30];
                [UIColor inru_colorsToComponents:c, _color1, _color2, nil];
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, c, nil, 2);
                CGContextDrawLinearGradient(context, gradient, 
                                            CGPointMake(0, 0), 
                                            CGPointMake(0, r.size.height), 
                                            kCGGradientDrawsAfterEndLocation | 
                                            kCGGradientDrawsBeforeStartLocation);
                CGGradientRelease(gradient);
            }
            break;

            
        case INPanelBGStyleTabBar:
            {
                static const CGFloat topGradient[] = { 
                     // gradient 
                     0x2e / 255.0, 0x2e / 255.0, 0x2e /255.0, 1,
                     0x15 / 255.0, 0x15 / 255.0, 0x15 /255.0, 1
                };
                static const CGFloat fillColor[] = { 
                     0, 0, 0, 1.0
                };
                
                // gradient
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, topGradient, nil, 2);
                CGFloat h = r.size.height / 2;
                CGContextDrawLinearGradient(context, gradient, 
                                            CGPointMake(0, 0),  
                                            CGPointMake(0, h), 0);
                CGGradientRelease(gradient);
                CGContextSetFillColor(context, fillColor);
                CGContextFillRect(context, INRectInset(r, 0, h, 0, 0));
                
                teColor  = [UIColor blackColor];
                te2Color = [UIColor inru_colorFromRGBA:0x434343FF];
                // beColor = [UIColor inru_colorFromRGBA:0x2D3642FF];
                
            }
            break;
            
                            
        case INPanelBGStyleNavigator:
            {
                static const CGFloat naviColors1[] = { 
                     // gradient 
                     0xb0 / 255.0, 0xBC / 255.0, 0xCD /255.0, 1,
                     0x88 / 255.0, 0x9B / 255.0, 0xB3 /255.0, 1
                };
                static const CGFloat naviColors2[] = { 
                     0x81 / 255.0, 0x95 / 255.0, 0xAF /255.0, 1,
                     0x6D / 255.0, 0x84 / 255.0, 0xA2 /255.0, 1
                };   
                
                //static const CGFloat naviColorsTopLine[] = { 
                //     0xCD / 255.0, 0xD5 / 255.0, 0xDF / 255.0, 1
                //};

                //static const CGFloat naviColorsBottomLine[] = { 
                //    0x2D / 255.0, 0x36 / 255.0, 0x42 / 255.0, 1
                //};
                
                // gradient
                CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, naviColors1, nil, 2);
                CGFloat h = r.size.height / 2;
                CGContextDrawLinearGradient(context, gradient, 
                                            CGPointMake(0, 0),  
                                            CGPointMake(0, h), 0);
                CGGradientRelease(gradient);
                gradient = CGGradientCreateWithColorComponents(colorSpace, naviColors2, nil, 2);
                CGContextDrawLinearGradient(context, gradient, 
                                            CGPointMake(0, h),  
                                            CGPointMake(0, r.size.height),0);
                CGGradientRelease(gradient);
                
                teColor = [UIColor inru_colorFromRGBA:0xCDD5DFFF];
                beColor = [UIColor inru_colorFromRGBA:0x2D3642FF];
                
            }
            break;
            
        default:
            break;
    }


/*    // not used, not optimized (especially for rounded rects)
    if (_drawBorder){ 
        [_borderColor set];
        if (_roundedRectRadius){
            [INCoreGraphics pathForRoundedRect:r radius:_roundedRectRadius context:context]; 
            CGContextStrokePath(context);
        } else {
            CGContextStrokeRect(context, r);
        }
    }
*/
    
    // edges
    CGContextSetLineWidth(context, 1);
    
    // top line 
    if (teColor) { 
        CGContextSetStrokeColorWithColor(context, teColor.CGColor);
        CGPoint line[2] = {
            CGPointMake(0,0.5), 
            CGPointMake(r.size.width,0.5)
        };
        CGContextStrokeLineSegments(context, line, 2);
    }
    // top + 1 line 
    if (te2Color) { 
        CGContextSetStrokeColorWithColor(context, te2Color.CGColor);
        CGPoint line[2] = {
            CGPointMake(0,0.5 + 1), 
            CGPointMake(r.size.width,0.5 + 1)
        };
        CGContextStrokeLineSegments(context, line, 2);
    }


    if (beColor) { 
        CGContextSetStrokeColorWithColor(context, beColor.CGColor);
        CGPoint line[2] = {
            CGPointMake(0,r.size.height - 0.5), 
            CGPointMake(r.size.width,r.size.height - 0.5)
        };
        CGContextStrokeLineSegments(context, line, 2);
    }
    
    CGColorSpaceRelease(colorSpace);
}

@end
