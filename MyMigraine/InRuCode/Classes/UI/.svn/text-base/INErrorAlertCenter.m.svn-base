//!
//! @file INErrorAlertCenter.m
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

#import "INErrorAlertCenter.h"
#import "INLocalization.h"
#import "INCommonTypes.h"

//==================================================================================================================================
//==================================================================================================================================

@interface INErrorAlertInfo : NSObject {    
    UIAlertView * _alertView;
    NSError     * _error;
}
@property(nonatomic,retain) UIAlertView * alertView;
@property(nonatomic,retain) NSError * error;
@end

//==================================================================================================================================

@implementation INErrorAlertInfo

@synthesize alertView = _alertView;
@synthesize error = _error;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)closeAlert {
    [_alertView dismissWithClickedButtonIndex:0 animated:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [self closeAlert];
    self.error = nil;
    self.alertView = nil;
    [super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INErrorAlertCenter

@synthesize noInternetTitle   = _noInternetTitle;
@synthesize noInternetMessage = _noInternetMessage;
@synthesize networkAuthMessage  = _networkAuthMessage;
@synthesize okButtonMessage  = _okButtonMessage;
@synthesize lastIssueIsNoInternetError = _lastIssueIsNoInternetError;
@synthesize shouldCenterAlertOnScreen = _shouldCenterAlertOnScreen;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
         _lastErrors = [NSMutableDictionary new]; 
        self.okButtonMessage = @"OK";
        _shouldCenterAlertOnScreen = NO;
        
        /*
         * Be notified about keyboard show/hide events
         */
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShowHide:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShowHide:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_lastErrors release];
    self.noInternetMessage = nil;
    self.noInternetTitle = nil;
    self.networkAuthMessage = nil;
    self.okButtonMessage = nil;
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)clearLastErrorForSender:(id)sender { 
    if (sender){
        [_lastErrors removeObjectForKey:sender];    
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)clearAllNetworkErrors { 
    NSMutableArray * array = [NSMutableArray array];
    for (id sender in _lastErrors.allKeys){ 
        INErrorAlertInfo * info = [_lastErrors objectForKey:sender];
        if ([info.error inru_isNetworkError]){
            [array addObject:sender];
        }    
 
    }    
    [_lastErrors removeObjectsForKeys:array];   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)error:(NSError *)error sender:(id)sender 
                                   title:(NSString *)title
                                 message:(NSString *)message
                               forceShow:(BOOL)forceShow { 
    // process "No internet" alert 
    if ([error inru_networkErrorNoInternet]){
        if (_noInternetMessage) { 
            message = _noInternetMessage;
        }
        if (_noInternetTitle) { 
            title = _noInternetTitle;
        }
        if (_lastIssueIsNoInternetError && !forceShow){
            return NO; // we will not show multiply messages
        }
        _lastIssueIsNoInternetError = YES;
        [self clearAllNetworkErrors];
    } else {
        _lastIssueIsNoInternetError = NO;
    }
                                  
    // process "Bad network password" error 
    if ([error inru_isAuthFailed]){ 
        if (_networkAuthMessage){ 
            message = _networkAuthMessage;    
        }
    }

    // Get alert info. Check what was that error.  
    INErrorAlertInfo * info = [_lastErrors objectForKey:sender];
    if (info && ! forceShow){
        if (info.error.code == error.code && [info.error.domain isEqualToString:error.domain]){
            // will not show duplicated errors
            return NO;    
        }
        // dismiss old alerts
        info.alertView = nil;
    }
 
    // create an alert                                                          
    UIAlertView * alert = [[[UIAlertView alloc] 
                             initWithTitle:title
                             message:message 
                             delegate:self 
                             cancelButtonTitle:self.okButtonMessage
                             otherButtonTitles:nil] autorelease];
                                                             
    if (!info){ 
        info = [[INErrorAlertInfo new] autorelease];
        [_lastErrors setObject:info forKey:sender];
    }
    info.error = error;
    [info closeAlert];
    info.alertView = alert;
    [info.alertView show];
    
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)error:(NSError *)error forSender:(id)sender withTitleKey:(NSString *)titleKey 
                                                        andMessageKey:(NSString *)messageKey
                                                            forceShow:(BOOL)forceShow { 
    // убрать в будущем
    return [self error:error sender:sender titleKey:titleKey messageKey:messageKey forceShow:forceShow];                                                        
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)error:(NSError *)error sender:(id)sender titleKey:(NSString *)titleKey messageKey:(NSString *)messageKey forceShow:(BOOL)forceShow {     
    NSString * message = nil;
    if (messageKey.length) { 
        message = InruLoc(messageKey, [error /* inru_*/localizedDescription]);
    } else {
        message = [error /* inru_*/localizedDescription];
    }
    NSString * title = titleKey == nil ? nil : InruLoc(titleKey);
    
    return [self error:error sender:sender title:title message:message forceShow:forceShow]; 
}

/*----------------------------------------------------------------------------------------------------------------------------------*/
/* Delegates */
/*----------------------------------------------------------------------------------------------------------------------------------*/

- (void)willPresentAlertView:(UIAlertView *)alertView {
    if (_shouldCenterAlertOnScreen && _keyboardIsShown) {
        if (INIPhoneInterface()) { 
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGRect centerRect = INRectCenter(CGRectMake(0, 0, screenRect.size.width, screenRect.size.height-_keyboardRect.size.height));
            alertView.center = centerRect.origin;
        } else {
            // сделать: правильное позиционирование в landscape. Внимание! вохможно, код для айфона также сбоит для ландшафтного режима! 
            NSAssert(0, @"not implemented for ipad yet mk_b32bd64f_0a80_4816_9398_f874d89db5b4");
        }
    }
}

/*----------------------------------------------------------------------------------------------------------------------------------*/
/* Notifications */
/*----------------------------------------------------------------------------------------------------------------------------------*/

- (void)keyboardWillShowHide:(NSNotification*)aNotification {
    _keyboardIsShown = [aNotification.name isEqualToString:UIKeyboardWillShowNotification];
    if (_keyboardIsShown) { 
        _keyboardRect = [aNotification inru_keyboardRect];
    } else {
        _keyboardRect = CGRectZero;
    }
}

@end
