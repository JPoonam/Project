
#import "BHGlobals.h"

@implementation BHReusableObjects

+ (UIFont *)blueLabelFont { 
    static UIFont * font = nil;
    if (!font) {
        font = [[UIFont fontWithName:@"Oswald" size:20] retain];
    }
    return font;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (UIFont *)redLabelFont { 
    static UIFont * font = nil;
    if (!font) {
        font = [[UIFont boldSystemFontOfSize:20] retain];
    }
    return font;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (UIColor *)texturedColor { 
    static UIColor * color = nil;
    if (!color) {
        #ifdef DEBUG_BRIGHT_BACKGROUND
            color = [[[UIColor redColor] colorWithAlphaComponent:0.2] retain];
        #else 
            color = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.png"]] retain];
        #endif 
    }
    return color;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (UIColor *)blueLabelColor { 
  //  return [UIColor inru_colorFromRGBA:0x006699FF];
   
    
    // DMI:change  blue color to green for title  
    return [UIColor inru_colorFromRGBA:0x227B40FF];
}

@end

