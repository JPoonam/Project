//!
//! @file INTitleLine.m
//!
//! @author Alexander Babaed=v
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
  

#import "INTitleLine.h"

NSString * INTitleLineTextureRed    = @"titleLineRed.png";
NSString * INTitleLineTextureGreen  = @"titleLineGreen.png";
NSString * INTitleLineTextureBlue   = @"titleLineBlue.png";
NSString * INTitleLineTexturePurple = @"titleLinePurple.png";
NSString * INTitleLineTextureYellow = @"titleLineYellow.png";
NSString * INTitleLineTextureGreenYellow = @"titleLineGreenYellow.png";

//==================================================================================================================================
//==================================================================================================================================

@implementation INTitleLine

- (UIImage *)textureForBackground { 
    return [UIImage imageNamed:@"titleLineGray.png"];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)textureWithName:(NSString *)aTextureName { 
	return [UIImage imageNamed:aTextureName];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateColoredImageAnimated:(BOOL)animated {
    _coloredImageView.image = [self textureWithName:_texture];
    if (animated){
        [UIView beginAnimations:@"lineAnimation" context:nil];
	}
    _coloredImageView.frame = CGRectMake(_startX, 0, _endX - _startX, self.bounds.size.height);
	if (animated){
        [UIView commitAnimations];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit {
    _startX = 100;
    _endX = 200;
    
    self.image =  [self textureForBackground];
    self.contentMode = UIViewContentModeScaleToFill;
    
    _coloredImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:INTitleLineTextureRed]];
    _coloredImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_coloredImageView];
    
    [self updateColoredImageAnimated:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateSliderWithTexture:(NSString *)aTextureName 
                          startX:(CGFloat)aStartX 
                         andEndX:(CGFloat)aEndX
                        animated:(BOOL)animated {
    
	if (_texture != aTextureName){
		[_texture autorelease];
		_texture = [aTextureName copy];
	}
	_startX = aStartX;
	_endX = aEndX;
	
	[self updateColoredImageAnimated:animated];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrame:(CGRect)aFrame { 
    BOOL adjustLine = (_startX == 0 && _endX == self.bounds.size.width);
    [super setFrame:aFrame];
    if (adjustLine) {
        [self updateSliderWithTexture:_texture animated:NO]; 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateSliderWithTexture:(NSString *)aTextureName 
                        animated:(BOOL)animated {
    [self updateSliderWithTexture:aTextureName
                           startX:0
                          andEndX:self.bounds.size.width
                         animated:animated];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
	[_texture release];
	[_coloredImageView release];
    [super dealloc];
}

@end
