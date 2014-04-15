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
  
#import <Foundation/Foundation.h>

enum {
    INFORMAT_ONLY_POSITIVE = 1
};

@interface NSString (INRU_Format)

- (NSString *)inru_formatNumberStringWithFracMinLength:(NSInteger)fracMinLen flags:(NSInteger)flags;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INDateFormatter : NSObject { 
    NSMutableDictionary * _formatters;
    NSLocale * _locale;  
}
 
+ (INDateFormatter *)sharedFormatter;

@property(nonatomic,retain) NSLocale * locale;

- (void)setRussianLocale;

- (NSDateFormatter *)registerFormatterWithString:(NSString *)dateFormatString key:(NSString *)key;
- (NSDateFormatter *)registerFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle 
                                          timeStyle:(NSDateFormatterStyle)timeStyle 
                                                key:(NSString *)key;
                                                
- (NSString *)formatDate:(NSDate *)date withFormatKey:(NSString *)fmtKey;
- (NSDate *)dateFromString:(NSString *)string withFormatKey:(NSString *)fmtKey;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface NSDate (INRU_Format)

// эти штуки работают с синглтоном INDateFormatter sharedFormatter]. Когда понадобится работа с несколькими поставщиками форматов INDateFormatter,
// то добавим соотвествующие выводы наверх 
- (NSString *)inru_formatWithKey:(NSString *)fmtKey;
+ (NSDate *)inru_dateFromString:(NSString *)string withFormatKey:(NSString *)fmtKey;

@end


/* 

Пример использования 

0. Допустим, мы работаем всегда с русскими локалями

[[INDateFormatter sharedFormatter] setRussianLocale]; // если не вызывать, то будет использоваться системная локаль 

1. регистрируем форматы. Смысл в том, что создание NSDateFormatter достаточно расточитаельно, лучше один раз 
   создать и потом реиспользовать из синглтона [INDateFormatter sharedFormatter]

  [[INDateFormatter sharedFormatter] registerFormatterWithString:@"d MMM" key:@"MY_DATE_FORMAT_1"]; 
  [[INDateFormatter sharedFormatter] registerFormatterWithString:@"HH:mm:ss" key:@"MY_TIME_FORMAT_2"]; 
  [[INDateFormatter sharedFormatter] registerFormatterWithDateStyle:NSDateFormatterFullStyle 
                                                          timeStyle:NSDateFormatterNoStyle key:@"FULL_DATE_FORMAT"]; 


2. Используем везде, где нужно

2.1 дата -> строка
   
   NSString * s1 = [[NSDate date] inru_formatWithKey:@"MY_DATE_FORMAT_1"];
   NSString * s2 = [[NSDate date] inru_formatWithKey:@"FULL_DATE_FORMAT"];
   
2.2 парсинг строк в дату 
    
   NSDate * d1 = [NSDate inru_dateFromString:@"23:34:56" withFormatKey:@"MY_TIME_FORMAT_2"];

*/


/* 

// http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns

NSDateFormatterNoStyle
Specifies no style.
Equal to kCFDateFormatterNoStyle.
Available in iOS 2.0 and later.
Declared in NSDateFormatter.h.
NSDateFormatterShortStyle
Specifies a short style, typically numeric only, such as “11/23/37” or “3:30pm”.
Equal to kCFDateFormatterShortStyle.
Available in iOS 2.0 and later.
Declared in NSDateFormatter.h.
NSDateFormatterMediumStyle
Specifies a medium style, typically with abbreviated text, such as “Nov 23, 1937”.
Equal to kCFDateFormatterMediumStyle.
Available in iOS 2.0 and later.
Declared in NSDateFormatter.h.
NSDateFormatterLongStyle
Specifies a long style, typically with full text, such as “November 23, 1937” or “3:30:32pm”.
Equal to kCFDateFormatterLongStyle.
Available in iOS 2.0 and later.
Declared in NSDateFormatter.h.
NSDateFormatterFullStyle
Specifies a full style with complete details, such as “Tuesday, April 12, 1952 AD” or “3:30:42pm PST”.
Equal to kCFDateFormatterFullStyle.
Available in iOS 2.0 and later.
Declared in NSDateFormatter.h
*/
