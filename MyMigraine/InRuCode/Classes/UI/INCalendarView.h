//!
//! @file INCalendarView.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2011 InRu
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
#import "INPanel.h"

@class INCalendarView, _INCalendarWorkSheetInfo, _INCalendarWorkSheet;

// "standard" sizes - 324x324

extern const CGFloat INCalendarViewWidth;
extern const CGFloat INCalendarViewHeight;

//==================================================================================================================================
//==================================================================================================================================

typedef enum {
    // текущий (активный месяц)    
    INCalendarViewCurrentMonthCellColor,
    INCalendarViewCurrentMonthFontColor,
    
    // недоступные для выбора даты
    INCalendarViewUnselectableCellColor,
    INCalendarViewUnselectableFontColor,
    INCalendarViewUnselectableCurrentMonthFontColor, 
    
    // сетка 
    INCalendarViewDarkGridLineColor,
    INCalendarViewLightGridLineColor,

    // сегодняшний день
    INCalendarViewTodayFontColor,
    
    // предыдущие и последующие месяцы
    INCalendarViewOtherMonthFontColor, 
    INCalendarViewOtherMonthCellColor,
    
    // selection
    INCalendarViewSelectedFontColor,
    INCalendarViewSelectedShadowColor, // тень для текста 
    INCalendarViewSelectedCellColor,
    INCalendarViewSelectedEndpointCellColor1,     
    INCalendarViewSelectedEndpointCellColor2,     
    INCalendarViewSelectedEndpointCellColor3,
    INCalendarViewSelectedEndpointFrameColor,
    
    // header 
    INCalendarViewHeaderTopColor,
    INCalendarViewHeaderBottomColor,    
    INCalendarViewHeaderTitleFontColor,
    INCalendarViewHeaderTitleShadowColor,
    INCalendarViewHeaderWeekdayFontColor,
    INCalendarViewHeaderWeekdayShadowColor,
    INCalendarViewHeaderArrowColor,
    
    INCalendarViewLastColor   
} INCalendarViewThemeColor;


typedef enum { 
    //  высота ячейки (46 по умолчанию)
    INCalendarViewGeometryCellHeight,

    //  ширина ячейки (46 по умолчанию)
    INCalendarViewGeometryCellWidth,

    //  высота заголовка (46 по умолчанию)
    INCalendarViewGeometryTitleHeight,

    //  сколько дополнительных строк (1 строка = 1 неделя) показывается  для предыдущего месяца (0..7, 0 по умолчанию)
    INCalendarViewGeometryPrevMonthExtraRows,

    //  сколько дополнительных строк (1 строка = 1 неделя) показывается  для следующего месяца (0..7, 0 по умолчанию)
    INCalendarViewGeometryNextMonthExtraRows,
    
    INCalendarViewGeometryLastValue
} INCalendarViewGeometryValue;

//==================================================================================================================================
//==================================================================================================================================

typedef enum {
    INCalendarViewSingleSelection,    
    INCalendarViewRangeSelection    
} INCalendarViewSelectionMode;

typedef union __attribute__((packed)) {
    struct { 
        NSUInteger day   : 8;
        NSUInteger month : 8;
        NSUInteger year  : 16;
    } v;
    NSUInteger value;
} INCalendarViewYMD;

//==================================================================================================================================
//==================================================================================================================================

@interface INCalendarSelectionItem : NSObject { 
    INCalendarViewYMD _ymd1, _ymd2;
    NSCalendar * _calendar;
}

@property (nonatomic,readonly) NSDate * dateFrom;
@property (nonatomic,readonly) NSDate * dateTo;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INCalendarHeaderView : INPanel  { 
    INCalendarView * _calendarView;
    UILabel * _titleLabel;
    UIButton * _prevButton, * _nextButton;
    UILabel * _dowLabels[7];
    _INCalendarWorkSheetInfo * _sheetInfo;
    UIColor * _colors[3]; 
}

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum {
    INCalendarViewPrevMonth,
    INCalendarViewCurrentMonth,
    INCalendarViewNextMonth
} INCalendarViewMonthType;

typedef struct {
	NSInteger left:1;
	NSInteger top:1;
	NSInteger right:1;
	NSInteger bottom:1;
} INCalendarCellLocation;

typedef struct {
    // сведения о ячейке, включая дату и прочие характеристики
    INCalendarViewYMD ymd;
    BOOL isSelected;    
    BOOL isSelectedRangeHead;    
    BOOL isSelectedRangeTail;    
    BOOL isToday;    
    INCalendarViewMonthType monthType;  
    BOOL isDisabled;

	INCalendarCellLocation location; // расположение в календаре
	INCalendarCellLocation selLocation; // расположение в выделенном участке


    // фон и фрейм для ячейки. Если цвет не задан, то по умолчанию ячейка красится общим фоном панели (INCalendarViewCurrentMonthCellColor)
    UIColor * cellBackgroundColor;
    CGRect cellBackgroundRect;
    
    // если ячейка выделена и является началом или концом выделения (drawSelectionEndpoint == YES), 
    // то в качестве фона рисуются меркеры начала и конца выделенного диапазона 
    BOOL drawSelectionEndpoint;
    
    // надпись "сегодня". 
    NSString * todayMarkerText; // если обнулить - то ничего не будет выведено
    CGRect todayMarkerRect;
    UIColor * todayMarkerTextColor;
    UIColor * todayMarkerTextShadowColor;
    UIFont * todayMarkerFont;
    
    // Основная надпись
    NSString * titleText; // если обнулить - то ничего не будет выведено
    UIColor * titleTextShadowColor;
    UIColor * titleTextColor;
    UIFont * titleFont;
    CGRect titleRect;    

} INCalendarCellDrawInfo;

//==================================================================================================================================
//==================================================================================================================================

@protocol INCalendarViewDelegate<NSObject> 
@optional
  
- (void)incalendarViewDidChangeSelection:(INCalendarView *)calendarView;
- (void)incalendarView:(INCalendarView *)calendarView didTouchDisabledDate:(NSDate *)date;

// не забыть вызвать  updateThemeColors
- (UIColor *)incalendarView:(INCalendarView *)calendarView themeColor:(INCalendarViewThemeColor)colorIndex;

// не забыть вызвать  updateGeometry
- (CGFloat)incalendarView:(INCalendarView *)calendarView geometryValue:(INCalendarViewGeometryValue)valueIndex;

// вызывается перед отрисовкой ячейки. Если вернуть YES то своя отрисовка вызвана не будет
- (BOOL)incalendarView:(INCalendarView *)calendarView willDrawCell:(INCalendarCellDrawInfo *)cellDrawInfo context:(CGContextRef)context;

// вызывается после отрисовки ячейки
- (void)incalendarView:(INCalendarView *)calendarView didDrawCell:(INCalendarCellDrawInfo *)cell context:(CGContextRef)context;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INCalendarView : UIView { 
    id<INCalendarViewDelegate> _delegate;
    _INCalendarWorkSheetInfo * _currentMonthInfo;
    _INCalendarWorkSheet * _currentSheet;
    _INCalendarWorkSheet * _comingSheet;
    INCalendarHeaderView * _headerView;
    UIView  * _sheetPlaceholder;
    UIColor * _disabledCellColor;

    NSCalendar * _calendar;
    struct _INCalendarViewMetrics {
        NSInteger cellHCount, cellVCount;
        NSInteger prevMonthExtraRows, nextMonthExtraRows;
        CGFloat cellWidth, cellHeight;
        CGFloat titleHeight;
    } _metrics;
    INCalendarViewSelectionMode _selectionMode;
    NSMutableSet * _selections;
    
    INCalendarViewYMD _minYMD, _maxYMD;
    NSDate * _minDateAllowed, * _maxDateAllowed;
    
    UIColor * _colors[INCalendarViewLastColor];
    BOOL _isTransitioning;
    NSInteger _tracking1;
    NSInteger _slideTrackingCellIndex;
    NSString * _todayText;
    
}

@property (nonatomic,assign) IBOutlet id<INCalendarViewDelegate> delegate;

// selections 
@property (nonatomic) INCalendarViewSelectionMode selectionMode;

@property (nonatomic, readonly) NSSet * selections;
- (void)setSelectionFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)setSelectedDate:(NSDate *)date;

@property (nonatomic, retain) NSString * todayText;

// Theming
- (void)updateThemeColors;
- (UIColor *)defaultThemeColor:(INCalendarViewThemeColor)colorIndex;

// Geometry 
- (void)updateGeometry;
- (CGFloat)defaultGeometryValue:(INCalendarViewGeometryValue)valueIndex;

// header access
@property (nonatomic, readonly) INCalendarHeaderView * headerView;

// 
@property (nonatomic, retain) NSDate * minDateAllowed;
@property (nonatomic, retain) NSDate * maxDateAllowed;
- (void)showDate:(NSDate *)date animated:(BOOL)animated;


@end
