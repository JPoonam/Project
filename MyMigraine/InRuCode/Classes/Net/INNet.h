//!
//! @file INNet.h
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

#import <Foundation/Foundation.h>

//! @brief Checks if we are connected to the network
extern BOOL INNetWeAreConnectedToNetwork();


/**
 @brief  A singleton class that represents a global network indicator in the status bar. All network-consuming classes must 
         register network activity with the start method and unregister with the stop method. 
 */

@interface INNetworkIndicator : NSObject {
    
}
//! @brief Notify about beginning of a network activity
+ (void)start; 

//! @brief Notify about finishing of a network activity 
+ (void)stop; 

@end
