//!
//! @file INSegmentedControl.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright ©  2011 InRu
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
#import "INCommonTypes.h"
#import "INView.h"

@class INSegmentedControl, _INSegmentedSliderTrackControl;

//==================================================================================================================================
//==================================================================================================================================

@protocol INSegmentedControlDelegate

- (void)insegmentedControl:(INSegmentedControl *)segmentedControl didSelectedSegmentAtIndex:(NSInteger)segmentIndex;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INSegmentedControl : UIView {
    id<INSegmentedControlDelegate> _delegate;
    UIImage * _backgroundImage;
    NSInteger _selectedSegment, _buttonCount;
    NSInteger _buttonWidthMode;
    CGSize _prevSize;
}

@property(nonatomic,assign) IBOutlet id<INSegmentedControlDelegate> delegate;
@property(nonatomic,retain) UIImage * backgroundImage;
@property(nonatomic,readonly) NSInteger buttonCount;
@property(nonatomic) NSInteger selectedSegmentIndex;

- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated;
- (void)setButtonCount:(NSInteger)buttonCount initialSelection:(NSInteger)initialSelection;
- (void)setButtons:(NSArray *)buttonCaptions initialSelection:(NSInteger)initialSelection;
- (void)setButtons:(NSArray *)buttonCaptions initialSelection:(NSInteger)initialSelection proportionalWidth:(BOOL)proportionalWidthMode;


// for overriding in descendants
- (void)setupButton:(INButton *)btn atIndex:(NSInteger)index;

- (UIEdgeInsets)contentInset;
- (CGRect)contentRect;
- (CGFloat)buttonGap;
- (UIButton *)buttonAtIndex:(NSInteger)index;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INSegmentedSliderControl : INSegmentedControl {
@private
    _INSegmentedSliderTrackControl * _trackControl;
    UIImage * _sliderImage;
}

@property(nonatomic,retain) UIImage * sliderImage;

@end
