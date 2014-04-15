//!
//! @file INTabbedNavigationTitleView.h
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

#import <UIKit/UIKit.h>

@class INTabbedNavigationTitleView;

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A INTabbedNavigationTitleView's delegate protocol 
    
*/
@protocol INTabbedNavigationTitleViewDelegate<NSObject>  
   
//! @brief Returns count of tabs
- (NSInteger)tabCountForTabbedTitle:(INTabbedNavigationTitleView *)tabbedTitle;
 
//! @brief Returns tab caption for a given tab index
- (NSString *)tabCaptionForTabbedTitle:(INTabbedNavigationTitleView *)tabbedTitle  
                                   andIndex:(NSInteger)tabIndex;

//! @brief Notifies that tabbedTitle did switched to tab with \c tabIndex
- (void)tabChangedToIndex:(NSInteger)tabIndex 
                         forForTabbedTitle:(INTabbedNavigationTitleView *)tabbedTitle;
@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A view with nice gradiented 'tab buttons'
    
*/
@interface INTabbedNavigationTitleView : UIView {
@private
	NSInteger _selectedTab;
    id <INTabbedNavigationTitleViewDelegate> _delegate;
    UIFont * _titleFont;
    CGFloat    _tabWidthes[50];
    UIColor *  _selectedTextColor;
    UIColor *  _textColor;
    BOOL _drawTitles;
}

@property(nonatomic) BOOL drawTitles;

//! @brief 1
@property(nonatomic,assign) NSInteger selectedTab;
     
//! @brief 1
@property(nonatomic,assign) id<INTabbedNavigationTitleViewDelegate> delegate;
    
//! @brief 1
@property(nonatomic,retain) UIFont * titleFont;

//! @brief 1
@property(nonatomic,retain) UIColor * selectedTextColor;
         
//! @brief 1
@property(nonatomic,retain) UIColor * textColor;

//! @brief 1
- (NSRange)positionForTab:(NSInteger)index withRecalculation:(BOOL)recalculation;

@end
