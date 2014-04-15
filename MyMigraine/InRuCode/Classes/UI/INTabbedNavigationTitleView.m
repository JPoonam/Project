//!
//! @file INTabbedNavigationTitleView.m
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

#import "INTabbedNavigationTitleView.h"
#import "INGraphics.h"

@implementation INTabbedNavigationTitleView

@synthesize selectedTab = _selectedTab;
@synthesize delegate = _delegate;
@synthesize titleFont = _titleFont;
@synthesize selectedTextColor = _selectedTextColor;
@synthesize textColor = _textColor;
@synthesize drawTitles = _drawTitles;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedTab:(NSInteger)value { 
    if (value != _selectedTab){ 
        _selectedTab = value;
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])){
		self.opaque = YES;
		self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        self.titleFont = [UIFont boldSystemFontOfSize:12];
        self.textColor = [UIColor inru_colorFromRGBA:0x7f7f7fFF];
        self.selectedTextColor = [UIColor whiteColor];
		_selectedTab = 0;
        _drawTitles = YES;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    self.titleFont = nil;
    self.selectedTextColor = nil;
    self.textColor = nil;
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrame:(CGRect)aFrame {
	// iPhone пытается уменьшить вью (думая, что он "как все"), но мы ему этого не дадим. 
	// Нам нужна вся ширина, чтобы сделать красивые табы.
    CGFloat width = 320; // should be reviewed to remove hardcoded 320. when test - check animation restore from
                         // child navigation controllers in the stack
	aFrame = CGRectMake(0, 0, width, self.bounds.size.height);
	[super setFrame:aFrame];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tabCount {
    NSInteger result = 0;
    if ([self.delegate respondsToSelector:@selector(tabCountForTabbedTitle:)]){
        result = [self.delegate tabCountForTabbedTitle:self];
    } 
    return result > 0 ? result :1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)titleAtIndex:(NSInteger)index { 
    NSString * title = nil;
    if ([self.delegate respondsToSelector:@selector(tabCaptionForTabbedTitle:andIndex:)]){ 
        title = [self.delegate tabCaptionForTabbedTitle:self andIndex:index];
    }
    if (!title){
        title = [NSString stringWithFormat:@"Item %d", index];
    }
    return title;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateTabWidthes {
    CGFloat totalWidth = 0;
    NSInteger tabsCount = [self tabCount];
    NSAssert(tabsCount <= 10, @"Too many tabs 5b2aad93_f79c_45de_bf95_575c42d8db0d");
    
    for (int i = 0; i < tabsCount; i++){
        _tabWidthes[i] = [[self titleAtIndex:i] sizeWithFont:_titleFont].width;
        totalWidth += _tabWidthes[i];
    }
    
    CGFloat currentTotalWidth = 0;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat widthDiff = MIN(viewWidth, totalWidth);
    CGFloat pad = (viewWidth - widthDiff)/tabsCount; 
    for (int i = 0; i < tabsCount - 1; i++){
	    _tabWidthes[i] = nearbyint(pad + ((widthDiff * _tabWidthes[i])/totalWidth));
        currentTotalWidth += _tabWidthes[i];
    }
    
    _tabWidthes[tabsCount - 1] = viewWidth - currentTotalWidth; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSRange)positionForTab:(NSInteger)index withRecalculation:(BOOL)recalculation { 
    if (recalculation){ 
        [self updateTabWidthes];
    }
    
    NSRange result;
    result.location = 0;
    for (int i = 0; i < index; i++) { 
        result.location += _tabWidthes[i];
    }
    
    result.length = _tabWidthes[index];
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect {
	// сначала подготовим цвета для разных рисовалок
	static const CGFloat colors[] = {
		0.6171875, 0.6171875, 0.6171875, 1.0, 
		0.16796875, 0.16796875, 0.16796875, 1.0
	};
	
	static const CGFloat selectedColors[] = {
		0.3515625, 0.3515625, 0.3515625, 1.0, 
		0.15234375, 0.15234375, 0.15234375, 1.0
	};
	
	static const CGFloat points[] = {0.0, 1.0};
	static const CGFloat borderColor[] = {1, 1, 1, 0.2};
	// static const CGFloat textColor[] = {0.484375, 0.484375, 0.484375, 1};
	// static const CGFloat selectedTextColor[] = {1, 1, 1, 1};

	// получим контекст и создадим градиенты и шрифт, которым рисуем заголовки табов
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, points, 2);
	CGGradientRef gradientSelected = CGGradientCreateWithColorComponents(colorSpace, selectedColors, points, 2);
	
	NSInteger tabsCount = [self tabCount];

    // Calculate tabWidth
    [self updateTabWidthes];
    
    CGFloat buttonHeight = self.frame.size.height; 

	CGContextSaveGState(context);

	// рисуем фоновый градиент "во весь вью", потом рисуем поверх другой градиент, который подсвечивает текущий таб
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, buttonHeight / 2), 0);
	NSRange selRange = [self positionForTab:_selectedTab withRecalculation:NO];
    CGContextClipToRect(context, CGRectMake(selRange.location, 0, selRange.length, buttonHeight/2));
	CGContextDrawLinearGradient(context, gradientSelected, CGPointMake(0, 0), CGPointMake(0, buttonHeight/2), 0);

	CGContextRestoreGState(context);

	// нарисуем границы табов и заголовки
	for (int i = 0; i < tabsCount; i++){
        NSRange tr = [self positionForTab:i withRecalculation:NO];
		CGContextSetStrokeColor(context, borderColor);
        CGContextAddRect(context, CGRectMake(tr.location, 0, tr.length, buttonHeight));
        CGContextDrawPath(context, kCGPathStroke);
		NSString * title = [self titleAtIndex:i];
        CGSize textSize = [title sizeWithFont:_titleFont];
		CGContextSetFillColorWithColor(context, (i == _selectedTab ? _selectedTextColor.CGColor :_textColor.CGColor));
        if (_drawTitles) { 
		    [title drawAtPoint:CGPointMake(tr.location + (tr.length - textSize.width)/2, (buttonHeight - textSize.height)/2) withFont:_titleFont];
        }
	}
    
    
	CGGradientRelease(gradient);
	CGGradientRelease(gradientSelected);
	CGColorSpaceRelease(colorSpace);
}

//----------------------------------------------------------------------------------------------------------------------------------

// если ткнули в неткнутый таб — перерисуемся и выберем новый
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:touch.view];
    [self updateTabWidthes];
	int buttonPressed = -1;
    for (int i = 0; i < [self tabCount]; i++){
        NSRange tr = [self positionForTab:i withRecalculation:NO];
        if (tr.location <= point.x && point.x <= tr.location + tr.length){ 
            buttonPressed = i;
            break;
        }
    }
 	if (_selectedTab != buttonPressed){
		_selectedTab = buttonPressed;
		[self setNeedsDisplay];
        if ([self.delegate respondsToSelector:@selector(tabChangedToIndex:forForTabbedTitle:)]){
            [self.delegate tabChangedToIndex:_selectedTab forForTabbedTitle:self];
        }    
	}
}
@end
