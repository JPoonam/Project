//!
//! @file INTable.h
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

/* 

This class is used only in Yandex.Raspisanie, so comment it out  

@class INTableViewCell;

//==================================================================================================================================
//==================================================================================================================================

@protocol INTableViewCellDelegate<NSObject>

@optional

- (BOOL)copyAbilityEnabledForCell:(INTableViewCell *)cell; 
- (NSString *)copyContentForCell:(INTableViewCell *)cell;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INTableViewCell : UITableViewCell {
    id <INTableViewCellDelegate> _delegate;
    UITableViewCellSelectionStyle _tempStoredStyle;
    NSIndexPath * _indexPath;
    BOOL _touchedMenuShown;
}

- (IBAction)copy:(id)sender;
- (void)showMenu;

@property(nonatomic,assign) IBOutlet id <INTableViewCellDelegate> delegate;

@property(nonatomic,retain) NSIndexPath * indexPath; // just to store temporary 

@end

*/

typedef enum{
	INPullToRefreshStateAnnounce = 0,
	INPullToRefreshStateReleaseToRefresh,
	INPullToRefreshStateProcessing,	
} INPullToRefreshState;

@class INPullToRefreshTableHeaderView;

//==================================================================================================================================
//==================================================================================================================================

@protocol INPullToRefreshTableHeaderViewDelegate 

- (void)inpullToRefreshView:(INPullToRefreshTableHeaderView *)view updateForState:(INPullToRefreshState)newState;
- (BOOL)inpullToRefreshViewCheckForProcessing:(INPullToRefreshTableHeaderView *)view;
- (BOOL)inpullToRefreshViewDidTriggerProcessing:(INPullToRefreshTableHeaderView *)view;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INPullToRefreshTableHeaderView : UIView {
    INPullToRefreshState _state;
    CGFloat _dragDownThresholdOffset;
    UIImageView * _arrowImageView;
    UIActivityIndicatorView * _activityIndicator;
    UILabel * _titleLabel;
    UILabel * _subtitleLabel;
    id<INPullToRefreshTableHeaderViewDelegate> _delegate;
}

@property (nonatomic) CGFloat dragDownThresholdOffset;
@property (nonatomic,strong) IBOutlet UIImageView * arrowImageView;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic,strong) IBOutlet UILabel * titleLabel;
@property (nonatomic,strong) IBOutlet UILabel * subtitleLabel;
@property (nonatomic,assign) IBOutlet id<INPullToRefreshTableHeaderViewDelegate> delegate;
@property (nonatomic,readonly) INPullToRefreshState state;

- (void)handleDidScrollDelegateMethod;
- (void)handleDidEndDraggingDelegateMethod;
- (void)addToTableView:(UITableView *)tableView;
- (void)updateStateAnimated:(BOOL)animated;

@end


/* 

@protocol EGORefreshTableHeaderDelegate;
@interface EGORefreshTableHeaderView : UIView {
	
	id _delegate;
	EGOPullRefreshState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	UIActivityIndicatorView *_activityView;
	
    
}

@property(nonatomic,assign) id <EGORefreshTableHeaderDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;
@end

*/
