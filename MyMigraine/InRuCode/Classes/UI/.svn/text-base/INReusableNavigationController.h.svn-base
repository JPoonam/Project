//!
//! @file INReusableNavigationController.h
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

/* 
Usage: 
 
INReusableNavigationController * controller = [INReusableNavigationController new];
controller.liveControllersCount = 4; // >= 2
 
@interface TestViewController : UIViewController<INReusableViewController> {
 
}
@end
 
@implementation TestViewController

- (id<NSCopying>) controllerKey {
   return @"somekey";    
 }
 
- (id) initWithControllerKey: (id<NSCopying>) aControllerKey {
    self = [self init];
    if (self != nil) {
        ....
    }
    return self;
}
@end
 
*/

/**
 @brief A must-implement protocol for all child controller of INReusableNavigationController 
    
*/
@protocol INReusableViewController 
    //! @brief Unique controller key (should contains data for deserialization of controller) 
    //    the controller key is copied by INReusableNavigationController 
    //    so return only autoreleased objects here!
    - (id<NSCopying>) controllerKey;

    //! @brief Restore controller state with the given controller key 
    - (id) initWithControllerKey: (id<NSCopying>) aControllerKey;
@end


/**
 @brief A class that tries to serialize child controllers when needed. Used on big,big controller hierarchies 
 
*/
@interface INReusableNavigationController : UINavigationController {
@private
    NSMutableArray * _internalStack;
    NSInteger _liveStackSize;
}
    //! @brief Internak stack 
    @property (nonatomic, readonly) NSArray * internalStack;

    /** @brief  
     How many controllers at the top of stack are kept alive 
     values < 2 disables reusable ability. Note that actual count of 
     existing at the given moment controllers can be bigger (not all view 
     controllers can support save/restore ability and thus could not be
     archived)
     
     The changes are applied to the next pop/push operations. Just 
     implementation feature, not a bug.
    */ 
    @property NSInteger liveControllersCount; 
@end


