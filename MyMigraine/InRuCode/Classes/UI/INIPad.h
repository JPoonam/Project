//!
//! @file INIPad.h
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

//==================================================================================================================================
//==================================================================================================================================

@protocol INInterfaceRotateWatcherDelegate 

- (void)interfaceRotatedFrom:(UIInterfaceOrientation)oldOrientation to:(UIInterfaceOrientation)newOrientation;

@end

//==================================================================================================================================
//==================================================================================================================================
//  перенести в common types?

@interface INInterfaceRotateWatcher : NSObject { 
    NSMutableArray * _subscribers;
    UIInterfaceOrientation _oldOrientation;
}

+ (void)subscribe:(id<INInterfaceRotateWatcherDelegate>)subscriber;
+ (void)unsubscribe:(id<INInterfaceRotateWatcherDelegate>)subscriber;

@end

//==================================================================================================================================
//==================================================================================================================================

@class INPopoverController;

@protocol INPopoverControllerDelegate<UIPopoverControllerDelegate>
@optional

//! @brief Called back with dismissPopoverAnimated:. Use it along with popoverControllerDidDismissPopover: to handle all popover closing events.
//         It is safe to release popover here  
- (void)popoverControllerDidInitiateManualDismissing:(INPopoverController *)popoverController;


@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum { 
    INPopoverRotationBehaviourDoNothing,
    INPopoverRotationBehaviourMoveToCenterOfWindow,
    INPopoverRotationBehaviourDismiss // dismiss the popover on any device rotation (default popover behaviour)
} INPopoverRotationBehaviour; 

//==================================================================================================================================
//==================================================================================================================================

@interface INPopoverController : UIPopoverController<INInterfaceRotateWatcherDelegate> { 
    INPopoverRotationBehaviour _deviceRotationBehaviour;
    NSInteger _tag;
}

@property(nonatomic) NSInteger tag;

//! @brief Default is INPopoverRotationBehaviourDismiss 
@property(nonatomic)INPopoverRotationBehaviour interfaceRotationBehaviour;

//! @brief just to allow pass it into addTarget:action:....
- (void)dismissPopoverAnimatedYES;

@end

