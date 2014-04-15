
#import "BHCharts.h"
#import "BH.h"

static const NSUInteger _PieColors[] = {  
    0x2f69bf,
    0xa2bf2f,
    0xbf5a2f,
    0xbfa22f,
    0x772fbf,
    0xbf2f2f,
    0x00327f,
    0x667f00,
    0x7f2600,
    0x7f6500,
    0x295ba6,
    0x8da629,
    0xa64f29,
    0xa68d29,
    0x6829a6,
    0xa62929,
    0x002459,
    0x475900,
    0x591b00,
    0x594700
};

//----------------------------------------------------------------------------------------------------------------------------------

UIColor * BHChartPieColorValueForPosition(NSUInteger position) { 
    NSUInteger colorID = position % (sizeof(_PieColors)/sizeof(NSUInteger));
    return [UIColor inru_colorFromRGBA: (_PieColors[colorID] << 8) | 0xff];    
}

//==================================================================================================================================
//==================================================================================================================================

@implementation  BHChartSeriesItem

@synthesize value = _value; 
@synthesize color = _color; 

//----------------------------------------------------------------------------------------------------------------------------------

- (NSComparisonResult)compareValueDesc:(BHChartSeriesItem *)otherItem { 
    return INCompareDouble(otherItem->_value, _value);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)description { 
    return [NSString stringWithFormat:@"%@ (%f %%)", self.name, _value];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_color release];
    [super dealloc];
}

@end 

//==================================================================================================================================
//==================================================================================================================================

#define OTHER_CAPTION @"Other"

@implementation  BHChartSeries

@synthesize seriesKind = _seriesKind;
@synthesize line1text = _line1text;
@synthesize line2text = _line2text;
@synthesize centeredText = _centeredText;
@synthesize dataState = _dataState;
@synthesize limitedItemCount = _limitedItemCount;
@synthesize addOtherItem = _addOtherItem;

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)chartItemCount { 
    if (_limitedItemCount >= 0) { 
         if (_limitedItemCount >= self.items.count) {
              return self.items.count;
         } else { 
             return _limitedItemCount + (_addOtherItem ? 1 : 0); // 1 is for "other"
         }
    } else {
        return self.items.count;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BHChartSeriesItem *)chartItemAtIndex:(NSUInteger)index { 
    if (_limitedItemCount >= 0 && index == _limitedItemCount)  {
        BHChartSeriesItem * otherItem = [BHChartSeriesItem newWithName:OTHER_CAPTION];
        double total = 0;
        for (int i = 0; i < _limitedItemCount; i++) { 
            BHChartSeriesItem * item = [self itemAtIndex:i]; 
            total += item.value;
        }
        otherItem.value = MAX(0, 100.0 - total);
        otherItem.color = BHChartPieColorValueForPosition(self.items.count);
        return [otherItem autorelease];
    } else { 
        return [self itemAtIndex:index];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithKind:(BHChartSeriesKind)kind name:(NSString *)name { 
    self = [super init];
    if (self) {
        self.name = name;
        _seriesKind = kind;
        _limitedItemCount = -1;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_line1text release];
    [_line2text release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)sortDescAndCutToMinThreshold:(CGFloat)minThresholdValue limitCount:(NSInteger)limitCount{ 
    [self sortItemsUsingSelector:@selector(compareValueDesc:)];
    double total = 0;
    for (int index = 0; index < self.items.count; index++) {
        BHChartSeriesItem * item = [self itemAtIndex:index];
        if (item.value < minThresholdValue || (limitCount >=0 && index >= limitCount)) {
            /*  
            while (self.items.count > index) { 
                [self removeItemAtIndex:index];
            }
            if (100 - total >= minThresholdValue) {  
                BHChartSeriesItem * item = [BHChartSeriesItem newWithName:OTHER_CAPTION];
                item.value = 100 - total;
                [self addItem:item];
                [item release];
            }
            break;
            */
            _limitedItemCount = index;
            break;
        }
        total += item.value;
    }
    // NSLog(@"%@", self.items);
    //if (limitCount >= 0 && (_limitedItemCount < 0 || _limitedItemCount > limitCount)) {  
    //    _limitedItemCount = limitCount;
    //}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addFromDictionary:(NSDictionary *)dict count:(NSInteger)count { 
    if (count < 0) { 
        count  = 0;
        for (NSString * item in dict) {
            NSNumber * count1 = [dict objectForKey:item]; 
            count += count1.intValue;
        }
    }
    NSAssert(count >= 0, @"mk_1c3af088_f790_4d5f_ae9a_3d23308aa8d6");

    for (NSString * item in dict) {
        NSNumber * count1 = [dict objectForKey:item]; 
        BHChartSeriesItem * item1 = [BHChartSeriesItem newWithName:item];
        item1.value = count1.doubleValue * 100.0 / count;
        [self addItem:item1];
        [item1 release];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)assignColorsByPosition { 
    NSUInteger index =0;
    for (BHChartSeriesItem * item in self) { 
        item.color = BHChartPieColorValueForPosition(index++);
    }
}

@end 

//==================================================================================================================================
//==================================================================================================================================

@implementation  BHChartSeriesCollection 

- (void)loadSinceDate:(BHStartDate)startDate {

    NSDate * startDate1 = BHDateFromStartDate(startDate);
    NSDate * requestDate = [startDate1 inru_incDay:-2];
    
    NSDateComponents * dateComponents = [[NSDateComponents new] autorelease];
    NSCalendar * calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSMutableArray * eventTriggers = [NSMutableArray arrayWithCapacity:20];
    
    NSMutableDictionary * allTriggers = [NSMutableDictionary dictionary];
    NSMutableDictionary * triggerFrequency = [NSMutableDictionary dictionary];
    NSInteger totalHeadacheCount = 0;
    int intensity[3][2] = {};
    NSMutableDictionary * allSymptoms = [NSMutableDictionary dictionary];
    NSMutableDictionary * allLocations = [NSMutableDictionary dictionary];
    
    enum { 
        PREVIOUS_DAY,
        CURRENT_DAY,
        TRIGGER_POOL_SIZE
    };
    struct {
        NSMutableDictionary * triggers;
        NSDate * midnightDate; 
    } triggerPool[TRIGGER_POOL_SIZE] = {
        {
            [NSMutableDictionary dictionary]
        },
        {
            [NSMutableDictionary dictionary],
            [NSDate distantPast]
        }
    };
    
    BOOL hasRecords = NO;
    
    NSFetchedResultsController * fetchedResults = [g_BH fetchedResultsControllerForEventWithStyle:BHFetchStyleCharts sinceDate:requestDate];
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [fetchedResults sections]) { 
        for (BHMigrainEvent * event in sectionInfo.objects) {
            BOOL hasHeadache = event.hasHeadache.boolValue;
            hasRecords = YES;
            
            NSDate * eventBeginDate = nil; 
            NSDate * eventEndDate = nil;
            NSDate * eventMidnightDate = nil; 
            
            if (hasHeadache) {
                [dateComponents setHour:event.startHour.intValue];
                [dateComponents setMinute:0];
                eventBeginDate = [calendar dateByAddingComponents:dateComponents toDate:event.timestamp options:0];
                [dateComponents setHour:0];
                [dateComponents setMinute:event.duration.intValue];
                eventEndDate = [calendar dateByAddingComponents:dateComponents toDate:eventBeginDate options:0];
            } else {
                eventBeginDate = event.timestamp;
                eventEndDate = event.timestamp;
            }
            {
                NSDateComponents * comps = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | 
                                                         NSYearCalendarUnit fromDate:eventBeginDate];
                [comps setHour: 0];
                [comps setMinute:0];
                [comps setSecond:0];
                eventMidnightDate = [calendar dateFromComponents:comps];
            }
            
            [eventTriggers removeAllObjects];
            for (BHCollectionItem * item in event.foods) {
                [eventTriggers addObject:item.name]; 
            }
            for (BHCollectionItem * item in event.lifestyles) {
                [eventTriggers addObject:item.name]; 
            }
            for (BHCollectionItem * item in event.environments) {
                [eventTriggers addObject:item.name]; 
            }
            if (event.menstruating.intValue == BHMenstruatingYes) {
                [eventTriggers addObject:@"Menstruating"]; 
            }
            if (event.skippedBreakfast.boolValue) { 
                [eventTriggers addObject:@"Skipped breakfast"]; 
            }
            if (event.skippedDinner.boolValue) { 
                [eventTriggers addObject:@"Skipped dinner"]; 
            }
            if (event.skippedLunch.boolValue) { 
                [eventTriggers addObject:@"Skipped launch"]; 
            }
            if (event.fasting.boolValue) { 
                [eventTriggers addObject:@"Fasting"]; 
            }
            
            if (![eventMidnightDate isEqualToDate:triggerPool[CURRENT_DAY].midnightDate]) {  
                NSTimeInterval ti = [eventMidnightDate timeIntervalSinceDate:triggerPool[CURRENT_DAY].midnightDate];
                BOOL isNextDayAfterCurrent = fabs(ti - 3600 * 24) < 1; 
                if (isNextDayAfterCurrent) { 
                    triggerPool[PREVIOUS_DAY] = triggerPool[CURRENT_DAY]; 
                } else {
                    triggerPool[PREVIOUS_DAY].midnightDate = nil;
                    triggerPool[PREVIOUS_DAY].triggers = nil; 
                }
                triggerPool[CURRENT_DAY].midnightDate = eventMidnightDate; 
                triggerPool[CURRENT_DAY].triggers = [NSMutableDictionary dictionary];
            }
            NSMutableDictionary * statDict = triggerPool[CURRENT_DAY].triggers;
            for (NSString * trigger in eventTriggers) { 
                [statDict setObject:[NSNull null] forKey:trigger];
            }
            
            
            if ([eventEndDate inru_isBefore:startDate1]) { 
                continue;
            }
            
            for (NSString * trigger in eventTriggers) { 
                [allTriggers setObject:[NSNumber numberWithInt:[[allTriggers objectForKey:trigger] intValue]+ 1] forKey:trigger];
            }
            
            // Trigger frequency
            if (hasHeadache) {
                totalHeadacheCount++;  
                for (NSString * trigger in triggerPool[CURRENT_DAY].triggers) { 
                    [triggerFrequency setObject:[NSNumber numberWithInt:[[triggerFrequency objectForKey:trigger] intValue]+ 1] forKey:trigger];
                }
            }
            
            // Symptoms
            if (hasHeadache) { 
                for (BHCollectionItem * symptom in event.symptoms) {
                    [allSymptoms setObject:[NSNumber numberWithInt:[[allSymptoms objectForKey:symptom.name] intValue]+ 1] forKey:symptom.name];
                }
            }   

            // Pain locations
            if (hasHeadache )
            { 
                for (BHCollectionItem * location in event.locations) {
                    [allLocations setObject:[NSNumber numberWithInt:[[allLocations objectForKey:location.name] intValue]+ 1] forKey:location.name];
                }
            }   
            
            // Pain Intencity
            if (hasHeadache) { 
                int value = event.intensity.intValue;
                int index = 0;
                switch(value) { 
                    case BHPainIntenseModerate:
                        index = 0;
                        break;
                        
                    case BHPainIntensePainful:
                        index = 1;
                        break;
                        
                    case BHPainIntenseVeryPainful:
                        index = 2;
                        break;
                }
                intensity[index][0]++;
                intensity[index][1]=value;
            }
        }
    }
        
    // exposures 
    {
        BHChartSeries * triggerExposures = [[BHChartSeries alloc] initWithKind:BHTriggerExposureChartSeries name:@"Potential Triggers"];
        triggerExposures.line2text = @"Share of triggers entered";
       //  triggerExposures.centeredText = YES;
        triggerExposures.addOtherItem = YES;
        [self addItem:triggerExposures];
        [triggerExposures release];
        if (allTriggers.count) { 
            [triggerExposures addFromDictionary:allTriggers count:-1];
            [triggerExposures sortDescAndCutToMinThreshold:BH_MIN_CHART_VALUE_ALLOWED limitCount:BH_CHART_PIE_ITEMS_ALLOWED];
            [triggerExposures assignColorsByPosition];
        }
    }
    
    
    // trigger frequency 
    {
        BHChartSeries * triggerFrequencySeries = [[BHChartSeries alloc] initWithKind:BHTriggerFrequencyChartSeries name:@"Trigger Exposure"];
        triggerFrequencySeries.line2text = @"hours prior to a headache";
        triggerFrequencySeries.line1text = @"Percentage of exposure to triggers 24-48";
        [self addItem:triggerFrequencySeries];
        [triggerFrequencySeries release];
        if (triggerFrequency.count) { 
            [triggerFrequencySeries addFromDictionary:triggerFrequency count:totalHeadacheCount];
            [triggerFrequencySeries sortDescAndCutToMinThreshold:BH_MIN_CHART_VALUE_ALLOWED limitCount:BH_CHART_PIE_ITEMS_ALLOWED];
        }
    }
    
    // symptom frequency 
    {
        BHChartSeries * symptomFrequencySeries = [[BHChartSeries alloc] initWithKind:BHSymptomsFrequencyChartSeries name:@"Symptom Frequency"];
        symptomFrequencySeries.line2text = @"headache symptom";
        symptomFrequencySeries.line1text = @"Percentage of times you experienced a specific";
        [self addItem:symptomFrequencySeries];
        [symptomFrequencySeries release];
        if (allSymptoms.count) { 
            [symptomFrequencySeries addFromDictionary:allSymptoms count:totalHeadacheCount];
            [symptomFrequencySeries sortDescAndCutToMinThreshold:BH_MIN_CHART_VALUE_ALLOWED limitCount:BH_CHART_PIE_ITEMS_ALLOWED];
        }
    }
    
    // pain location 
    {
        BHChartSeries * painLocationSeries = [[BHChartSeries alloc] initWithKind:BHPainLocationChartSeries name:@"Pain Location"];
        painLocationSeries.line2text = @"headache pain location";
        painLocationSeries.line1text = @"Percentage of times you indicated a specific";
        [self addItem:painLocationSeries];
        [painLocationSeries release];
        if (allLocations.count) { 
            [painLocationSeries addFromDictionary:allLocations count:totalHeadacheCount];
            [painLocationSeries sortDescAndCutToMinThreshold:BH_MIN_CHART_VALUE_ALLOWED limitCount:BH_CHART_PIE_ITEMS_ALLOWED];
        }
    }
    
    // pain level
    {
        BHChartSeries * painLevel = [[BHChartSeries alloc] initWithKind:BHPainLevelChartSeries name:@"Pain Level"];
        [self addItem:painLevel];
        // painLevel.centeredText = YES;
        painLevel.line1text = @"Percentage of times you indicated a specific";
        painLevel.line2text = @"headache pain intensity";
        [painLevel release];
        int intenseCount = intensity[0][0] + intensity[1][0] + intensity[2][0];
        if (intenseCount) {
            for (int i = 0; i < 3; i++) { 
                if (intensity[i][0]) {
                     BHChartSeriesItem * item = [BHChartSeriesItem newWithName:BHPainIntenceToString(intensity[i][1])];
                     item.value = intensity[i][0] * 100.0 / intenseCount;
                     item.color = BHColorForPainIntense(intensity[i][1]);
                     [painLevel addItem:item];
                     [item release];
                }
            }
            [painLevel sortItemsUsingSelector:@selector(compareValueDesc:)];
        }
    }
    
    for (BHChartSeries * series in self) { 
        if (series.hasItems) { 
            series.dataState = BHChartSeriesHasDataState; 
        } else 
        if (hasRecords && startDate.dateKind != BHStartDateAll) { 
            series.dataState = BHChartSeriesHasNoFilteredDataState;
        } else {
            series.dataState = BHChartSeriesHasNoDataState;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (BHChartSeriesCollection *)collectionSinceDate:(BHStartDate)startDate {
    BHChartSeriesCollection * result = [BHChartSeriesCollection new];
    [result loadSinceDate:startDate]; 
    return [result autorelease];  
}
/*
+ (BHChartSeriesCollection *)collectionSinceDate:(BHStartDate)startDate painLocation:(BOOL)painLoc
{
    BHChartSeriesCollection * result = [BHChartSeriesCollection new];
    [result setWithPainLocation:painLoc];
    [result loadSinceDate:startDate]; 
    return [result autorelease];  
}
*/
@end 

