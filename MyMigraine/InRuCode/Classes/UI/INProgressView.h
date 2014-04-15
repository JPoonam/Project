//!
//! @file INProgressView.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2010-2011 InRu
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

typedef enum {
    INProgressViewStyleDefault, // system one.
    INProgressViewStyleCustom   // you must assign backgroundImage, progressImage, positionImageOffset.
                                // images must be stretchable!!! see UISlider documentation
} INProgressViewStyle;

//==================================================================================================================================
//==================================================================================================================================

@interface INProgressView : UIProgressView {
    INProgressViewStyle _extendedBarStyle;
    UIImage * _backgroundImage;
    UIImage * _progressImage;
}

@property(nonatomic) INProgressViewStyle extendedBarStyle;

@property(nonatomic,retain) UIImage * backgroundImage;
@property(nonatomic,retain) UIImage * progressImage;


@end
