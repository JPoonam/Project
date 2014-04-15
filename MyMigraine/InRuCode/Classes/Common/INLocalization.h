//!
//! @file INLocalization.h
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
    поиск в текущем и нижележащих каталогах напрямую вкодированные кириллические ресурсы:
    
    grep  -r --include='*.[m|h|mm|c]' --colour=auto -i -H -n --perl '@"[^"\n]*[абвгдежзийклмнопрстуфхцчшщьыъэюя]+' .

*/


#import <Foundation/Foundation.h>

#ifdef __cplusplus 
extern "C" {
#endif
    
extern NSString * INLocalizationDidChangeNotification;
    
//! @brief Finds a localized string by it's key, uses it as a format string for creating a final localized message
//         Works correct with non-existed localizations (takes a default localization from English resources)
extern NSString * InruLoc(NSString * key, ...);

//! @brief allows override localization with other language. pass nil to reset to system localization; returns YES if approproate language
//         resources were loaded successfully. will post InruLocLocalizationDidChangeNotification
extern BOOL INSetLocalization(NSString * language);

    
#ifdef __cplusplus 
}
#endif
