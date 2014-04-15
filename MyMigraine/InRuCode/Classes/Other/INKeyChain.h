//!
//! @file INKeyChain.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Based partly on code by Jonathan Wight, Jon Crosby, Mike Malone and Buzz Andersen.
//! Copyright © 2011 InRu
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

@interface INKeyChain : NSObject {

}

+ (NSString *)passwordForUsername:(NSString *)username service:(NSString *)service error:(NSError **)error;
+ (NSString *)passwordForUsername:(NSString *)username service:(NSString *)service;

+ (BOOL)savePassword:(NSString *)password forUsername:(NSString *)username service:(NSString *)service error:(NSError **)error;
+ (void)savePassword:(NSString *)password forUsername:(NSString *)username service:(NSString *)service;

+ (BOOL)deletePasswordForUsername:(NSString *)username service:(NSString *)serviceName error:(NSError **)error;
+ (void)deletePasswordForUsername:(NSString *)username service:(NSString *)serviceName;

@end

