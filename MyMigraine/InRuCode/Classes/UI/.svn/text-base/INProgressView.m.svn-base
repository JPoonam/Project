//!
//! @file INProgressView.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
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

#import "INProgressView.h"

@implementation INProgressView

@synthesize extendedBarStyle = _extendedBarStyle;
@synthesize backgroundImage = _backgroundImage;
@synthesize progressImage = _progressImage;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setExtendedBarStyle:(INProgressViewStyle)value { 
    if (value != _extendedBarStyle) { 
        _extendedBarStyle = value;
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBackgroundImage:(UIImage *)value { 
    if (value != _backgroundImage) { 
        [_backgroundImage autorelease];
        _backgroundImage = [value retain];
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setProgressImage:(UIImage *)value { 
    if (value != _progressImage) { 
        [_progressImage autorelease];
        _progressImage = [value retain];
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)dealloc {
    [_backgroundImage release];
    [_progressImage release];
    [super dealloc];
}

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    switch(_extendedBarStyle) {
        case INProgressViewStyleDefault:
            [super drawRect:rect];
            break;
            
        case INProgressViewStyleCustom:
            {
                CGRect r = self.bounds;
                CGSize sz = _backgroundImage.size;
                r.size.height = sz.height;
                [_backgroundImage drawInRect:r];
                CGRect rp = r;
                sz = _progressImage.size;
                rp.size.height = sz.height;
                rp.size.width = round(self.progress * rp.size.width);
                CGFloat minWidth = sz.width;
                if (rp.size.width) {
                    if (rp.size.width < minWidth) {
                        rp.size.width = minWidth;
                    }  
                    if (rp.size.width > r.size.width) {
                        rp.size.width = r.size.width;
                    }
                    [_progressImage drawInRect:rp];
                }
            }
            break;
    }
}

@end
