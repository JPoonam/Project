//!
//! @file INLabel.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
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

#import "INLabel.h"
#import "INCommonTypes.h"
#import "INGraphics.h"
#import <objc/runtime.h>

#define MENU_SELECTOR_PREFIX @"inLabelSelectMenuItem_"
#define LONG_TOUCH_DELAY     0.5

//==================================================================================================================================
//==================================================================================================================================

@implementation INLabel

@synthesize delegate = _delegate;
@synthesize tagObject = _tagObject;
@synthesize tag2 = _tag2;
@synthesize touchedTextColor = _touchedTextColor;
@synthesize touchedShadowColor = _touchedShadowColor;
@synthesize copyAbilityEnabled = _copyAbilityEnabled;
@synthesize useLegacyDrawing = _useLegacyDrawing;
@synthesize isTextUnderlined = _isTextUnderlined;
@synthesize isTouchedTextUnderlined = _isTouchedTextUnderlined;
@synthesize verticalTextAlignment = _verticalAlignment;
@synthesize disableShadowOnHighlight = _disableShadowOnHighlight;
@synthesize contentEdgeInsets = _contentEdgeInsets;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setVerticalTextAlignment:(INTextVAlignment)value { 
    if (value != _verticalAlignment) { 
        _verticalAlignment = value; 
        [self setNeedsDisplay];
    } 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setUseLegacyDrawing:(BOOL)value { 
    if (value != _useLegacyDrawing) { 
        _useLegacyDrawing = value; 
        [self setNeedsDisplay];
    } 
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)setDisableShadowOnHighlight:(BOOL)value { 
    if (value != _disableShadowOnHighlight) { 
        _disableShadowOnHighlight = value; 
        [self setNeedsDisplay];
    } 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setIsTouchedTextUnderlined:(BOOL)value { 
    if (value != _isTouchedTextUnderlined) { 
        _isTouchedTextUnderlined = value; 
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setIsTextUnderlined:(BOOL)value { 
    if (value != _isTextUnderlined) { 
        _isTextUnderlined = value; 
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)menuCanBeShown { 
    if (self.copyAbilityEnabled) { 
        return YES;
    }
    if (INSystemVersionEqualsOrGreater(3,2,0)) {
        if ([_delegate respondsToSelector:@selector(inlabelItemsForMenu:)]) { 
            return [[_delegate inlabelItemsForMenu:self] count] != 0;
        }
    } 
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setDelegate:(id <INLabelDelegate>)value {  
    if (value != _delegate) { 
        _delegate = value;
        if (_delegate) { 
             self.userInteractionEnabled = YES;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_internalInit {
    // self.userInteractionEnabled = YES;
    _verticalAlignment = INTextVAlignmentMiddle;
    _touchEdgeInsets =  UIEdgeInsetsMake(-10, -10, -10, -10);
    _disableShadowOnHighlight = YES;
    _contentEdgeInsets = UIEdgeInsetsZero;
    
    if (INSystemVersionEqualsOrGreater(3, 2, 0)) { 
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureFired:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:_tapGestureRecognizer];
        [_tapGestureRecognizer release];
        _tapGestureRecognizer.enabled = self.enabled;
        
        _longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGestureFired:)];
        _longTapGestureRecognizer.minimumPressDuration = LONG_TOUCH_DELAY;
        [self addGestureRecognizer:_longTapGestureRecognizer];
        [_longTapGestureRecognizer release];
        _longTapGestureRecognizer.enabled = self.enabled;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setEnabled:(BOOL)enabled { 
    [super setEnabled:enabled];
    _longTapGestureRecognizer.enabled = self.enabled;
    _tapGestureRecognizer.enabled = self.enabled;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tapGestureFired:(UITapGestureRecognizer *)recognizer { 
    // если у нас версия поддерживает рекогнайзеры - используем ее, иначе - срабаоывает код touchesBegan,,,,touchesEnd ets
    if (INSystemVersionEqualsOrGreater(3, 2, 0)) {
        if (recognizer.state == UIGestureRecognizerStateEnded) { 
            // NSLog(@"Single tap %d", recognizer.state);
            if ([_delegate respondsToSelector:@selector(inlabelTouched:)]) { 
                [_delegate inlabelTouched:self]; 
            }
        }
    }
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)longTapGestureFired:(UILongPressGestureRecognizer *)recognizer { 
    // Здесь мы просто игнорируем лонг тач, все отработается в touchesBegan,,,,touchesEnd ets
    
    // NSLog(@"Long tap %d", recognizer.state); 
    //if (recognizer.state == UIGestureRecognizerStateEnded) { 
    //    [UIAlertView inru_showAlertWithMessage:@"Long Tap"];
    //}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        [self inru_internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self inru_internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_touchedTextColor release];
    [_touchedShadowColor release];
    [_tagObject release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets { 
    if (!UIEdgeInsetsEqualToEdgeInsets(contentEdgeInsets, _contentEdgeInsets)) { 
        _contentEdgeInsets = contentEdgeInsets;
        [self setNeedsDisplay];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)internalDrawRect:(BOOL)doDrawing { 

    // тексты, шрифты, еще что-то
    UITextAlignment align = self.textAlignment;
    NSString * text = self.text;
    UIFont * font = self.font;
    UILineBreakMode lbm = self.lineBreakMode;
    NSInteger numberOfLines = self.numberOfLines;
    BOOL singleLineMode = numberOfLines == 1;
    CGSize shadowOffset = self.shadowOffset;
    
    UIColor * shadowColor = nil;
    UIColor * textColor = self.textColor;
    BOOL underlineMode = NO;
    if (_touchedAttributesApplied) { 
        underlineMode  = self.isTouchedTextUnderlined;
        UIColor * ttc = self.touchedTextColor;
        if (ttc) { 
            textColor = ttc;
        }
    } else {
        underlineMode = self.isTextUnderlined;
    }
   // UIColor * underlineColor = textColor;
    
    if (self.enabled) { 
        if (shadowOffset.height != 0 || shadowOffset.width != 0) { 
            shadowColor = self.shadowColor;
            UIColor * tsc = self.touchedShadowColor;
            if (_touchedAttributesApplied && tsc) { 
                shadowColor = tsc;
            }
        }
        if (self.highlighted) { 
            if (self.highlightedTextColor) {
                textColor = self.highlightedTextColor;
            }
            if (_disableShadowOnHighlight) { 
                shadowColor = nil;
            }
        }
    } else { 
       // underlineColor = textColor = [UIColor lightGrayColor];
    }
    BOOL drawShadow = shadowColor != nil;
    
    
    // берем первоначальный прямоугольник для рисования
    CGRect r = UIEdgeInsetsInsetRect(self.bounds, _contentEdgeInsets);
    
    // в отличие от оригинального UILabel мы делаем смещение для тени - чтобы поместилась
    // mk: убрал 30 марта 2012 года. Теперь надо учитывать смещение по тени при расчете высоты.
    /* 
    if (drawShadow) {
        r = INRectInset(r, (shadowOffset.width < 0 ? -shadowOffset.width : 0),
                           (shadowOffset.height < 0 ? -shadowOffset.height : 0),
                           (shadowOffset.width > 0 ? shadowOffset.width : 0),
                           (shadowOffset.height > 0 ? shadowOffset.height : 0));
    }
    */
    
    // подсчитываем шрифты, на основе этого безобразия рассчитываем фактический прямоугольник рисования
    // BOOL fontIsReduced = NO;
    CGRect rDraw = INRectFromSize(r.size);
    UIFont * actualFont = font;
    CGFloat lineHeight = [@"!" sizeWithFont:font].height;
    CGFloat actualLineHeight = lineHeight;
    if (self.adjustsFontSizeToFitWidth && self.minimumFontSize > 0 && singleLineMode) {
        CGFloat actualFontSize = 0;
        rDraw.size = [text sizeWithFont:font minFontSize:self.minimumFontSize actualFontSize:&actualFontSize 
                               forWidth:r.size.width lineBreakMode:lbm];
        if (actualFontSize && actualFontSize != font.pointSize) {
            UIFont * reducedFont = [font fontWithSize:actualFontSize];
            CGFloat reducedLineHeight = [@"!" sizeWithFont:reducedFont].height;
            // NSLog(@"old:(%f, %f), new:(%f, %f)",actualFont.ascender,actualFont.descender, reducedFont.ascender, reducedFont.descender); 
            
            // только такое выравнивание имеет смысл 
            if (_verticalAlignment == INTextVAlignmentMiddle) {
                switch (self.baselineAdjustment) { 
                    case UIBaselineAdjustmentAlignCenters:
                        break;

                    case UIBaselineAdjustmentNone:
                        r.origin.y -= round((actualLineHeight - reducedLineHeight) / 2); //  (-actualFont.ascender + reducedFont.ascender) / 2;
                        break;
                        
                    case UIBaselineAdjustmentAlignBaselines:
                        {  
                             CGFloat d1 = actualFont.ascender - actualLineHeight /2;
                             CGFloat d2 = reducedFont.ascender - reducedLineHeight /2;
                             r.origin.y += round(d1 - d2); // (actualFont.ascender - reducedFont.ascender) / 2;
                        }
                        break; 
                }
            }
            actualLineHeight = reducedLineHeight;
            actualFont = reducedFont;
        }
    } else
    if (singleLineMode) { 
        rDraw.size = [text sizeWithFont:actualFont forWidth:rDraw.size.width lineBreakMode:lbm];
    } else {
        rDraw.size = [text sizeWithFont:actualFont constrainedToSize:rDraw.size lineBreakMode:lbm];
    }
    if (numberOfLines > 0) {
        CGFloat a = numberOfLines * actualLineHeight;
        if (rDraw.size.height > a) { 
            rDraw.size.height = a;
        }
    }
    numberOfLines = round(rDraw.size.height / actualLineHeight);
    
    // выравниваем наш прямоугольник
    rDraw.origin.y = r.origin.y;
    rDraw.origin.x = r.origin.x;
    switch (align) {
       case UITextAlignmentLeft:
           if (shadowOffset.width < 0) { 
                rDraw.origin.x += -shadowOffset.width;
           }
           break;
           
       case UITextAlignmentCenter:
           rDraw.origin.x += round((r.size.width - rDraw.size.width) / 2);
           break;
           
       case UITextAlignmentRight:
           rDraw.origin.x += r.size.width - rDraw.size.width;
           if (shadowOffset.width > 0) { 
               rDraw.origin.x -= shadowOffset.width;
           }
           break;
    }
    switch (_verticalAlignment) {
        case INTextVAlignmentTop:
           if (shadowOffset.height < 0) { 
               rDraw.origin.y += -shadowOffset.height;
           } 
           break;
           
        case INTextVAlignmentMiddle:
           rDraw.origin.y += round((r.size.height - rDraw.size.height) / 2);
           break;
           
       case INTextVAlignmentBottom:
           rDraw.origin.y = r.size.height - rDraw.size.height;
           if (shadowOffset.height > 0) { 
              rDraw.origin.y -= shadowOffset.height;
           } 
           break;
    }
    
    if (!doDrawing) { 
        return rDraw;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // отладка
    // CGContextSetStrokeColorWithColor(ctx,[UIColor redColor].CGColor);
    // CGContextStrokeRect(ctx, rDraw);
   
    // толщина линии
    CGFloat underlineOffset;
    if (underlineMode) {
       CGFloat d = fabs(actualFont.descender) / 3;
       if (d <= 1) {
           d = 1.0;
       } 
       CGFloat lineWidth = floor(d);
       underlineOffset = lineWidth * 1.5;
       CGContextSetLineWidth(ctx,lineWidth); 
    }
    // draw
    for (int i = 0; i < 2; i++) { 
        BOOL shadowMode = i == 0;
        if (shadowMode) {
            if (!drawShadow) { 
                continue;
            }
            [shadowColor set];
        } else {
            shadowOffset.height = 0;
            shadowOffset.width = 0;
            [textColor set];
        }
        
        //if (numberOfLines == 1) { 
        //    if (fontIsReduced) { 
            // todo: выравнивать для baseline
        //    }
        //    if (shadowMode) {
        //        r1.origin.y += shadowOffset.height;
        //        r1.origin.x += shadowOffset.width;
        //    }
        //    [text drawInRect:rDraw withFont:actualFont lineBreakMode:lbm alignment:UITextAlignmentLeft];
        // } else 
        {
            NSUInteger l = text.length;
            NSUInteger startIndex = 0;
            NSUInteger lineNo = 1;
            CGFloat rOffset = 0;
            while (startIndex < l && lineNo <= numberOfLines) {
                NSUInteger lineEndIndex,contentsEndIndex; 
                [text getLineStart:&startIndex end:&lineEndIndex contentsEnd:&contentsEndIndex forRange:NSMakeRange(startIndex,1)];
                NSRange currentRange = NSMakeRange(startIndex,contentsEndIndex - startIndex);
                NSString * str = [text substringWithRange:currentRange];
                CGSize constrainedSize = CGSizeMake(rDraw.size.width,rDraw.size.height - rOffset);
                CGSize actualSize = [str sizeWithFont:actualFont constrainedToSize:constrainedSize lineBreakMode:lbm];
                if (actualSize.height == 0) { 
                    actualSize.height = actualLineHeight;
                }
                NSInteger lll = lroundf(actualSize.height / actualLineHeight); 
                
                // вычисляем прямоугольник
                CGRect r1 = rDraw;
                r1.origin.y += rOffset;
                if (shadowMode) {
                    r1.origin.y += shadowOffset.height;
                    r1.origin.x += shadowOffset.width;
                }
                // r1.size = actualSize;
                r1.size.height = actualSize.height;
                rOffset += actualSize.height;
                
                // рисуем текст
                // CGSize drawnSize;
                if (numberOfLines == 1) {
                    // вызывается только один раз
                    // drawnSize = 
                    [text drawAtPoint:r1.origin forWidth:rDraw.size.width withFont:actualFont lineBreakMode:lbm]; 
                } else {
                    // drawnSize = 
                    [str drawInRect:r1 withFont:actualFont lineBreakMode:lbm alignment:align];
                }
                 
                // рисуем подчеркивание
                if (underlineMode) {
                    NSString * underlinedSubString = str;
                    
                    // if (!shadowMode) { CGContextSetStrokeColorWithColor(context, underlColor.CGColor);   
                    for (int ii = 0; ii < lll; ii++) {
                        CGFloat w = r1.size.width;
                        CGFloat x = r1.origin.x;
                        // вырвниваем границы подчеркивания для многострочных линий
                        NSUInteger usl = underlinedSubString.length;
                        if (lll > 1 && usl) {
                            int lastIndexOk = 0;
                            // CGFloat lastIndexSize = 0;
                            NSString * lastSubstring = nil;
                            CGSize lineSpace = CGSizeMake(actualSize.width,2000); 
                            for (int j = 1; j <= usl; j++) {
                                NSString * str1 = [underlinedSubString substringToIndex:j];
                                CGSize sz = [str1 sizeWithFont:actualFont constrainedToSize:lineSpace lineBreakMode:lbm];
                                if (sz.height > actualLineHeight && lastIndexOk != 0 ) {
                                    //if (self.tag == 555) {
                                    //    NSLog(@"break!");
                                    //}
                                    break;
                                }
                                //if (self.tag == 555) {
                                //        NSLog(@"'%@' %@",str1,NSStringFromCGSize(sz));
                                //}
                                lastIndexOk = j;
                                // lastIndexSize = sz.width;
                                lastSubstring = str1;
                            }

                            CGFloat lastIndexSize = [lastSubstring sizeWithFont:actualFont].width;
                        
                            //if (self.tag == 555) {
                            //    NSLog(@"%d:%d of %d '%@' %f %f",lineNo,i, lll, lastSubstring, lastIndexSize, 
                                                      // [[underlinedSubString substringToIndex:lastIndexOk] sizeWithFont:actualFont].width
                            //                           
                            //                           [lastSubstring sizeWithFont:actualFont  
                            //                           constrainedToSize:lineSpace lineBreakMode:lbm].width
                            //                           );
                            // }

                            underlinedSubString = [underlinedSubString substringFromIndex:lastIndexOk];
                            w = lastIndexSize;
                            
                            switch (align) {
                               case UITextAlignmentLeft:
                                   break;
                                   
                               case UITextAlignmentCenter:
                                   x += round((r1.size.width - w) / 2);
                                   break;
                                   
                               case UITextAlignmentRight:
                                   x += r1.size.width - w;
                                   break;
                            }
                        }
                        
                        CGFloat y = ceilf(r1.origin.y + actualLineHeight * ii + actualFont.ascender) + underlineOffset; // not
                        CGPoint points[2] = {
                            {x,     y },
                            {x + w, y }
                        };
                        CGContextStrokeLineSegments(ctx,points,2);
                    }
                }
                                     
                startIndex = lineEndIndex;
                lineNo += lll;
            }
        }
    }
    return rDraw;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect {
    // legacy drawing drawing
    if (_useLegacyDrawing) { 
       [super drawRect:rect];
        return;
    }
    
    [self internalDrawRect:YES];

    return;

    /* 
    // underline the text (for single lines only, sorry
    BOOL shouldUnderline = NO;
    UIColor * underlColor = nil;
    if (_touchedAttributesApplied) { 
        shouldUnderline = _touchTextUnderlined;
        underlColor = _touchTextUnderlined ? _touchedTextColor : self.textColor;
    } else {
        shouldUnderline = _textUnderlined;
        underlColor = self.textColor;
    }    
    if (shouldUnderline && self.text.length && self.numberOfLines == 1) { // nly for 
        CGRect rB = self.bounds;
        CGRect r = [self textRectForBounds:rB limitedToNumberOfLines:1];
        UIFont * font = self.font;
        BOOL fontIsReduced = NO;
        if (self.adjustsFontSizeToFitWidth && self.minimumFontSize > 0) {
            CGFloat actualFontSize = 0;
            [self.text sizeWithFont:font minFontSize:self.minimumFontSize actualFontSize:&actualFontSize 
                           forWidth:r.size.width lineBreakMode:self.lineBreakMode];
            if (actualFontSize && actualFontSize != font.pointSize) {
                font = [font fontWithSize:actualFontSize];
                fontIsReduced = YES;
            } 
        }           
        CGSize sz = [self.text sizeWithFont:font constrainedToSize:r.size lineBreakMode:self.lineBreakMode];
        sz.height = [@"!" sizeWithFont:font].height;
                   
	    // currently ignoring multiline and auto-font stuff
        //if (self.numberOfLines == 1 && ((self.adjustsFontSizeToFitWidth == NO) || ()) {
            CGRect lblRect = r;
            lblRect.origin.y = round((rB.size.height - sz.height) / 2);
            lblRect.size.height = sz.height;
            lblRect.size.width = sz.width;
            
            #warning mk: доделать когда будет время + позицию меню сделать нормальной + тач зоны ограничить надписью
            if (fontIsReduced) { 
                // CGFloat a = self.font.descender;                
                // CGFloat v = self.font.ascender;
                // CGFloat c = -24;                
                
                switch (self.baselineAdjustment) { 
                   case UIBaselineAdjustmentAlignBaselines:
                       lblRect.origin.y -= self.font.descender + font.descender;
                       break;
                       
                   case UIBaselineAdjustmentAlignCenters:
                       break;
                       
                   case UIBaselineAdjustmentNone:
                       lblRect.origin.y += self.font.descender + font.descender;
                       break; 
                }
            }
            
            switch (self.textAlignment) {
               case UITextAlignmentLeft:
                   break;
                   
               case UITextAlignmentCenter:
                   lblRect.origin.x = round((rB.size.width - lblRect.size.width) / 2);
                   break;
                   
               case UITextAlignmentRight:
                   lblRect.origin.x = rB.size.width - lblRect.size.width;
                   break;
            }
            CGContextRef context = UIGraphicsGetCurrentContext();

            //CGContextSetFillColorWithColor(context, [[UIColor inru_colorFromRGBA:0xff000033] CGColor]);
            //CGContextFillRect(context,lblRect);

            CGContextSetStrokeColorWithColor(context, underlColor.CGColor);
            // CGFloat dc = round(font.descender) + 1;
            CGFloat y = round(lblRect.origin.y + lblRect.size.height + (font.descender + 1)) - 0.5; // not
            CGPoint points[2] = {
                {lblRect.origin.x,            y },
                {lblRect.origin.x + sz.width, y }
            };
            CGContextStrokeLineSegments(context,points,2);
        //} else {
        //    NSAssert(0, @"NOT IMPLEMENTED YET 0e4e4e90_fa59_47b9_ae8d_ce721eb20030");
        //}
    }
    */
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)cancelTouchAndHoldTrigger { 
  	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showMenuOnTouch) object:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateTouchStyle {
    BOOL shouldApplyAttributes = _touched && _touchOverLabel;
    if (_touchedAttributesApplied != shouldApplyAttributes) {
        _touchedAttributesApplied = shouldApplyAttributes;
        [self setNeedsDisplay];
        /*  
        if (_touchedAttributesApplied) {
            if (_touchedTextColor) { 
                _originalColor = [self.textColor retain];
                self.textColor = _touchedTextColor;
            }
        } else {
            if (_originalColor) { 
                self.textColor = _originalColor;
                [_originalColor release];
                _originalColor = nil;
            }
        }
        */
    }
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)touchableArea { 
    CGRect r  = [self internalDrawRect:NO];
    // CGRect rB = self.bounds;  
    return UIEdgeInsetsInsetRect(r,_touchEdgeInsets);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGPoint)updateTouches:(NSSet *)touches { 
    UITouch * t = [touches anyObject];
    CGPoint pt = [t locationInView:self];
    _touchOverLabel = CGRectContainsPoint(self.touchableArea, pt);
    return pt;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    if (result) { 
        CGRect r = self.touchableArea; 
        if (!CGRectContainsPoint(r, point)) {
            result = NO; 
        }
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // stop previous menu 
    if (_touchAndHoldMenuShown) { 
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        _touchAndHoldMenuShown = NO;
        _touchOverLabel = NO;
        _touched = NO;
        [self updateTouchStyle];
        return;
    }
    
    if (self.enabled) { 
        CGPoint pt = [self updateTouches:touches];
        _touched = YES;
        [self updateTouchStyle];
        if (_touchOverLabel) {
            if (self.menuCanBeShown) {         
                _longTouchAtPoint = pt;
                [self performSelector:@selector(showMenuOnTouch) withObject:nil afterDelay:LONG_TOUCH_DELAY];
            } 
        }
    }
    //  [super touchesBegan: touches withEvent: event];
}
//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL handle = _touched;
    _touched = NO;
    [self updateTouchStyle];
    [self cancelTouchAndHoldTrigger];
    
    if (!_touchAndHoldMenuShown) { 
        [self updateTouches:touches];
        if (_touchOverLabel && handle) { 
            if ([_delegate respondsToSelector:@selector(inlabelTouched:)]) { 
                [_delegate inlabelTouched:self]; 
            }
        }
        // [super touchesEnded: touches withEvent: event];
    } else {
        // [super touchesCancelled: touches withEvent: event];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _touched = NO;
    [self updateTouchStyle];    
    [self cancelTouchAndHoldTrigger];
    // [super touchesCancelled: touches withEvent: event];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelTouchAndHoldTrigger];
    [self updateTouches:touches];
    [self updateTouchStyle];
    // [super touchesMoved: touches withEvent: event];
}

//----------------------------------------------------------------------------------------------------------------------------------

static void _MenuItemSelectorIMP(INLabel * self, SEL _cmd) {
    // NSLog(@"called ------ %@",NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(inlabel:didSelectMenuItemAtIndex:)]) {
        NSInteger index = [[NSStringFromSelector(_cmd) substringFromIndex:MENU_SELECTOR_PREFIX.length] intValue];  
        [self.delegate inlabel:self didSelectMenuItemAtIndex:index];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)showMenu {
    if (self.menuCanBeShown) { 
        UIMenuController * menu = [UIMenuController sharedMenuController];
        [menu setMenuVisible:NO animated:YES];
        [self becomeFirstResponder];
        [menu update];
        CGRect r = [self internalDrawRect:NO]; 
        r.origin.x = _longTouchAtPoint.x;
        r.size.width = 1;
        // todo: позиционировать меню книзу в зависимости от позиции на экране 
        // CGRect mf = menu.menuFrame;
        if (INSystemVersionEqualsOrGreater(3,2,0)) {
            if ([_delegate respondsToSelector:@selector(inlabelItemsForMenu:)]) {
                NSArray * a = [_delegate inlabelItemsForMenu:self];
                NSMutableArray * ma = [NSMutableArray arrayWithCapacity:a.count];
                for (NSString * caption in a) {
                    /* 
                      небольшой финт ушами. так как в sender передается UIMenuController, то мы, чтобы различить,
                      какой пункт меню был выбран,присваиваем каждому пункту динамический cелектор xxxx_Y.
                      и тут же этот метод добавляем в класс. Можно это делать и в resolveInstanceMethod,
                      но пусть будет так как будет, работает и ладно
                    */
                    NSString * selector = [NSString stringWithFormat: MENU_SELECTOR_PREFIX @"%d",ma.count];
                    SEL sel = NSSelectorFromString(selector); 
                    class_addMethod([self class], sel, (IMP)_MenuItemSelectorIMP, "v@:");
                    UIMenuItem * item = [[UIMenuItem alloc] initWithTitle:caption action:sel];
                    [ma addObject:item];
                    [item release];
                }
                menu.menuItems = ma;
            } else {
                menu.menuItems = nil;
            }
        }
        [menu setTargetRect:r inView:self];
        [menu setMenuVisible:YES animated:YES];
        _touched = NO;
        [self updateTouchStyle];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    // NSLog(@"can perform %@",NSStringFromSelector(action));
    if (action == @selector(copy:)) {
        return self.copyAbilityEnabled; 
    }
    // if ([NSStringFromSelector(action) hasPrefix:MENU_SELECTOR_PREFIX]) { 
    //    return YES;
    // }
    return [super canPerformAction:action withSender:sender];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)copy:(id)sender {
    if (self.copyAbilityEnabled) {
        NSString * data = self.text;
        if ([_delegate respondsToSelector:@selector(inlabelTextForPasterboard:)]) { 
            data = [_delegate inlabelTextForPasterboard:self];
        }
        if (data.length) {
            [[UIPasteboard generalPasteboard] inru_setString:data];
        }     
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)menuClosed { 
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIMenuControllerWillHideMenuNotification object: nil];
    _touchAndHoldMenuShown = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canBecomeFirstResponder {
    return self.menuCanBeShown; // self.copyAbilityEnabled;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)showMenuOnTouch {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(menuClosed) 
                   name:UIMenuControllerWillHideMenuNotification 
                 object:nil];
    _touchAndHoldMenuShown = YES;
    [self showMenu];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setupAsLinkLabelForURLString:(NSString *)URLString {
    self.isTouchedTextUnderlined = YES;
    self.textColor = [UIColor inru_colorFromRGBA:0x336699FF];
    self.copyAbilityEnabled = YES;
    self.delegate = (id<INLabelDelegate>)self;
    self.tagObject = [[URLString copy] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark INLabelDelegate self-implementation. used for [self setupAsLinkLabelForURLString]

- (NSString *)inlabelTextForPasterboard:(INLabel *)label { 
    return label.tagObject;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inlabelTouched:(INLabel *)label { 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:label.tagObject]];
}


@end
