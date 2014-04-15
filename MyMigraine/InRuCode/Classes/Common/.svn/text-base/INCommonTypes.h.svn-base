//!
//! @file INCommonTypes.h
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
  
#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

/** Some useful category extensions for `NSMutableArray` class */
@interface NSMutableArray (INRU)

///---------------------------------------------------------------------------------------
/// @name ￼Creating and Initializing a Mutable Array
///---------------------------------------------------------------------------------------

/** Обычный массив, элементы которого не получают вызовы `retain` и `release` при размещении и удалении из него. */
+ (NSMutableArray*)inru_nonRetainingArray;

///---------------------------------------------------------------------------------------
/// @name Rearranging Content
///---------------------------------------------------------------------------------------

/** Перемешивает содержимое массива (изменяет порядок элементов). */
- (void)inru_shuffle;

@end

//==================================================================================================================================
//==================================================================================================================================

/** Some useful category extensions for `NSString` class */
@interface NSString (INRU)

///---------------------------------------------------------------------------------------
/// @name Creating and Initializing Strings
///---------------------------------------------------------------------------------------

/// Создание строки из объекта NSData (в предположении, что данные отформатированы в UTF8 формате)
+ (NSString *)inru_stringFromData:(NSData *)data;

///---------------------------------------------------------------------------------------
/// @name Dividing Strings
///---------------------------------------------------------------------------------------

/// Trims all spaces, tabs and newline symbols from both ends of string
- (NSString *)inru_trim;

/// Trims all spaces, tabs and newline symbols from left of string
- (NSString *)inru_trimLeft;

///---------------------------------------------------------------------------------------
/// @name Identifying and Comparing Strings
///---------------------------------------------------------------------------------------

/// Compares 2 strings. Consider nil equals to @"" and vice versa
+ (BOOL)inru_string:(NSString *)string isEqualTo:(NSString *)otherString;

///---------------------------------------------------------------------------------------
/// @name Other Tasks 
///---------------------------------------------------------------------------------------

/// Try to convert string like "win1251" to NSStringEncoding. Returns 0 if encoding is unknown 
- (NSStringEncoding)inru_stringToEncoding __deprecated;

/// Creates a new UUID(GUID) and returns it's string reprecentation
+ (NSString *)inru_newUUID;

/// Генерируем рыбу для текста указанной длины 
+ (NSString *)inru_loremIpsumOfLength:(NSInteger)length;

/// Вычисление MD5 для UTF8 представления данной строки.
///
/// @return хеш MD5 – 32-символьная строка шестнадцатиричных символов (в нижнем регистре) 
- (NSString *)inru_md5Digest;

/* SHA-1 type hash */
- (NSString *)inru_sha1;

/* SHA-2 type hash 256bit long */
- (NSString *)inru_sha256;


///---------------------------------------------------------------------------------------
/// @name HTML-related stuff  
///---------------------------------------------------------------------------------------

/** Strips all < tags > from html string.

    @see inru_htmlToPlain
*/
- (NSString *)inru_stripHtmlTags;

/** Strips all < tags > from html string + converts symbols like &quot; into the chars

    @see inru_stripHtmlTags
*/
- (NSString *)inru_htmlToPlain;

///---------------------------------------------------------------------------------------
/// @name Changing Case 
///---------------------------------------------------------------------------------------

/// Возвращает копию строки с первым символом в верхнем регистре
- (NSString *)inru_capitalizeFirstLetter;

///---------------------------------------------------------------------------------------
/// @name Working with Paths
///---------------------------------------------------------------------------------------

/// Возвращает копию строки с заменой всех служебных символов файловой системы в '_'. Полученый результат можно использовать в качестве имени файла 
/// 
/// Наиболее частое применение - сохранение в кеше полученных из некоторого URL данных. 
/// Чтобы не напрягаться с названиями файлов и гарантировать их уникальность, можно сохранять данные в файле с 
/// именем [[NSURL absoluteString] inru_normalizeFileName]
///
/// @warning *todo:* Проверить, возможно fileSystemRepresentation сделает то же самое.
/// @warning *todo:* Также проверить реализацию, может быть некоторые символы таки можно использовать или экранировать.
- (NSString *)inru_normalizeFileName;

@end

//==================================================================================================================================
//==================================================================================================================================

/** Some useful category extensions for NSMutableString class */
@interface NSMutableString (INRU)


/// Clears the string (makes it @"")
///
/// @bug Кандидат на удаление (используется только INNetXML)
- (void)inru_clear;

/// Add a single Unichar symbol to the receiver
- (void)inru_appendUnichar:(unichar)c;

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum { 
    INWeekdaySunday    = 1,
    INWeekdayMonday    = 2,
    INWeekdayTuesday   = 3,
    INWeekdayWednesday = 4,
    INWeekdayThursday  = 5,
    INWeekdayFriday    = 6,
    INWeekdaySaturday  = 7
} INWeekday;

typedef struct { 
    NSInteger year, 
              month, // 1..12 
              day,   // 1.. 
              hour, minute, second;
    INWeekday weekday;
} INDateComponents;

/** Some useful category extensions for NSDate class */

@interface NSDate (INRU)

///---------------------------------------------------------------------------------------
/// @name Creating and Initializing Date Objects
///---------------------------------------------------------------------------------------

/// Возвращает дату, представляющую начало (полночь) текущего дня (сегодня)
+ (NSDate *)inru_todayMidnight;

///---------------------------------------------------------------------------------------
/// @name Working with Date Components
///---------------------------------------------------------------------------------------

/// Creates NSDate object from date components
+ (NSDate *) inru_dateFromComponents:(INDateComponents)input;

/// Splits the current date into single components (years, hours, etc). 
/// Gregorian calendar is used. 
- (INDateComponents)inru_components;

/// Splits the difference to given date into single components (years, hours, etc). 
/// Gregorian calendar is used. 
- (INDateComponents)inru_diffToDate:(NSDate*)date;

/// Возвращает дату, представляющую начало (полночь) оригинального дня   
- (NSDate *)inru_trimTime;

/// Returns date with incremented or decremented month(s).
/// Gregorian calendar is used. 
- (NSDate *)inru_incMonth:(NSInteger)increment; 

/// Returns date with incremented or decremented days(s).
/// Gregorian calendar is used. 
- (NSDate *)inru_incDay:(NSInteger)increment;

/// Returns date with incremented or decremented hours(s).
/// Gregorian calendar is used. 
- (NSDate *)inru_incHour:(NSInteger)increment;

/// Returns date with incremented or decremented minutes(s).
/// Gregorian calendar is used. 
- (NSDate *)inru_incMinute:(NSInteger)increment;

/// Returns midnight of first day of given date week 
/// Gregorian calendar is used. 
- (NSDate *)inru_beginOfWeek;

///---------------------------------------------------------------------------------------
/// @name Parsing Strings to Dates
///---------------------------------------------------------------------------------------

/// Parses string in the  '[Tue,] 09 Mar 2010 14:44:44 GMT' format. Used in RSS and web. 
+ (NSDate *)inru_dateFromRfc822String:(NSString *)string; 

/// Parses string into the NSDate given the passed format, US locale
/// @warning Не самая производительная вещь, лучше работать с INDateFormatter
+ (NSDate *)inru_dateFromString:(NSString *)string withFormat:(NSString *)format;

///---------------------------------------------------------------------------------------
/// @name Representing Dates as Strings
///---------------------------------------------------------------------------------------

/// Outputs date in the given format, using specified locale
/// @warning Не самая производительная вещь, лучше работать с INDateFormatter
- (NSString *)inru_toStringWithFormat:(NSString *)format locale:(NSString*)locale;


/// Outputs date in the given format
/// @warning Не самая производительная вещь, лучше работать с INDateFormatter
- (NSString *)inru_toStringWithFormat:(NSString *)format;

///---------------------------------------------------------------------------------------
/// @name Comparing Dates
///---------------------------------------------------------------------------------------

/// Возвращает YES, если данная дата является сегодняшней (без учета времени)
- (BOOL)inru_isToday;

/// Возвращает YES, если дата указывает на *более ранее* по времени событие по сравнению с `otherDate`
///
/// Фактически, это просто удобная обертка над `compare:`
/// @see inru_isAfter 
/// @see inru_isAfterOrEqual 
/// @see inru_isBeforeOrEqual 
- (BOOL)inru_isBefore:(NSDate *)otherDate;


/// Возвращает YES, если дата указывает на *более позднее* по времени событие по сравнению с `otherDate`
///
/// Фактически, это просто удобная обертка над `compare:`
/// @see inru_isBefore 
/// @see inru_isAfterOrEqual 
/// @see inru_isBeforeOrEqual 
- (BOOL)inru_isAfter:(NSDate *)otherDate;

/// Возвращает YES, если дата указывает на *более позднее или равное* по времени событие по сравнению с `otherDate`
///
/// Фактически, это просто удобная обертка над `compare:`
/// @see inru_isAfter 
/// @see inru_isBefore 
/// @see inru_isBeforeOrEqual 
- (BOOL)inru_isAfterOrEqual:(NSDate *)otherDate;


/// Возвращает YES, если дата указывает на *более ранее или равное* по времени событие по сравнению с `otherDate`
///
/// Фактически, это просто удобная обертка над `compare:`
/// @see inru_isAfter 
/// @see inru_isBefore 
/// @see inru_isAfterOrEqual 
- (BOOL)inru_isBeforeOrEqual:(NSDate *)otherDate; 

///---------------------------------------------------------------------------------------
/// @name Other Tasks
///---------------------------------------------------------------------------------------

/// Returns count of day in the month of the given date
- (NSInteger)inru_daysInThisMonth; 

@end

//==================================================================================================================================
//==================================================================================================================================

/// The domains of INError class (network errors are separated in the stand-alone domain)
extern NSString * INErrorDomain; 
extern NSString * INNetErrorDomain; 
extern NSString * INNetErrorHTTPResponseKey;

/// Error codes for INErrorDomain and INNetErrorDomain
typedef enum { 
    INErrorCodeBase               = 7000,
    INErrorCodeBadParameter,
    INErrorCodeBadHTTPStatusCode,
    INErrorCodeSessionNotOpened,  // any session :)
    INErrorCodeAuthFailed,
    INErrorCodeBadData,
    INErrorCodeCustomBase = INErrorCodeBase + 1000
} INErrorCode;

/** A descendant of `NSError`. Provides some handy methods and own error domain/codes space */
@interface INError : NSError { 
    
}

///---------------------------------------------------------------------------------------
/// @name Creating Error Objects
///---------------------------------------------------------------------------------------

/// Creates an error object with the given code and a description (localized)
+ (id)errorWithCode:(INErrorCode)code description:(NSString *)description; 


/// Creates an error object with the given code and a description (localized)
+ (id)errorWithCode:(INErrorCode)code;

@end

//==================================================================================================================================
//==================================================================================================================================

/** Some useful category extensions for NSError class */
@interface NSError (INRU)

+ (id)inru_errorWithDomain:(NSString *)domain code:(NSInteger)code localizedDescription:(NSString *)format, ...;

///---------------------------------------------------------------------------------------
/// @name Test for certain errors 
///---------------------------------------------------------------------------------------

/// Returns YES if domain is NSURLErrorDomain and error code is `errorСode`
- (BOOL)inru_isURLDomainError:(NSInteger)errorCode;

/// Returns YES if error is a 'no internet' one
- (BOOL)inru_networkErrorNoInternet; 

/// Returns YES if error is NSURLErrorCancelled
- (BOOL)inru_networkErrorCanceled;

/// Returns YES if domain is NSURLErrorDomain or INNetErrorDomain
- (BOOL)inru_isNetworkError;

/// Возвращает YES если ошибка имеет отношение к авторизации, в той или иной форме (как правило, это сетевая авторизация)
- (BOOL)inru_isAuthFailed;

/// Returns YES if domain is INErrorDomain or INNetErrorDomain and error code is `errorСode`
- (BOOL)inru_isINError:(NSInteger)errorCode;

@end

//==================================================================================================================================
//==================================================================================================================================

// пока это постоянно, но так будет не всегда. Лучше использовать то, что можно потом расширить или переопределить 
#define INNavBarHeight 44
#define INNavBarLandscapeHeight 32

// А это чуть полегче удержать в голове
#if TARGET_IPHONE_SIMULATOR != 0 
    #define IN_SIMULATOR_BUILD
#else 
    #define IN_DEVICE_BUILD
#endif

#ifndef NS_BLOCK_ASSERTIONS
    #define IN_ASSERT_ENABLED
#endif 

#define INFlexibleWidthHeight (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)
#define INFlexibleMargins     (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)

//==================================================================================================================================

// This works in function and non-function scope (but not inside structs,unions).
// look here for more details http://stackoverflow.com/questions/3385515/static-assert-in-c
#define IN_STATIC_ASSERT_MSG(COND,MSG)  typedef char static_assertion_##MSG[(!!(COND))*2-1]
#define IN_STATIC_ASSERT_INTERNAL3(X,L) IN_STATIC_ASSERT_MSG(X,static_assertion_at_line_##L)
#define IN_STATIC_ASSERT_INTERNAL2(X,L) IN_STATIC_ASSERT_INTERNAL3(X,L)
#define IN_STATIC_ASSERT(X)             IN_STATIC_ASSERT_INTERNAL2(X,__LINE__) /* use this! */

//==================================================================================================================================
//==================================================================================================================================

/// Splits a rect into 2 pieces:left & right one
void INRectSplitInto2Rects(CGRect src, CGFloat leftRectWidth, CGRect * leftR, CGRect * rightR);

/// Splits a rect into 2 vertical pieces:left & right one
void INRectSplitInto2VertRects(CGRect src, CGFloat topRectHeight, CGRect *  topR, CGRect * bottomR);

/// Insets the rect, works like CGRectInset but provides independent control for each side
CGRect INRectInset(CGRect src, CGFloat left, CGFloat top, CGFloat right, CGFloat bottom); 

/* Returns a rectangle that is smaller or larger than the source rectangle, with the same origin. */
CGRect INRectResize(CGRect src, CGFloat dx, CGFloat dy);

/// A distance between 2 points. High math! sqrt(a^2 + b^b). Useful for multitouch handling
CGFloat INPointDistance(CGPoint point1, CGPoint point2);

/// Приведение всех параметров прямоугольника к целым значениям - полезно для борьбы с размытостью в UI
CGRect INRectNormalize(CGRect src);

/// Создание прямоугольника с позицией (0,0) и данными размерами 
CG_INLINE CGRect INRectFromSize(CGSize size){
    CGRect rect;
    rect.origin.x = 0; rect.origin.y = 0;
    rect.size.width = size.width;
    rect.size.height = size.height;
    return rect;
}

/// Возвращает однопиксельный прямоугольник, располагающийя в центре исходного. Полезно для позиционирования поповеров 
CG_INLINE CGRect INRectCenter(CGRect src) {
    CGRect rect;
    rect.origin.x = rint(src.origin.x + src.size.width / 2);
    rect.origin.y = rint(src.origin.y + src.size.height / 2);
    rect.size.width = 1;
    rect.size.height = 1;
    return rect;
}

/// Вписать (отшкалировать) rect в boundsRect, так, чтобы он влез туда целиком и расположился по центру. 
/// Даже если rect меньше, он будет растянут до границ  boundRect  
CGRect INRectAspectFitRectInRect(CGRect rect, CGRect boundRect);

/// Заполнить (отшкалировать) rect в boundsRect, так, чтобы он влез туда целиком по меньшей из сторон. 
/// Даже если rect меньше, он будет растянут до границ boundRect  
CGRect INRectAspectFillRectInRect(CGRect rect, CGRect boundRect);

//==================================================================================================================================
//==================================================================================================================================
//** Some useful category extensions for NSSet class  */
/*  
@interface NSSet(INRU)

/// Put the set into a nil-terminated sequence of id's. 
/// If count of object in set is less than a sequence length, the rest of sequence members is set to nil
/// Useful for multitouches handling
///
/// @bug кандидат на удаление
- (void)inru_splitToObjects:(id *)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

@end    
*/

//==================================================================================================================================
//==================================================================================================================================

/** Some useful category extensions for NSDictionary class */
@interface NSDictionary(INRU)

/*
/// Gets an integer from the diсtionary's member or default value for any failure (no object, object can't be interpret as a number, etc)
///
/// @bug кандидат на удаление (используется только в Яндекс-Электричках)
- (NSInteger)inru_integerForKey:(id)aKey defaultValue:(NSInteger)defaultValue;

/// Gets a string from the diсtionary's member or default value for anu failure (no object, object can't be interpret as a string, etc)
///
/// @bug кандидат на удаление
- (NSString *)inru_stringForKey:(id)aKey defaultValue:(NSString *)defaultValue; 

/// Gets a double value from the distionary's member or default value for anu failure (no object, object can't be interpret as a number, etc)
///
/// @bug кандидат на удаление
- (double)inru_doubleForKey:(id)aKey defaultValue:(double)defaultValue;
*/

/// Формирует содержимое словаря (списки ключ-значние) в тело POST запроса в указанной кодировке. Результат можно передавать в [NSURLConnection setHTTPBody:] 
- (NSData *)inru_serializeAsHTTPPostFormBodyUsingEncoding:(NSStringEncoding)encoding;

/// Формирует содержимое словаря (списки ключ-значние) в строку параметров (часть URL адреса, следующая за знаком '?') GET запроса. Применяется для формирования сложных URL 
- (NSString *)inru_serializeAsHTTPGetString;

@end

//==================================================================================================================================
//==================================================================================================================================
/** Some useful category extensions for `NSMutableDictionary` class */
@interface NSMutableDictionary(INRU)

/// Аналог `[NSMutableDictionary setObject]` позволяющий обойтись без поверки на *nil* аргументов `aKey` и `anObject` 
///
/// @param anObject сохраняемый в словаре объект. Если он равен *nil*, то соответствующий ключу `aKey` объект удаляется из словаря  
/// @param aKey ключ объекта. Если он равен *nil*, то никаких действий не совершается  
- (void)inru_setObject:(id)anObject forKey:(id)aKey;

@end


//==================================================================================================================================
//==================================================================================================================================
/** Вспомогательный класс для загрузки объектов из NIB/XIB ресурсных файлов 

    Выступает в качестве `File Owner` для создаваемых посредством загрузки XIB объектов.  
*/
@interface INNibLoader : NSObject { 
    UITableViewCell * _tableCell;
    UITableViewCell * _view;
    BOOL _cacheNib;
}

//! @brief A singleton for loading rarely used cells/ Caching is disabled
+ (INNibLoader *)sharedLoader; 

@property(nonatomic) BOOL cacheNib; // надо реализовать, еще не успел
@property(nonatomic,retain) IBOutlet UITableViewCell * tableCell;
@property(nonatomic,retain) IBOutlet UIView * view;

- (UITableViewCell *)loadCellFromNib:(NSString *)nibFile reuseIdentifier:(NSString *)reuseIdentifier; 
- (UITableViewCell *)reusableCellForTable:(UITableView *)tableView nibFile:(NSString *)nibFile reuseIdentifier:(NSString *)reuseIdentifier;
- (UITableViewCell *)reusableCellForTable:(UITableView *)tableView nibFile:(NSString *)nibFile reuseIdentifier:(NSString *)reuseIdentifier justLoaded:(BOOL *)justLoaded; 
- (UIView *)loadViewFromNib:(NSString *)nibFile; 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface UIPasteboard(INRU)

- (void)inru_setString:(NSString *)string;

@end

//==================================================================================================================================
//==================================================================================================================================

extern BOOL       INIPhoneInterface();
extern BOOL       INIPadInterface();

extern BOOL       INSystemVersionEqualsOrGreater(NSInteger major, NSInteger minor, NSInteger build);

extern NSString * INAppName();
extern NSString * INAppVersion();
extern NSDate	* INAppBuildDate();

extern uint64_t   INFreeDiskSpace();
extern NSString * INHardwarePlatform();
extern NSUInteger INTickCount();

extern BOOL       INCanMakeVoiceCall(NSString * telNo);
extern void       INMakeVoiceCall(NSString * telNo);

extern void       INPlayControlTockSound();

extern NSString  *INDocumentsDirectory(void);

//==================================================================================================================================
//==================================================================================================================================

extern double     INRandom();
extern NSInteger  INRandomInRange(NSInteger minValue, NSInteger maxValue);

//==================================================================================================================================
//==================================================================================================================================

// часто встречается, надоело набивать снова и снова 
CG_INLINE NSComparisonResult INCompareInt(NSInteger v1, NSInteger v2) { 
    if (v1 < v2) {
        return NSOrderedAscending;
    } 
    if (v1 == v2) {
        return NSOrderedSame;
    } 
    return NSOrderedDescending;
}

// часто встречается, надоело набивать снова и снова 
CG_INLINE NSComparisonResult INCompareCGFloat(CGFloat v1, CGFloat v2) { 
    if (v1 < v2) {
        return NSOrderedAscending;
    } 
    if (v1 == v2) {
        return NSOrderedSame;
    } 
    return NSOrderedDescending;
}

// часто встречается, надоело набивать снова и снова 
CG_INLINE NSComparisonResult INCompareDouble(double v1, double v2) { 
    if (v1 < v2) {
        return NSOrderedAscending;
    } 
    if (v1 == v2) {
        return NSOrderedSame;
    } 
    return NSOrderedDescending;
}

extern NSString * INFourByteNumberToString(SInt32 number);

CG_INLINE NSInteger INNormalizeIntegerForRange(NSInteger value, NSInteger minValidValue, NSInteger maxValidValue) {
    if (value < minValidValue) { 
        return minValidValue;
    }
    if (value > maxValidValue) { 
        return maxValidValue;
    }
    return value;
}

//==================================================================================================================================
//==================================================================================================================================

@interface NSNotification (INRU)

- (CGRect)inru_keyboardRect;
- (CGRect)inru_keyboardRectForView:(UIView *)view;

@end


/*==================================================================================================================================*/
/*
	IN_SYNTHESIZE_SINGLETON_FOR_HEADER(classname)
	IN_SYNTHESIZE_SINGLETON_FOR_CLASS(classname)

	Синтез синглтона для класса, который инициализируется методом init.
*/
/*==================================================================================================================================*/

#define IN_SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *sharedInstance = nil; \
\
+ (classname *)sharedInstance \
{ \
@synchronized(self) \
{ \
if (sharedInstance == nil) \
{ \
sharedInstance = [[self alloc] init]; \
} \
} \
\
return sharedInstance; \
}

#define IN_SYNTHESIZE_SINGLETON_FOR_HEADER(classname) + (classname *)sharedInstance;


//==================================================================================================================================
//==================================================================================================================================

// устанавливать для каждого потока, где он требуется!

#ifndef NS_BLOCK_ASSERTIONS
 
extern void INInstallAlertedAssertionHandlerForCurrentThread();
extern void INEnableAlertedAssertionHandlerForInternalINLibThreads(BOOL autoInstallHandlerForNewThreads);
extern BOOL INAlertedAssertionHandlerForInternalINLibThreadsEnabled();

#else 

NS_INLINE void INInstallAlertedAssertionHandlerForCurrentThread() { } 
NS_INLINE void INEnableAlertedAssertionHandlerForInternalINLibThreads(BOOL autoInstallHandlerForNewThreads) { }
NS_INLINE BOOL INAlertedAssertionHandlerForInternalINLibThreadsEnabled() { return FALSE; } 

#endif 

extern BOOL INDebugIsAppBeingDebugged();
extern void INDebugSimulateMemoryWarning();

/// 
/// Очень часто для отладки требуется писать файлы, полученные от сети для просмотра. Соответственно,   
/// эта функция делает такую штуку. Естественно, имеет смысл только для симулятора
///
#ifdef IN_SIMULATOR_BUILD

void INDebugSaveDataToDeveloperDesktop(NSData * data, NSString * subPath, NSString * filename, NSString * extension);

#else 

NS_INLINE void INDebugSaveDataToDeveloperDesktop(NSData * data, NSString * subPath, NSString * filename, NSString * extension) { } 

#endif  

//==================================================================================================================================
//==================================================================================================================================

extern BOOL INIsRussianLocalization();
extern BOOL INIsRussianLocale();
