//!
//! @file INCommonTypes.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @author Igor Pokrovsky
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

#import "INCommonTypes.h"
#include <sys/time.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <unistd.h>

@implementation NSMutableArray (INRU)

+ (NSMutableArray*)inru_nonRetainingArray {
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    NSMutableArray *array;
    callbacks.retain = NULL;
    callbacks.release = NULL;
#if !__has_feature(objc_arc)
    array = (NSMutableArray*)CFArrayCreateMutable(NULL,0,&callbacks);
    return [array autorelease];
#else 
    array = (__bridge NSMutableArray*)CFArrayCreateMutable(NULL,0,&callbacks);
    return array;
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_shuffle {
    /* http://en.wikipedia.org/wiki/Knuth_shuffle */
	
    for(NSInteger i = [self count] - 1; i >= 1; i--) {
        NSInteger j = INRandomInRange(0, i);
        [self exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSMutableString (INRU)

- (void)inru_clear {
    NSRange r;
    if ((r.length = self.length)) { 
        r.location = 0; 
        [self deleteCharactersInRange:r];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------
// этот враппер процентов на 30-50 медленее непосредственно вызываемого CFStringAppendCharacters
- (void)inru_appendUnichar:(unichar)c { 
    CFStringAppendCharacters((CFMutableStringRef)self,&c,1);
}

//----------------------------------------------------------------------------------------------------------------------------------

// a helper for [NSString inru_stripHtmlTags]. not for using outside
- (void)inru_private_appendToStrippedHtml:(NSString *)html {
    NSCharacterSet * set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    // mk:removed. if you need that - use inru_htmlToPlain 
    // html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    BOOL prevCharIsSpace = !self.length || [set characterIsMember:[self characterAtIndex:self.length-1]];
 
    CFStringInlineBuffer inlineBuffer;
    CFIndex htmlLength = CFStringGetLength((CFStringRef)html);
    CFStringInitInlineBuffer((CFStringRef)html, &inlineBuffer, CFRangeMake(0, htmlLength));
    
    for (int i = 0; i < htmlLength; i++){
        UniChar c = CFStringGetCharacterFromInlineBuffer(&inlineBuffer, i);
        // for (int i = 0; i < len; i++){ 
        // unichar c = [html characterAtIndex:i];
        BOOL addChar = YES;
        if ([set characterIsMember:c]){ 
            if (prevCharIsSpace){ 
                addChar = NO;
            } else {
                prevCharIsSpace = YES;
                c = ' ';
            }
        } else {
            prevCharIsSpace = NO;
        }
        if (addChar){
            CFStringAppendCharacters((CFMutableStringRef)self, &c, 1);
        }
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSString (INRU)

//----------------------------------------------------------------------------------------------------------------------------------

+ (BOOL)inru_string:(NSString *)string isEqualTo:(NSString *)otherString {
    if (! string ){
        return otherString.length == 0;
    } else 
    if (! otherString ){
        return string.length == 0;
    } else {
        return [string isEqualToString:otherString];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

//  todo: проверить, возможно fileSystemRepresentation сделает то же самое
//  todo: может быть некоторые символы таки можно использовать или экранировать
- (NSString *)inru_normalizeFileName {
    NSMutableString * string = [NSMutableString stringWithCapacity:self.length];
    for (int i = 0; i < self.length; i++) {
        unichar c = [self characterAtIndex:i];
        switch (c) { 
            case '?':
            case '&':
            case '/':
            case '<':
            case '>':
            case '|':
            case '*':
            case '\\':            
            case ':': c = '_';
                      break;
        }
        [string inru_appendUnichar:c];
    }
    return string;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSStringEncoding)inru_stringToEncoding { 
    // 
    // Not fully implemented. Most encodings are skipped. Add yourself what you need.
    //
    // mk:optimize - put in into map when it will become too big?
/*
    static struct ENCODING {
        NSString * name; 
        NSStringEncoding encoding;     
    } ENCODINGS[] = {
        { @"windows-1251", NSWindowsCP1251StringEncoding } 
    };
   
    NSString * lcString = [self lowercaseString];
    for (int i = 0; i < sizeof(ENCODINGS)/ sizeof( struct ENCODING); i++){
        if ([ENCODINGS[i].name isEqualToString:lcString]){
            return ENCODINGS[i].encoding;
        }
    }
    return 0;
    
    // mk: модифицировано к ARC. Кандидат на удаление, кажется эта фича уже бессмыслена в новых версиях оси
*/
    NSString * lcString = [self lowercaseString];
    if ([@"windows-1251" isEqualToString:lcString]){
        return NSWindowsCP1251StringEncoding;
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_stripHtmlTags { 
    NSMutableString * result = [NSMutableString stringWithCapacity:self.length];
    NSRange r = NSMakeRange(0, self.length);
    while (r.location < self.length){
        NSRange r2 = [self rangeOfString:@"<" options:NSLiteralSearch range:r];
        if (r2.length == 0){
            [result inru_private_appendToStrippedHtml:[self substringFromIndex:r.location] ];
            break;
        }
        [result inru_private_appendToStrippedHtml:[self substringWithRange:
                                                   NSMakeRange(r.location, r2.location - r.location)]];
        r.length   -= r2.location - r.location;
        r.location  = r2.location;
        r2 = [self rangeOfString:@">" options:NSLiteralSearch range:r];
        if (r2.length == 0){
            break;
        }
        r.length   -= r2.location - r.location + 1;
        r.location  = r2.location + 1;
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_htmlToPlain { 
    NSString        * str = [self inru_stripHtmlTags];
    if (!str) { 
        return @"";
    }
    NSMutableString * result   = [NSMutableString stringWithCapacity:str.length];
    NSScanner       * scanner  = [NSScanner scannerWithString:str];
    NSCharacterSet  * ampSet   = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    NSCharacterSet  * colonSet = [NSCharacterSet characterSetWithCharactersInString:@";"];
    
    scanner.charactersToBeSkipped = nil;
    while (! scanner.isAtEnd){
        NSString * s = nil;
        [scanner scanUpToCharactersFromSet:ampSet intoString:&s];
        if (s.length){
            [result appendString:s];     
        }
        if (scanner.isAtEnd)break;
        [scanner scanString:@"&" intoString:NULL];
        
        s = nil;
        [scanner scanUpToCharactersFromSet:colonSet intoString:&s];
        if (s.length){
            static NSDictionary * dict = nil;
            if (!dict){ 
               dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                         // todo: compare and extend the list with http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
                         // 
                         
                          // All symbols are different. They only look similar in the monospaced font!
                        
                          @" ",   @"nbsp",  // неразрывный пробел
                          @" ",   @"ensp",  // узкий пробел (еn-шириной в букву n)
                          @" ",   @"emsp",  // широкий пробел (em-шириной в букву m)	&;	  
                          @"–",   @"ndash", // узкое тире (en-тире)
                          @"—",   @"mdash", // широкое тире (em -тире)
                        
                          @"",    @"shy",   //  мягкий перенос 
                          
                          @"\'",  @"apos",
                          @"\"",  @"quot",
                          @"′",   @"prime", // 
                          @"″",   @"Prime", // 
                          @"“",   @"ldquo", // 
                          @"„",   @"bdquo", // 
                          @"”",   @"rdquo", // 
                          @"«",   @"laquo", // 
                          @"»",   @"raquo", // 
                          @"‹",   @"lsaquo", // 
                          @"›",   @"rsaquo", // 
                          @"‘",   @"lsquo", // 
                          @"’",   @"rsquo", // 
                          @"‚",   @"sbquo", // 
                        
                          @"¢",   @"cent",   // 
                          @"£",   @"pound",  // 
                          @"€",   @"euro",   // 
                          @"¥",   @"yen",    // 
                          @"¤",   @"curren", // 
                          @"ƒ",   @"fnof",   // 
                        
                          @"§",   @"sect", // 
                          @"°",   @"deg", // 
                          @"…",   @"hellip", // 
                          @"©",   @"copy", // 
                          @"®",   @"reg", // 
                          @"™",   @"trade", // 
                          @"µ",   @"micro", // 
                          @"‰",   @"permil", // 
                          @"&",   @"amp", // 
                          @"‾",   @"oline", // 
                          @"´",   @"acute", // 
                          @"¦",   @"brvbar", // 
                          @"¶",   @"para", // 
                          
                          @"•",   @"bull",   // 
                          @"·",   @"middot", // 
                          @"†",   @"dagger", // 
                          @"‡",   @"Dagger", // 
                          @"♠",   @"spades", // 
                          @"♣",   @"clubs",  // 
                          @"♥",   @"hearts", // 
                          @"♦",   @"diams",  // 
                          @"◊",   @"loz",    // 
                        
                          @"←",   @"larr", // 
                          @"↑",   @"uarr", // 
                          @"→",   @"rarr", // 
                          @"↓",   @"darr", // 
                          @"↔",   @"harr", // 
                        
                          @"×",   @"times", // 
                          @"÷",   @"divide", // 
                          @"⁄",   @"frasl", // 
                          @"−",   @"minus", // 
                        
                          @"<",   @"lt", // 
                          @">",   @"gt", // 
                          @"≤",   @"le", // 
                          @"≥",   @"ge", // 
                          @"≈",   @"asymp", // 
                          @"≠",   @"ne", // 
                          @"≡",   @"equiv", // 
                          @"±",   @"plusmn", // 
                          @"¼",   @"frac14", // 
                          @"½",   @"frac12", // 
                          @"¾",   @"frac34", // 
                          @"¹",   @"sup1", // 
                          @"²",   @"sup2", // 
                          @"³",   @"sup3", // 
                          @"√",   @"radic", // 
                          @"∞",   @"infin", // 
                          @"∑",   @"sum", // 
                          @"∏",   @"prod", // 
                          @"∂",   @"part", // 
                          @"∫",   @"int", // 
                        nil
                       ];
            }
            NSString * s1 = [dict objectForKey:s];
            if (s1){
               s = s1;
            } else {
               // #warning убрать
               // NSLog(@"-------------------- inru_htmlToPlain: unhandled keyword: %@", s); 
               s = [NSString stringWithFormat:@"&%@;",s];    
            }
            [result appendString:s];     
        }
        [scanner scanString:@";" intoString:NULL];
    }
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)inru_loremIpsumOfLength:(NSInteger)length {
    NSString * lorem = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore "
                       @"et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip "
                       @"ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat "
                       @"nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim "
                       @"id est laborum. ";

    return [@"" stringByPaddingToLength:length withString:lorem startingAtIndex:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)inru_stringFromData:(NSData *)data { 
    NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
#if !__has_feature(objc_arc)
    [string autorelease];
#endif
    return string;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_trim { 
    NSCharacterSet * set = [NSCharacterSet whitespaceAndNewlineCharacterSet]; 
    return [self stringByTrimmingCharactersInSet:set];   
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_trimLeft { 
    NSCharacterSet * set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSScanner * scanner = [NSScanner scannerWithString:self];
    scanner.charactersToBeSkipped = nil;
    if ([scanner scanCharactersFromSet:set intoString:nil]){ 
        return [self substringFromIndex:scanner.scanLocation];  
    } else {
        return [NSString stringWithString:self];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString * )inru_newUUID {
#if !__has_feature(objc_arc)
    CFUUIDRef  uuidObj = CFUUIDCreate(nil);
    NSString * newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
#else
    CFUUIDRef  uuidObj = CFUUIDCreate(nil);
    NSString * newUUID = CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return newUUID;
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_capitalizeFirstLetter { 
    NSRange r = { 0, 1 };
    return self.length ? [self stringByReplacingCharactersInRange:r  
                                         withString:[[self substringToIndex:1] uppercaseString]] : @"";
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_md5Digest {
    const char * str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (NSString *)inru_sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;    
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (NSString *)inru_sha256 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;    
}

@end


//==================================================================================================================================
//==================================================================================================================================

@implementation NSDate (INRU)

+ (NSDate *)inru_todayMidnight { 
    return [[NSDate date] inru_trimTime];   
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSDate *)inru_dateFromString:(NSString *)string withFormat:(NSString *)format { 
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSLocale * enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:enUS];
    [formatter setDateFormat:format];
    NSDate * result = [formatter dateFromString:string];
#if !__has_feature(objc_arc)
    [enUS release];
    [formatter release];
#endif
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_toStringWithFormat:(NSString *)format locale:(NSString*)locale { 
    NSDateFormatter * fmt = [NSDateFormatter new];
    [fmt setDateFormat:format]; 
	NSLocale * someLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    [fmt setLocale:someLocale];
    NSString * str = [fmt stringFromDate:self];
    
#if !__has_feature(objc_arc)
    [someLocale release];
    [fmt release];
#endif
    return str;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (NSString *)inru_toStringWithFormat:(NSString *)format { 
    NSDateFormatter * fmt = [NSDateFormatter new];
    [fmt setDateFormat:format]; 
    NSString * str = [fmt stringFromDate:self];
#if !__has_feature(objc_arc)
    [fmt release];
#endif
    return str;
}

//----------------------------------------------------------------------------------------------------------------------------------

/* 
+ (NSDateFormatter * )inru_rfc2822Formatter {
    static NSDateFormatter * formatter = nil;
    if (formatter == nil){
        formatter = [[NSDateFormatter alloc] init];
        NSLocale * enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:enUS];
        [enUS release];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    }
    return formatter;
}

// return [self inru_dateFromRfc822String:string]; 

*/
//----------------------------------------------------------------------------------------------------------------------------------

+ (NSDate *)inru_dateFromRfc822String:(NSString *)string {
    
    // убираем опциональный денб недели в начале
    NSRange r = [string rangeOfString:@", "];
    if (r.location != NSNotFound) { 
        string = [string substringFromIndex:r.location+2];
    }
    
    // форматер. он нормально переваривает двухцифровой год и односимвольный месяц, 
    // но не понимает время без секунд. 
    // Если нужно работать с форматом HH:MM - то надо расширить все это дело 
    static NSDateFormatter * formatter = nil;
    if (formatter == nil){
        formatter = [NSDateFormatter new];
        NSLocale * enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:enUS];
        #if !__has_feature(objc_arc)
            [enUS release];
        #endif
        [formatter setDateFormat:@"dd MMM yyyy HH:mm:ss z"];
    }
    
    /* 
        NSString * s = [formatter stringFromDate:[NSDate date]];
        NSDate * d   = [formatter dateFromString:@"Sat, 05 May 2012 06:03:00 EDT"];
        NSDate * d2  = [formatter dateFromString:@"Sat, 05 May 12 06:00:00 GMT+0444"];
        NSDate * d3  = [formatter dateFromString:s];
        NSLog(@"%@", d2);
    */
        
    NSDate * result = [formatter dateFromString:string];     
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)inru_daysInThisMonth { 
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange result = [calendar rangeOfUnit:NSDayCalendarUnit 
                                    inUnit:NSMonthCalendarUnit 
                                   forDate:self];
#if !__has_feature(objc_arc)
    [calendar release];
#endif
    return result.length;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)inru_beginOfWeek { 
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * comps = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSInteger delta = (7 + comps.weekday - calendar.firstWeekday) % 7;

    NSDateComponents * offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-delta];
    NSDate * d = [[calendar dateByAddingComponents:offsetComponents toDate:self options:0] inru_trimTime];
#if !__has_feature(objc_arc)
    [offsetComponents release];
    [calendar release];
#endif
    return d;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSDate*) inru_dateFromComponents:(INDateComponents)input {
	NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	comps.year = input.year;
	comps.month = input.month;
	comps.day = input.day;
	comps.hour = input.hour;
	comps.minute = input.minute;
	comps.second = input.second;
	NSDate *date = [calendar dateFromComponents:comps];
#if !__has_feature(objc_arc)
	[comps release];
    [calendar release];
#endif
	
	return date;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (INDateComponents)inru_components { 
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * comps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
                                                    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | 
                                                    NSWeekdayCalendarUnit fromDate:self];
 
    INDateComponents result = {
       .year = comps.year, 
       .month = comps.month, 
       .day = comps.day, 
       .hour = comps.hour, 
       .minute = comps.minute, 
       .second = comps.second,
       .weekday = comps.weekday
    };
#if !__has_feature(objc_arc)
    [calendar release];
#endif
    return result;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (INDateComponents) inru_diffToDate:(NSDate*)date {	
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSUInteger compMask = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | 
						  NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comps = [cal components:compMask fromDate:self toDate:date options:0];
#if !__has_feature(objc_arc)
	[cal release];
#endif
	
    INDateComponents result = {
		.year = comps.year, 
		.month = comps.month, 
		.day = comps.day, 
		.hour = comps.hour, 
		.minute = comps.minute, 
		.second = comps.second,
		.weekday = comps.weekday
    };
	return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)inru_dateByAddingComponents:(NSDateComponents *)offsetComponents { 
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate * d = [calendar dateByAddingComponents:offsetComponents 
                                           toDate:self options:0];
#if !__has_feature(objc_arc)
    [calendar release];
#endif
    return d;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)inru_incMonth:(NSInteger)increment { 
    NSDateComponents * offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:increment];
    NSDate * d = [self inru_dateByAddingComponents:offsetComponents];
#if !__has_feature(objc_arc)
    [offsetComponents release];
#endif
    return d;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)inru_incDay:(NSInteger)increment { 
    NSDateComponents * offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:increment];
    NSDate * d = [self inru_dateByAddingComponents:offsetComponents];
#if !__has_feature(objc_arc)
    [offsetComponents release];
#endif
    return d;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)inru_incMinute:(NSInteger)increment { 
    NSDateComponents * offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMinute:increment];
    NSDate * d = [self inru_dateByAddingComponents:offsetComponents];
#if !__has_feature(objc_arc)
    [offsetComponents release];
#endif
    return d;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

- (NSDate*)inru_incHour:(NSInteger)increment {
	return [self inru_incMinute:increment*60];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)inru_trimTime { 
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * comps = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | 
                                                     NSYearCalendarUnit fromDate:self];
    [comps setHour: 0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate * date = [calendar dateFromComponents:comps];
#if !__has_feature(objc_arc)
    [calendar release];
#endif
    return date;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isToday { 
    return 0 == [[self inru_trimTime] compare:[NSDate inru_todayMidnight]];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isBefore:(NSDate *)otherDate { 
    return otherDate && [self compare:otherDate] == NSOrderedAscending; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isAfter:(NSDate *)otherDate { 
    return !otherDate || [self compare:otherDate] == NSOrderedDescending; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isAfterOrEqual:(NSDate *)otherDate { 
    return !otherDate || [self compare:otherDate] != NSOrderedAscending; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isBeforeOrEqual:(NSDate *)otherDate { 
    return otherDate && [self compare:otherDate] != NSOrderedDescending; 
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSError (INRU)
 
+ (id)inru_errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    NSString * message = [NSString stringWithFormat:format, ap];
    va_end(ap);
    return [NSError errorWithDomain:domain
                               code:code
                           userInfo:message ? [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey] : nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isURLDomainError {
    return [self.domain isEqualToString:NSURLErrorDomain];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isURLDomainError:(NSInteger)errorCode {
    return [self inru_isURLDomainError] && (self.code == errorCode);    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isNetworkError { 
    return [self.domain isEqualToString:NSURLErrorDomain] ||
           [self.domain isEqualToString:INNetErrorDomain];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isAuthFailed { 
    return ([self inru_isURLDomainError:NSURLErrorUserCancelledAuthentication])||
           ([self.domain isEqualToString:INErrorDomain] && self.code == INErrorCodeAuthFailed); 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_networkErrorNoInternet { 
    return [self inru_isURLDomainError] && (self.code == NSURLErrorNotConnectedToInternet);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_networkErrorCanceled { 
    if ([self inru_isURLDomainError] && (self.code == NSURLErrorCancelled)) { 
         return YES;
    }
    if ([self.domain isEqualToString:@"WebKitErrorDomain"] && self.code == 102 /* WebKitErrorFrameLoadInterruptedByPolicyChange */) { 
        return YES;
    }
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)inru_isINError:(NSInteger)errorCode {
    return (self.code == errorCode) && 
           ([self.domain isEqualToString:INErrorDomain] || [self.domain isEqualToString:INNetErrorDomain]);
}

@end

//==================================================================================================================================
//==================================================================================================================================

NSString * INErrorDomain    = @"INErrorDomain"; 
NSString * INNetErrorDomain = @"INNetErrorDomain"; 
NSString * INNetErrorHTTPResponseKey = @"NSHTTPURLResponse";


@implementation INError

+ (id)errorWithCode:(INErrorCode)code description:(NSString *)description { 
    INError * err = [INError errorWithDomain:INErrorDomain 
                                        code:code 
                                    userInfo:[NSDictionary dictionaryWithObject:description 
                                                                          forKey:NSLocalizedDescriptionKey]];
    
    return err;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)errorWithCode:(INErrorCode)code  { 
    INError * err = [INError errorWithDomain:INErrorDomain 
                                        code:code 
                                    userInfo:nil];
    
    return err;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)localizedDescription { 
    NSString * result = [self.userInfo objectForKey:NSLocalizedDescriptionKey];
    if (result.length == 0){ 
        if ([self.domain isEqualToString:INErrorDomain] || 
            [self.domain isEqualToString:INNetErrorDomain] ){
            
            static NSDictionary * CodeMessage1 = nil;
            if (!CodeMessage1) {
                CodeMessage1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Bad parameter", @"en",
                                    @"Недопустимый параметр", @"ru", nil], [NSNumber numberWithInt:INErrorCodeBadParameter],

                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Bad HTTP response status code", @"en",
                                    @"Ошибка запроса HTTP", @"ru", nil], [NSNumber numberWithInt:INErrorCodeBadHTTPStatusCode],

                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Session is not opened", @"en",
                                    @"Сессия не открыта", @"ru", nil], [NSNumber numberWithInt:INErrorCodeSessionNotOpened],

                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Authorization failed. Wrong password or username", @"en",
                                    @"Ошибка авторизации. Неправильное имя пользователя или пароль", @"ru", nil],
                                    [NSNumber numberWithInt:INErrorCodeAuthFailed],

                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Unknown data format", @"en",
                                    @"Неизвестный формат данных", @"ru", nil], [NSNumber numberWithInt:INErrorCodeBadData],
                
                                 nil];
            }
            
            int code1 = self.code;
            NSString * langKey = @"en";
            if (INIsRussianLocalization()) {
                langKey = @"ru";
            }
            result = [[CodeMessage1 objectForKey:[NSNumber numberWithInt:code1]] objectForKey:langKey];
            if (result) {
                // special handling for HTTP Bad response
                if (code1 == INErrorCodeBadHTTPStatusCode) { 
                    id r = [self.userInfo objectForKey:INNetErrorHTTPResponseKey];
                    if ([r isKindOfClass:NSHTTPURLResponse.class]) { 
                        result = [NSString stringWithFormat:@"%@: %d (%@)",result, [r statusCode], 
                                 [NSHTTPURLResponse localizedStringForStatusCode:[r statusCode]]];    
                    }
                }
            }
        }
    }
    if (!result){ 
        result = /* [self inru_localizedDescriptionForMsg:*/[super localizedDescription]; // ];    
    }
    return result;
}

@end

//==================================================================================================================================
//==================================================================================================================================

CGRect INRectNormalize(CGRect src){ 
    CGRect r;
    r.origin.x = rint(src.origin.x);
    r.origin.y = rint(src.origin.y);
    r.size.width = rint(src.size.width);
    r.size.height = rint(src.size.height);
    return r;
}

//----------------------------------------------------------------------------------------------------------------------------------

CGRect INRectAspectFitRectInRect(CGRect rect, CGRect boundRect) { 
    NSCParameterAssert(rect.size.width && rect.size.height && boundRect.size.width && boundRect.size.height);
    CGFloat rratio = rect.size.width / rect.size.height;
    CGFloat bratio = boundRect.size.width / boundRect.size.height;
    
    if (rratio > bratio) { 
        rect.size.height = rect.size.height * boundRect.size.width / rect.size.width;
        rect.size.width = boundRect.size.width;
    } else { 
        rect.size.width = rect.size.width * boundRect.size.height / rect.size.height;
        rect.size.height = boundRect.size.height;
    }
    
    rect.origin.x = (boundRect.size.width - rect.size.width) / 2 + boundRect.origin.x;
    rect.origin.y = (boundRect.size.height - rect.size.height) / 2 + boundRect.origin.y;
    // rect.size.width = MIN(boundRect.size.width,rect.size.width);
    // rect.size.height = MIN(boundRect.size.height,rect.size.height);
    return rect;
}

//----------------------------------------------------------------------------------------------------------------------------------

CGRect INRectAspectFillRectInRect(CGRect rect, CGRect boundRect) { 
    NSCParameterAssert(rect.size.width && rect.size.height && boundRect.size.width && boundRect.size.height);
    CGFloat rratio = rect.size.width / rect.size.height;
    CGFloat bratio = boundRect.size.width / boundRect.size.height;
    
    if (rratio < bratio) { 
        rect.size.height = rect.size.height * boundRect.size.width / rect.size.width;
        rect.size.width = boundRect.size.width;
    } else { 
        rect.size.width = rect.size.width * boundRect.size.height / rect.size.height;
        rect.size.height = boundRect.size.height;
    }
    
    rect.origin.x = (boundRect.size.width - rect.size.width) / 2 + boundRect.origin.x;
    rect.origin.y = (boundRect.size.height - rect.size.height) / 2 + boundRect.origin.y;
    /* 
     rect.size.width = MIN(boundRect.size.width,rect.size.width);
     rect.size.height = MIN(boundRect.size.height,rect.size.height);
     */
    return rect;
}

//----------------------------------------------------------------------------------------------------------------------------------

void INRectSplitInto2Rects(CGRect src, CGFloat leftRectWidth, CGRect * leftR, CGRect * rightR){
    if (leftR) {
        *leftR = src;
        leftR->size.width = leftRectWidth;
    }
    
    if (rightR) { 
        *rightR = src;
        rightR->origin.x = src.origin.x + leftRectWidth;
        rightR->size.width = src.size.width - leftRectWidth;
    }
}

void INRectSplitInto2VertRects(CGRect src, CGFloat topRectHeight, CGRect *topR, CGRect *bottomR){
    if (topR) {
        *topR = src;
        topR->size.height = topRectHeight;
    }
    
    if (bottomR) { 
        *bottomR = src;
        bottomR->origin.y = src.origin.y + topRectHeight;
        bottomR->size.height = src.size.height - topRectHeight;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

CGRect INRectInset(CGRect src, CGFloat left, CGFloat top, CGFloat right, CGFloat bottom){
    CGRect result = src;
    result.origin.x += left;
    result.size.width -= left + right;
    result.origin.y += top;
    result.size.height -= bottom + top;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

CGRect INRectResize(CGRect src, CGFloat dx, CGFloat dy) {
	CGRect result = src;
	result.size.width += dx;
	result.size.height += dy;
	return result;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

CGFloat INPointDistance(CGPoint point1, CGPoint point2){ 
    CGFloat x = point1.x - point2.x;
    CGFloat y = point1.y - point2.y;
    return sqrt(x * x + y * y);     
}

//==================================================================================================================================
//==================================================================================================================================
/* 
@implementation NSSet(INRU)

- (void)inru_splitToObjects:(id *)firstObj, ...  {
    va_list ap;
        id * obj = nil;
        BOOL firstObjProcessing = YES;
    va_start(ap, firstObj);
        // fill from set
        for (id objInSet in self){
            if (firstObjProcessing){ 
                obj = firstObj;  
                firstObjProcessing = NO;
            } else {
                obj = va_arg(ap, id *);
            }
            if (obj == nil)break;
            *obj = objInSet;
        }
        // reset rest of arguments
        while (obj){
            obj = va_arg(ap, id *);
            if (obj){ 
                *obj = nil;    
            }
        }
    va_end(ap);
}

@end
*/

//==================================================================================================================================
//==================================================================================================================================

@implementation NSDictionary(INRU)

/* 
- (NSInteger)inru_integerForKey:(id)aKey defaultValue:(NSInteger)defaultValue { 
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSNumber class]]){ 
        return [(NSNumber *)obj integerValue];
    }
    return defaultValue;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (double)inru_doubleForKey:(id)aKey defaultValue:(double)defaultValue { 
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSNumber class]]){ 
        return [(NSNumber *)obj doubleValue];
    }
    return defaultValue;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_stringForKey:(id)aKey defaultValue:(NSString *)defaultValue { 
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSString class]]){ 
        return (NSString *)obj;
    }
    return defaultValue;
}

*/

//----------------------------------------------------------------------------------------------------------------------------------

static NSString * _inru_CorrectEscaping(NSString * srcString, NSStringEncoding encoding) { 
    
    // see here
    // http://stackoverflow.com/questions/705448/iphone-sdk-problem-with-ampersand-in-the-url-string
    // 
    
    CFStringInlineBuffer inlineBuffer;
#if !__has_feature(objc_arc)
    CFStringRef str = (CFStringRef)[srcString stringByAddingPercentEscapesUsingEncoding:encoding];
#else 
    CFStringRef str = (__bridge CFStringRef)[srcString stringByAddingPercentEscapesUsingEncoding:encoding];
#endif
    if (!str) { 
        return @"";
    } 
    CFIndex length = CFStringGetLength(str);
    CFStringInitInlineBuffer(str, &inlineBuffer, CFRangeMake(0, length));
 
    NSMutableString * result = [NSMutableString stringWithCapacity:length]; 
 
    UniChar ch[3];
    for (CFIndex cnt = 0; cnt < length; cnt++) {
         ch[0] = CFStringGetCharacterFromInlineBuffer(&inlineBuffer, cnt);
         int chCount = 1;
         switch (ch[0]) { 
             case '$':
             case '&':
             case '+':
             case ',':
             case '/':
             case ':':
             case ';':
             case '=':
             case '?':
             case '@':
             case ' ':
             case '\t':
             case '#':
             case '<':
             case '>':
             case '\\':
             case '\n':
                 { 
                    chCount = 3;
                    char c[30];
                    sprintf(c,"%X",ch[0]);
                    ch[0] = '%';
                    ch[1] = c[0];
                    ch[2] = c[1];
                 }
                 break;
        }
        CFStringAppendCharacters((CFMutableStringRef)result, ch, chCount);
    }
    return result;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)_inru_internal_serializeForHTTPUsingEncoding:(NSStringEncoding)encoding { 
    NSMutableString * result = [NSMutableString string];
    BOOL firstString = YES;
    for (id key in self) { 
        [result appendFormat:@"%@%@=%@",
                (firstString ? @"" : @"&"),
                _inru_CorrectEscaping([key description],encoding),
                _inru_CorrectEscaping([[self objectForKey:key] description],encoding)];
        firstString = NO;
    }
    // NSLog(@"--- %@",result);
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSData *)inru_serializeAsHTTPPostFormBodyUsingEncoding:(NSStringEncoding)encoding {
    return [[self _inru_internal_serializeForHTTPUsingEncoding:encoding] dataUsingEncoding:encoding]; // ммм. кажется, во втором случае надо ASCII Encoding
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)inru_serializeAsHTTPGetString {
    return [self _inru_internal_serializeForHTTPUsingEncoding:NSUTF8StringEncoding];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSMutableDictionary(INRU)

- (void)inru_setObject:(id)anObject forKey:(id)aKey { 
    if (aKey) { 
        if (anObject) { 
            [self setObject:anObject forKey:aKey];
        } else {
            [self removeObjectForKey:aKey];
        }
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INNibLoader

@synthesize tableCell = _tableCell;
@synthesize cacheNib = _cacheNib;
@synthesize view = _view;


+ (INNibLoader *)sharedLoader {
    static INNibLoader * loader = nil;
    if (!loader) { 
        loader = [INNibLoader new];
        loader.cacheNib = NO;
    }
    return loader;
}

//----------------------------------------------------------------------------------------------------------------------------------

-(id)init { 
    self = [super init];
    if (self != nil) {
        _cacheNib = YES;
    }
    return self;
}    

//----------------------------------------------------------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
- (void)dealloc {
    [_tableCell release];
    [_view release];
    [super dealloc];
}
#endif

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)loadCellFromNib:(NSString *)nibFile reuseIdentifier:(NSString *)reuseIdentifier {
    [[NSBundle mainBundle] loadNibNamed:nibFile owner:self options:nil];
    
    //
    //  todo: implement nib caching (UINib)
    //
    
    UITableViewCell * cell = _tableCell;
#ifndef NS_BLOCK_ASSERTIONS
    if (!_tableCell) { 
        @throw [NSException exceptionWithName:@"INNibLoaderCellNotFoundException" 
                                       reason:[NSString stringWithFormat:@"INNibLoader: could not load nib's cell from '%@'.", nibFile]
                                     userInfo:nil];
    }

    if (reuseIdentifier) { // you can pass nil if you want to skip checking
        if (![cell.reuseIdentifier isEqualToString:reuseIdentifier]) { 
            @throw [NSException exceptionWithName:@"INNibLoaderCellReuseIDMismathException" 
                                           reason:[NSString stringWithFormat:@"INNibLoader: an attempt to load nib's cell with reuseIdentifier '%@'."
                                                                             @" Expected value is '%@'! (forgot to assign cell identifier in Nib?)",
                                                                             cell.reuseIdentifier, reuseIdentifier]
                                         userInfo:nil];
        }
    }
#endif
    self.tableCell = nil;
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)reusableCellForTable:(UITableView *)tableView nibFile:(NSString *)nibFile reuseIdentifier:(NSString *)reuseIdentifier justLoaded:(BOOL *)justLoaded { 
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [self loadCellFromNib:nibFile reuseIdentifier:reuseIdentifier];
        if (justLoaded) { 
            *justLoaded = YES;
        }
    } else {
        if (justLoaded) { 
            *justLoaded = NO;
        }
    }
    return cell;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)reusableCellForTable:(UITableView *)tableView nibFile:(NSString *)nibFile reuseIdentifier:(NSString *)reuseIdentifier {
    return [self reusableCellForTable:tableView nibFile:nibFile reuseIdentifier:reuseIdentifier justLoaded:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)loadViewFromNib:(NSString *)nibFile { 
    [[NSBundle mainBundle] loadNibNamed:nibFile owner:self options:nil];
    UIView * result = _view;
    if (!_view) {
        @throw [NSException exceptionWithName:@"INNibLoaderViewNotFoundException" 
                                       reason:[NSString stringWithFormat:@"INNibLoader: could not load view '%@'. Forgot to assign 'view' outlet for File Owner?", nibFile]
                                     userInfo:nil];
    }
    self.view = nil;
    return result;
}

@end

//==================================================================================================================================
//==================================================================================================================================

BOOL INIPadInterface(){ 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    static BOOL cachedValue;
    static BOOL cacheResolved = NO;
    if (!cacheResolved) {
        cacheResolved = YES;
        cachedValue = UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad;
    }
    return cachedValue;
#else 
    return NO;
#endif 
}

//----------------------------------------------------------------------------------------------------------------------------------

BOOL INIPhoneInterface(){ 
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    static BOOL cachedValue;
    static BOOL cacheResolved = NO;
    if (!cacheResolved) {
        cacheResolved = YES;
        cachedValue = UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone;
    }
    return cachedValue;
#else 
    return YES;
#endif 
}

//----------------------------------------------------------------------------------------------------------------------------------

extern BOOL INSystemVersionEqualsOrGreater(NSInteger major, NSInteger minor, NSInteger build) { 
    static NSInteger _cachedVersion = 0;
    if (!_cachedVersion) {
        NSArray * array = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
        NSInteger v1 = array.count > 0 ? [[array objectAtIndex:0] intValue] : 0;
        NSInteger v2 = array.count > 1 ? [[array objectAtIndex:1] intValue] : 0;
        NSInteger v3 = array.count > 2 ? [[array objectAtIndex:2] intValue] : 0;
        _cachedVersion = (v1 << 16) | (v2 << 8) | v3;
    }
    
    return ((major << 16) | (minor << 8) | build) <= _cachedVersion; 
}

//----------------------------------------------------------------------------------------------------------------------------------

NSString * INAppName() { 
    NSString * result = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    // todo: переделать по-человечески, учитывая всякие локализации и нюансы
    return result;
}

NSString * INAppVersion() { 
    NSString * result = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    // todo: переделать по-человечески, учитывая всякие локализации и нюансы
    return result;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

NSDate *INAppBuildDate(void) {
	NSError *error = nil;	
	NSDate *exeDate = nil;
	
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSBundle mainBundle] executablePath]
																				error:&error];
	if (attributes && !error) {		
		return [attributes objectForKey:NSFileModificationDate];
	}
	
	return exeDate;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

NSString * INHardwarePlatform(void) {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

//----------------------------------------------------------------------------------------------------------------------------------
 
double INRandom(){
    static double maxValue = 4294967295.0;
    return ((double)arc4random())/maxValue;
}

//----------------------------------------------------------------------------------------------------------------------------------

NSInteger INRandomInRange(NSInteger minValue, NSInteger maxValue) { 
    if (minValue >= maxValue) { 
        return minValue;
    }
    
    NSInteger v = minValue + lround(INRandom() * (maxValue - minValue)); 
    return INNormalizeIntegerForRange(v,minValue,maxValue);
}

//----------------------------------------------------------------------------------------------------------------------------------

NSUInteger INTickCount() {
    struct timeval tv;
    if(gettimeofday(&tv, NULL) != 0) { 
        return 0;
    }
    return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
}

//----------------------------------------------------------------------------------------------------------------------------------

NSString * INFourByteNumberToString(SInt32 number) { 
    NSMutableString * str = [NSMutableString stringWithCapacity:4];
    number = CFSwapInt32HostToBig(number);
    for (int i = 0; i < 4; i++) { 
        unsigned char c = (number >> i * 8) & 0xff;
        //if (isalnum(c)) { 
        //    [str inru_appendUnichar:c];
        //} else {
            [str appendFormat:@"%c",c];
        //}
    }
    // NSInteger fakeCharArray[2] = { CFSwapInt32HostToBig(number), 0 };
    // return [NSString stringWithFormat:@"%s", fakeCharArray];
    return str;
}

//----------------------------------------------------------------------------------------------------------------------------------

//  подготовка телефонного номера к набору (не всякий телефонный номер воспринимается системой)
//
// SMS: This parameter can contain the digits 0 through 9 and the plus (+), hyphen (-), and period (.) characters. 
// The URL string must not include any message text or other information.

// TEL: To prevent users from maliciously redirecting phone calls or changing the behavior of a phone or account, 
// the Phone application supports most, but not all, of the special characters in the tel scheme. Specifically, if 
// a URL contains the * or # characters, the Phone application does not attempt to dial the corresponding phone number. 
// If your application receives URL strings from the user or an unknown source, you should also make sure that any 
// special characters that might not be appropriate in a URL are escaped properly. For native applications, use 
// the stringByAddingPercentEscapesUsingEncoding: method of NSString to escape characters, which returns a 
// properly escaped version of your original string.

static NSString * INNormalizeTelNo(NSString * telNo) {
    telNo = [telNo inru_trim];

    NSMutableString * result = [NSMutableString stringWithCapacity:telNo.length];
    
    BOOL prevSymbolsWasDashOrSpace = NO;
    for (int i = 0; i < telNo.length; i++) {
        unichar c = [telNo characterAtIndex:i];
        if (c == ' ' || c == '-' || c == '(' || c == ')') { 
            if (!prevSymbolsWasDashOrSpace) {     
                [result appendString:@"-"];
            } 
            prevSymbolsWasDashOrSpace = YES;
        } else {
            prevSymbolsWasDashOrSpace = (c == '+');
            [result inru_appendUnichar:c];
        }
    }
    return result;   
}

/*
__attribute__((constructor))void ttt() { 
    NSMutableString * a = [NSMutableString string];//WithCapacity:1000000];
    NSMutableString * b = [NSMutableString stringWithCapacity:1000000];
    NSUInteger t0 = INTickCount();
    unichar c = 0x1234;
    for (int i = 0; i < 1000000; i++) { 
    //CFShowStr((CFStringRef)b);

        // [b appendString:@"C"];
        // CFStringAppendCharacters ((CFMutableStringRef)b,&c,1);
        [b inru_appendUnichar:c];
    } 
    NSUInteger t1 = INTickCount();
    for (int i = 0; i < 1000000; i++) { 
        CFStringAppendCharacters ((CFMutableStringRef)a,&c,1);
    } 
    NSUInteger t2 = INTickCount();
    NSLog(@"---> 1:%d 2:%d",t1-t0, t2-t1);
    // NSLog(@"---> %@",INNormalizeTelNo(@"приветˇÁa"));
    exit(1);
}
*/
//----------------------------------------------------------------------------------------------------------------------------------

BOOL INCanMakeVoiceCall(NSString * telNo) {
#if TARGET_IPHONE_SIMULATOR != 0 
    return YES;
#else 
    NSString * str = INNormalizeTelNo(telNo);
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", str]];
    return [[UIApplication sharedApplication] canOpenURL:url];
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

void INMakeVoiceCall(NSString * telNo) {
    NSString * str = INNormalizeTelNo(telNo);
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", str]];
    [[UIApplication sharedApplication] openURL:url];
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

NSString *INDocumentsDirectory(void) {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

//==================================================================================================================================
//==================================================================================================================================

@implementation UIPasteboard(INRU)

- (void)inru_setString:(NSString *)string { 
    [self setValue:string forPasteboardType:@"public.utf8-plain-text"];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSNotification (INRU)

- (CGRect)inru_keyboardRect {
    CGRect result = CGRectZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200	
    if (INSystemVersionEqualsOrGreater(3,2,0)) {
        NSValue * value = [[self userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
        if (value) {
            result = [value CGRectValue];
        }
    } else 
#endif
    {   
        NSValue * value = [[self userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"]; // заменил на строки, чтобы компилятор не верещал. Думаю все будет ок
        NSValue * value2 = [[self userInfo] objectForKey:@"UIKeyboardCenterEndUserInfoKey"];
        if (value && value2) { 
            result = [value CGRectValue];
            CGPoint pt = [value2 CGPointValue]; 
            result.origin.x = pt.x - result.size.width  / 2;
            result.origin.y = pt.y - result.size.height / 2;
        }
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)inru_keyboardRectForView:(UIView *)view {
    return [view convertRect:[self inru_keyboardRect] fromView:nil];
}

@end

//==================================================================================================================================
//==================================================================================================================================

#ifndef NS_BLOCK_ASSERTIONS 
  
@interface INAlertedAssertionHandler : NSAssertionHandler { 
    // NSInteger _threadName;
    NSException * _originalException;
}

@end 

@implementation INAlertedAssertionHandler

//----------------------------------------------------------------------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
    if (buttonIndex == alertView.cancelButtonIndex) {
        @throw _originalException;
    } else { 
        // [[UIPasteboard generalPasteboard] inru_setString:alertView.message];
    }
#if !__has_feature(objc_arc)
    [self release];
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)displayMessage:(NSString *)message { 
    UIAlertView * alert = [[UIAlertView alloc]
                            initWithTitle:@"Fatal Error (tell developers!)"
                            message:[NSString stringWithFormat:@"Assertion failed: %@",message]
                            delegate:(id)self 
                            cancelButtonTitle: @"Exit App"
                            otherButtonTitles: @"Continue", nil];
    [alert show];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)fileLocation:(NSString *)fileName lineNo:(NSInteger)lineNo { 
    return [NSString stringWithFormat:@"(%@:%d)",[fileName lastPathComponent],lineNo];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleMessage:(NSString *)message { 

   NSLog(@"!!! --------------------------");
   NSLog(@"!!! Assertion failed: %@", message);
   NSLog(@"!!! --------------------------");

   _originalException = [NSException exceptionWithName:@"NSInternalInconsistencyException" reason:message userInfo:nil];
#if !__has_feature(objc_arc)
   [_originalException retain];
#endif

#ifdef IN_SIMULATOR_BUILD
    // kill(getpid(),SIGINT);
   // __asm__ ("int3");
    // see here http://stackoverflow.com/questions/1149113/breaking-into-the-debugger-on-iphone for more approaches to break into debugger
    
    // on simulator just emulates standard behaviour
    @throw _originalException;

#else
   if (INDebugIsAppBeingDebugged()) {  
       @throw _originalException;
   } else { 
       [self performSelectorOnMainThread:@selector(displayMessage:) withObject:message waitUntilDone:NO];
   }
#endif 

} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName 
   lineNumber:(NSInteger)line description:(NSString *)format,... {

   va_list ap;
   va_start(ap, format);
   NSString * message = [[NSString alloc] initWithFormat:format arguments:ap];
   va_end(ap);
   
   [self handleMessage:[NSString stringWithFormat:@"[%@ %@] at %@: %@",
                  object,
                  NSStringFromSelector(selector),
                  [self fileLocation:fileName lineNo:line],
                  message]];
#if !__has_feature(objc_arc)
   [message release];
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName 
    lineNumber:(NSInteger)line description:(NSString *)format,... { 
    
   va_list ap;
   va_start(ap, format);
   NSString * message = [[NSString alloc] initWithFormat:format arguments:ap];
   va_end(ap);
   
   [self handleMessage:
                  [NSString stringWithFormat:@"%@() at %@: %@",
                  functionName,
                  [self fileLocation:fileName lineNo:line],
                  message]];
#if !__has_feature(objc_arc)
    [message autorelease];
#endif
}

@end

//==================================================================================================================================

// устанавливать для каждого потока, где он требуется!
// 
// Неактуально: Не забыть прилинковать Foundation.framework как Weak иначе на айпаде 3.2 не запустится
// todo: попробовать создать аналог наследника  INAlertedAssertionHandler только не наследником а прокси. Это будет полезно
// в будущем при проверке того, есть ли нужный класс в фреймворке.

void INInstallAlertedAssertionHandlerForCurrentThread() {
    INAlertedAssertionHandler * handler = [INAlertedAssertionHandler new];
/* 
    NSString * key = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if (INSystemVersionEqualsOrGreater(4,0,0)) {
        key = nil;// NSAssertionHandlerKey;
    }
    if (key == nil)
#endif 
    {
        key = @"NSAssertionHandler";
    }
*/
    NSString * key = @"NSAssertionHandler";
    [[NSThread currentThread].threadDictionary setObject:handler forKey:key];
#if !__has_feature(objc_arc)
    [handler release];
#endif
}

static BOOL _InruLibAutoInstallHandlerForNewThreads = NO;

void INEnableAlertedAssertionHandlerForInternalINLibThreads(BOOL autoInstallHandlerForNewThreads) { 
   _InruLibAutoInstallHandlerForNewThreads = autoInstallHandlerForNewThreads;
}

BOOL INAlertedAssertionHandlerForInternalINLibThreadsEnabled() { 
    return _InruLibAutoInstallHandlerForNewThreads;
}

#endif

//==================================================================================================================================
//==================================================================================================================================

#import <AudioToolbox/AudioToolbox.h>
#import <dlfcn.h>
 
void INPlayControlTockSound() { 
    static SystemSoundID soundID = 0; 
    static OSStatus (* _AudioServicesCreateSystemSoundID)(CFURLRef inFileURL, SystemSoundID * outSystemSoundID) = nil;
    static void (* _AudioServicesPlaySystemSound)(SystemSoundID inSystemSoundID) = nil;
    static void * _AudioToolBoxHandle = nil; 
    
    // просто для того чтобы не включать фреймворк в каждый проект
    if (!_AudioToolBoxHandle) { 
        _AudioToolBoxHandle = dlopen("/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox", RTLD_LOCAL | RTLD_LAZY);
        if (_AudioToolBoxHandle) { 
            _AudioServicesCreateSystemSoundID = dlsym(_AudioToolBoxHandle,"AudioServicesCreateSystemSoundID");
            _AudioServicesPlaySystemSound = dlsym(_AudioToolBoxHandle,"AudioServicesPlaySystemSound");
        }
    }
    
#ifdef IN_SIMULATOR_BUILD
    // это решение дает чистый и громкий звук (работает и на устройстве тоже). Недостаток - всегда одна и та же громкость, вне зависимости от настроек
    if (!soundID && _AudioServicesCreateSystemSoundID) { 
        NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
        #if !__has_feature(objc_arc)
            _AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        #else 
            _AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        #endif
    }
#else
    BOOL systemSoundsEnabled = CFPreferencesGetAppBooleanValue(
                                         CFSTR("keyboard"),
                                         CFSTR("/var/mobile/Library/Preferences/com.apple.preferences.sounds"),
                                         NULL);
    if (systemSoundsEnabled) {
        if (!soundID) { 
            soundID = 0x450; // это решение дает звук правильной громкости. Пока что работает на всех версиях iOS
        }
    }
#endif
    if (soundID && _AudioServicesPlaySystemSound) { 
        _AudioServicesPlaySystemSound(soundID);
    } 
    // AudioServicesDisposeSystemSoundID(soundID); // нет необходимости, да и нельзя это делать прямо тут - звук играется асинхронно
}

//----------------------------------------------------------------------------------------------------------------------------------

BOOL INDebugIsAppBeingDebugged() { 
    int mib[4];
    size_t bufSize = 0;
    // int local_error = 0;
    struct kinfo_proc kp;

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();

    bufSize = sizeof (kp);
    if ((/* local_error = */ sysctl(mib, 4, &kp, &bufSize, NULL, 0)) < 0) {
        // label.text = @"Failure calling sysctl";
        return NO;
    }
    return (kp.kp_proc.p_flag & P_TRACED) != 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

void INDebugSimulateMemoryWarning() { 
    // надо проверить, сработает ли на девайсе 
    // альтернативные методы есть тут http://stackoverflow.com/questions/2784892/simulate-memory-warnings-from-the-code-possible
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        (CFStringRef)@"UISimulatedMemoryWarningNotification", NULL, NULL, true);
}

//----------------------------------------------------------------------------------------------------------------------------------

BOOL INIsRussianLocalization() { 
    NSString * preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [preferredLang isEqualToString:@"ru"];
}

//----------------------------------------------------------------------------------------------------------------------------------

BOOL INIsRussianLocale() { 
    NSLocale * locale = [NSLocale autoupdatingCurrentLocale];
    NSString * lang = [locale objectForKey:NSLocaleLanguageCode];
    return [lang isEqualToString:@"ru"];
}

//----------------------------------------------------------------------------------------------------------------------------------

#ifdef IN_SIMULATOR_BUILD

void INDebugSaveDataToDeveloperDesktop(NSData * data, NSString * subPath, NSString * filename, NSString * extension) { 

    NSString * path = [NSString stringWithFormat:@"/Users/%@/Desktop/", NSUserName()];
    path = [path stringByAppendingPathComponent:subPath];
    if (NSNotFound != [path rangeOfString:@".."].location) { // немного паранойи не помешает
        NSCAssert(0,@"mk_1611bd72_6929_4554_b0ed_205a42acf932");
        return; 
    } 

    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    // clean folder on first start 
    static int fileCounter = 0;
    if (fileCounter == 0) {   
        NSError * error = nil;
        for (NSString * name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error]) { 
            NSString * currentPath = [path stringByAppendingPathComponent:name];
            NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:currentPath error:&error];
            NSString * fileType = [attributes objectForKey:NSFileType];
            if ([fileType isEqualToString:NSFileTypeRegular] == YES) {
                [[NSFileManager defaultManager] removeItemAtPath:currentPath error:&error];            
            }
        }
    }
    
    NSString * fullPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d. %@", ++fileCounter,
                                                               [filename.inru_normalizeFileName stringByAppendingPathExtension:extension]]];
    [data writeToFile:fullPath atomically:NO];
}

#endif

//----------------------------------------------------------------------------------------------------------------------------------

uint64_t INFreeDiskSpace() {
    //uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;

    NSError * error = nil;  
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary * dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    if (dictionary) {  
       //  NSNumber * fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];  
        NSNumber * freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        // totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        // NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {  
        NSLog(@"Failed for get free space size:%@", error);  
    }  

    return totalFreeSpace;
}
