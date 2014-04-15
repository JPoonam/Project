//!
//! @file INGraph.m
//! 
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
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
#import "INGraph.h"
#import "INView.h"
#import "INCommonTypes.h"
#import "INGraphics.h"

#import <QuartzCore/QuartzCore.h>

@class INGraphSeriesInfo, INGraphScaleInfo, INGraphSeriesLayer;

// скорее всего это все не нужно, я отключил анимацию через actions

#define NO_ANIMATION_ON \
        [CATransaction begin]; \
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
#define NO_ANIMATION_OFF \
        [CATransaction commit];

#define WITHOUT_ANIMATION(__block__) { \
        [CATransaction begin]; \
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; \
        { __block__; } \
        [CATransaction commit]; \
    }

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphLayer : CALayer {
@package
    INGraph * _graph;
    BOOL _debugMode;
}

@property(nonatomic,assign) INGraph * graph;
@property(nonatomic) BOOL debugMode;

@end


//==================================================================================================================================
//==================================================================================================================================

enum { 
    MEASURE_LAYER_MAIN,
    MEASURE_LAYER_OVERLAY,
    MEASURE_LAYER_LBOUND,
    MEASURE_LAYER_RBOUND    
}; 

@interface INGraphPinchLayer : INGraphLayer {
@package 
     NSInteger _mode;
     NSInteger _sampleIndex;
     INGraphSeriesData * _data;
}

- (id)initWithGraph:(INGraph *)graph name:(NSString *)name mode:(NSInteger)mode;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphSeriesInfo : NSObject {
    INGraphSeriesData * _data;
    INGraph * _graph;
    INGraphSeriesLayer * _layer;
    INGraphSeriesParams * _params;
}

@property(nonatomic,retain) INGraphSeriesLayer * layer;
@property(nonatomic,retain) INGraphSeriesData * data;
@property(nonatomic,assign) INGraph * graph;
@property(nonatomic,readonly) INGraphSeriesParams * params;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INGraph() 

- (UIColor *)debugColorForLayer:(INGraphLayer *)layer;
- (void)adjustFrameForLayer:(INGraphLayer *)layer;
- (BOOL)canDraw;
- (void)stopTouchMeasure;
- (void)updateTouchMeasure:(UIEvent *)event;
- (void)updateParams:(INGraphSeriesParams *)params forData:(INGraphSeriesData *)data;

@property(nonatomic,readonly) INGraphSeriesLayer * seriesSuperlayer;
// @property(nonatomic,readonly) CGPoint measureStart;
// @property(nonatomic,readonly) CGPoint measureEnd;

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INGraphSeriesParams

@synthesize dataRowFrom = _dataRowFrom;
@synthesize dataRowTo = _dataRowTo;
@synthesize layoutDiffPart = _layoutDiffPart;
@synthesize bandWorkPart = _bandWorkPart;
@synthesize bandMinWidth = _bandMinWidth;
@synthesize bandMaxWidth = _bandMaxWidth;
@synthesize layoutSolidPart = _layoutSolidPart;
@synthesize options = _options;
@synthesize strokeWidth = _strokeWidth;
@synthesize seriesIndex = _seriesIndex;
@synthesize strokeColor  = _strokeColor; 
@synthesize fillColor    = _fillColor;  
@synthesize fillGradient = _fillGradient;
@synthesize graphStyle = _graphStyle;
@synthesize layoutPaintPart = _layoutPaintPart;
@synthesize layoutPaintOffset = _layoutPaintOffset;
@synthesize dataMergeModes = _mergeModes;
@synthesize fillColor1 = _barFirstFillColor;
@synthesize fillColor2 = _barLastFillColor;
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize zeroValue = _zeroValue;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFillGradient:(CGGradientRef)value { 
    if (value != _fillGradient) { 
        CGGradientRelease(_fillGradient);
        _fillGradient = CGGradientRetain(value);
    }
}
//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [_strokeColor release];
    [_fillColor release];
    [_barFirstFillColor release];
    [_barLastFillColor release];
    
    self.fillGradient = nil;
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)assign:(INGraphSeriesParams *)params { 
    _layoutDiffPart = params.layoutDiffPart;
    _layoutSolidPart = params.layoutSolidPart;
    _options = params.options;
    self.strokeColor = params.strokeColor;
    self.fillColor = params.fillColor;
    self.fillGradient = params.fillGradient;
    _strokeWidth = params.strokeWidth;
    _graphStyle = params.graphStyle;
    _bandWorkPart = params.bandWorkPart;
    _bandMinWidth = params.bandMinWidth;
    _bandMaxWidth = params.bandMaxWidth;
    _layoutPaintPart = params.layoutPaintPart;
    _layoutPaintOffset = params.layoutPaintOffset;
    _mergeModes = params.dataMergeModes;
     self.fillColor1 = params.fillColor1;
     self.fillColor2 = params.fillColor2;
    _dataRowFrom = params.dataRowFrom;
    _dataRowTo = params.dataRowTo;
    _minValue = params.minValue;
    _maxValue = params.maxValue;
    _zeroValue = params->_zeroValue;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)check { 
    NSParameterAssert(_layoutDiffPart > 0);
    NSParameterAssert(_layoutDiffPart <= 1.0);
    NSParameterAssert(_layoutSolidPart >= 0);
    NSParameterAssert(_layoutSolidPart + _layoutDiffPart <= 1.0);
    NSParameterAssert(_layoutPaintPart > 0 && _layoutPaintPart <= 1.0);
    NSParameterAssert(_layoutPaintOffset >= 0);
    NSParameterAssert(_layoutPaintOffset + _layoutPaintPart <= 1.0);
    NSParameterAssert(_bandWorkPart > 0 && _bandWorkPart <= 1);
    NSParameterAssert(0 <= _graphStyle && _graphStyle < INGraphLastStyle);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)resetToDefaults { 
    _layoutDiffPart = 0.5;
    _layoutSolidPart = 0.25;
    _layoutPaintOffset = 0.0;
    _layoutPaintPart = 1.0;
    _minValue = 0;
    _maxValue = 0;
    _zeroValue = 0;
    _strokeWidth = 0;
    _mergeModes = NULL;
    _graphStyle = INGraphLineStyle;
    _bandWorkPart = 1.0;
    _bandMinWidth = 0;
    _bandMaxWidth = 0;
    _dataRowFrom = 0;
    _dataRowTo = 0;
    _options = INGraphStroke;
    self.strokeColor = [UIColor blackColor];
    self.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self check];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSeriesIndex:(NSInteger)value { 
    _seriesIndex = value;
}
 
@end

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphOverlayLayer : INGraphLayer { 
    INGraphOverlay * _overlay;
}

@end

//==================================================================================================================================

@implementation INGraphOverlayLayer

- (void)setOverlay:(INGraphOverlay *)overlay { 
    _overlay = overlay;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawInContext:(CGContextRef)context {
    if (!_graph.canDraw) { 
        return;
    }
    
    [super drawInContext:context];
    
    if ([_graph.graphDelegate respondsToSelector:@selector(graph:drawOverlay:inContext:)]) { 
        [_graph.graphDelegate graph:_graph drawOverlay:_overlay inContext:context];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphOverlay() 

@property(nonatomic,assign) INGraph * graph;
@property(nonatomic,retain) INGraphOverlayLayer * layer;

@end

//==================================================================================================================================

@implementation INGraphOverlay 

@synthesize graph = _graph;
@synthesize tag = _tag;
@synthesize layer = _layer;

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frame { 
    return _layer.frame;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [_layer removeFromSuperlayer];
    [_layer release];
    [super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INGraphSeriesData

@synthesize sampleCount = _filled;
@synthesize valuesPerSample = _valuesPerSample;
@synthesize axisXOffset = _axisXOffset;

//----------------------------------------------------------------------------------------------------------------------------------

+ (BOOL)isNoValue:(CGFloat)value {
    return isnan(value);
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)setNoValue:(CGFloat *)value count:(NSInteger)count { 
    NSParameterAssert(value);
    NSParameterAssert(count > 0);
    for (int i = 0; i < count; i++) { 
        *value++ = NAN;
    } 
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)dataWithValuesPerSample:(NSInteger)valuesPerSample {
    NSParameterAssert(valuesPerSample > 0); 
    INGraphSeriesData * data = [[self.class new] autorelease];    
    data->_valuesPerSample   = valuesPerSample;
    data->_precalculatedInfo = malloc(sizeof(struct _INGraphSeriesDataCalcInfo) * (valuesPerSample + 1)); // each for every value plus one for common
    return data;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        // 
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    free(_data);
    free(_precalculatedInfo);
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)markInvalidated {
    _precalculated = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

#define OFFSET_FOR_SAMPLE(__sample__) ((__sample__) * _valuesPerSample)
#define BYTES_FOR_SAMPLE(__sample__) ((__sample__) * _valuesPerSample * sizeof(CGFloat))
 
//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)descriptionForSampleAtIndex:(NSInteger)index { 
    CGFloat * sample = [self sampleAtIndex:index];
    NSMutableString * string = [NSMutableString string];
    for (int j = 0; j < _valuesPerSample; j++) { 
        [string appendFormat:@"%.6f ",sample[j]];  
    } 
    return string;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dump {
    NSLog(@"-- INGraphSeriesParams dump %lu of %lu bytes filled", BYTES_FOR_SAMPLE(_filled), BYTES_FOR_SAMPLE(_allocated)); 
    for (int i =0; i < _filled; i++) { 
        NSString * string = [NSString stringWithFormat:@"  % 3d %@",i,[self descriptionForSampleAtIndex:i]];
        NSLog(@"%@",string); 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dumpAsCArray {    
    NSLog(@"-- INGraphSeriesParams dump (C Array) "); // (min %.6f, max %.6f) {", self.minValue, self.maxValue);
    NSLog(@"const CGFloat a[%d * %d] = {", _filled, _valuesPerSample);
    for (int i =0; i < _filled; i++) { 
        CGFloat * sample = [self sampleAtIndex:i];
        NSMutableString * string = [NSMutableString stringWithFormat:@"  "];
        for (int j = 0; j < _valuesPerSample; j++) { 
            if (isnan(sample[j])) {
                [string appendString:@"NAN, "];
            } else {
                [string appendFormat:@"%.6f, ",sample[j]];
            }  
        } 
        NSLog(@"%@",string); 
    }
    NSLog(@"}; ");
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)precalculate { 
    if (!_precalculated) { 
        _precalculated = YES;
        // reset
        for (int i = 0; i < _valuesPerSample; i++) {
            _precalculatedInfo[i].maxValue = NAN;
            _precalculatedInfo[i].minValue = NAN;
        } 
        // count on samples
        if (_filled) { 
            CGFloat * sample = [self sampleAtIndex:0];
            for (int j = 0; j < _filled; j++) { 
                for (int i = 0; i < _valuesPerSample; i++) {
                    CGFloat v = sample[i];
                    if (! isnan(v)) { 
                        if (isnan(_precalculatedInfo[i].maxValue) || (_precalculatedInfo[i].maxValue < v)) { 
                            _precalculatedInfo[i].maxValue = v;    
                        }
                        if (isnan(_precalculatedInfo[i].minValue) || (_precalculatedInfo[i].minValue > v)) { 
                            _precalculatedInfo[i].minValue = v;    
                        }
                    }
                }
                sample += _valuesPerSample;    
            };
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat) minValueAndMaxValue:(CGFloat *)maxValue forRowFrom:(NSInteger)rangeFrom rowTo:(NSInteger)rangeTo {
    NSParameterAssert(rangeFrom >= 0 && rangeTo <_valuesPerSample && rangeFrom <= rangeTo);
    [self precalculate];
 
    CGFloat minV = NAN;
    CGFloat maxV = NAN;  
    for (int i = rangeFrom; i <= rangeTo; i++) {
        CGFloat v = _precalculatedInfo[i].maxValue;
        if (! isnan(v)) { 
            if (isnan(maxV) || (maxV < v)) { 
                maxV = v;    
            }
        }
        v = _precalculatedInfo[i].minValue;
        if (! isnan(v)) { 
            if (isnan(minV) || (minV > v)) { 
                minV = v;    
            }
        }
    }
    if (maxValue) {
       *maxValue = maxV;
    }
    return minV;
}

//----------------------------------------------------------------------------------------------------------------------------------
 
- (void)clear {
    _filled = 0;
    _precalculated = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)deleteInRange:(NSRange)range {
    NSParameterAssert(range.location >= 0);
    NSParameterAssert(range.location + range.length <= self.sampleCount);
    
    // [self dump];
    
    // simple case - truncate the end)
    if (range.location + range.length == _filled) { 
        // nothing
    } else {
        memmove(_data + OFFSET_FOR_SAMPLE(range.location),  
                _data + OFFSET_FOR_SAMPLE(range.length + range.location),
                BYTES_FOR_SAMPLE(_filled - range.length - range.location));       
    }
    _filled -= range.length;
    NSAssert(_filled >= 0, @"db1554df_6379_47ef_ab66_adf0cce49a21");
    
    // [self dump];
}

//----------------------------------------------------------------------------------------------------------------------------------
 
- (CGFloat *)add:(const CGFloat *)samples count:(NSInteger)count { 
    NSParameterAssert(count > 0);
    NSParameterAssert(samples);
    NSParameterAssert(_valuesPerSample > 0);

    NSInteger newFilled = _filled + count;
    if (newFilled > _allocated) {
        _allocated = newFilled + 100; // пока что такое приращение, потом посмотрим 
        _data = realloc(_data, BYTES_FOR_SAMPLE(_allocated)); 
    }
    CGFloat * result = _data + OFFSET_FOR_SAMPLE(_filled);
    memcpy(result, samples, BYTES_FOR_SAMPLE(count));
    _filled = newFilled;
    _precalculated = NO;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addFromData:(INGraphSeriesData *)data {
    NSParameterAssert(_valuesPerSample == data->_valuesPerSample); 
    [self add:data->_data count:data->_filled];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addMergedData:(INGraphSeriesData *)data mergeSize:(NSInteger)mergeCount mergeModes:(const NSInteger *)mergeModes { 
    NSParameterAssert(data.valuesPerSample == _valuesPerSample);
    NSParameterAssert(mergeCount > 0);
    [self clear];
    CGFloat * sampleSrc = [data sampleAtIndex:0];
    CGFloat * sampleDst = nil;
    NSInteger sampleCount = data.sampleCount;
    
    // for join == 1 simply copy the source data;
    if (mergeCount == 1) { 
        [self add:sampleSrc count:sampleCount];
        return;
    }
    //  NSInteger cycles = (data.sampleCount + joinCount - 1) / joinCount;
    NSInteger mCounter = 0; 
    for (int i = 0; i < data.sampleCount; i++) {
        if (mCounter == 0) { 
            [self add:sampleSrc count:1];
            sampleDst = _data + OFFSET_FOR_SAMPLE(_filled-1);
        } else { 
            // join data
            for (int j = 0; j < _valuesPerSample; j++) { 
                CGFloat s = sampleSrc[j];
                CGFloat d = sampleDst[j];
                if (isnan(s)) { 
                    continue;
                }
                if (isnan(d)) {
                    sampleDst[j] = s;
                    continue;  
                }
                NSInteger mmode = mergeModes ? mergeModes[j] : INGraphMergeModeSum;
                switch(mmode) { 
                    case INGraphMergeModeSum:
                        sampleDst[j] += s;
                        break; 
                    
                    case INGraphMergeModeMin:
                        if (s < d) { 
                            sampleDst[j] = s;
                        }
                        break;
                        
                    case INGraphMergeModeMax:
                        if (s > d) { 
                            sampleDst[j] = s;
                        }
                        break;
                    
                    case INGraphMergeModeFirstValue:
                        break;

                    case INGraphMergeModeLastValue:
                        sampleDst[j] = s;
                        break;
                }
            }
        }
        mCounter++;
        sampleSrc += _valuesPerSample;
        if (mCounter == mergeCount) {
            mCounter = 0;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat *)sampleAtIndex:(NSInteger)index { 
    NSParameterAssert(0 <= index && index < _filled); 
    return _data + OFFSET_FOR_SAMPLE(index);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadRandomDataMin:(CGFloat)min max:(CGFloat)max count:(NSInteger)count allowNoValue:(BOOL)allowNoValue {  
    NSParameterAssert(_valuesPerSample > 0);
    NSParameterAssert(INGraphDataValueMin < INGraphDataValueMax && INGraphDataValueMax < INGraphDataValueFirst);
    NSParameterAssert(INGraphDataValueMax < INGraphDataValueLast);
    
    [self clear];
    CGFloat * a = malloc(sizeof(CGFloat) * _valuesPerSample);
    for (int i = 0; i < count; i++) {
        if (allowNoValue && (random() % 3 == 0)) { 
            for (int j = 0; j < _valuesPerSample; j++) { 
                a[j] = NAN;
            }
        } else {
            for (int j = 0; j < _valuesPerSample; j++) { 
                CGFloat base = min;
                CGFloat delta = max-min;
                switch (j) { 
                    case INGraphDataValueMax:
                        base  = a[INGraphDataValueMin];
                        delta = max - base;
                        break;
                    case INGraphDataValueFirst:
                    case INGraphDataValueLast:
                        base  = a[INGraphDataValueMin];
                        delta = a[INGraphDataValueMax] - base;
                        break;
                }                    
                a[j] = base + INRandom() * delta;
            }
        }
        [self add:a count:1];
    }
    free(a);
}

@end

//==================================================================================================================================
//==================================================================================================================================

typedef CGFloat (* AlignFuncPtr)(CGFloat);
typedef CGFloat (* AlignFuncPtr2)(CGFloat,CGFloat,CGFloat);

static CGFloat _AlignOrigin1(CGFloat v,CGFloat min,CGFloat max) { 
    CGFloat r = floorf(v) + 0.5;
    if (r < min) {
       r++;
    } else
    if (r > max) { 
        r--;
    }
    return r;
}

static CGFloat _AlignInset1(CGFloat w) {  
    return floorf(w / 2);
}  

static CGFloat _AlignOrigin2(CGFloat v,CGFloat min,CGFloat max) { 
    CGFloat v2 = floorf(v);
    CGFloat delta = v - v2;
    if (delta <= 0.5) { 
        v2 += 0.25; 
    }  else { 
        v2 += 0.75; 
    }
    if (v2 < min) {
       v2 += 0.5;
    } else
    if (v2 > max) { 
        v2-= 0.5;
    }
    return v2;
}  

static CGFloat _AlignSize1(CGFloat v) { 
    return floorf(v);
}

static CGFloat _AlignInset2(CGFloat w) {  
    return floorf(w) / 2;
} 

static CGFloat _AlignSize2(CGFloat v) { 
    CGFloat v2 = floorf(v);
    CGFloat delta = v - v2;
    if (delta <= 0.5) { 
        return v2; 
    }  else { 
        return v2 + 0.5; 
    }
}

            
void _StrokePath(CGContextRef context, UIColor * color, CGFloat strokeWidth) { 
    if (color) {            
        CGContextSetStrokeColorWithColor(context,color.CGColor);
        CGContextSetLineWidth(context, strokeWidth);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextStrokePath(context);
    }
}

void _FillArea(CGContextRef context, INGraphSeriesParams * params, NSInteger flags, CGRect rect,UIColor * fillColor) { 
    if (flags & INGraphGradientFill) {
        if (params.fillGradient) {
            NSInteger options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
            CGContextDrawLinearGradient(context, params.fillGradient,
                                        CGPointMake(rect.origin.x,rect.origin.y),
                                        CGPointMake(rect.origin.x,rect.origin.y + rect.size.height),
                                        options);
        }
    }
    if (flags & INGraphColorFill) {
        UIColor * clr = fillColor;
        if (clr) {
            CGContextSetFillColorWithColor(context,clr.CGColor);
        }
        CGContextFillRect(context, rect);
    } 
}

void _FillAreaAndStroke(CGContextRef context, INGraphSeriesParams * params, NSInteger flags, CGRect rect, 
                        CGPathRef path, CGFloat strokeWidth, UIColor * fillColor, NSInteger fillMask) { 
    if (!CGPathIsEmpty(path)) {
        // convert INGraphColorFill2, INGraphColorFill1 to INGraphColorFill
        if (fillMask & flags) { 
            flags &= ~fillMask;
            flags |= INGraphColorFill;
        } else {
            flags &= ~INGraphColorFill;
        }
        
        // fill areas
        if (flags & (INGraphGradientFill | INGraphColorFill)) {
            CGContextSaveGState(context);
            { 
                CGPathRef fillPath = CGPathCreateCopy(path);
                CGContextAddPath(context, fillPath);
                CGContextClip(context);
                _FillArea(context,params,flags,rect,fillColor);
                CGPathRelease(fillPath);
            }
            CGContextRestoreGState(context);
        }
        
        // stroke areas
        if (flags & INGraphStroke) {
            CGContextAddPath(context, path);
            _StrokePath(context,params.strokeColor,strokeWidth);
        }
    }
}
       
NSInteger _GoodSampleIndex(const CGFloat * sampleArray, NSInteger sampleCount, NSInteger startIndex, NSInteger valuesPerSample, NSInteger row) {
    NSCParameterAssert(valuesPerSample > 0);
    NSCParameterAssert(startIndex >= 0);
    NSCParameterAssert(0 <= row && row < valuesPerSample);
    
    if (valuesPerSample > 0) {
        const CGFloat * sa = sampleArray + valuesPerSample * startIndex; 
        while(startIndex < sampleCount) { 
            if (!isnan(sa[row])) { 
               return startIndex;
            }
            startIndex++;
            sa += valuesPerSample;
        }
    } else {
       NSCAssert(0, @"531ec8de_1cf5_48b6_a05d_8ac81a677068"); // пока не нужно
    }
    return -1;
}

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphSeriesLayer : INGraphLayer {
@package 
    INGraphSeriesInfo * _info;
    INGraphSeriesData * _mergedData;
    INGraphSeriesData * _dataToDraw;
    BOOL _validated;
    
    CGFloat paintHeight, paintOffset, paintBottom, solidHeight, diffHeight,diffOffset;
    CGFloat solidOffset,screenScale,lineAlign,oneLineWidth;
    CGFloat maxValue, minValue;
    CGRect  paintRect;
    CGFloat _startOffsetX;
    CGFloat tickWidth,scale,mediumV,mediumY;
    
}

@property(nonatomic,assign) INGraphSeriesInfo * info;
@property(nonatomic,readonly) INGraphSeriesData * joinedData;

- (void)invalidate;

@end

//==================================================================================================================================

@implementation INGraphSeriesLayer

@synthesize info = _info;
@synthesize joinedData = _mergedData;

- (void)dealloc { 
    [_mergedData release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)invalidate { 
    _validated = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)validate:(INGraphSeriesParams *)params {
    //  
    if (_validated) { 
        return YES;
    }

    INGraphSeriesData * data = _info.data;
    NSInteger rowA = params.dataRowFrom;
    NSInteger rowB = params.dataRowTo;
    NSInteger flags = params.options;
    
    // ****************** Calc areas, screen scale, line widthes ************************************/
    CGRect rBounds = self.bounds;
    paintHeight = floor(rBounds.size.height * params.layoutPaintPart);
    paintOffset = floor(rBounds.size.height * params.layoutPaintOffset);
    paintRect   = CGRectMake(0,paintOffset,rBounds.size.width,paintHeight);
    paintBottom = paintRect.origin.y + paintRect.size.height;
    solidHeight = rint(paintHeight * params.layoutSolidPart);
    diffHeight  = rint(paintHeight * params.layoutDiffPart);
    diffOffset  = paintOffset + paintHeight - diffHeight - solidHeight;
    if (diffOffset < 0) {
        diffOffset = 0;
        solidHeight =  paintOffset + paintHeight - diffHeight; 
    }
    solidOffset  = diffHeight + diffOffset;
    screenScale  = INGraphicsScreenScale();
    oneLineWidth = 1 / screenScale;
    lineAlign    = oneLineWidth / 2;
 
    // *****************  Other precalculations (data based)****************************************/
    minValue = [data minValueAndMaxValue:&maxValue forRowFrom:rowA rowTo:rowB];
    if (!data.sampleCount || isnan(minValue) || !_graph.fullAxisXLength) {
        return NO;
    }
    NSInteger valuesPerSample = data.valuesPerSample;
    
    CGFloat unjoinedTickWidth = paintRect.size.width / _graph.fullAxisXLength;
    _startOffsetX = unjoinedTickWidth * data.axisXOffset + paintRect.origin.x;
    const NSInteger * mergeModes = params.dataMergeModes;
    switch(params.graphStyle) {
        case INGraphBarStyle:
        case INGraphCandleStyle: 
            NSAssert((valuesPerSample >= 4), @"cfaeccb2_3fc2_4130_a402_b35c089a6a14");
            NSAssert((rowB - rowA + 1 == 4), @"4214f515_9005_4623_ba88_50c3e993955a");
            if (!mergeModes && valuesPerSample == 4) {
                static const NSInteger mm[] = {
                    INGraphMergeModeMin, 
                    INGraphMergeModeMax, 
                    INGraphMergeModeFirstValue, 
                    INGraphMergeModeLastValue
                };
                mergeModes = mm;
            }
            break;
            
        case INGraphLineStyle:
            NSAssert((valuesPerSample >= 1), @"03403b13_95bb_405c_bd14_8be73660a9ed");
            NSAssert((rowB - rowA + 1 == 1), @"382222a5_938d_4245_a299_fc93cebac931");
            if (!mergeModes && valuesPerSample == 1) {
                static const NSInteger mm[] = {
                    INGraphMergeModeLastValue
                };
                mergeModes = mm;
            }
            break;
        
        case INGraphClassicBarStyle:
            NSAssert(valuesPerSample >= 1, @"1a79a98f_340f_4db8_8892_d32aab1a7d1f");
            NSAssert(rowB - rowA + 1 == 1, @"12aff24e_5be2_4e7e_9d15_15fcb9290703");
            if (!mergeModes && valuesPerSample == 1) {
                static const NSInteger mm[] = {
                    INGraphMergeModeSum
                };
                mergeModes = mm;
            }
            break;
    }
    
    // NSLog(@"--- %d", data.sampleCount); 
    // @throw [NSException exceptionWithName:@"(NSString *)name" reason:@"(NSString *)reason" 
               // userInfo:nil];
            
    // marge values if needed
    NSInteger sampleCount = data.sampleCount;
    tickWidth = unjoinedTickWidth;
    if (flags & INGraphMergeSamples && params.bandMinWidth > 0 && unjoinedTickWidth < params.bandMinWidth) {
        CGFloat   myLength = unjoinedTickWidth * sampleCount;
        NSInteger estimatedCount = ceil(myLength / params.bandMinWidth);
        NSInteger mergedCount = (sampleCount + estimatedCount - 1) / estimatedCount;
        if (mergedCount > 1) { // при некоторых близких значениях unjoinedTickWidth и  params.bandMinWidth => mergedCount == 1
            if (!_mergedData || _mergedData.valuesPerSample != valuesPerSample) { 
                [_mergedData release];
                _mergedData = [[data.class dataWithValuesPerSample:valuesPerSample] retain];
            }
            // [data dump];
            [_mergedData addMergedData:data mergeSize:mergedCount mergeModes:mergeModes];
            data = _mergedData;
            sampleCount = data.sampleCount;
            tickWidth = myLength / sampleCount;
            minValue = [data minValueAndMaxValue:&maxValue forRowFrom:rowA rowTo:rowB]; // calc again
        }
    }
    
    // calc scales
    if (flags & INGraphOverrideMinValue) { 
        minValue = params.minValue; // MIN(params.minValue, minValue);
    }
    if (flags & INGraphOverrideMaxValue) { 
        maxValue = params.maxValue; // MAX(params.maxValue, maxValue);
    }
    scale = (minValue == maxValue) ? 0 : (diffHeight/(maxValue - minValue));
    mediumV = minValue + (maxValue - minValue)/ 2; 
    mediumY = diffHeight / 2 + diffOffset;
    
    _validated = YES;
    _dataToDraw = data;    
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)validate {
    if (!_validated) {
        [_graph updateParams:_info.params forData:_info.data];
        [self validate:_info.params];
    }
    return _validated;
}

//----------------------------------------------------------------------------------------------------------------------------------

CG_INLINE CGFloat _NormalizeRatio(CGFloat v) { 
    if (v < 0) { 
        v = 0;
    }
    if (v > 1.0) {
        v = 1.0;
    }
    return v;
}

- (CGFloat)alignOrigin:(CGFloat)v {
    CGFloat min = paintOffset;
    CGFloat max = paintBottom;
    if (screenScale > 1) { 
        return _AlignOrigin2(v,min,max);
    } else {
        return _AlignOrigin1(v,min,max);
    }
}

- (CGFloat)alignSize:(CGFloat)v {
    if (screenScale > 1) { 
        return _AlignSize2(v);
    } else {
        return _AlignSize1(v);
    }
}
// offset is in view's coordinates
// realSampleIndex, realData are not used now and can be removed
- (void)offsetX:(CGFloat)offset toDataOffset:(CGFloat *)dataOffset sampleIndex:(NSInteger *)sampleIndex 
           offsetDeltaX:(CGFloat *)offsetDeltaX 
           data:(INGraphSeriesData **)data realSampleIndex:(NSInteger *)realSampleIndex 
           realData:(INGraphSeriesData **)realData {
    [self validate];
    NSInteger rowA = _info.params.dataRowFrom;
    CGRect  r  = self.bounds;
    CGFloat localOffset = [self convertPoint:CGPointMake(offset, 0) fromLayer:_graph.layer].x;
    if (localOffset < _startOffsetX) { 
        localOffset = _startOffsetX;
    }
    *sampleIndex = 0; 
    *data = _dataToDraw;
    *realSampleIndex = 0;
    *realData = _info.data;
    *offsetDeltaX = 0;
    *dataOffset = 0;
    
    if (_dataToDraw.sampleCount > 0) { 
        *dataOffset = _NormalizeRatio(localOffset / r.size.width);

        CGFloat x = 0;
        // CGFloat width = tickWidth * _dataToDraw.sampleCount;
        // CGFloat sdataOffsetRatio = _NormalizeRatio((localOffset - _startOffsetX) / width);
        // *sampleIndex = rint(sdataOffsetRatio * _dataToDraw.sampleCount);
        CGFloat approx = (localOffset - _startOffsetX) / tickWidth; 
        *sampleIndex = floor(approx); //  - 0.5); // (localOffset - _startOffsetX) / width
        // NSLog(@"%d %f %f %f %f",*sampleIndex,localOffset,_startOffsetX,tickWidth,approx);
        if (*sampleIndex < 0) {
            *sampleIndex = 0;
        } 
        if (*sampleIndex >= _dataToDraw.sampleCount) { 
            *sampleIndex = _dataToDraw.sampleCount-1;
        }
            
        
        // ищем первые реальные данные
        NSInteger deltaPrev;  
        NSInteger deltaNext; 
        BOOL hasPrev = NO, hasNext = NO;
        for (int i = *sampleIndex; i >=0; i--) { 
            if (!isnan([_dataToDraw sampleAtIndex:i][rowA])) {
                deltaPrev = *sampleIndex - i;
                hasPrev = YES;
                break;
            }
        }
        for (int i = *sampleIndex+1; i < _dataToDraw.sampleCount; i++) { 
            if (!isnan([_dataToDraw sampleAtIndex:i][rowA])) {
                deltaNext = i - *sampleIndex;
                hasNext = YES;
                break;
            }
        }
        
        if (hasPrev && hasNext) {
            if (deltaPrev < deltaNext) { 
                hasNext = NO;   
            } else 
            if (deltaPrev > deltaNext) {
                hasPrev = NO;   
            } else {   
                // находим ближайшее по смещению x
                if ((localOffset - _startOffsetX - (tickWidth * (0.5 + *sampleIndex - deltaPrev))) <= 
                    (tickWidth * (0.5 + *sampleIndex + deltaPrev) - (localOffset - _startOffsetX))
                    ) {
                   hasNext = NO;  
                } else {
                    hasPrev = NO; 
                }
            }
        }
        
        if (hasPrev) {
            if (hasNext) {
               NSAssert(0, @"c83f1d84_5750_44f7_bc90_bcbe3b9bd5e9");
                 
            } else { 
               *sampleIndex -= deltaPrev;
            }
        } else {
            if (hasNext) { 
               *sampleIndex += deltaNext;
            } else { 
               *sampleIndex = 0;  
            }
        }
        NSAssert(0 <= *sampleIndex && *sampleIndex < _dataToDraw.sampleCount, @"842aa3ea_a2e7_47e6_ba0b_bd459a491fcc");
        
        x = [self alignOrigin:tickWidth * (0.5 + *sampleIndex)];  
        *offsetDeltaX = x - localOffset; 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawInContext:(CGContextRef)context {
    if (!_graph.canDraw) { 
        return;
    }
    
    [super drawInContext:context];
   
    INGraphSeriesParams * params = _info.params;
    NSInteger flags = params.options;
    if (flags & INGraphDontDraw) { 
        return;
    }
    if (![self validate:params]) { 
        return;
    }
    NSInteger valuesPerSample = _dataToDraw.valuesPerSample;
    NSInteger sampleCount = _dataToDraw.sampleCount;
    NSInteger rowA = params.dataRowFrom;
    NSInteger graphStyle = params.graphStyle;
    CGFloat startOffsetX = _startOffsetX;
   
    /* 
    if ( graphStyle == INGraphLineStyle && _graph.alignLineGraphToBounds &&  _graph.fullAxisXLength > 1) {  
        CGFloat newWidth = (paintRect.size.width * _graph.fullAxisXLength) / (_graph.fullAxisXLength - 1);
        CGFloat dpr = rint((newWidth - paintRect.size.width) / 2);
        paintRect = CGRectInset(paintRect,-dpr / 2,0); 
    }
    */

    // *****************  calcs 3 *******************************************************/
    
    AlignFuncPtr2 ALIGN_ORIGIN = _AlignOrigin1;
    AlignFuncPtr ALIGN_SIZE   = _AlignSize1;
    AlignFuncPtr ALIGN_INSET_FROM_SIZEDIFF = _AlignInset1;
    CGFloat   strokeWidth = params.strokeWidth;
    if (strokeWidth == 0) {
        if (screenScale > 1) { 
            ALIGN_ORIGIN = _AlignOrigin2;
            ALIGN_SIZE   = _AlignSize2;
            ALIGN_INSET_FROM_SIZEDIFF = _AlignInset2;
        }
        strokeWidth = oneLineWidth;
    }
    
    // *****************  debug painting *******************************************************/
    
    if (_debugMode) {
        CGRect rB = self.bounds;
        CGContextSaveGState(context);
        UIColor * color = [_graph debugColorForLayer:self];  
        CGContextSetLineWidth(context, oneLineWidth);
        const CGFloat dashes[2] = { 1, 2 }; 
        CGContextSetLineDash(context,0,dashes,2);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGPoint pt[4] = { 
           CGPointMake(0, diffOffset + lineAlign),CGPointMake(rB.size.width, diffOffset + lineAlign),
           CGPointMake(0, solidOffset+ lineAlign),CGPointMake(rB.size.width, solidOffset + lineAlign)
        };
        CGContextStrokeLineSegments(context,pt,4);
        CGContextRestoreGState(context);
    }
    
    // ****************** MACRO, sorry *******************************
    
#define PT_Y(_v1_) (mediumY - ((_v1_) - mediumV) * scale)
#define PT_X(_i_)  (startOffsetX + (_i_) * tickWidth)
// #define PTV_Y(_v1_) (mediumY - ((CGFloat)(_v1_ - volumeMediumV)) * volumeScale)
// #define ADD_PATH_TO_CONTEXT(__path__) { CGContextAddPath(context, __path__); __path__ = nil; }
#define PT_YIDX(_idx_) (PT_Y((sample0 + _idx_ * valuesPerSample)[rowA]))
#define PT_YIDX_I(_idx_,_idx2_) (PT_Y((sample0 + _idx_ * valuesPerSample)[_idx2_]))
#define ADD_BEZIER    CGPathAddCurveToPoint(path, nil,\
                      (-pt_Prev2.x + 6*pt_Prev1.x + pt_I.x) / 6, (-pt_Prev2.y + 6* pt_Prev1.y + pt_I.y) / 6, \
                      ( pt_Prev1.x + 6*pt_I.x - pt_Next.x) / 6, ( pt_Prev1.y + 6* pt_I.y - pt_Next.y) / 6, pt_I.x,pt_I.y );
#define NORM_ORIGIN(_origin_) { if (_origin_ < origin) { _origin_ = origin; } else if (_origin_ > bottom) { _origin_ = bottom; } }    

    
    // ****************** LINE STYLE DRAWINGS  *******************************
    
    if (graphStyle == INGraphLineStyle) {
        CGMutablePathRef path = CGPathCreateMutable();
        startOffsetX += tickWidth / 2;
       
        CGFloat * sample0 = [_dataToDraw sampleAtIndex:0];
        NSInteger firstGoodSampleIndex = _GoodSampleIndex(sample0,sampleCount,0,valuesPerSample,rowA);
        if (firstGoodSampleIndex >= 0) { // draw if we have te least one significant sample
    
            CGPoint startPoint = CGPointMake(PT_X(firstGoodSampleIndex), PT_YIDX(firstGoodSampleIndex));

            CGPathMoveToPoint(path, nil, startPoint.x, startPoint.y);
            
            NSInteger i = firstGoodSampleIndex; 
            if (flags & INGraphLineApplyBezier) {
                // У нас есть только точка(0). Для первого отрезка кривой надо найти точку (1) - обязательно и точку (2) - опционально   
                NSInteger idx_1 = _GoodSampleIndex(sample0,sampleCount,i+1,valuesPerSample,rowA);
                if (idx_1 > 0) { // нашли точку 1  
                    NSInteger idx_Next = _GoodSampleIndex(sample0,sampleCount,idx_1+1,valuesPerSample,rowA);
                    if (idx_Next < 0) { // у нас всего две точки. Рисуем прямую
                        CGPathAddLineToPoint(path, nil, PT_X(idx_1), PT_YIDX(idx_1));
                    } else {
                        // начинаем рисовать безье тут. для первого отрезка точки -2 и -1 совмещаем. текущей точкой принимаем idx_i
                        CGPoint pt_I     = CGPointMake(PT_X(idx_1), PT_YIDX(idx_1));
                        CGPoint pt_Next  = CGPointMake(PT_X(idx_Next), PT_YIDX(idx_Next));
                        CGPoint pt_Prev1 = startPoint;
                        CGPoint pt_Prev2 = startPoint;                   
                        ADD_BEZIER;
                        while (idx_Next > 0) { 
                            pt_Prev2 = pt_Prev1;
                            pt_Prev1 = pt_I;
                            pt_I = pt_Next;
                            idx_Next = _GoodSampleIndex(sample0,sampleCount,idx_Next+1,valuesPerSample,rowA);
                            if (idx_Next > 0) {
                                pt_Next  = CGPointMake(PT_X(idx_Next), PT_YIDX(idx_Next));
                            }
                            ADD_BEZIER;
                        }
                    }
                }
            } else {
               while ((i = _GoodSampleIndex(sample0,sampleCount,i+1,valuesPerSample,rowA)) > 0) { 
                    CGPathAddLineToPoint(path, nil, PT_X(i), PT_YIDX(i));
               }
            }

            if (!CGPathIsEmpty(path)) {    
                // fill area. Copy the path, close it properly
                if (flags & (INGraphColorFill | INGraphGradientFill)) {
                    CGContextSaveGState(context);
                    { 
                        CGMutablePathRef fillPath = CGPathCreateMutableCopy(path);
                        CGPoint lastPoint = CGPathGetCurrentPoint(fillPath);
                        if (flags & INGraphLineDiffFill) {
                            if (flags & INGraphUseZeroValue) {
                                CGFloat zeroY =  PT_Y(params.zeroValue);
                                CGPathAddLineToPoint(fillPath, nil, lastPoint.x, zeroY);
                                CGPathAddLineToPoint(fillPath, nil, startPoint.x, zeroY);
                                CGPathAddLineToPoint(fillPath, nil, startPoint.x, startPoint.y);
                            } else { 
                                CGPathAddLineToPoint(fillPath, nil, lastPoint.x, startPoint.y);
                            }
                        } else {
                            CGPathAddLineToPoint(fillPath, nil, lastPoint.x, paintBottom);
                            CGPathAddLineToPoint(fillPath, nil, startPoint.x,paintBottom);
                        }
                        CGPathCloseSubpath(fillPath);
                        CGContextAddPath(context,fillPath);
                        CGContextClip(context);
                        _FillArea(context,params,flags,paintRect,params.fillColor);
                        CGPathRelease(fillPath); 
                    }
                    CGContextRestoreGState(context);
                }

                // outline the line graph
                if (flags & INGraphStroke) {
                    CGContextAddPath(context,path);
                    _StrokePath(context,params.strokeColor, strokeWidth);
                }
            }
        }
        
        // release the path. in most situations path == nil already
        CGPathRelease(path);
        return;
    }
    
    // ****************** BAR-LIKE DRAWINGS *******************************
    if (graphStyle == INGraphCandleStyle || graphStyle == INGraphBarStyle || graphStyle == INGraphClassicBarStyle) { 
        CGFloat * sample0 = [_dataToDraw sampleAtIndex:0];
        CGFloat pointX = ALIGN_ORIGIN(startOffsetX,paintOffset,paintBottom);
        CGMutablePathRef path = CGPathCreateMutable();
        CGMutablePathRef path1 = nil;
        CGMutablePathRef path2 = nil;
        
        if (graphStyle == INGraphBarStyle || graphStyle == INGraphCandleStyle) { 
            path1 = CGPathCreateMutable();
            path2  = CGPathCreateMutable();
            NSAssert(valuesPerSample >= 4, @"36b189b6_432b_48c9_bc5f_ec2b538a7cfc");
        }

        CGFloat bandMaxWidth = params.bandMaxWidth;
        for (int i = 0; i < sampleCount; i++) { 
            CGFloat bandLeft = pointX;
            CGFloat bandWidth  = rint(PT_X(i+1)-pointX);
            pointX = bandLeft + bandWidth;
            if (isnan((sample0 + i * valuesPerSample)[rowA])) { 
                continue;
            }
            
            if (pointX > paintRect.size.width) {
                bandWidth -= oneLineWidth; // pointX - paintRect.size.width;    
            }
            if (bandMaxWidth > 0 && bandWidth > bandMaxWidth) { 
                CGFloat delta = floor((bandWidth - bandMaxWidth)/2);
                bandWidth = bandMaxWidth;
                bandLeft += delta;
            }
            CGFloat inset = ALIGN_INSET_FROM_SIZEDIFF((1 - params.bandWorkPart) * bandWidth);
            bandLeft  += inset;
            bandWidth -= 2 * inset;
            switch (graphStyle) {
                case INGraphClassicBarStyle:
                    {  
                        CGRect bandRect = CGRectMake(bandLeft,ALIGN_ORIGIN(PT_YIDX(i),paintOffset,paintBottom),bandWidth,0);
                        bandRect.size.height = ALIGN_SIZE(paintBottom - bandRect.origin.y);
                        if (bandRect.size.height < 0) { 
                            bandRect.size.height = 0;
                        }
                        CGPathAddRect(path,nil, bandRect);
                    }
                    break;
                
                case INGraphBarStyle:
                    {
                        inset = ALIGN_INSET_FROM_SIZEDIFF((bandWidth * 2) / 3);
                        CGFloat leftFirst  = bandLeft;
                        CGFloat bodyLeft   = leftFirst + inset;
                        CGFloat bodyWidth  = bandWidth - 2 * inset;
                        CGFloat leftLast   = bodyLeft + bodyWidth;
                        CGFloat origin = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueMax),paintOffset,paintBottom);
                        if (origin < diffOffset) { 
                           origin = diffOffset;
                        }
                        CGFloat height = ALIGN_SIZE(PT_YIDX_I(i,INGraphDataValueMin) - origin);
                        CGFloat triangleSizeHor = inset;
                        CGFloat triangleSizeVer = inset;
                        CGFloat bottom = origin + height; 
                        CGPoint pt[4];
                        CGFloat o;
                                                 
                        // body  
                        CGPathAddRect(path,nil, CGRectMake(bodyLeft,origin,bodyWidth,height));
                        
                        // left value
                        o = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueFirst),paintOffset,paintBottom);
                        NORM_ORIGIN(o);
                        pt[0] = CGPointMake(leftFirst,o); 
                        pt[1] = CGPointMake(bodyLeft,o + triangleSizeVer);
                        pt[2] = CGPointMake(bodyLeft,o);
                        pt[3] = pt[0];  
                        CGPathAddLines(path1,nil,pt,4);
                        
                        
                        // right value
                        o = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueLast),paintOffset,paintBottom);
                        NORM_ORIGIN(o);
                        pt[0] = CGPointMake(leftLast+triangleSizeHor,o); 
                        pt[1] = CGPointMake(leftLast,o + triangleSizeVer);
                        pt[2] = CGPointMake(leftLast,o);
                        pt[3] = pt[0];  
                        CGPathAddLines(path2,nil,pt,4);

                    }
                    break;
                case INGraphCandleStyle:
                    {
                        CGRect  bandRect = CGRectMake(bandLeft,0,bandWidth,0);
                        CGFloat o1 = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueLast),paintOffset,paintBottom);
                        CGFloat o2 = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueFirst),paintOffset,paintBottom);
                        if (o1 < o2) { 
                            bandRect.origin.y = o1;
                            bandRect.size.height = o2 - o1;
                        } else {
                            bandRect.origin.y = o2;
                            bandRect.size.height = o1 - o2;
                        }
                        CGPathAddRect(o1 < o2 ? path1 : path2,nil, bandRect);
                        
                        // inset = ALIGN_INSET_FROM_SIZEDIFF((bandWidth * 2) / 3);
                        // CGRect minMaxRect = CGRectInset(bandRect, inset, 0);
                        CGFloat minMaxX = ALIGN_ORIGIN(bandRect.origin.x + bandRect.size.width / 2,0,100000.0);
                        o1 = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueMax),paintOffset,paintBottom);
                        if (o1 < bandRect.origin.y) {
                            CGPathMoveToPoint(path, nil, minMaxX, o1);
                            CGPathAddLineToPoint(path, nil, minMaxX, bandRect.origin.y);
                             
                            // minMaxRect.origin.y = o1;
                            // minMaxRect.size.height =  bandRect.origin.y - minMaxRect.origin.y;
                            // CGPathAddRect(path,nil, minMaxRect);
                        }
                        o1 = ALIGN_ORIGIN(PT_YIDX_I(i,INGraphDataValueMin),paintOffset,paintBottom);
                        o2 = bandRect.origin.y + bandRect.size.height;
                        if (o1 > o2) { 
                            // minMaxRect.origin.y = o2;
                            // minMaxRect.size.height = o1 - o2;
                            // CGPathAddRect(path,nil, minMaxRect);
                            CGPathMoveToPoint(path, nil, minMaxX, o1);
                            CGPathAddLineToPoint(path, nil, minMaxX, o2);
                        }

                     }
                    break;
            }
        }
         
        if (path) {
           _FillAreaAndStroke(context,params,flags,paintRect,path,strokeWidth,params.fillColor, INGraphColorFill);
        }
        
        if (path1) {
            _FillAreaAndStroke(context,params,flags,paintRect,path1,strokeWidth,params.fillColor1, INGraphColorFill1);
        }

        if (path2) { 
            _FillAreaAndStroke(context,params,flags,paintRect,path2,strokeWidth,params.fillColor2, INGraphColorFill2);
        }

        // release the path. in most situations path == nil already
        CGPathRelease(path);
        CGPathRelease(path1);
        CGPathRelease(path2);
        return;
    }
    NSAssert(0, @"5a8c0d9a_4b2c_466b_b523_aa7cc1f10e22");
    
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INGraphSeriesInfo

@synthesize layer = _layer;
@synthesize data = _data;
@synthesize graph = _graph;
@synthesize params = _params;

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        _params = [INGraphSeriesParams new];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [_layer removeFromSuperlayer];
    [_params release];
    [_data release];
    [_layer release];
    [super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INGraphLayer

@synthesize graph = _graph;
@synthesize debugMode = _debugMode;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setDebugMode:(BOOL)value { 
    if (value != _debugMode) { 
        _debugMode = value;
        [self setNeedsDisplay];
    }
    for (INGraphLayer * layer in self.sublayers) { 
        layer.debugMode = value;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setNeedsDisplayWithChildren {
    [self setNeedsDisplay];
    for (INGraphLayer * layer in self.sublayers) { 
        [layer setNeedsDisplayWithChildren];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
	self = [super init];
	if (self) {
        NSMutableDictionary * newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   [NSNull null], @"onOrderIn",
                                   [NSNull null], @"onOrderOut",
                                   [NSNull null], @"sublayers",
                                   [NSNull null], @"contentsScale",
                                   [NSNull null], @"name",
                                   [NSNull null], @"onLayout",
                                   [NSNull null], @"contents",
                                   [NSNull null], @"bounds",
                                   [NSNull null], @"position",                                   
                                   [NSNull null], @"onDraw",
                                   [NSNull null], @"hidden",
                                   [NSNull null], @"backgroundColor",
                                   // [NSNull null], @"needsDisplayOnBoundsChange",
                                   nil]; 
        self.actions = newActions;
        [newActions release];
        [self inru_setMaxContentScale];    
 	}
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------
// этот метод не помогает, надо отключать для конкретного инстанса (см код выше)
//+ (id < CAAction >)defaultActionForKey:(NSString *)key { 
//    NSLog(@"action %@", key);
//    return nil;
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithGraph:(INGraph *)graph name:(NSString *)name {
	self = [self init];
	if (self) {
        _graph = graph;
        self.name = name;
        _debugMode = _graph.debugMode; 
    }
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)adjustFrame {
    [_graph adjustFrameForLayer:self]; 
    for (INGraphLayer * layer in self.sublayers) { 
        [layer adjustFrame];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawInContext:(CGContextRef)context {
    if (!_graph.canDraw) { 
        //+NSLog(@"%@ drawInContext - delayed", self.name);
        return;
    } else {
       // NSLog(@"%x draw layer %@", _graph, self.name); 
    }

    [super drawInContext:context];
    
    // NSLog(@"draw %@", [self inru_dumpString]); 
    if (_debugMode) { 
        CGRect r = self.bounds;
        CGContextSaveGState(context);
        UIGraphicsPushContext(context);
        { 
            UIColor * color = [_graph debugColorForLayer:self];  
            [[color colorWithAlphaComponent:0.05] set];
            CGContextFillRect(context, r);
            CGContextSetLineWidth(context, 1);
            // const CGFloat dashes[2] = { 5, 5 }; 
            // CGContextSetLineDash(context,0,dashes,2);
            [color set];
            CGContextStrokeRect(context,r);
            
            UIFont * fnt = [UIFont systemFontOfSize:12];
            r = CGRectInset(r,2,0);
            r.size = [self.name sizeWithFont:fnt constrainedToSize:r.size lineBreakMode:UILineBreakModeTailTruncation];
            CGContextFillRect(context, CGRectInset(r,-2,0)); 
            [[UIColor whiteColor] set]; 
            [self.name drawInRect:r withFont:fnt];
        }
        UIGraphicsPopContext();
        CGContextRestoreGState(context);
    }
    
    //[_graph customDrawLayer:self inContext:context];
}


@end


//==================================================================================================================================
//==================================================================================================================================

@implementation INGraph

@synthesize debugMode = _debugMode;
@synthesize defaultParams = _defaultParams;
@synthesize graphDelegate = _graphDelegate;
@synthesize seriesInsets = _seriesSuperlayerInsets;
@synthesize seriesData = _seriesData;
@synthesize drawingEnabled = _drawingEnabled;
@synthesize overlays = _overlays;
// @synthesize measureStart = _pinch.startPoint;
// @synthesize measureEnd = _pinchEndPoint;

//----------------------------------------------------------------------------------------------------------------------------------

- (INGraphPinchState)pinchState { 
    return _pinch.state;  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)pinchBoundInset { 
    return _pinch.boundInset;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setPinchBoundInset:(CGFloat)value { 
    _pinch.boundInset = value;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INGraphSeriesLayer *)seriesSuperlayer  {
    return (INGraphSeriesLayer *)_seriesSuperlayer;
}

//----------------------------------------------------------------------------------------------------------------------------------
- (void)setDrawingEnabled:(BOOL)value { 
    if (_drawingEnabled != value) { 
        _drawingEnabled = value;
        if (!_drawingEnabled) { 
           _drawingDelayed = NO;
           //+NSLog(@"%x DRAWING DISABLED", self);
        } else { 
            if (_drawingDelayed) {
                //+NSLog(@"%x DRAWING ENABLED WITH REPAINTING", self);
                [self setNeedsDisplay];
                [((INGraphLayer *)self.layer) setNeedsDisplayWithChildren];
            } else { 
                //+NSLog(@"%x DRAWING ENABLED", self);
            }
        } 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canDraw {
    if (!_drawingEnabled) {  
        _drawingDelayed = YES;  
        return NO;
    }
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSeriesInsets:(UIEdgeInsets)value {
    if (!UIEdgeInsetsEqualToEdgeInsets(value,_seriesSuperlayerInsets)) {
        _seriesSuperlayerInsets = value;
        WITHOUT_ANIMATION(
            [_seriesSuperlayer adjustFrame];
            if (_pinch.layer) { 
                [_pinch.layer adjustFrame];
            }
        ) 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setDebugMode:(BOOL)value {
   _debugMode = value;
   ((INGraphLayer *)self.layer).debugMode = value; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setNeedsDisplayForOverlayWithTag:(NSInteger)tag { 
    for (INGraphOverlay * overlay in _overlays) { 
        if (overlay.tag == tag) { 
             [overlay.layer setNeedsDisplay];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeAllOverlays { 
    [_overlays removeAllObjects];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INGraphOverlay *)addOverlayAboveSeries:(BOOL)above { 
    NO_ANIMATION_ON
    
    INGraphOverlay * overlay = [INGraphOverlay new];
    overlay.graph = self;
    INGraphOverlayLayer  * layer = [[INGraphOverlayLayer alloc] initWithGraph:self
                                     name:[NSString stringWithFormat:@"overlay_%d",_overlays.count]];

    [layer setOverlay:overlay];
    overlay.layer = layer;
    if (above) { 
        [self.layer insertSublayer:layer above:_seriesSuperlayer];
    } else { 
        [self.layer insertSublayer:layer below:_seriesSuperlayer];
    }
    [_overlays addObject:overlay];
    [layer adjustFrame];
    [overlay release];
    [layer release];
    
    NO_ANIMATION_OFF
    return overlay;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)postInitInitialization { 
    self.contentMode = UIViewContentModeRedraw;

    _drawingEnabled = YES;
        
    _seriesInfo = [NSMutableArray new];
    _defaultParams = [INGraphSeriesParams new];
    [_defaultParams resetToDefaults];
    
    _overlays = [NSMutableArray new];
    
    INGraphLayer * layer = ((INGraphLayer *)self.layer);
    layer.graph = self;
    layer.name = @"main";
    layer.needsDisplayOnBoundsChange = YES;
 
    _seriesSuperlayer = [[INGraphLayer alloc] initWithGraph:self name:@"seriesSuperlayer"];
    _seriesSuperlayerInsets = UIEdgeInsetsMake(10,10,10,10);
    [layer addSublayer:_seriesSuperlayer];
    
    [(INGraphLayer *)self.layer adjustFrame];
    
    _pinch.boundInset = 3.0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self postInitInitialization];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self postInitInitialization];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrame:(CGRect)aFrame {
    CGRect oldFrame = self.frame; 
    [super setFrame:aFrame];
    if (!CGSizeEqualToSize(aFrame.size, oldFrame.size)) { 
        WITHOUT_ANIMATION([(INGraphLayer *)self.layer adjustFrame]);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_defaultParams release];
    [_seriesData release];
    [_seriesInfo release];
    [_overlays release];
    [_seriesSuperlayer release];
    [_pinch.layer release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (Class)layerClass { 
    return INGraphLayer.class; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIColor *)debugColorForLayer:(INGraphLayer *)layer {
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
        [UIColor blackColor], @"main", 
        [UIColor magentaColor], @"seriesSuperlayer", 
        [UIColor greenColor], @"series_0", 
        [UIColor orangeColor], @"series_1", 
        [UIColor greenColor], @"series_2", 
        [UIColor blueColor], @"series_3", 
        nil];
    UIColor * color = [dict objectForKey:layer.name];
    return color ? color : [UIColor redColor];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)adjustFrameForLayer:(INGraphLayer *)layer {
    CGRect r = self.bounds;
    if (layer == self.layer) { 
        return;
    }
    if (layer == _seriesSuperlayer) { 
        layer.frame =  UIEdgeInsetsInsetRect(r,_seriesSuperlayerInsets);  
        [layer setNeedsDisplay];
        return;  
    }
    if (layer.class == INGraphSeriesLayer.class) { 
        layer.frame = _seriesSuperlayer.bounds;
        [layer setNeedsDisplay];
        [(INGraphSeriesLayer *)layer invalidate]; 
        return;
    }
    if (layer.class == INGraphOverlayLayer.class) { 
        layer.frame = r;
        [layer setNeedsDisplay];
        return;
    }
    if (layer == _pinch.layer) {
        layer.frame = CGRectInset(_seriesSuperlayer.frame,-_pinch.boundInset,-_pinch.boundInset);
        [layer setNeedsDisplay];
        return;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateParams:(INGraphSeriesParams *)params forData:(INGraphSeriesData *)data { 
    [params assign:_defaultParams];
    if ([_graphDelegate respondsToSelector:@selector(graph:setupParams:forSeriesData:)]) { 
        [_graphDelegate graph:self setupParams:params forSeriesData:data];
    }
    [params check];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateData:(BOOL)reloadParams { 
    for (INGraphSeriesInfo * info in _seriesInfo) {
        [info.data markInvalidated];
        [info.layer invalidate]; 
        if (reloadParams) { 
            [self updateParams:info.params forData:info.data];
        }
        [info.layer setNeedsDisplay];
    }
    _seriesInfoPrecalculated = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)customDrawLayer:(CALayer *)layer inContext:(CGContextRef)context { 

//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSeriesData:(NSArray *) seriesData updateUI:(BOOL)updateUI {
    [_seriesData autorelease];
    _seriesData = [seriesData retain];
 
    // remove all existing items
    [_seriesInfo removeAllObjects];

    // add items
    int i = 0;
    for (INGraphSeriesData * data in seriesData) { 
        NSAssert([data isKindOfClass:INGraphSeriesData.class], @"1af36023_d396_4e2e_948b_fa3ee03554b9");
        INGraphSeriesInfo * info = [INGraphSeriesInfo new];
        info.data = data;
        info.graph = self;
        [info.params setSeriesIndex:i];
        info.layer = [[[INGraphSeriesLayer alloc] initWithGraph:self name:[NSString stringWithFormat:@"series_%d",i]] autorelease];
        info.layer.info = info;
        info.layer.debugMode = _debugMode; 
        [_seriesSuperlayer addSublayer:info.layer];
        [_seriesInfo addObject:info];
        [info release];
        i++;
    }
    _seriesInfoPrecalculated = NO;
    
    // update layout, look and feel;
    [_seriesSuperlayer adjustFrame];
    if (updateUI) {
        [self updateData:YES];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSeriesData:(NSArray *) seriesData {
    [self setSeriesData:seriesData updateUI:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)precalculate { 
    if (!_seriesInfoPrecalculated) { 
        _seriesInfoPrecalculated = YES;
        _fullAxisXLength = 0;
        for (INGraphSeriesInfo * info in _seriesInfo) {
            NSInteger dataTail = info.data.axisXOffset + info.data.sampleCount;
            if (dataTail > _fullAxisXLength) { 
                _fullAxisXLength = dataTail;
            }
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)fullAxisXLength { 
    [self precalculate];
    return _fullAxisXLength;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)seriesFrame { 
    return _seriesSuperlayer.frame;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSMutableArray *)seriesInfo {
    return _seriesInfo;
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)drawRect:(CGRect)rect {
//    if ([_graphDelegate respondsToSelector:@selector(graph:drawBackgroundInContext:bounds:)]) { 
//        [_graphDelegate graph:self drawBackgroundInContext:UIGraphicsGetCurrentContext() bounds:self.bounds];
//    }
// }

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)updateTouchesFromEvent:(UIEvent *)event { 
    NSInteger countOther = 0; // всего актуальных касаний (может быть больше двух)
    
    // проход первый, проверяем, сохранились ли старые касания
    BOOL f1 = NO, f2 = NO;
    for (UITouch * touch in [event touchesForView:self]) {
        if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) { 
            continue;
        }
        if (touch == _pinch.touch1) { 
            f1 = YES;
        } else 
        if (touch == _pinch.touch2) { 
            f2 = YES;
        } else {
            countOther++;
        }
    }
    
    NSInteger result = 0;
    if (f1) { 
        result++;
    } else {
        _pinch.touch1 = nil;
    }
    if (f2) { 
        result++;
    } else {
        _pinch.touch2 = nil;
    }
    
    // если добавились новые тачи - считаем их
    if (result < 2 && countOther ) {
        for (UITouch * touch in [event touchesForView:self]) {
            if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) { 
                continue;
            }
            if (touch != _pinch.touch1 && touch != _pinch.touch2) { 
                if (!_pinch.touch1) { 
                    _pinch.touch1 = touch;
                } else {
                    _pinch.touch2 = touch;
                }
                result++;
                if (result == 2) { 
                    break;
                }
            }
        }
    }

    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)pinchEnabled { 
    return _pinch.enabled;
}

- (void)setPinchEnabled:(BOOL)value { 
    if (_pinch.enabled != value) { 
        _pinch.enabled = value; 
        if (!_pinch.enabled) { 
            [self stopTouchMeasure];
        } else { 
            NSAssert(_pinch.state == INGraphPinchStateNone, @"d44c892b_4355_4e98_bb3f_c49b0a424e94");
            self.multipleTouchEnabled = YES;
        }
    }
}

- (BOOL)canPinch {
    if (_pinch.enabled) { 
        if ([_graphDelegate respondsToSelector:@selector(graphWantsToStartPinch:)]) { 
            return [_graphDelegate graphWantsToStartPinch:self];
        }
        return YES;
    }
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self canPinch]) {
        [self updateTouchMeasure:event];
    } else { 
        [super touchesBegan: touches withEvent: event];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
	// NSLog(@"MOVED %d %d", touches.count, [[touches anyObject] tapCount]);
    if (_pinch.state) { 
        [self updateTouchMeasure:event];
    } else {
    	[super touchesMoved:touches withEvent:event];
    }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { 
    if (_pinch.state) {  
        [self stopTouchMeasure];
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {	
    if (_pinch.state) {
        [self updateTouchMeasure:event];    
    } else {
	    [super touchesEnded: touches withEvent: event];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stopTouchMeasure {
    if (_pinch.state != INGraphPinchStateNone) { 
        _pinch.state = INGraphPinchStateNone;
        if ([_graphDelegate respondsToSelector:@selector(graphPinchChanged:)]) { 
            [_graphDelegate graphPinchChanged:self];
        }
    }
    if (_pinch.layer) { 
        [_pinch.layer removeFromSuperlayer];
        [_pinch.layer release];
        _pinch.layer = nil;
    }
    _pinch.boundLayer1 = _pinch.boundLayer2 = _pinch.overlayLayer = nil;
    _pinch.startPoint = CGPointMake(-1, -1);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGPoint)pointFromTouch:(UITouch *)touch { 
    CGRect r = _seriesSuperlayer.frame;
    CGPoint p = [touch locationInView:self];
    // align y
    if (p.y < r.origin.y) { 
        p.y = r.origin.y;
    } else
    if (p.y >= r.origin.y + r.size.height) { 
        p.y = r.origin.y + r.size.height;
    }
    
    // align x
    if (p.x < r.origin.x) { 
        p.x = r.origin.x;
    } else
    if (p.x >= r.origin.x + r.size.width) { 
        p.x = r.origin.x + r.size.width;
    }
    return p;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)touchMeasureSeriesIndex { 
    NSInteger result = 0;
    if ([_graphDelegate respondsToSelector:@selector(graphPinchSeriesIndex:)]) { 
        result = [_graphDelegate graphPinchSeriesIndex:self];
    }
    return (0 <= result && result < _seriesInfo.count) ? result : -1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGPoint)pinchOriginForLeftBound:(BOOL)leftBound alignedToValue:(BOOL)alignedToValue topAndBottom:(BOOL)topAndBottom { 
   CGPoint pt;
   if (leftBound) { 
       pt = alignedToValue ? _pinch.originalAlignedStartPoint : _pinch.originalStartPoint;
       if (topAndBottom) {
           pt.y = _pinch.startPoint.y;    
       }
   } else {
       pt = alignedToValue ? _pinch.originalAlignedEndPoint : _pinch.originalEndPoint;
       if (topAndBottom) {
           pt.y = _pinch.endPoint.y;    
       }
   }
   return pt;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateTouchMeasure:(UIEvent *)event { 

    CGRect r = _seriesSuperlayer.frame;
    
    NSInteger touchesCount = [self updateTouchesFromEvent:event];
    NSAssert(touchesCount <= 2 && touchesCount >= 0, @"16186a72_6f20_4760_9f43_f3bd672d5569");

    if (touchesCount == 0) { 
        [self stopTouchMeasure];
        return;
    }
    // 
    // - (void)graph:(INGraph *)graph pinchStateChangedTo:(INGraphPinchState)state;
    //

    CGPoint pt1 = CGPointZero;
    CGPoint pt2 = CGPointZero;
    CGPoint ptSingle = CGPointZero;
    if (_pinch.touch1) { 
        ptSingle = pt1 = [self pointFromTouch:_pinch.touch1];
    }
    if (_pinch.touch2) { 
        ptSingle = pt2 = [self pointFromTouch:_pinch.touch2];
    }
    
    BOOL singleTouch = (touchesCount == 1);
    
    // if points are equal in x coordinates then we have single touch
    // Такие вещи надо проверять и отображать в делегате, а тут у нас будет скакать 
    // попап по вертикали в момент перехода.
    // if (_pinch.touch1 && _pinch.touch2 &&  pt1.x == pt2.x) { 
    //    asser(!singleTouch && touchesCount == 2);
    //    singleTouch = YES;
    // }
    
    if (singleTouch) { 
        pt1 = pt2 = ptSingle;
    } else {
        // swap min <-> max
        if (pt1.x > pt2.x) {
            CGPoint ptA = pt1;
            pt1 = pt2;
            pt2 = ptA;
        }
    }
    
    INGraphPinchState newState = singleTouch ? INGraphPinchStateSingle : INGraphPinchStateDouble;
    
    // при 
    if (_pinch.state != newState || !CGPointEqualToPoint(pt1,_pinch.originalStartPoint) || !CGPointEqualToPoint(pt2,_pinch.originalEndPoint)) { 
        _pinch.state = newState;

        _pinch.originalStartPoint = _pinch.originalAlignedStartPoint = pt1;
        _pinch.originalEndPoint = _pinch.originalAlignedEndPoint = pt2;
        
        // это потом наверное стоит сделать опционально
        pt1.y =  r.origin.y;
        pt2.y =  r.origin.y + r.size.height;

        _pinch.startPoint = pt1;
        _pinch.endPoint = pt2;
                                                                        
        // create layer if not yet
        if (!_pinch.layer) {
            _pinch.layer = [[INGraphPinchLayer alloc] initWithGraph:self name:@"touchMeasure" mode:MEASURE_LAYER_MAIN];
            // _touchMeasureLayer.backgroundColor = [UIColor yellowColor].CGColor;
            [self.layer addSublayer:_pinch.layer];
            [_pinch.layer adjustFrame];
        }
        
        if (!singleTouch) {
            if (!_pinch.overlayLayer) {  
                _pinch.overlayLayer = [[INGraphPinchLayer alloc] initWithGraph:self name:@"touchMeasureOverlay" mode:MEASURE_LAYER_OVERLAY];
                _pinch.overlayLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
                [_pinch.layer addSublayer:_pinch.overlayLayer];
                [_pinch.overlayLayer release];
            }
            _pinch.overlayLayer.hidden = NO;
        } else {
            _pinch.overlayLayer.hidden = YES;
        }
        
        if (!_pinch.boundLayer1) { 
            _pinch.boundLayer1 = [[INGraphPinchLayer alloc] initWithGraph:self name:@"touchMeasureOverlay" mode:MEASURE_LAYER_LBOUND];
            // _pinch.boundLayer1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2].CGColor;
            _pinch.boundLayer1.needsDisplayOnBoundsChange = YES; 
            [_pinch.layer addSublayer:_pinch.boundLayer1];
            [_pinch.boundLayer1 release];
        }
        if (_pinch.state == INGraphPinchStateDouble) { 
            if (!_pinch.boundLayer2) { 
                _pinch.boundLayer2 = [[INGraphPinchLayer alloc] initWithGraph:self name:@"touchMeasureOverlay" mode:MEASURE_LAYER_RBOUND];
                // _touchBoundLayer2.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2].CGColor;
                _pinch.boundLayer2.needsDisplayOnBoundsChange = YES; 
                [_pinch.layer addSublayer:_pinch.boundLayer2];
                [_pinch.boundLayer2 release];
            }
        } else {
            if (_pinch.boundLayer2) {
                [_pinch.boundLayer2 removeFromSuperlayer];
            }
            _pinch.boundLayer2 = nil;
        }
        
        CGPoint pt1_o = [_pinch.layer convertPoint:_pinch.startPoint fromLayer:self.layer];
        CGPoint pt2_o = [_pinch.layer convertPoint:_pinch.endPoint fromLayer:self.layer];
        
        NSInteger serIndex = [self touchMeasureSeriesIndex];
        NSInteger leftSampleIndex = -1;
        NSInteger rightSampleIndex = -1;
        INGraphSeriesData *realData = nil; 
        
        _pinch.mediumV = 0;
        _pinch.mediumY = 0;
        _pinch.scale = 0;
        
        if (0 <= serIndex && serIndex < _seriesInfo.count) { 
            INGraphSeriesInfo * info = [_seriesInfo objectAtIndex:serIndex];
            CGFloat dataOffset,offsetDeltaX;
            
            _pinch.mediumV = info.layer->mediumV;
            _pinch.mediumY = info.layer->mediumY;
            _pinch.scale   = info.layer->scale;

            [info.layer offsetX:_pinch.startPoint.x toDataOffset:&dataOffset 
                                  sampleIndex:&_pinch.boundLayer1->_sampleIndex 
                                  offsetDeltaX:&offsetDeltaX 
                                  data:&_pinch.boundLayer1->_data 
                                  realSampleIndex:&leftSampleIndex 
                                  realData:&realData];
            // NSLog(@" %f sampleIndex: %d %f",_pinch.startPoint.x, _pinch.boundLayer1->_sampleIndex, offsetDeltaX);
            pt1_o.x += offsetDeltaX;
            _pinch.originalAlignedStartPoint.x += offsetDeltaX;
            if (singleTouch) { 
                pt2_o.x = pt1_o.x;
                _pinch.originalAlignedEndPoint.x = _pinch.originalAlignedStartPoint.x;
            } else { 
                [info.layer offsetX:_pinch.endPoint.x toDataOffset:&dataOffset sampleIndex:&_pinch.boundLayer2->_sampleIndex 
                               offsetDeltaX:&offsetDeltaX 
                               data:&_pinch.boundLayer2->_data 
                               realSampleIndex:&rightSampleIndex realData:&realData];
                pt2_o.x += offsetDeltaX;
                _pinch.originalAlignedEndPoint.x += offsetDeltaX;
                // NSLog(@" %f sampleIndex: %d %f",_pinch.endPoint.x, _pinch.boundLayer2->_sampleIndex, offsetDeltaX);
            }
        }
        
        // overlay
        CGRect rOvr = CGRectMake(rint(pt1_o.x),rint(pt1_o.y),rint( pt2_o.x - pt1_o.x),rint(pt2_o.y - pt1_o.y));
        if (!singleTouch) {
            _pinch.overlayLayer.frame = rOvr;
        }
        
        // left bound
        CGRect r1 = CGRectMake(rOvr.origin.x - _pinch.boundInset, 
                               rOvr.origin.y - _pinch.boundInset,
                               2 * _pinch.boundInset, 
                               rOvr.size.height + 2 * _pinch.boundInset); 
        _pinch.boundLayer1.frame = r1;
        [_pinch.boundLayer1 setNeedsDisplay];
        
        // right bound 
        if (_pinch.boundLayer2) { 
            CGRect r2 = r1;
            r2.origin.x = rOvr.origin.x + rOvr.size.width - _pinch.boundInset;
             _pinch.boundLayer2.frame = r2;
             [_pinch.boundLayer2 setNeedsDisplay];
        }
        // NSLog(@"%d-- %@ -- %@ --",_touchMeasureMode,_touchBoundLayer1,_touchBoundLayer2);
        
        if ([_graphDelegate respondsToSelector:@selector(graphPinchChanged:)]) { 
            [_graphDelegate graphPinchChanged:self];
        }
    }
}

- (void)getPinchMergedData:(INGraphSeriesData **)data sampleIndex:(NSInteger *)sampleIndex leftBound:(BOOL)leftBound {
    INGraphPinchLayer * layer = leftBound ? _pinch.boundLayer1 : _pinch.boundLayer2;
    *data = layer->_data;
    *sampleIndex = layer->_sampleIndex;
}

- (CGFloat)pinchYForValue:(CGFloat)value { 
    return (_pinch.mediumY - ((value) - _pinch.mediumV) * _pinch.scale) + _pinch.boundInset;  
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INGraphPinchLayer

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithGraph:(INGraph *)graph name:(NSString *)name mode:(NSInteger)mode {
    if (self = [super initWithGraph:graph name:name]) {
        _mode = mode;    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawInContext:(CGContextRef)context {
    [super drawInContext:context];
    CGRect r = self.bounds;
    
    if (_mode == MEASURE_LAYER_LBOUND || _mode == MEASURE_LAYER_RBOUND) {
        INGraphPinchState state = _graph.pinchState;
        if (state != INGraphPinchStateNone) { 
            if ([_graph.graphDelegate respondsToSelector:@selector(graph:drawPinchBoundInRect:context:bound:data:sampleIndex:)]) {
                UIGraphicsPushContext(context);
                [_graph.graphDelegate graph:_graph drawPinchBoundInRect:self.bounds context:context 
                                      bound:(state == INGraphPinchStateSingle) ? INGraphPinchSingleBound : 
                                            (_mode == MEASURE_LAYER_LBOUND ? INGraphPinchLeftBound : INGraphPinchRightBound) 
                                      data:_data sampleIndex:_sampleIndex];
                UIGraphicsPopContext();
            } else { 
                // CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
                // CGContextStrokeRect(context,self.bounds); 
                
                // этот код просто для примера. он практиечски беслолезен
                
                CGFloat x  = r.origin.x + floor(r.size.width/2) - 0.5;
                CGFloat y1 = r.origin.y;
                CGFloat y2 = r.origin.y + r.size.height;
                CGFloat delta = 1;
                
                CGPoint pt[4] = { 
                    CGPointMake(x,y1),
                    CGPointMake(x,y2),
                    CGPointMake(x+delta,y1),
                    CGPointMake(x+delta,y2),
                };
                
                CGContextSetLineWidth(context,1);
                CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
                CGContextStrokeLineSegments(context, pt, 2);
                CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
                CGContextStrokeLineSegments(context, pt + 2, 2);

                // top. bottom signs
                CGRect rTop = r;
                rTop.size.height = r.size.width;
                CGRect rBottom = rTop;
                rBottom.origin.y = r.origin.y + r.size.height - rBottom.size.height;
                CGContextAddEllipseInRect(context,rTop);
                CGContextAddEllipseInRect(context,rBottom);
                CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
                CGContextFillPath(context);
                
                // value sign
                // CGContextBeginPath(context);
                //CGContextAddEllipseInRect(context,valueRect);
                //CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
                //CGContextFillPath(context);
                
                // draw simple signs (for line)
                if (_data) {
                    CGRect rBullet = rBottom;
                    CGFloat value = [_data sampleAtIndex:_sampleIndex][0];
                    rBullet.origin.y = [_graph pinchYForValue:value] - rBullet.size.height / 2;
                    CGContextBeginPath(context);
                    CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
                    CGContextAddEllipseInRect(context,rBullet);
                    CGContextFillPath(context);
                }
            }
        }
    }
}

@end
