//!
//! @file INIPad.m
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

#import "INIPad.h"
#import "INCommonTypes.h"


//==================================================================================================================================
//==================================================================================================================================

@interface INPopoverController ()
@end

@implementation INPopoverController

@synthesize interfaceRotationBehaviour = _deviceRotationBehaviour;
@synthesize tag = _tag;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithContentViewController:(UIViewController *)viewController {
    self = [super initWithContentViewController:viewController];
    if (self != nil) {
        [INInterfaceRotateWatcher subscribe:self];
        _deviceRotationBehaviour = INPopoverRotationBehaviourDismiss;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    // #warning remove it
    // NSLog(@"dellloc %@", self.contentViewController);
    [INInterfaceRotateWatcher unsubscribe:self];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)interfaceRotatedFrom:(UIInterfaceOrientation)oldOrientation to:(UIInterfaceOrientation)newOrientation { 
    switch (_deviceRotationBehaviour) { 
        case INPopoverRotationBehaviourDoNothing:
            break;

        case INPopoverRotationBehaviourMoveToCenterOfWindow:
            {
                UIView * v = [[UIApplication sharedApplication].windows objectAtIndex:0];
                [self presentPopoverFromRect:v.bounds inView:v permittedArrowDirections:0 animated:YES];
            }
            break;
            
        case INPopoverRotationBehaviourDismiss:
            if (self.popoverVisible) {
                if ([self.delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)]) { 
                    if (![self.delegate popoverControllerShouldDismissPopover:self]) { 
                        return;
                    }
                }
                [self dismissPopoverAnimated:NO];
            }
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dismissPopoverAnimatedYES { 
    [self dismissPopoverAnimated:YES];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dismissPopoverAnimated:(BOOL)animated { 
    [super dismissPopoverAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(popoverControllerDidInitiateManualDismissing:)]) { 
        [(id)self.delegate popoverControllerDidInitiateManualDismissing:self];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INInterfaceRotateWatcher ()
- (void) deviceOrientationChanged:(NSNotification *)notification;
@end

@implementation INInterfaceRotateWatcher

static INInterfaceRotateWatcher * g_WatcherSignleton = nil;

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)subscribe:(id<INInterfaceRotateWatcherDelegate>)subscriber { 
   NSParameterAssert(subscriber);
   if (!g_WatcherSignleton) { 
       g_WatcherSignleton = [INInterfaceRotateWatcher new];
   }
   [g_WatcherSignleton->_subscribers addObject:subscriber];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)unsubscribe:(id<INInterfaceRotateWatcherDelegate>)subscriber { 
    NSParameterAssert(subscriber);
    if (g_WatcherSignleton) { 
        [g_WatcherSignleton->_subscribers removeObject:subscriber];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        _subscribers = [[NSMutableArray inru_nonRetainingArray] retain];
        _oldOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(deviceOrientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification 
                                                   object:nil];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [_subscribers release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) deviceOrientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation newOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (newOrientation != _oldOrientation) {
        UIInterfaceOrientation old = _oldOrientation;
        _oldOrientation = newOrientation;
        NSMutableArray * a = [NSMutableArray inru_nonRetainingArray];
        [a addObjectsFromArray:_subscribers]; // _subscribers can be modified during processing
        for (id object in a) { 
            [object interfaceRotatedFrom:old to:newOrientation];
        }
    }
}

@end 

