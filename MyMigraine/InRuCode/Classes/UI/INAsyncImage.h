//!
//! @file INAsyncImage.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2012 InRu
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

#import "INCommonTypes.h"
#import "INNetCenter.h"

typedef enum { 
    INAsyncImageIdleState,
    INAsyncImageIdleLoading,
    INAsyncImageIdleLoaded,
    INAsyncImageIdleFailed
} INAsyncImageState;

//==================================================================================================================================
//==================================================================================================================================

@interface INAsyncImage : INObject {
    UIImage * _image;
    UIImage * _substitutionImage;
    NSString * _URLString;
    INNetCenter * _netCenter;
}

- (id)initWithURLString:(NSString *)URLString netCenter:(INNetCenter *)center;

@property (nonatomic,readonly) BOOL imageLoaded;
@property (nonatomic,readonly) INAsyncImageState imageState;
@property (nonatomic,retain) UIImage * image;
@property (nonatomic,retain) UIImage * substitutionImage;
@property (nonatomic,retain) NSString * URLString;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INAsyncImageView : UIImageView { 
    UIActivityIndicatorView * _activityIndicator;
    INAsyncImage * _asyncImage;
    SEL _asyncImageGetter;
    UIActivityIndicatorViewStyle _activityIndicatorStyle;
    BOOL _activityIndicatorVisible;
}

@property (nonatomic) BOOL activityIndicatorVisible;
@property (nonatomic) UIActivityIndicatorViewStyle activityIndicatorStyle;

- (void)setAsyncImage:(INAsyncImage *)image;
- (void)setAsyncImage:(INAsyncImage *)image getter:(SEL)getter;

@end

