//!
//! @file INTabbedNavigationController.h
//!
//! @author Alexander Babaev (alex.babaev@me.com)
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
#import "INTabbedNavigationTitleView.h"
#import "INTitleLine.h"

@class INTabbedNavigationController;

/**
 @brief A INTabbedNavigationController's delegate protocol
    
*/
@protocol INTabbedNavigationControllerDelegate<NSObject> 
@optional
//! @brief Provides line texture (resource image file name)for a tab in INTabbedNavigationController
- (NSString *)lineTextureForTabbedNavigation:(INTabbedNavigationController *)tabbedController 
                                         andIndex:(NSInteger)tabIndex;

//! @brief Notifies that tabbed controller is about to switch from one tab to another one
- (void)tabbedNavigation:(INTabbedNavigationController *)tabbedController 
                 willSwitchToTab:(NSInteger)tabIndex 
                 withController:(UIViewController *)controller;

//! @brief Notifies that tabbed controller will open one of it's stacked view controllers (including tab controller)
- (void)tabbedNavigation:(INTabbedNavigationController *)tabbedController 
                 willShowViewController:(UIViewController *)controller
                        isTabController:(BOOL)isATab;
                
//! @brief @brief Notifies that tabbed controller will pop one of it's stacked view controllers
- (void)tabbedNavigation:(INTabbedNavigationController *)tabbedController 
                popViewController:(UIViewController *)controller
                         animated:(BOOL)animated;
@end

//==================================================================================================================================
//==================================================================================================================================

/**
   @brief A custom navigation controller with a nice tabs 
   
   !!! Do not assign INTabbedNavigationController.delegate !!! 
   Use tabbedDelegate for that (add needful delegate methods from UINavigationControllerDelegate
   handling there when needed)
*/
@interface INTabbedNavigationController : UINavigationController
                                <UINavigationControllerDelegate,
                                 INTabbedNavigationTitleViewDelegate> {
                                     
	INTabbedNavigationTitleView * _rootTitleView;
	NSArray * _tabViewControllers;
    INTitleLine * _titleLine;
    id<INTabbedNavigationControllerDelegate> _tabbedDelegate;
}
//! @brief root view controllers for tabs
@property(nonatomic, copy) NSArray * tabViewControllers;
    
//! @brief A delegate 
@property(nonatomic,assign)id<INTabbedNavigationControllerDelegate> tabbedDelegate;

//! @brief Tabs header colored line
@property(nonatomic,readonly) INTitleLine * titleLine;
   
//! @brief Tabs header view
@property(nonatomic,readonly) INTabbedNavigationTitleView * titleView;

//! @brief Selected tab index
@property NSInteger selectedTab;

//! @brief Selects a tab by it's index
- (void) selectTab:(NSInteger)aNewTabIndex;

//! @brief Returns a free area for chilf controller, i.e. area that is not occupied by tab title line (5px currently)
- (CGRect)frameWithoutTitleLineForViewController:(UIViewController *)controller;
    
//! @brief Title line height (currently 5px). Used to calculate free controller area (see \c frameWithoutTitleLineForViewController also)
- (CGFloat)titleLineHeight;
@end

