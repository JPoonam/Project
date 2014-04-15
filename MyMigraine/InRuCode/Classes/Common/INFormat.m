//!
//! @file INFormat.h
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

#import "INFormat.h"

static struct {
    unichar decimalSeparator[10];
    NSInteger decimalSeparatorLength;
    unichar groupSeparator[10];
    NSInteger groupSeparatorLength;
    NSString * badValue;
    BOOL loaded;
} g_NumberFormatData = {};

//==================================================================================================================================
//==================================================================================================================================

@implementation NSString (INRU_Format)

- (NSString *)inru_formatNumberStringWithFracMinLength:(NSInteger)fracMinLen flags:(NSInteger)flags {
    NSString * str = self;
    NSInteger count = str.length;
    if (!count) { 
       str = @"0";
       count = 1;
    }
    if (!g_NumberFormatData.loaded) {
        g_NumberFormatData.badValue = @"-";
        g_NumberFormatData.loaded = YES;
        NSString * decSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        g_NumberFormatData.decimalSeparatorLength = decSeparator.length;
        if (g_NumberFormatData.decimalSeparatorLength > 10) { 
            g_NumberFormatData.decimalSeparatorLength = 0;
        }
        [decSeparator getCharacters:g_NumberFormatData.decimalSeparator range:NSMakeRange(0,g_NumberFormatData.decimalSeparatorLength)];  

        NSString * groupSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        g_NumberFormatData.groupSeparatorLength = groupSeparator.length;
        if (g_NumberFormatData.groupSeparatorLength > 10) { 
            g_NumberFormatData.groupSeparatorLength = 0;
        }
        [groupSeparator getCharacters:g_NumberFormatData.groupSeparator range:NSMakeRange(0,g_NumberFormatData.groupSeparatorLength)];  
    }
    if (count > 30) {
        goto bad;
    }
                   
    unichar chars[100], decimal[30], fraction[30];
    unichar sign = 0;
    [str getCharacters:chars range:NSMakeRange(0,count)];
    NSInteger decimalCount = 0, fractionalCount = 0;
    BOOL intMode = YES;
    // split int and fraction 
    for (int i = 0; i < count; i++) { 
        unichar c = chars[i];
        if (c == '.') {
            if (intMode) { 
                intMode = NO;            
            } else {
                goto bad;    
            }
            continue;
        }
        if ('0' <= c && c <= '9') { 
            if (intMode) {
                decimal[decimalCount++] = c;
            } else {
                fraction[fractionalCount++] = c;
            }
            continue;
        }
        if (c == ' ') { 
           continue;
        }
        if ((c == '-' || c == '+') && intMode && decimalCount == 0) { 
            sign = c;
            continue;
        }
        goto bad;   
    }
    
    // remove leading and traing zeros
    int decimalStart = 0;
    for (; decimalStart < decimalCount; decimalStart++) { 
        if (decimal[decimalStart] != '0') { 
            break;
        }
    }
    while (fractionalCount && fraction[fractionalCount-1] == '0') {  
       fractionalCount--;       
    }
    
    // form results
    int offset = 0;
    int startOffset = 0;
    if (sign) { 
        startOffset++;
        chars[offset++] = sign;
    }
    
    // decimals
    unichar * dp = decimal + decimalStart;
    decimalCount -= decimalStart;
    
    if (flags & INFORMAT_ONLY_POSITIVE) { 
        if (fractionalCount == 0 && ((decimalCount == 0) || (decimalCount == 1 && dp[0] == '0'))) {
            goto bad;    
        }
        if (sign == '-') {
            goto bad;
        }
    }
    if (decimalCount == 0) { 
        chars[offset++] = '0';
    } else { 
        for (int i = 0; i < decimalCount; i++) { 
            if ((offset > startOffset) && ((decimalCount - i) % 3) == 0) { 
                for (int j = 0; j < g_NumberFormatData.groupSeparatorLength; j++) { 
                    chars[offset++] = g_NumberFormatData.groupSeparator[j];      
                }
            }
            chars[offset++] = dp[i];
        }
    }
  
    if (fractionalCount || fracMinLen > 0 ) {
        // decimalPoint
        for (int j = 0; j < g_NumberFormatData.decimalSeparatorLength; j++) { 
            chars[offset++] = g_NumberFormatData.decimalSeparator[j];      
        }
                 
        // fractional points
        for (int j = 0; j < fractionalCount; j++) { 
            chars[offset++] = fraction[j];      
        }
        for (int j = fractionalCount; j < fracMinLen; j++) {
            chars[offset++] = '0';
        }
    }
    
    NSString * result = [NSString stringWithCharacters:chars length:offset];
    return result;
             
bad:
    return  g_NumberFormatData.badValue;                      
}

@end

//==================================================================================================================================
//==================================================================================================================================

// NSString * INDateFormat;

static INDateFormatter * g_Formatter = nil;

@implementation INDateFormatter

@synthesize locale = _locale;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setLocale:(NSLocale *)value { 
    if (_locale != value) { 
        [_locale autorelease];
        _locale = [value retain];
        for (NSDateFormatter * fmt in _formatters.allValues) { 
            fmt.locale = _locale;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {
        _formatters = [NSMutableDictionary new];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_formatters release];
    [_locale release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (INDateFormatter *)sharedFormatter { 
    if (!g_Formatter) { 
        NSAssert([NSThread isMainThread], @"59f2dcf4_33f3_42bb_a43c_6b06d322ce4e Call it from main thread first!");
        g_Formatter = [INDateFormatter new];
    }
    return g_Formatter;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setRussianLocale { 
    self.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"ru"] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDateFormatter *)registerFormatterWithString:(NSString *)dateFormatString key:(NSString *)key { 
    NSParameterAssert(key);
    NSParameterAssert(dateFormatString);
    NSDateFormatter * fmt = [NSDateFormatter new];
    if (_locale) { 
        fmt.locale = _locale;
    }
    fmt.dateFormat = dateFormatString;
    [_formatters setObject:fmt forKey:key];
    [fmt release];
    return fmt;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDateFormatter *)registerFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle 
                                          timeStyle:(NSDateFormatterStyle)timeStyle 
                                                key:(NSString *)key { 
    NSParameterAssert(key);
    NSDateFormatter * fmt = [NSDateFormatter new];
    if (_locale) { 
        fmt.locale = _locale;
    }
    fmt.dateStyle = dateStyle;
    fmt.timeStyle = timeStyle;
    [_formatters setObject:fmt forKey:key];
    [fmt release];
    return fmt;
}    

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)formatDate:(NSDate *)date withFormatKey:(NSString *)fmtKey { 
    NSDateFormatter * fmt = [_formatters objectForKey:fmtKey];
    return [fmt stringFromDate:date];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)dateFromString:(NSString *)string withFormatKey:(NSString *)fmtKey { 
    NSDateFormatter * fmt = [_formatters objectForKey:fmtKey];
    return [fmt dateFromString:string];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSDate (INRU_Format)

- (NSString *)inru_formatWithKey:(NSString *)fmtKey { 
     return [[INDateFormatter sharedFormatter] formatDate:self withFormatKey:fmtKey];    
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSDate *)inru_dateFromString:(NSString *)string withFormatKey:(NSString *)fmtKey {  
     return [[INDateFormatter sharedFormatter] dateFromString:string withFormatKey:fmtKey];    
}

@end

