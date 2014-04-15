//!
//! @file INGraph.h
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

#import <UIKit/UIKit.h>

@class INGraphLayer, INGraph, INGraphOverlayLayer, INGraphPinchLayer;

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphSeriesData : NSObject { 
    CGFloat * _data;
    NSInteger _allocated,_filled,_valuesPerSample,_axisXOffset;
    
    BOOL _precalculated;
    struct _INGraphSeriesDataCalcInfo { 
        CGFloat minValue;
        CGFloat maxValue;
    } * _precalculatedInfo;
}

+ (id)dataWithValuesPerSample:(NSInteger)valuesPerSample;

@property(nonatomic,readonly) NSInteger sampleCount;
@property(nonatomic,readonly) NSInteger valuesPerSample;
@property(nonatomic) NSInteger axisXOffset;

- (CGFloat) minValueAndMaxValue:(CGFloat *)maxValue forRowFrom:(NSInteger)rangeFrom rowTo:(NSInteger)rangeTo;
- (CGFloat *)sampleAtIndex:(NSInteger)index;

- (void)clear;
- (void)deleteInRange:(NSRange)range;

- (CGFloat *)add:(const CGFloat *)samples count:(NSInteger)count; // length(samples) == count * valuesPerSample!!!
- (void)addFromData:(INGraphSeriesData *)data; 
- (void)addMergedData:(INGraphSeriesData *)data mergeSize:(NSInteger)mergeCount mergeModes:(const NSInteger *)mergeModes;

- (void)loadRandomDataMin:(CGFloat)min max:(CGFloat)max count:(NSInteger)count allowNoValue:(BOOL)allowNoValue;
- (void)dump;
- (void)dumpAsCArray;
- (NSString *)descriptionForSampleAtIndex:(NSInteger)index;
 
+ (BOOL)isNoValue:(CGFloat)value; // use NaN as NOT VALUE. MACRO: isnan(), NAN macro
+ (void)setNoValue:(CGFloat *)value count:(NSInteger)count; 

@end

//==================================================================================================================================
//==================================================================================================================================

enum {
   INGraphDataValueMin,
   INGraphDataValueMax,
   INGraphDataValueFirst,
   INGraphDataValueLast
}; // порядок не менять!!!! 
   // именно в таком порядке формируются годные данные для [INGraphSeriesData loadRandomDataMin..];
   // т.е. samples[0] <= samples[2], samples[3] <= samples[1]
   // отрисовывается и трактуется все тоже в таком порядке 

enum {
   INGraphMergeModeMin = INGraphDataValueMin,
   INGraphMergeModeMax = INGraphDataValueMax,
   INGraphMergeModeFirstValue = INGraphDataValueFirst,
   INGraphMergeModeLastValue = INGraphDataValueLast,
   INGraphMergeModeSum
};

enum { 
    INGraphLineStyle,
    INGraphBarStyle,
    INGraphCandleStyle,
    INGraphClassicBarStyle,
    // ---
    INGraphLastStyle
};

enum { 
    // Common
    INGraphStroke            = 1 << 0,
    INGraphGradientFill      = 1 << 1,
    INGraphColorFill         = 1 << 2,
    INGraphColorFill1        = 1 << 3,
    INGraphColorFill2        = 1 << 4,    
    INGraphMergeSamples      = 1 << 5,
    INGraphDontDraw          = 1 << 6,
    
    INGraphOverrideMinValue  = 1 << 7,   
    INGraphOverrideMaxValue  = 1 << 8,
    INGraphUseZeroValue      = 1 << 9,     
    
    // Line 
    INGraphLineApplyBezier   = 1 << 10,
    INGraphLineDiffFill      = 1 << 11
};

@interface INGraphSeriesParams : NSObject {
    CGFloat _layoutDiffPart;
    CGFloat _layoutSolidPart;
    CGFloat _layoutPaintPart;
    CGFloat _layoutPaintOffset;
    CGFloat _bandWorkPart, _bandMinWidth, _bandMaxWidth;
    CGFloat _strokeWidth;
    NSInteger _seriesIndex;
    NSInteger _options;
    UIColor * _strokeColor, * _barFirstFillColor, * _barLastFillColor;
    UIColor * _fillColor;
    NSInteger _graphStyle;
    CGGradientRef _fillGradient;
    const NSInteger * _mergeModes; 
    NSInteger _dataRowFrom;
    NSInteger _dataRowTo;
    CGFloat _minValue,_maxValue,_zeroValue;
}

@property(nonatomic) CGFloat layoutDiffPart;  // (0..1] 
@property(nonatomic) CGFloat layoutSolidPart; // [0..1)
@property(nonatomic) CGFloat layoutPaintPart;   // (0..1] 
@property(nonatomic) CGFloat layoutPaintOffset; // [0..1)

@property(nonatomic) CGFloat minValue; 
@property(nonatomic) CGFloat maxValue; 
@property(nonatomic) CGFloat zeroValue; 

@property(nonatomic) CGFloat bandWorkPart;    // (0..1] // процент закрашиваемой/отображаемой площади для баров, свечек
@property(nonatomic) CGFloat bandMinWidth;    // <= 0 - no limit
@property(nonatomic) CGFloat bandMaxWidth;    // <= 0 - no limit  
 
@property(nonatomic) NSInteger options;
@property(nonatomic) const NSInteger * dataMergeModes;
@property(nonatomic) NSInteger dataRowFrom;
@property(nonatomic) NSInteger dataRowTo;

@property(nonatomic,retain) UIColor * fillColor1;
@property(nonatomic,retain) UIColor * fillColor2;

//@property(nonatomic,retain,getter=fillColor1,setter=setFillColor1) UIColor * barFirstValueFillColor;
//@property(nonatomic,retain,getter=fillColor1,setter=setFillColor2) UIColor * barLastValueFillColor;
//@property(nonatomic,retain,getter=fillColor1,setter=setFillColor1) UIColor * candleGrowFillColor;
//@property(nonatomic,retain,getter=fillColor1,setter=setFillColor2) UIColor * candleFallFillColor;

@property(nonatomic) CGFloat strokeWidth;     // 0 is for thinnest line possible 
@property(nonatomic,retain) UIColor * strokeColor;   
@property(nonatomic,retain) UIColor * fillColor;
@property(nonatomic) CGGradientRef fillGradient;   

@property(nonatomic) NSInteger graphStyle;

@property(nonatomic) NSInteger seriesIndex; // чтобы знать, какая именно серия в графике передается в делегат 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INGraphOverlay : NSObject {
    INGraphOverlayLayer * _layer;
    INGraph * _graph;
    NSInteger _tag;    
}

@property(nonatomic,readonly) INGraph * graph; 
@property(nonatomic,readonly) CGRect frame;
@property(nonatomic) NSInteger tag;

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum { 
    INGraphPinchStateNone = 0,
    INGraphPinchStateSingle = 1,
    INGraphPinchStateDouble = 2
} INGraphPinchState;

typedef enum { 
    INGraphPinchSingleBound,
    INGraphPinchLeftBound,
    INGraphPinchRightBound
} INGraphPinchBound;

//==================================================================================================================================
//==================================================================================================================================

@protocol INGraphDelegate<NSObject>

@optional 

- (void)graph:(INGraph *)graph setupParams:(INGraphSeriesParams *)params forSeriesData:(INGraphSeriesData *)data;
- (void)graph:(INGraph *)graph drawOverlay:(INGraphOverlay *)overlay inContext:(CGContextRef)context;  

@optional 

- (void)graph:(INGraph *)graph drawPinchBoundInRect:(CGRect)rect context:(CGContextRef)context 
                                              bound:(INGraphPinchBound)bound
                                               data:(INGraphSeriesData *)data sampleIndex:(NSInteger)sampleIndex;
- (NSInteger)graphPinchSeriesIndex:(INGraph *)graph; // 0 is default
- (void)graphPinchChanged:(INGraph *)graph;
- (BOOL)graphWantsToStartPinch:(INGraph *)graph; // default is YES; 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INGraph : UIView {
    BOOL _debugMode;
    INGraphLayer   * _seriesSuperlayer;
    UIEdgeInsets     _seriesSuperlayerInsets;
    NSMutableArray * _seriesInfo;
    NSArray        * _seriesData;  
    BOOL             _seriesInfoPrecalculated;
    NSInteger        _fullAxisXLength; // precalculated info
    INGraphSeriesParams * _defaultParams;
    id<INGraphDelegate> _graphDelegate;
    NSMutableArray    * _overlays;
    BOOL _drawingEnabled, _drawingDelayed;
    
    // touch measure mode
    struct {
        BOOL enabled;
        INGraphPinchState state;  
        INGraphPinchLayer * overlayLayer, * boundLayer1, * boundLayer2;  
        INGraphPinchLayer * layer;
        CGFloat boundInset;
        CGPoint startPoint, endPoint, originalStartPoint, originalEndPoint;
        CGPoint originalAlignedEndPoint,originalAlignedStartPoint;
        UITouch * touch1, * touch2;
        
        CGFloat mediumV,mediumY,scale;
    } _pinch;
}

- (void)postInitInitialization; 
 
@property(nonatomic) BOOL debugMode;
@property(nonatomic) BOOL drawingEnabled;

@property(nonatomic) BOOL pinchEnabled;
@property(nonatomic) CGFloat pinchBoundInset;
@property(nonatomic,readonly) INGraphPinchState pinchState;
- (CGPoint)pinchOriginForLeftBound:(BOOL)leftBound alignedToValue:(BOOL)alignedToValue topAndBottom:(BOOL)topAndBottom;
- (void)getPinchMergedData:(INGraphSeriesData **)data sampleIndex:(NSInteger *)sampleIndex leftBound:(BOOL)leftBound;
- (CGFloat)pinchYForValue:(CGFloat)value;

@property(nonatomic,readonly) INGraphSeriesParams * defaultParams;
@property(nonatomic,assign) id<INGraphDelegate> graphDelegate;
@property(nonatomic,readonly) NSInteger fullAxisXLength;
@property(nonatomic) UIEdgeInsets seriesInsets; 

@property(nonatomic,readonly) NSArray * overlays;
- (void)setNeedsDisplayForOverlayWithTag:(NSInteger)tag;
- (INGraphOverlay *)addOverlayAboveSeries:(BOOL)above;
- (void)removeAllOverlays;

@property(nonatomic,readonly) CGRect seriesFrame; 
@property(nonatomic,retain) NSArray * seriesData; // array of INGraphSeriesData
- (void)setSeriesData:(NSArray *) seriesData updateUI:(BOOL)updateUI;
- (void)updateData:(BOOL)reloadParams;

@end
