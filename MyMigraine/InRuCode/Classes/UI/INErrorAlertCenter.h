//!
//! @file INErrorAlertCenter.h
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

#import <UIKit/UIKit.h>

@class INErrorAlertCenter;

/**
 @brief A helper for displaying multiply error alerts. 
 
 Does not display repeatable alerts. Special handling for "No internet" error
*/
@interface INErrorAlertCenter : NSObject <UIAlertViewDelegate> {
@private
    NSMutableDictionary * _lastErrors;
    NSString * _noInternetTitle;
    NSString * _noInternetMessage;
    NSString * _networkAuthMessage;
    NSString * _okButtonMessage;
    BOOL       _lastIssueIsNoInternetError;
    BOOL       _shouldCenterAlertOnScreen;
    BOOL       _keyboardIsShown;
    CGRect     _keyboardRect;
}

//! @brief A title for 'no internet' alert window 
@property(nonatomic, copy) NSString * noInternetTitle;

//! @brief A message for 'no internet' alert window 
@property(nonatomic, copy) NSString * noInternetMessage;
    
//! @brief A message for 'access denied/rejected' alert window 
@property(nonatomic, copy) NSString * networkAuthMessage;

//! @brief "OK" button text for the alert window 
@property(nonatomic, copy) NSString * okButtonMessage;

//! @brief Returns YES if the last registered error was a 'no internet' one
@property(nonatomic) BOOL lastIssueIsNoInternetError;

//! @brief Turn on and off automatic reposition of alert view on iPhone screen in case keyboard is already shown. Doesnt correctly work on ipad in landscape mode.
@property(nonatomic) BOOL shouldCenterAlertOnScreen;

//! @brief Register error for sender \c sender with the title and message keys.
//! Shows an alert window if it is a new error for sender or \c forceShow is YES
// deprecated. replace to error:sender:titleKey:messageKey:forceShow
- (BOOL)error:(NSError *)error forSender:(id)sender withTitleKey:(NSString *)titleKey andMessageKey:(NSString *)messageKey forceShow:(BOOL)forceShow __deprecated;

- (BOOL)error:(NSError *)error sender:(id)sender titleKey:(NSString *)titleKey messageKey:(NSString *)messageKey forceShow:(BOOL)forceShow;                               
- (BOOL)error:(NSError *)error sender:(id)sender title:(NSString *)title message:(NSString *)message forceShow:(BOOL)forceShow;


//! @brief Clear remembered error status for sender \c sender. 
- (void)clearLastErrorForSender:(id)sender; 

@end
