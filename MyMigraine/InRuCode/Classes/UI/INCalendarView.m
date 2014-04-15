//!
//! @file INCalendarView.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2011 Inru
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

#import "INCalendarView.h"
#import "INCommonTypes.h"
#import "INGraphics.h"

//#warning mk:todo:low: сделать черную рамку вокруг выделенной даты ниже на пиксель (только при INCalendarViewSingleSelection) 

const CGFloat INCalendarViewWidth  = 324;
const CGFloat INCalendarViewHeight = 324;

enum {
    CellSheetPrevMonth = INCalendarViewPrevMonth, 
    CellSheetCurrent   = INCalendarViewCurrentMonth, 
    CellSheetNextMonth = INCalendarViewNextMonth
};

typedef struct {
    INCalendarViewYMD ymd;
    BOOL isToday;
    BOOL isPreToday_notUsed, isAfterToday_notUsed;
    NSInteger sheet;
    BOOL isPrevMonth;
    BOOL isDisabled;
    BOOL isSelStart;
    BOOL isSelected;
    BOOL isSelEnd;
    NSUInteger cellIndex;    
} _CellInfo;

//==================================================================================================================================
//==================================================================================================================================

@interface INCalendarView()

- (void)selectSheetForDate:(NSDate *)date animated:(BOOL)animated;
- (void)moveForward:(BOOL)forward;
- (void)updateCurrentSheet:(BOOL)fullReplace;
- (void)handleTouchToCell1:(_CellInfo)c1 cell2:(_CellInfo)c2;
- (void)resetTracking;
- (void)touchedInactive:(_CellInfo)c2;

@property(nonatomic,retain) _INCalendarWorkSheetInfo * currentMonthInfo;
@property(nonatomic,readonly) struct _INCalendarViewMetrics metrics;
@property(nonatomic,readonly) INCalendarViewYMD minYMD;
@property(nonatomic,readonly) INCalendarViewYMD maxYMD;

- (NSString *)effectiveTodayString;
- (UIColor *)themeColor:(INCalendarViewThemeColor)colorIndex;
- (CGFloat)geometryValue:(INCalendarViewGeometryValue)valueIndex;

@end

//==================================================================================================================================
//==================================================================================================================================

CG_INLINE NSComparisonResult _CompareYMD(INCalendarViewYMD ymd1, INCalendarViewYMD ymd2) { 
    return INCompareInt(ymd1.value,ymd2.value);
}

//----------------------------------------------------------------------------------------------------------------------------------

static INCalendarViewYMD _DateToYMD(NSDate * date, NSCalendar * calendar) { 
    NSDateComponents * ct = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | 
           NSDayCalendarUnit fromDate:date]; // test inru_incDay:-2]];
    INCalendarViewYMD result = {
        .v.year = ct.year,
        .v.month = ct.month,
        .v.day = ct.day
    };
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

static NSDate * _YMDToDate(INCalendarViewYMD ymd, NSCalendar * calendar) {
    NSDateComponents * c2 = [[NSDateComponents new] autorelease];
    [c2 setYear: ymd.v.year];
    [c2 setMonth: ymd.v.month];
    [c2 setDay: ymd.v.day];
    NSDate * date = [calendar dateFromComponents:c2];
    return date;    
}

//----------------------------------------------------------------------------------------------------------------------------------

//static NSInteger _YMDDistance(INCalendarViewYMD ymd1, INCalendarViewYMD ymd2, NSCalendar * calendar) {
//   return lround([_YMDToDate(ymd1,calendar) timeIntervalSinceDate:_YMDToDate(ymd2,calendar)] / (24.0 * 3600));   
//} 

//==================================================================================================================================
//==================================================================================================================================

@implementation INCalendarSelectionItem 

+ (id)itemWithYMD:(INCalendarViewYMD)ymd1 ymd2:(INCalendarViewYMD)ymd2 calendar:(NSCalendar *)calendar { 
    INCalendarSelectionItem * result = [[INCalendarSelectionItem new] autorelease];
    assert(_CompareYMD(ymd1,ymd2) <=0);
    result->_ymd1 = ymd1;
    result->_ymd2 = ymd2;
    result->_calendar = [calendar retain];
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)dateFrom { 
    return _YMDToDate(_ymd1, _calendar);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)dateTo { 
    return _YMDToDate(_ymd2, _calendar);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_calendar release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)markSelectedCells:(_CellInfo *)cellInfoArray42 length:(NSInteger)length { 
    if (_CompareYMD(_ymd2,cellInfoArray42[0].ymd) < 0 || _CompareYMD(cellInfoArray42[length-1].ymd,_ymd1) < 0) { 
        // не пересекаются
    } else { 
        int index1 = 0;
        for (int i = 0; i < length; i++) { 
             NSInteger cmp = _CompareYMD(_ymd1,cellInfoArray42[i].ymd);
            if (cmp <= 0) {
                index1 = i;
                if (cmp == 0) { 
                    cellInfoArray42[i].isSelStart = YES;
                }
                break;
            }
        }
        for (int i = index1; i < length; i++) {
            NSInteger cmp = _CompareYMD(cellInfoArray42[i].ymd,_ymd2); 
            if (cmp <= 0) {
                cellInfoArray42[i].isSelected = YES;
                if (cmp == 0) { 
                    cellInfoArray42[i].isSelEnd = YES;
                }
            } else {
                break;
            }
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INCalendarViewYMD) ymd1 { 
    return _ymd1;
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (INCalendarViewYMD) ymd2 { 
    return _ymd2;
} 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface _INCalendarWorkSheetInfo : NSObject {
@package
    NSInteger _year, _month, _daysInMonth, _dowOfFirstMonthDay; //, _dowLastMonthDay;
    // NSInteger _daysInPrevMonth;
    NSInteger _weekday2CellMap[8]; // we use only 1...7
    NSInteger _rowCount;
    NSInteger _prevMonthExtraRowCount, _nextMonthExtraRowCount;
    NSInteger _cell2WeekdayMap[7];
    _CellInfo * _cells;
    NSInteger _firstWeekdayIndex;
    NSDate * _date;
    NSCalendar * _calendar;
    INCalendarViewYMD _lastDayOfPrevMonth;
    INCalendarViewYMD _firstDayOfNextMonth;
    BOOL _canGoToPrevMonth, _canGoToNextMonth;
    NSInteger _nextMonthCellRow; // 4 or 5 + extra values
}

@end

//==================================================================================================================================

@implementation _INCalendarWorkSheetInfo

- (id)initWithDate:(NSDate *)date calendar:(NSCalendar *)calendar extraRowCountForPrevMonth:(NSUInteger)prevMonthExtraRows nextMonth:(NSUInteger)nextMonthExtraRows { 
    self = [super init];
    if (self != nil) {
        NSParameterAssert(date);
        
        _date = [date retain];
        _calendar = [calendar retain];
        _rowCount = 6 + nextMonthExtraRows + prevMonthExtraRows;
        _prevMonthExtraRowCount = prevMonthExtraRows;
        _nextMonthExtraRowCount = nextMonthExtraRows;
        _cells = malloc(sizeof(_CellInfo) * 7 * _rowCount);
        
        NSDateComponents * components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit |  
                                            NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:date];
        _year = components.year;
        _month = components.month;
        NSInteger day = components.day;
        NSInteger wday = components.weekday;
        _daysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
        _dowOfFirstMonthDay = (((wday - 1) - (day - 1) + 7 * 20 /* 49*/) % 7) + 1;
        
        // сколько дней в предыдущем месяце, номер месяца и года
        NSDateComponents * c2 = [[NSDateComponents new] autorelease];
        [c2 setDay:-components.day];
        NSDate * d2 = [calendar dateByAddingComponents:c2 toDate:date options:0];
        NSDateComponents * compPrevMonth = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:d2];
        _lastDayOfPrevMonth = _DateToYMD(d2, calendar);  

        // следующий год 
        _firstDayOfNextMonth = (INCalendarViewYMD){
            .v.year = _year,
            .v.month = _month + 1,
            .v.day = 1
        };      
        if (_firstDayOfNextMonth.v.month == 13) {
           _firstDayOfNextMonth.v.month = 1;
           _firstDayOfNextMonth.v.year++;
        }
    
        // сегодня
        INCalendarViewYMD today = _DateToYMD([NSDate date], calendar);    

        _firstWeekdayIndex = calendar.firstWeekday -1;
        for (int i = 1; i < 8; i++) {
            int cellIndex = ((i - _firstWeekdayIndex-1) + 28) % 7;
            _weekday2CellMap[i]   = cellIndex;
            _cell2WeekdayMap[cellIndex] = i;
        }
        
        bzero(_cells,sizeof(_CellInfo) * _rowCount * 7);
        NSInteger currentSheetOffset = _weekday2CellMap[_dowOfFirstMonthDay] + _prevMonthExtraRowCount * 7;
        for (int i = 0; i < _rowCount * 7; i++) { 
            _cells[i].cellIndex = i;
            if (i < currentSheetOffset) { 
                _cells[i].ymd.v.year  = compPrevMonth.year;
                _cells[i].ymd.v.month = compPrevMonth.month;
                _cells[i].ymd.v.day   = compPrevMonth.day + i - currentSheetOffset + 1;
                _cells[i].sheet = CellSheetPrevMonth;
            } else {
                NSInteger day = i - currentSheetOffset + 1;
                if (day <= _daysInMonth) {  
                    _cells[i].ymd.v.year  = _year;
                    _cells[i].ymd.v.month = _month;
                    _cells[i].ymd.v.day   = day;
                    _cells[i].sheet = CellSheetCurrent;
                } else {
                    _cells[i].ymd.v.year  = _firstDayOfNextMonth.v.year;
                    _cells[i].ymd.v.month = _firstDayOfNextMonth.v.month;
                    _cells[i].ymd.v.day   = day - _daysInMonth;
                    // _cells[i].isCurrentSheet = YES;
                    if (_cells[i].ymd.v.day == 1) { 
                        _nextMonthCellRow = i / 7;
                    }
                    _cells[i].sheet = CellSheetNextMonth;
                }
            }
            int cmp = _CompareYMD(today, _cells[i].ymd);
            if (cmp < 0) {
                _cells[i].isPreToday_notUsed = YES;      
            } else 
            if (cmp > 0) {
                _cells[i].isAfterToday_notUsed = YES;      
            } else { 
                _cells[i].isToday = YES;      
            } 
        }
        
        //_dowFirstMonthDay = _IncDOW(components.weekday, -components.day);
        //_dowLastMonthDay = _IncDOW(_dowFirstMonthDay,_daysInMonth);
        //_daysInPrevMonth = [[date inru_incMonth:-1] inru_daysInThisMonth];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateWithNewActiveMonth:(INCalendarViewYMD)ymd {
    NSInteger v = ymd.v.year * 100 + ymd.v.month; 
    for (int i = 0; i < _rowCount * 7; i++) {
         switch (INCompareInt(_cells[i].ymd.v.year * 100 + _cells[i].ymd.v.month, v)) { 
             case NSOrderedAscending:
                 _cells[i].sheet = CellSheetPrevMonth;
                 break;
             case NSOrderedSame:
                 _cells[i].sheet = CellSheetCurrent;
                 break;
             case NSOrderedDescending:
                 _cells[i].sheet = CellSheetNextMonth;
                 break;
             default:
                 NSAssert(0,@"mk_46b659f9_3cb2_4322_bc0a_7eae12bfc943");
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)dateIsVisible:(NSDate *)date { 
    INCalendarViewYMD ymd = _DateToYMD(date, _calendar);
    return (_cells[0].ymd.value <= ymd.value) && (ymd.value <= _cells[_rowCount * 7 - 1].ymd.value);       
}
//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_date release];
    [_calendar release];
    free(_cells);
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (_CellInfo)infoForCellOfIndex:(NSInteger)cellIndex { 
    NSParameterAssert(0 <= cellIndex && cellIndex < _rowCount * 7);
    return _cells[cellIndex]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSArray *)weekDays { 
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = _calendar.locale;
    NSMutableArray * a = [NSMutableArray arrayWithArray:[dateFormatter shortStandaloneWeekdaySymbols]];
   [dateFormatter release];
   if (_firstWeekdayIndex > 0) {
       for (int i = 0; i < _firstWeekdayIndex; i++) { 
           [a addObject:[a objectAtIndex:0]];
           [a removeObjectAtIndex:0];
       }
   }
   return a;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)yyyymmAsString { 
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.locale = _calendar.locale;
    dateFormatter.dateFormat = @"LLLL yyyy";
    NSString * result = [dateFormatter stringFromDate:_date];
    [dateFormatter release];  
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applySelections:(NSSet *)selections { 
    for (int i = 0; i < _rowCount * 7; i++) { 
        _cells[i].isSelected = NO;
        _cells[i].isSelStart = NO;
        _cells[i].isSelEnd = NO;
    }
    for (INCalendarSelectionItem * selection in selections) { 
        [selection markSelectedCells:_cells length:_rowCount * 7];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applyDisabledState:(INCalendarViewYMD)minYMD maxYMD:(INCalendarViewYMD)maxYMD {
    for (int i = 0; i < _rowCount * 7; i++) { 
        _cells[i].isDisabled = NO;
        if (minYMD.value != 0 && _cells[i].ymd.value < minYMD.value) { 
            _cells[i].isDisabled = YES;
        } else 
        if (maxYMD.value !=0 && _cells[i].ymd.value > maxYMD.value) { 
            _cells[i].isDisabled = YES;
        } 
    }
    _canGoToPrevMonth = (minYMD.value == 0) || (minYMD.value <= _lastDayOfPrevMonth.value);  
    _canGoToNextMonth = (maxYMD.value == 0) || (maxYMD.value >= _firstDayOfNextMonth.value);  
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface _TouchProcessor : NSObject {
@package  
    UITouch * _touch1, * _touch2;
    UIView * _view;
}

@end

@implementation _TouchProcessor; 

- (NSInteger)updateTouchesFromEvent:(UIEvent *)event { 
    NSInteger countOther = 0; // всего актуальных касаний (может быть больше двух)
    
    // проход первый, проверяем, сохранились ли старые касания
    BOOL f1 = NO, f2 = NO;
    for (UITouch * touch in [event touchesForView:_view]) {
        if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) { 
            continue;
        }
        if (touch == _touch1) { 
            f1 = YES;
        } else 
        if (touch == _touch2) { 
            f2 = YES;
        } else {
            countOther++;
        }
    }
    
    NSInteger result = 0;
    if (f1) { 
        result++;
    } else {
        _touch1 = nil;
    }
    if (f2) { 
        result++;
    } else {
        _touch2 = nil;
    }
    
    // если добавились новые тачи - считаем их
    if (result < 2 && countOther ) {
        for (UITouch * touch in [event touchesForView:_view]) {
            if (touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled) { 
                continue;
            }
            if (touch != _touch1 && touch != _touch2) { 
                if (!_touch1) { 
                    _touch1 = touch;
                } else {
                    _touch2 = touch;
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

- (void)handleTouchesWithEvent:(UIEvent *)event {
    [self updateTouchesFromEvent:event];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reset { 
   _touch1 = _touch2 = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)count { 
   NSInteger i =0;
   if (_touch1) { 
      i++;
   }
   if (_touch2) { 
      i++;
   }
   return i;
}
     
@end

//==================================================================================================================================
//==================================================================================================================================

@interface _INCalendarWorkSheet : UIView {
    struct _INCalendarViewMetrics _metrics;
    INCalendarView * _calendarView;
    _INCalendarWorkSheetInfo * _sheetInfo;  
    UIImage * _selectionImage; // , *_todayOverlayImage;
    _CellInfo _startTouch;
    _TouchProcessor * _touchProcessor;    
}

@property (nonatomic,retain)  UIImage * selectionImage;
@property (nonatomic,retain)  _INCalendarWorkSheetInfo * sheetInfo; 

@end

//==================================================================================================================================

@implementation _INCalendarWorkSheet

@synthesize selectionImage = _selectionImage;
@synthesize sheetInfo = _sheetInfo;

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)panelForCalendarView:(INCalendarView *)cv sheetInfo:(_INCalendarWorkSheetInfo *)info { 
    _INCalendarWorkSheet * result = [[[_INCalendarWorkSheet alloc] initWithFrame:CGRectMake(0,0,200,200)] autorelease];
    result->_calendarView = cv;
    result.sheetInfo = info;
    result->_metrics = cv.metrics;
    result->_touchProcessor = [_TouchProcessor new]; 
    result->_touchProcessor->_view = result;
    if (cv.selectionMode != INCalendarViewSingleSelection) { 
        result.multipleTouchEnabled = YES;
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_sheetInfo release];
    [_touchProcessor release];
    [_selectionImage release];
    // [_todayOverlayImage release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)selectionImage { 
    if (!_selectionImage) {
         CGSize sz = CGSizeMake(_metrics.cellWidth,_metrics.cellHeight);
         INGraphicsBeginImageContext(sz);
         CGFloat c[30];
         UIColor * color1 = [_calendarView themeColor:INCalendarViewSelectedEndpointCellColor1];
         UIColor * color2 = [_calendarView themeColor:INCalendarViewSelectedEndpointCellColor2]; 
         UIColor * color3 = [_calendarView themeColor:INCalendarViewSelectedEndpointCellColor3]; 

         CGFloat hGradient =0, hFill = 0, fillOffset = 0;
         if (color1) {
             // if (!color2) {
                 // рисуем сплошной фон
             //    hFill = sz.height;
             //} else {
                 //if (!color3) { 
                     // рисуем сплошной градиент
                    // hGradient = sz.height;
                 //} else {
                     hGradient = sz.height / 2;
                     hFill = sz.height / 2;
                     fillOffset = hGradient;
                 //}
             //}
             
             CGContextRef context = UIGraphicsGetCurrentContext();             
             if (hGradient) { 
                 [UIColor inru_colorsToComponents:c, color1, color2, nil];        
                 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                 CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, c, nil, 2);

                 CGContextDrawLinearGradient(context, gradient, 
                                        CGPointMake(0, 0),  
                                        CGPointMake(0, hGradient),0);
                 CGGradientRelease(gradient);   
                 CGColorSpaceRelease(colorSpace);
            }
            if (hFill) { 
                 CGContextSetFillColorWithColor(context, color3.CGColor);
                 CGContextFillRect(context,CGRectMake(0,fillOffset, sz.width,hFill));
            }
        }    
        _selectionImage = [UIGraphicsGetImageFromCurrentImageContext() retain]; 
        UIGraphicsEndImageContext();                         
    }
    return _selectionImage;
}

//----------------------------------------------------------------------------------------------------------------------------------

/*
- (UIImage *)todayOverlayImage { 
    if (!_todayOverlayImage) {
         CGRect r = { .size = CGSizeMake(_metrics.cellWidth,_metrics.cellHeight) };
         
         INGraphicsBeginImageContext(r.size);
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSetFillColorWithColor(context, [UIColor inru_colorFromRGBA:0x00000010].CGColor);
         CGContextFillRect(context,r);
         
         CGContextSetShadowWithColor (context, CGSizeMake(0,0), 20, [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor);
         CGContextSetLineWidth(context, 20);
         CGContextStrokeRect(context, CGRectInset(r,-10,-10));

         _todayOverlayImage = [UIGraphicsGetImageFromCurrentImageContext() retain]; 
         UIGraphicsEndImageContext();                         
    }
    return _todayOverlayImage;
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect { 
    CGRect r = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 
    CGContextSetFillColorWithColor(context, [_calendarView themeColor:INCalendarViewCurrentMonthCellColor].CGColor);
    CGContextFillRect(context, rect);
    
    struct { 
        CGRect frame;
        UIColor * color; 
    } postProcess[10] = {};
    NSInteger postProcessIndex = 0;     

    // dray grid
    CGMutablePathRef pathGray  = CGPathCreateMutable();
    CGMutablePathRef pathLight = CGPathCreateMutable();
    for (int i = 0; i <=_metrics.cellVCount; i++) { 
        CGFloat y = i * _metrics.cellHeight + 0.5;
        CGPathMoveToPoint(pathGray, nil, 1, y);
        CGPathAddLineToPoint(pathGray, nil, r.size.width, y);
        CGPathMoveToPoint(pathLight, nil, 0, y+1);
        CGPathAddLineToPoint(pathLight, nil, r.size.width, y+1);
    }
    for (int i = 0; i <= _metrics.cellHCount; i++) { 
        CGFloat x = i * _metrics.cellWidth + 0.5;
        CGPathMoveToPoint(pathGray, nil, x+1, 0);
        CGPathAddLineToPoint(pathGray, nil, x+1, r.size.height-1);
        CGPathMoveToPoint(pathLight, nil, x, 1);
        CGPathAddLineToPoint(pathLight, nil, x, r.size.height);    
    }
    CGContextSetStrokeColorWithColor(context, [_calendarView themeColor:INCalendarViewLightGridLineColor].CGColor);
    CGContextBeginPath(context);
    CGContextAddPath(context, pathLight);
    CGContextStrokePath(context);
    CGPathRelease(pathLight);
    CGContextSetStrokeColorWithColor(context, [_calendarView themeColor:INCalendarViewDarkGridLineColor].CGColor);
    CGContextBeginPath(context);
    CGContextAddPath(context, pathGray);
    CGContextStrokePath(context);
    CGPathRelease(pathGray);
    
    // draw cell-by-cell 
    UIFont * font = [UIFont boldSystemFontOfSize:24];
    UIColor * activeColor   = [_calendarView themeColor:INCalendarViewCurrentMonthFontColor];
    UIColor * activeNextMonthColor = [_calendarView themeColor:INCalendarViewOtherMonthFontColor];

	int selHeadOffset = 0;
	int selTailOffset = _metrics.cellVCount*_metrics.cellHCount - 1;
	for(int i = 0; i <= selTailOffset; i++) {
		_CellInfo cellInfo = [_sheetInfo infoForCellOfIndex:i];

		if (cellInfo.isSelStart) {
			selHeadOffset = i;
		}
		if (cellInfo.isSelEnd) {
			selTailOffset = i;
			break;
		}
	}

	int cellIndex = 0;
    for (int y = 0; y <_metrics.cellVCount; y++) { 
        for (int x = 0; x < _metrics.cellHCount; x++) { 
        
            // cellRect - клетка с чистым содержимым, годным чтобы закрасить клетку не трогая линий
            CGRect cellRect = CGRectMake(x * _metrics.cellWidth + 2, y * _metrics.cellHeight + 2,
                                         _metrics.cellWidth-2, _metrics.cellHeight-2);
            
            // годный для рисования рамки вокруг ячейки 
            CGRect selFrameRect = INRectInset(cellRect,-0.5,-1.5,-1.5,-0.5);
           
            // закраска и светлых и темных полосок  
            CGRect fillNoLightNoDarkFrame = INRectInset(cellRect,0,-2,-2,0);
            
            // точка отрисовка сплошныж оверлееев
            CGPoint overlayOrigin = CGPointMake(cellRect.origin.x-1,cellRect.origin.y-1);

            if (x == 0) { 
                fillNoLightNoDarkFrame = INRectInset(fillNoLightNoDarkFrame, -2, 0, 0, 0);
                selFrameRect = INRectInset(selFrameRect, -1, 0, 0, 0);
            }
            if (y == _metrics.cellVCount-1) { 
                fillNoLightNoDarkFrame = INRectInset(fillNoLightNoDarkFrame, 0, 0, 0, -2);
                selFrameRect = INRectInset(selFrameRect, 0, 0, 0, -1);
            }
            
            _CellInfo cellInfo = [_sheetInfo infoForCellOfIndex:cellIndex];

	        INCalendarCellLocation selLocation = {0};
	        if (cellInfo.isSelected) {
		        selLocation.left = (x == 0 || cellInfo.isSelStart);
		        selLocation.right = (x == _metrics.cellHCount - 1 || cellInfo.isSelEnd);

		        selLocation.top = (y == 0
				        || (cellIndex >= selHeadOffset
						        && cellIndex < selHeadOffset + _metrics.cellHCount));

		        selLocation.bottom = (y == _metrics.cellVCount - 1
				        || (cellIndex >= selTailOffset - _metrics.cellHCount
						        && cellIndex < selTailOffset));
	        }

            // чистим фон (линии просвечивают)
            //if (cellInfo.isToday) {
            //    CGContextSetFillColorWithColor(context,self.backgroundColor.CGColor);
            //    CGContextFillRect(context, INRectInset(cellRect,0,-1,-1,0));
            //}
            INCalendarCellDrawInfo drawInfo = {
                .titleTextShadowColor = [UIColor whiteColor],
                .ymd = cellInfo.ymd,
                .isSelected = cellInfo.isSelected,
                .isSelectedRangeHead = cellInfo.isSelStart,    
                .isSelectedRangeTail = cellInfo.isSelEnd,
                .isToday             = cellInfo.isToday,
                .monthType           = cellInfo.sheet,
                .isDisabled          = cellInfo.isDisabled,

		        .location.left       = (x == 0),
		        .location.top        = (y == 0),
		        .location.right      = (x == _metrics.cellHCount-1),
		        .location.bottom     = (y == _metrics.cellVCount-1),

		        .selLocation         = selLocation,
            };
            
            //  готовим background + shadow color
            {
                UIColor * fillColor = nil;
                CGRect rectToFill = cellRect;
                if (cellInfo.isSelected) {
                    if (cellInfo.isSelStart || cellInfo.isSelEnd) {
                        drawInfo.drawSelectionEndpoint = YES;
                    } else {
                        fillColor = [_calendarView themeColor:INCalendarViewSelectedCellColor];
                    }
                    rectToFill = fillNoLightNoDarkFrame;
                    drawInfo.titleTextShadowColor = [_calendarView themeColor:INCalendarViewSelectedShadowColor];
                } else
                //if (cellInfo.isToday) { 
                    // fillColor = _calendarView.todayCellColor;
                    // rectToFill = INRectInset(cellRect,0 /* -1 */,-1,-1,0);
                //} else 
                if (cellInfo.isDisabled) { 
                    fillColor = [_calendarView themeColor:INCalendarViewUnselectableCellColor];
                    rectToFill = INRectInset(cellRect,0,-1,-1,0);
                    
                } else 
                if (cellInfo.sheet != CellSheetCurrent) { 
                    fillColor = [_calendarView themeColor:INCalendarViewOtherMonthCellColor];
                    rectToFill = INRectInset(cellRect,1,1,1,1);
                }
                drawInfo.cellBackgroundColor = fillColor;
                drawInfo.cellBackgroundRect  = rectToFill;
            }

            // готовим напись today 
            if (cellInfo.isToday) {
                //[self.todayOverlayImage drawAtPoint:overlayOrigin];
                // #warning dddd 
                NSString * text = _calendarView.effectiveTodayString;
                drawInfo.todayMarkerText = text;
                if (text.length) { 
                    drawInfo.todayMarkerFont = [UIFont boldSystemFontOfSize:9];
                    CGRect r = { .size = [text sizeWithFont:drawInfo.todayMarkerFont] };
                    r.origin.x = cellRect.origin.x + round((cellRect.size.width - r.size.width) / 2);
                    r.origin.y = cellRect.origin.y + round(cellRect.size.height - r.size.height * 1.1);
                    drawInfo.todayMarkerRect = r;
                    drawInfo.todayMarkerTextShadowColor = drawInfo.titleTextShadowColor;
                    if (cellInfo.isSelected) { 
                        drawInfo.todayMarkerTextColor = [_calendarView themeColor:INCalendarViewSelectedFontColor]; 
                    } else { 
                        drawInfo.todayMarkerTextColor = [_calendarView themeColor:INCalendarViewTodayFontColor]; 
                    }
                }
            }
            
            // prepare text
            { 
                NSString * text = [NSString stringWithFormat:@"%d",cellInfo.ymd.v.day];
                CGRect rt;
                rt.size = [text sizeWithFont:font];
                rt.origin.x = cellRect.origin.x + lround((cellRect.size.width  - rt.size.width) / 2);
                rt.origin.y = cellRect.origin.y + lround((cellRect.size.height  - rt.size.height) / 2);
                drawInfo.titleText = text;
                drawInfo.titleRect = rt;
                drawInfo.titleFont = font;
            }

            if (cellInfo.isDisabled) {
                drawInfo.titleTextShadowColor = nil; 
            }

            // text - second pass
            {
                UIColor * textColor = nil;
                if (cellInfo.isSelected /* || cellInfo.isToday */) {
                    textColor = [_calendarView themeColor:INCalendarViewSelectedFontColor]; // [UIColor whiteColor];
                    // rt.origin.y+=2;
                } else {
                    if (cellInfo.isDisabled) {
                        if (cellInfo.sheet == CellSheetCurrent) {
                            textColor = [_calendarView themeColor:INCalendarViewUnselectableCurrentMonthFontColor];
                        } else { 
                            textColor = [_calendarView themeColor:INCalendarViewUnselectableFontColor];
                        }
                    } else { 
                        if (cellInfo.sheet == CellSheetCurrent) { 
                            textColor = activeColor;
                        } else { 
                            textColor = activeNextMonthColor;
                        }
                    }
                }
                drawInfo.titleTextColor = textColor;
            }
            
            BOOL skipDraw = NO;
            
            // вызываем делегата
            if ([_calendarView.delegate respondsToSelector:@selector(incalendarView:willDrawCell:context:)]) { 
                skipDraw = [_calendarView.delegate incalendarView:_calendarView willDrawCell:&drawInfo context:context];
            } 
            
            // рисуем
            if (!skipDraw) { 
                // 1. закрашиваем фон 
                if (drawInfo.cellBackgroundColor) {
                    CGContextSetFillColorWithColor(context,drawInfo.cellBackgroundColor.CGColor);
                    CGContextFillRect(context, drawInfo.cellBackgroundRect);           
                }
                if (drawInfo.drawSelectionEndpoint) { 
                    [self.selectionImage drawAtPoint:overlayOrigin];  
                    postProcess[postProcessIndex].frame  = selFrameRect;
                    postProcess[postProcessIndex].color  = [_calendarView themeColor:INCalendarViewSelectedEndpointFrameColor];
                    postProcessIndex++;
                }
                
                // 2. Выводим текст "today"
                if (drawInfo.todayMarkerText) { 
                    [drawInfo.todayMarkerTextShadowColor set]; 
                    drawInfo.todayMarkerRect.origin.y++;
                    [drawInfo.todayMarkerText drawInRect:drawInfo.todayMarkerRect withFont:drawInfo.todayMarkerFont];
                    [drawInfo.todayMarkerTextColor set];
                    drawInfo.todayMarkerRect.origin.y--;
                    [drawInfo.todayMarkerText drawInRect:drawInfo.todayMarkerRect withFont:drawInfo.todayMarkerFont];
                }
                
                // 3. Выводим основной текст
                if (drawInfo.titleText) {
                    if (drawInfo.titleTextShadowColor) { 
                        [drawInfo.titleTextShadowColor set];
                        [drawInfo.titleText drawInRect:drawInfo.titleRect withFont:drawInfo.titleFont];   
                    }
                    
                    if (drawInfo.titleTextColor) { 
                        [drawInfo.titleTextColor set];
                        drawInfo.titleRect.origin.y--;
                        [drawInfo.titleText drawInRect:drawInfo.titleRect withFont:drawInfo.titleFont]; 
                    }
                }
            }

            // вызываем делегата
            if ([_calendarView.delegate respondsToSelector:@selector(incalendarView:didDrawCell:context:)]) { 
                [_calendarView.delegate incalendarView:_calendarView didDrawCell:&drawInfo context:context];
            } 
            
            cellIndex++;
        }
    }
    
    for (int i = 0; i < postProcessIndex; i++) { 
        CGContextSetStrokeColorWithColor(context,  postProcess[i].color.CGColor);
        CGContextStrokeRect(context,postProcess[i].frame);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

enum { 
    TOUCH_NONE, TOUCH_ACTIVE, TOUCH_INACTIVE
};

- (NSInteger)touch:(UITouch *)touch toCoordinate:(_CellInfo *)c {
    if (touch) {  
        CGPoint p = [touch locationInView:self];
        CGRect r = self.bounds;
        struct _INCalendarViewMetrics m = _calendarView.metrics; 
        if (CGRectContainsPoint(r, p)) { 
            NSUInteger x = floor(p.x / m.cellWidth);  
            NSUInteger y = floor(p.y / m.cellHeight);
            NSUInteger cellIndex = x + y * m.cellHCount;
            if (y < m.cellVCount && x < m.cellHCount) { 
                _CellInfo cc = [_sheetInfo infoForCellOfIndex:cellIndex];
                *c = cc;
                if (!cc.isDisabled) { 
                    return TOUCH_ACTIVE;
                } else { 
                    return TOUCH_INACTIVE; 
                }
            }
        }
    }
    return TOUCH_NONE;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_touchProcessor handleTouchesWithEvent:event];
    _CellInfo c1, c2;
    switch ([self touch:_touchProcessor->_touch1 toCoordinate:&c1]) { 
        case TOUCH_INACTIVE:
            [_calendarView touchedInactive:c1];
            // no break here!
        case TOUCH_NONE:
           c1.ymd.value = 0;
           break;
    }

    switch ([self touch:_touchProcessor->_touch2 toCoordinate:&c2]) { 
        case TOUCH_INACTIVE:
            [_calendarView touchedInactive:c2];
            // no break here!
        case TOUCH_NONE:
           c2.ymd.value = 0;
           break;
    }
    [_calendarView handleTouchToCell1:c1 cell2:c2];            
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_touchProcessor handleTouchesWithEvent:event];
    [_calendarView resetTracking];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event { 
    [_touchProcessor reset];
    [_calendarView resetTracking];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_touchProcessor handleTouchesWithEvent:event];
    _CellInfo c1, c2; 
    if (TOUCH_ACTIVE != [self touch:_touchProcessor->_touch1 toCoordinate:&c1]) { 
        c1.ymd.value = 0;
    }
    if (TOUCH_ACTIVE != [self touch:_touchProcessor->_touch2 toCoordinate:&c2]) { 
        c2.ymd.value = 0;
    }
    [_calendarView handleTouchToCell1:c1 cell2:c2];           
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INCalendarHeaderView 

- (void)updateThemeColors {
    self.backgroundStyle = INPanelBGStyleVerticalGradient;
    self.topGradientColor = [_calendarView themeColor:INCalendarViewHeaderTopColor];
    self.bottomGradientColor = [_calendarView themeColor:INCalendarViewHeaderBottomColor];
    _titleLabel.textColor = [_calendarView themeColor:INCalendarViewHeaderTitleFontColor];
	_titleLabel.shadowColor = [_calendarView themeColor:INCalendarViewHeaderTitleShadowColor];
    UIColor *weekDayColor = [_calendarView themeColor:INCalendarViewHeaderWeekdayFontColor];
    UIColor *weekDayShadowColor = [_calendarView themeColor:INCalendarViewHeaderWeekdayShadowColor];
	for (int i=0; i < 7; i++) {
        _dowLabels[i].textColor = weekDayColor;
		_dowLabels[i].shadowColor = weekDayShadowColor;
    }
    
    const CGSize buttonImageSize = CGSizeMake(15,15);
    UIColor * buttonColor = [_calendarView themeColor:INCalendarViewHeaderArrowColor];
    // right image 
    INGraphicsBeginImageContext(buttonImageSize);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();             
        CGContextSetFillColorWithColor(context, buttonColor.CGColor);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, buttonImageSize.width, buttonImageSize.height / 2);
        CGContextAddLineToPoint(context, 0, buttonImageSize.height);
        CGContextAddLineToPoint(context, 0, 0);
        CGContextFillPath(context);
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext(); 
        [_nextButton setImage:img forState:UIControlStateNormal];
    }
    UIGraphicsEndImageContext();                         

    // right image 
    INGraphicsBeginImageContext(buttonImageSize);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();             
        CGContextSetFillColorWithColor(context, buttonColor.CGColor);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, buttonImageSize.width,0);
        CGContextAddLineToPoint(context,  buttonImageSize.width, buttonImageSize.height);
        CGContextAddLineToPoint(context,0, buttonImageSize.height / 2);
        CGContextAddLineToPoint(context,  buttonImageSize.width, 0);
        CGContextFillPath(context);
        UIImage * img = UIGraphicsGetImageFromCurrentImageContext(); 
        [_prevButton setImage:img forState:UIControlStateNormal];
    }
    UIGraphicsEndImageContext();                         

    
    //    
//    [ setTitleColor:self.buttonColor forState:UIControlStateNormal];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame  calendarView:(INCalendarView *)cv{
    self = [super initWithFrame:frame];
    if (self != nil) {
        _calendarView = cv;
        CGRect r = self.bounds;
        CGRect rTop,rBottom;
        INRectSplitInto2VertRects(r, r.size.height - 15, &rTop, &rBottom);
        rTop.size.height += 6;
        rBottom.origin.y++;
        CGRect rb1,rb2,rl;
        
        INRectSplitInto2Rects(rTop, 46 /* r.size.height */, &rb1, &rl);
        INRectSplitInto2Rects(rl,   rl.size.width - 46 /* r.size.height */, &rl, &rb2);
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(rl,2,4)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:22];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.minimumFontSize = 7;        
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        //_titleLabel.shadowColor = [UIColor whiteColor];
        // _titleLabel.backgroundColor = [UIColor orangeColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.shadowOffset = CGSizeMake(0,1);
        _titleLabel.text = @"";
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_titleLabel];
        
        _prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _prevButton.frame = rb1;
        // _prevButton.titleLabel.font = [UIFont boldSystemFontOfSize:INSystemVersionEqualsOrGreater(3,2,0) ? 18 : 28];
        //[_prevButton setTitle:@"◀" forState:UIControlStateNormal];
        //_prevButton.reversesTitleShadowWhenHighlighted = YES;
        //_prevButton.titleLabel.shadowOffset = CGSizeMake(0,1);
        // [_prevButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        //[_prevButton setTitleColor:[UIColor clearColor] forState:UIControlStateDisabled];
        //[_prevButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
        _prevButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [_prevButton addTarget:self action:@selector(nextPrevButtonPressed:) forControlEvents:UIControlEventTouchUpInside]; 
        [self addSubview:_prevButton];

        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = rb2;
        //_nextButton.titleLabel.font = _prevButton.titleLabel.font;
        // _nextButton.titleLabel.shadowOffset = CGSizeMake(0,1);
        //[_nextButton setTitle:@"▶" forState:UIControlStateNormal];
        //[_nextButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        // _nextButton.reversesTitleShadowWhenHighlighted = YES;
        //[_nextButton setTitleColor:[UIColor clearColor] forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(nextPrevButtonPressed:) forControlEvents:UIControlEventTouchUpInside]; 
        _nextButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_nextButton];
    
        struct _INCalendarViewMetrics metrics = cv.metrics;                            
        for (int i=0; i < 7; i++) { 
            CGRect r = rBottom;
            r.size.width = metrics.cellWidth;
            UILabel * l = [[UILabel alloc] initWithFrame:r];
            _dowLabels[i] = l;
            l.font = [UIFont boldSystemFontOfSize:10];
            l.textAlignment = UITextAlignmentCenter;
            //l.shadowColor = [UIColor whiteColor];
            //l.textColor = [UIColor darkGrayColor];
            l.backgroundColor = [UIColor clearColor];
            l.shadowOffset = CGSizeMake(0,1);
            l.text = @"-";
            [self addSubview:l];
        }

        [self updateThemeColors];
        self.opaque = YES;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_sheetInfo release];
    for (int i=0; i < sizeof(_colors) / sizeof(id); i++) { 
       [_colors[i] release];
    }
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSheetInfo:(_INCalendarWorkSheetInfo *)info {
    [_sheetInfo release];
    _sheetInfo = [info retain];
    NSArray * a = info.weekDays;
    for (int i = 0; i < 7; i++) { 
       _dowLabels[i].text = [a objectAtIndex:i];
    }
    _titleLabel.text = _sheetInfo.yyyymmAsString;
    _prevButton.hidden = !info->_canGoToPrevMonth;
    _nextButton.hidden = !info->_canGoToNextMonth;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)layoutSubviews { 
   [super layoutSubviews];
   CGRect r = self.bounds;
   CGFloat w = _calendarView.metrics.cellWidth;
   for (int i=0; i < 7; i++) { 
      CGRect rb = _dowLabels[i].frame;
      rb.origin.y = r.size.height - rb.size.height;
      rb.size.width = w;
      rb.origin.x = i * w;
      _dowLabels[i].frame = rb;
   }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)nextPrevButtonPressed:(UIButton *)button { 
    [_calendarView moveForward:button == _nextButton];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INCalendarView

@synthesize delegate = _delegate;
@synthesize currentMonthInfo = _currentMonthInfo;
@synthesize metrics = _metrics;
@synthesize selectionMode = _selectionMode;
@synthesize selections = _selections;
@synthesize minDateAllowed = _minDateAllowed;
@synthesize maxDateAllowed = _maxDateAllowed;
@synthesize minYMD = _minYMD;
@synthesize maxYMD = _maxYMD;
@synthesize headerView = _headerView;
@synthesize todayText = _todayText;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateThemeColors { 
    _currentSheet.selectionImage = nil;
    _comingSheet.selectionImage = nil;
    [_comingSheet setNeedsDisplay]; 
    [_currentSheet setNeedsDisplay];
    [_headerView updateThemeColors];
}

//----------------------------------------------------------------------------------------------------------------------------------

#ifndef NS_BLOCK_ASSERTIONS

+ (void)initialize { 
    INCalendarViewYMD v = { 
       .v.year = 0x1234,
       .v.month = 0x56,
       .v.day = 0x78,       
    };
    NSCAssert(v.value == 0x12345678, @"INCalendarView: Oops. Byte ordering is not LE now!!");
}

#endif
//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectionMode:(INCalendarViewSelectionMode)value {  
    if (value != _selectionMode) { 
        _selectionMode = value;
        // [_selections removeAllObjects];
        [self updateCurrentSheet:YES];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIColor *)defaultThemeColor:(INCalendarViewThemeColor)colorIndex {
    UIColor * result = nil;
    if (!result) { 
        switch (colorIndex) {    
            // background 
            case INCalendarViewCurrentMonthCellColor:
                result = [UIColor inru_colorFromRGBA:0xD5d5d5FF];
                break;
                
            case INCalendarViewUnselectableCellColor:
                result = [UIColor inru_colorFromRGBA:0xD0D0D0FF];
                break;
                
            // disabled state 
            case INCalendarViewUnselectableCurrentMonthFontColor:
            case INCalendarViewUnselectableFontColor:
                result = [UIColor inru_colorFromRGBA:0xBBBBBBFF];
                break;
                
                // grids 
            case INCalendarViewDarkGridLineColor:
                result = [UIColor lightGrayColor];
                break;                
                
            case INCalendarViewLightGridLineColor:
                result = [UIColor whiteColor];
                break;       
                
                // current month 
            case INCalendarViewCurrentMonthFontColor:   
                result = [UIColor inru_colorFromRGBA:0x47576aFF];
                break;
                
                // today mark
            case INCalendarViewTodayFontColor:
                result = [UIColor inru_colorFromRGBA:0x90969EFF];
                break;
                
                // inactive monthes
            case INCalendarViewOtherMonthFontColor:
                result = [UIColor inru_colorFromRGBA:0x90969EFF];
                break;
                
            case INCalendarViewOtherMonthCellColor:
                result = nil;
                break;
                
                // selection
            case INCalendarViewSelectedFontColor:
                result = [UIColor whiteColor];
                break;
                
            case INCalendarViewSelectedShadowColor:
                result = [UIColor inru_colorFromRGBA:0x47576aFF];
                break;
                
            case INCalendarViewSelectedCellColor:
                result = [UIColor inru_colorFromRGBA:0x3366997F];
                break;
                
            case INCalendarViewSelectedEndpointCellColor1:
                result = [UIColor inru_colorFromRGBA:0x72B1EFFF];
                break;
                
            case INCalendarViewSelectedEndpointCellColor2:
                result = [UIColor inru_colorFromRGBA:0x2B8AE7FF];
                break;
                
            case INCalendarViewSelectedEndpointCellColor3:
                result = [UIColor inru_colorFromRGBA:0x0072E2FF];
                break;
                
            case INCalendarViewSelectedEndpointFrameColor:
                result = [UIColor blackColor];
                break;
                
            case INCalendarViewHeaderTopColor:
                result = [UIColor inru_colorFromRGBA:0xF6F6F6FF];
                break;
                
            case INCalendarViewHeaderBottomColor:
                result = [UIColor inru_colorFromRGBA:0xCDCDCDFF];
                break;
                
            case INCalendarViewHeaderTitleFontColor:
                result = [UIColor darkGrayColor]; 
                break;

	        case INCalendarViewHeaderTitleShadowColor:
	            result = [UIColor whiteColor];
	            break;

            case INCalendarViewHeaderWeekdayFontColor:
                result = [UIColor darkGrayColor]; 
                break;

            case INCalendarViewHeaderWeekdayShadowColor:
                result = [UIColor whiteColor];
                break;

            case INCalendarViewHeaderArrowColor:
                result = [UIColor inru_colorFromRGBA:0x3B4858FF];
                break;
                
            case INCalendarViewLastColor:
                // to make a compiler happy
                break;
        }
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIColor *)themeColor:(INCalendarViewThemeColor)colorIndex {
    UIColor * result = nil;
    if ([_delegate respondsToSelector:@selector(incalendarView:themeColor:)]) { 
        result = [_delegate incalendarView:self themeColor:colorIndex];
    }
    if (!result) {
        result = [self defaultThemeColor:colorIndex];
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateGeometry {
    _metrics.cellWidth   = [self geometryValue:INCalendarViewGeometryCellWidth];
    _metrics.cellHeight  = [self geometryValue:INCalendarViewGeometryCellHeight];
    _metrics.titleHeight = [self geometryValue:INCalendarViewGeometryTitleHeight];
    
    CGRect rHeader, rSheet;
    INRectSplitInto2VertRects(self.bounds, _metrics.titleHeight, &rHeader, &rSheet);

    _headerView.frame = rHeader;
    _sheetPlaceholder.frame = rSheet;
    
    [self updateCurrentSheet:YES];
    
    
    /* 
    //----------------------------------------------------------------------------------------------------------------------------------
    
    - (void)setExtraRowCountForPrevMonth:(NSUInteger)prevMonthExtraRows nextMonth:(NSUInteger)nextMonthExtraRows { 
        NSParameterAssert(prevMonthExtraRows < 7);
        NSParameterAssert(nextMonthExtraRows < 7); 
        _metrics.cellVCount = 6 + prevMonthExtraRows + nextMonthExtraRows;
        _metrics.prevMonthExtraRows = prevMonthExtraRows;
        _metrics.nextMonthExtraRows = nextMonthExtraRows;
        [self updateCurrentSheet:YES];
    }
    */
}
//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)defaultGeometryValue:(INCalendarViewGeometryValue)valueIndex {
    switch (valueIndex) {
        case INCalendarViewGeometryCellHeight:
        case INCalendarViewGeometryCellWidth:
        case INCalendarViewGeometryTitleHeight:
            return 46.0;
        
        case INCalendarViewGeometryPrevMonthExtraRows:
        case INCalendarViewGeometryNextMonthExtraRows:
            return 0;
            
        case INCalendarViewGeometryLastValue:
            // to make a compiler happy
            break;
        
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)geometryValue:(INCalendarViewGeometryValue)valueIndex {
    if ([_delegate respondsToSelector:@selector(incalendarView:geometryValue:)]) { 
        return [_delegate incalendarView:self geometryValue:valueIndex];
        // тут надо бы проверку делать на валидные данные6 но лень 
    } else { 
        return [self defaultGeometryValue:valueIndex];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.clipsToBounds = YES;
    
    _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    _calendar.locale = [NSLocale currentLocale];
    _selections = [NSMutableSet new];
    
    _metrics = (struct _INCalendarViewMetrics)
        { 
          .cellHCount  = 7,
          .cellVCount  = 6,
          .cellWidth   = [self defaultGeometryValue:INCalendarViewGeometryCellWidth],
          .cellHeight  = [self defaultGeometryValue:INCalendarViewGeometryCellHeight],
          .titleHeight = [self defaultGeometryValue:INCalendarViewGeometryTitleHeight],
          .prevMonthExtraRows = [self defaultGeometryValue:INCalendarViewGeometryPrevMonthExtraRows],
          .nextMonthExtraRows = [self defaultGeometryValue:INCalendarViewGeometryNextMonthExtraRows]
        };
    
    CGRect rHeader, rSheet;
    INRectSplitInto2VertRects(self.bounds, _metrics.titleHeight, &rHeader, &rSheet);
    
    _headerView = [[INCalendarHeaderView alloc] initWithFrame:rHeader calendarView:self];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_headerView];
    [_headerView release];
    
    _sheetPlaceholder = [[UIView alloc] initWithFrame:rSheet];
    _sheetPlaceholder.autoresizingMask = INFlexibleWidthHeight;
    [self addSubview:_sheetPlaceholder];
    _sheetPlaceholder.backgroundColor = [UIColor clearColor]; // self.backgroundColor;
    _sheetPlaceholder.clipsToBounds = YES;
    [_sheetPlaceholder release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globalsChanged:) 
          name:UIApplicationSignificantTimeChangeNotification object:nil];
          
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globalsChanged:) 
          name:NSCurrentLocaleDidChangeNotification object:nil];
    
    [self selectSheetForDate:[NSDate date] animated:NO];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
    [_calendar release];
    [_currentMonthInfo release];
    [_selections release];
    for (int i=0; i < INCalendarViewLastColor; i++) { 
       [_colors[i] release];
    }
    [_minDateAllowed release];
    [_maxDateAllowed release];
    [_todayText release];
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)effectiveTodayString {
    
    if (_todayText) {
        return _todayText;    
    }
    
    // добавить локализаций по вкусу или задавать в self.todayText
    if (INIsRussianLocale()) { 
        return @"сегодня";
    } else { 
        return @"today";
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForSheetPanel {
    // CGRect r = self.bounds;
    CGFloat w = _metrics.cellHCount * _metrics.cellWidth; 
    return CGRectMake(0, 0 /* _metrics.titleHeight*/ ,w + 2,_metrics.cellVCount * _metrics.cellHeight + 2);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)globalsChanged:(NSNotification *)ntf {
    _calendar.locale = [NSLocale currentLocale];
    [self updateCurrentSheet:YES];   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateCurrentSheet:(BOOL)fullReplace { 
    if (fullReplace) { 
        if (_currentMonthInfo) { 
            [self selectSheetForDate:_currentMonthInfo->_date animated:NO]; 
        }   
    } else { 
        if (_currentSheet) { 
            [_currentSheet setNeedsDisplay];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setMinDateAllowed:(NSDate *)date { 
    if (date != _minDateAllowed) { 
       [_minDateAllowed release];
       _minDateAllowed = [date retain];
       _minYMD = _DateToYMD(date, _calendar);
       [self updateCurrentSheet:YES];
    }   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setMaxDateAllowed:(NSDate *)date { 
    if (date != _maxDateAllowed) { 
       [_maxDateAllowed release];
       _maxDateAllowed = [date retain];
       _maxYMD = _DateToYMD(date, _calendar);
       [self updateCurrentSheet:YES];
    }   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)moveForward:(BOOL)forward { 
    NSDate * d;
    if (_currentMonthInfo) { 
        d = _currentMonthInfo->_date;
    } else { 
        d = [NSDate date];
    }
    [self selectSheetForDate:[d inru_incMonth:forward ? 1 : -1] animated:YES];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context { 
    _isTransitioning = NO;
    [_currentSheet removeFromSuperview];
    _currentSheet = _comingSheet;
    _comingSheet = nil;       
    _currentSheet.frame = self.frameForSheetPanel;
}
        
//----------------------------------------------------------------------------------------------------------------------------------

- (void)selectSheetForDate:(NSDate *)date animated:(BOOL)animated { 
    if (_isTransitioning) { 
        return;
    }
    
    // выравниваем дату
    INCalendarViewYMD dymd = _DateToYMD(date, _calendar);
    if (_minYMD.value && dymd.value < _minYMD.value) { 
        date = _minDateAllowed;
    } else
    if (_maxYMD.value && dymd.value > _maxYMD.value) { 
        date = _maxDateAllowed;  
    }
    if (!date) { 
       date = [NSDate date];
    }
    if (!_currentMonthInfo) { 
        animated = NO; // initial setup
    }

    dymd = _DateToYMD(date, _calendar);
 
    // подготавливаем новую панель
    assert(!_comingSheet);
    _INCalendarWorkSheetInfo * comingInfo = [[_INCalendarWorkSheetInfo alloc] initWithDate:date calendar:_calendar 
                                             extraRowCountForPrevMonth:_metrics.prevMonthExtraRows nextMonth:_metrics.nextMonthExtraRows];
    [comingInfo applySelections:_selections];
    [comingInfo applyDisabledState:_minYMD maxYMD:_maxYMD]; 
    _comingSheet = [_INCalendarWorkSheet panelForCalendarView:self sheetInfo:comingInfo];
    [comingInfo release];
    if (_currentSheet) { 
        [_sheetPlaceholder insertSubview:_comingSheet belowSubview:_currentSheet];
    } else {
        [_sheetPlaceholder addSubview:_comingSheet];
    }
    // [self insertSubview:_comingSheet belowSubview: _currentSheet ? (id)_currentSheet : (id)_headerView];

    // Заголовок
    [_headerView setSheetInfo:comingInfo];
 
    // устанавливаем ее
    CGFloat vOffset = 0;
    CGRect r = self.frameForSheetPanel;
    if (animated) { 

        
        CGRect r1 = r;
        CGRect r2 = r;
        CGFloat sign = -1;
        if (dymd.value >= _currentMonthInfo->_firstDayOfNextMonth.value) { 
            sign = 1;
            NSInteger off =  (6 + _currentMonthInfo->_nextMonthExtraRowCount + 
                                  _currentMonthInfo->_prevMonthExtraRowCount) +
                                  _currentMonthInfo->_prevMonthExtraRowCount -
                                  _currentMonthInfo->_nextMonthCellRow; // + 
                              // +
                              // )
            vOffset = off * _metrics.cellHeight + 2;
        } else {
            sign = -1;
            NSInteger off = 0;
            if (comingInfo->_nextMonthCellRow == 5) { 
                //if ([_currentMonthInfo infoForCellOfIndex:0].isCurrentSheet) { 
                    off = 1;
                //} else { 
                //    off = 2;
                //}
            } else { 
                // 4 
                off = 2;
            }
            off += comingInfo->_nextMonthExtraRowCount + 2 * _currentMonthInfo->_prevMonthExtraRowCount;
            
            // NSLog(@"----month %@ cr %d off %d", comingInfo->_date, comingInfo->_nextMonthCellRow, off); 
            vOffset = 2 + off * _metrics.cellHeight ;
        }
        
        // текущий лист мы обновляем  (даты уже не принадлежат к текущему месяцу) и отрисовываем
        [_currentSheet.sheetInfo updateWithNewActiveMonth:dymd];
        [_currentSheet setNeedsDisplay];
        
        r1.origin.y += sign * (r.size.height - vOffset);
        r2.origin.y -= sign * (r.size.height - vOffset);

        _comingSheet.frame = r1;
        _isTransitioning = YES;
        [UIView beginAnimations:@"changeArea" context:nil];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDelegate:self];
        // #warning восстановить 0.5
        [UIView setAnimationDuration:0.5];
        {
            _currentSheet.frame = r2;      
            _comingSheet.frame = r;   
        }
        [UIView commitAnimations];
    } else {
       [_currentSheet removeFromSuperview];
       _currentSheet = _comingSheet;
       _comingSheet = nil;       
       _currentSheet.frame = r;
    }
    
    [_currentMonthInfo autorelease];
    _currentMonthInfo = [comingInfo retain];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)showDate:(NSDate *)date animated:(BOOL)animated { 
    if ([_currentMonthInfo dateIsVisible:date]) { 
        return;
    }
    
    [self selectSheetForDate:date animated:animated];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setTracking:(NSInteger)value { 
   if (value != _tracking1) { 
       // NSLog(@"Tracking %d",_tracking1);
       _tracking1 = value;
   }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)replaceSelectionWithYMD:(INCalendarViewYMD)ymd1 ymd2:(INCalendarViewYMD)ymd2 tracking:(NSInteger)tracking{ 
    [_selections removeAllObjects];
    [_selections addObject:[INCalendarSelectionItem itemWithYMD:ymd1 ymd2:ymd2  calendar:_calendar]];
    [self setTracking:tracking];
    [_currentMonthInfo applySelections:_selections];
    [self updateCurrentSheet:NO];
    if ([_delegate respondsToSelector:@selector(incalendarViewDidChangeSelection:)]) { 
        [_delegate incalendarViewDidChangeSelection:self];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

enum { 
    TRACKING_NONE,
    TRACKING_EDGE_A = 100,
    TRACKING_EDGE_B = 200,
    TRACKING_EDGE_BOTH = 100200,    
    TRACKING_SLIDE     = 400000
};


- (void)resetTracking {
    [self setTracking:TRACKING_NONE];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchedInactive:(_CellInfo)cell { 
    if ([_delegate respondsToSelector:@selector(incalendarView:didTouchDisabledDate:)]) { 
        [_delegate incalendarView:self didTouchDisabledDate:_YMDToDate(cell.ymd, _calendar)];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

#define CELL_OK(__C__) (__C__.ymd.value != 0 )


- (void)handleTouchToCell1:(_CellInfo)c1 cell2:(_CellInfo)c2 {
    if (_isTransitioning) { 
        return;
    }

    if (!CELL_OK(c1) && !CELL_OK(c2)) { 
        [self setTracking:TRACKING_NONE];
        return;
    }
    
    NSInteger cellCount = 1;
    _CellInfo cell1, cell2;
    if (CELL_OK(c1)) {
        if (CELL_OK(c2)) { 
            switch(_CompareYMD(c1.ymd,c2.ymd)) { 
                case NSOrderedAscending:
                    cell1 = c1;
                    cell2 = c2;
                    cellCount = 2;
                    break;
                    
                case NSOrderedDescending:
                    cell1 = c2;
                    cell2 = c1;
                    cellCount = 2;
                    break;
                    
                case NSOrderedSame:
                   cell1 = c1; 
                   break;
            }
        } else { 
            cell1 = c1;
        }
    } else {
        cell1 = c2;
    }
    if (cellCount == 1) { 
        cell2 = cell1;
    }
    
    
    // если мы тыкнули на неактивный месяц, то делаем прокрутку
    BOOL makeScroll = NO;
    switch (cell1.sheet) {
        case CellSheetNextMonth:
           makeScroll = _currentMonthInfo->_canGoToNextMonth; 
           break;
           
        case CellSheetPrevMonth:
           makeScroll = _currentMonthInfo->_canGoToPrevMonth; 
           break;
    }
    if (cellCount == 2) {
        if (makeScroll && cell1.sheet == cell2.sheet) { // только если оба тыка должны делать скроллинг в оном направлении
            //
        } else {
            makeScroll = NO;
        }
    }
    
    // -----------------------------------------------------
    //  SINGLE SELECTION MODE
    // ---------------------------------
    
    if (_selectionMode == INCalendarViewSingleSelection) { 
        [self replaceSelectionWithYMD:cell1.ymd ymd2:cell2.ymd tracking:TRACKING_NONE];
         goto make_scroll_and_exit;
    }
    
    // -----------------------------------------------------
    //  1 RANGE SELECTION MODE
    // ---------------------------------
    
    if (_selectionMode == INCalendarViewRangeSelection) {
        assert(_selections.count <= 1);

        // 
        // тут пока что скроллинг не отработан. надо подумать, чтобы было удобно. пока что отключим 
        makeScroll = NO;
    
        // Самое простое - касание двумя пальцами 
        if (cellCount > 1) { 
            [self replaceSelectionWithYMD:cell1.ymd ymd2:cell2.ymd tracking:TRACKING_NONE];
            goto make_scroll_and_exit;  
        }
    
        // Начинаем обработку касание одним пальцем отсюда
        assert(cellCount == 1);
        
        // Если ничего не выбрано, то первый тык выбирает диапазон длины 1
        if (_selections.count == 0) { 
            [self replaceSelectionWithYMD:cell1.ymd ymd2:cell1.ymd tracking:TRACKING_NONE];
            goto make_scroll_and_exit;
        }
        
        // начиная с этой точки у нас уже выбран какой-то диапазон, смотрим, что это такое 
        INCalendarSelectionItem * item = [_selections anyObject];
        assert(item);
        INCalendarViewYMD ymd1 = item.ymd1;
        INCalendarViewYMD ymd2 = item.ymd2;
                   
        // для случаев, когда тракинг не идет - мы его стартуем  
        if (_tracking1 == TRACKING_NONE) {
            
            // если палец ткнулся снаружи диапазона - то стартуем новое единичное выделение здесь
            if (cell1.ymd.value < ymd1.value || ymd2.value <  cell1.ymd.value ) {
                [self replaceSelectionWithYMD:cell1.ymd ymd2:cell1.ymd tracking:TRACKING_NONE];
            } else 

            // если мы попали на какую-то конечную точку, то включаем тракинг
            if (cell1.ymd.value == ymd1.value) {
                if (cell1.ymd.value == ymd2.value) {
                    [self setTracking:TRACKING_EDGE_BOTH];
                } else { 
                    [self setTracking:TRACKING_EDGE_A];
                }
            } else 
            if (cell1.ymd.value == ymd2.value) {
                [self setTracking:TRACKING_EDGE_B];
            } else 
            
            // включаем тракинг слайдинга дат 
            {
                [self setTracking:TRACKING_SLIDE];
                _slideTrackingCellIndex = cell1.cellIndex;
            }
            goto make_scroll_and_exit;
        }
        
        // тракинг одиночной точки  -> просто перемещаем точку
        if (_tracking1 == TRACKING_EDGE_BOTH) {
            switch (_CompareYMD(cell1.ymd,ymd1)) {
               case NSOrderedAscending: 
                   [self replaceSelectionWithYMD:cell1.ymd ymd2:ymd2 tracking:TRACKING_EDGE_A]; // тракинг еще идет, но у нас уже не одиночная точка!
                   break;
                  
               case NSOrderedDescending:
                   [self replaceSelectionWithYMD:ymd1 ymd2:cell1.ymd tracking:TRACKING_EDGE_B];  // тракинг еще идет, но у нас уже не одиночная точка!
                   break;
            }
            goto make_scroll_and_exit;
        }
        
        // тракинг начальной даты - тут есть нюанс - в некий момент конец может стать началом!
        if (_tracking1 == TRACKING_EDGE_A) {
             switch (_CompareYMD(cell1.ymd,ymd2)) {
                case NSOrderedAscending: 
                    [self replaceSelectionWithYMD:cell1.ymd ymd2:ymd2 tracking:TRACKING_EDGE_A]; 
                    break;
                case NSOrderedSame : 
                    [self replaceSelectionWithYMD:cell1.ymd ymd2:ymd2 tracking:TRACKING_EDGE_BOTH]; 
                    break;
                case NSOrderedDescending : 
                    [self replaceSelectionWithYMD:ymd2 ymd2:cell1.ymd tracking:TRACKING_EDGE_B]; 
                    break;
            }
            goto make_scroll_and_exit;
        }

        // тракинг начальной даты - тут есть нюанс - в некий момент конец может стать началом!
        if (_tracking1 == TRACKING_EDGE_B) {
             switch (_CompareYMD(ymd1,cell1.ymd)) {
                case NSOrderedAscending: 
                    [self replaceSelectionWithYMD:ymd1 ymd2:cell1.ymd tracking:TRACKING_EDGE_B]; 
                    break;
                case NSOrderedSame : 
                    [self replaceSelectionWithYMD:cell1.ymd ymd2:cell1.ymd tracking:TRACKING_EDGE_BOTH]; 
                    break;
                case NSOrderedDescending : 
                    [self replaceSelectionWithYMD:cell1.ymd ymd2:ymd1 tracking:TRACKING_EDGE_A]; 
                    break;
            }
            goto make_scroll_and_exit;
        }

        // слайдинг
        if (_tracking1 == TRACKING_SLIDE) { 
             NSInteger newCellIndex = cell1.cellIndex;
             NSInteger delta = newCellIndex - _slideTrackingCellIndex; 
             if (delta) { 
                 NSDate * d1 = [_YMDToDate(ymd1, _calendar) inru_incDay:delta];
                 NSDate * d2 = [_YMDToDate(ymd2, _calendar) inru_incDay:delta];
                 INCalendarViewYMD dymd1 = _DateToYMD(d1, _calendar);
                 INCalendarViewYMD dymd2 = _DateToYMD(d2, _calendar);
                 if (_minYMD.value <= dymd1.value && ((_maxYMD.value == 0) || (dymd2.value <= _maxYMD.value))) { 
                     [self replaceSelectionWithYMD:dymd1 ymd2:dymd2 tracking:TRACKING_SLIDE]; 
                     _slideTrackingCellIndex = newCellIndex;
                 }
             }
             goto make_scroll_and_exit;
        }
    }
    
    // а тут нам не место
    NSAssert(0,@"mk_6b1f5b5f_5765_490e_b77e_fbd151eb6ecf");
    
make_scroll_and_exit:

    if (makeScroll) { 
        [self moveForward:cell1.sheet == CellSheetNextMonth]; 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectionFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    fromDate = [fromDate inru_trimTime]; 
    toDate = [toDate inru_trimTime]; 
    NSParameterAssert(fromDate);
    NSParameterAssert(toDate);
    NSParameterAssert([fromDate compare:toDate] <=0);
    [_selections removeAllObjects];
    [_selections addObject:[INCalendarSelectionItem itemWithYMD:_DateToYMD(fromDate,_calendar) ymd2:_DateToYMD(toDate,_calendar) calendar:_calendar]];
    [_currentMonthInfo applySelections:_selections];
    [self updateCurrentSheet:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedDate:(NSDate *)date { 
    [self setSelectionFromDate:date toDate:date];
}

@end


