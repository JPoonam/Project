//!
//! @file INLocalization.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! @copyright Copyright © 2010-2011 InRu
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
  
  
/* 

#define NSLocalizedString(key, comment) \
	    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]
#define NSLocalizedStringFromTable(key, tbl, comment) \
	    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:(tbl)]
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
	    [bundle localizedStringForKey:(key) value:@"" table:(tbl)]
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
	    [bundle localizedStringForKey:(key) value:(val) table:(tbl)]
*/
  
#import "INLocalization.h"

NSString * INLocalizationDidChangeNotification = @"INLocalizationDidChangeNotification";

static NSDictionary   * _DefaultLocalization = nil; // English, most usually
static NSString       * _NonExistentKey = @"19@#$@%@";
static NSDictionary   * _ForcedLocalization = nil; 

//----------------------------------------------------------------------------------------------------------------------------------

static NSDictionary  * _DictionaryForLanguage(NSString * language) { 
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * path  = [bundle pathForResource:@"Localizable" 
                                        ofType:@"strings" 
                                   inDirectory:nil 
                               forLocalization:language]; //todo - get this info ("English") from bundle's plist
    return [NSDictionary dictionaryWithContentsOfFile:path];  
}

//----------------------------------------------------------------------------------------------------------------------------------

BOOL INSetLocalization(NSString * language) {
#if !__has_feature(objc_arc)
    [_ForcedLocalization release];
    _ForcedLocalization = [_DictionaryForLanguage(language) retain];
#else
    _ForcedLocalization = _DictionaryForLanguage(language);
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:INLocalizationDidChangeNotification object:nil];
    return _ForcedLocalization != nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

static NSString * InruGetLocResource (NSString * key){
    if (!key || !key.length){
        return @"<<< empty key >>>";
    }
    
    // first try explicitly set localization 
    if (_ForcedLocalization) {
        NSString * res = [_ForcedLocalization valueForKey:key];
        if (res) {
            return res;
        }
    }
        
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * res = [bundle localizedStringForKey:key value:_NonExistentKey table:nil];
    if ([res isEqualToString:_NonExistentKey]) {
        
        // loading default localization dictionary
        if (!_DefaultLocalization){
            _DefaultLocalization = _DictionaryForLanguage(@"English"); //todo? - get this info ("English") from bundle's plist?
            #if !__has_feature(objc_arc)
                [_DefaultLocalization retain];
            #endif
        }
        
        if (_DefaultLocalization){ 
            res = [_DefaultLocalization valueForKey:key];
            if (res) {
                return res;
            }
        }
        return [NSString stringWithFormat:@"<<< key '%@' not found in resources >>>", key];
    }
    return res;
}

//----------------------------------------------------------------------------------------------------------------------------------

NSString * InruLoc(NSString * key, ...){
    va_list ap;
    NSString * str = InruGetLocResource(key);
    va_start(ap, key);
    NSString * result = [[NSString alloc] initWithFormat:str arguments:ap];
    va_end(ap);
#if !__has_feature(objc_arc)
    [result autorelease];
#endif
    return result; 
}
