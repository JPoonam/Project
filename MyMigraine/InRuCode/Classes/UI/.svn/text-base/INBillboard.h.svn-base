//!
//! @file INBillboard.h
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

#import <UIKit/UIKit.h>

@class INBillboardPlateView, INBillboard;

@interface INBillboardMessage : NSObject { 
    NSString * _message;
    NSInteger _tag;
    UIFont * _font;
    UIColor * _color;
    BOOL _opaque;
}

@property(nonatomic) NSInteger tag;
@property(nonatomic,retain) NSString * message;
@property(nonatomic,retain) UIFont * font;
@property(nonatomic,retain) UIColor * color;
@property(nonatomic) BOOL opaque;

+ (INBillboardMessage *)messageWithMessage:(NSString *)message tag:(NSInteger) tag;

@end

//==================================================================================================================================
//==================================================================================================================================

@protocol INBillboardDelegate <NSObject>
@optional

- (void)billBoard:(INBillboard *)billboard wantsToCustomizeMessage:(INBillboardMessage *)message;

// should return YES if it complelety handled painting
- (BOOL)billBoard:(INBillboard *)billboard customDraw:(INBillboardMessage *)message rect:(CGRect)aRect;
- (void)billBoard:(INBillboard *)billboard postDraw:(INBillboardMessage *)message rect:(CGRect)aRect;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief Simplest view with a bunch of right-to-left running strings.   
    
 @todo  Add customizable colors, animation timeouts, etc.
*/
@interface INBillboard : UIView {
@private
    NSArray * _messages;
    UIFont * _font;
    UIColor * _color;
    int _nextItemInArray;
    INBillboardPlateView * _vForAway, * _v2;
    id<INBillboardDelegate> _delegate;
}

//! @brief Array of INBillboardMessage to display NSString
@property(nonatomic,retain) NSArray * messages;

//! @brief Default font for messages
@property(nonatomic,retain) UIFont  * font;

//! @brief Default color for messages
@property(nonatomic,retain) UIColor  * color;


@property(nonatomic,assign) id<INBillboardDelegate> delegate; 

@end
