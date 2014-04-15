//!
//! @file INDynamicPages.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2011 InRu
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
#import "INObject.h"

@class INDynamicPagesViewController, INDynamicPagesCategoryItem, INDynamicPageView;

typedef enum { 
    INDynamicPageLeftShadowImage,
    INDynamicPageRightShadowImage,
    INDynamicPageShadowImageLast
} INDynamicPageShadowImageID;


//==================================================================================================================================
//==================================================================================================================================

@protocol INDynamicPagesDelegate<NSObject>


@required 

// Category UI
- (UIView *)indynamicPages:(INDynamicPagesViewController *)pagesController viewForCategoryItem:(INDynamicPagesCategoryItem *)categoryItem expanded:(BOOL)expanded reusingView:(UIView *)view;

// Category selection
- (void)indynamicPages:(INDynamicPagesViewController *)pagesController didSelectCategoryItem:(INDynamicPagesCategoryItem *)categoryItem;

@optional

// Category UI 
- (CGFloat)indynamicPages:(INDynamicPagesViewController *)pagesController widthForCategoryPanelExpanded:(BOOL)expanded portraitOrientation:(BOOL)portraitOrientation;
- (CGFloat)indynamicPages:(INDynamicPagesViewController *)pagesController heightForCategoryItem:(INDynamicPagesCategoryItem *)categoryItem expanded:(BOOL)expanded;
- (UIEdgeInsets)indynamicPages:(INDynamicPagesViewController *)pagesController categoryTableInsetsForPortraitOrientation:(BOOL)portraitOrientation expanded:(BOOL)expanded;
- (UIView *)indynamicPages:(INDynamicPagesViewController *)pagesController backgroundViewForCategoryItem:(INDynamicPagesCategoryItem *)categoryItem expanded:(BOOL)expanded selected:(BOOL)selected;
- (void)indynamicPages:(INDynamicPagesViewController *)pagesController layoutCategoryPanelExpanded:(BOOL)expanded portraitOrientation:(BOOL)portraitOrientation animated:(BOOL)animated;

// Category selection
- (BOOL)indynamicPages:(INDynamicPagesViewController *)pagesController willSelectCategoryItem:(INDynamicPagesCategoryItem *)categoryItem selectedItem:(INDynamicPagesCategoryItem *)selectedItem;

// Page UI
- (CGFloat)indynamicPages:(INDynamicPagesViewController *)pagesController contentWidthForPageWithContext:(id)context level:(NSUInteger)level portraitOrientation:(BOOL)portraitOrientation;
- (CGFloat)indynamicPages:(INDynamicPagesViewController *)pagesController childOffsetInBoorkmarkStateForPage:(INDynamicPageView *)page portraitOrientation:(BOOL)portraitOrientation;
- (void)indynamicPages:(INDynamicPagesViewController *)pagesController didCreatePage:(INDynamicPageView *)page; // called in animated state 
- (void)indynamicPages:(INDynamicPagesViewController *)pagesController didPageLayOutAfterCreation:(INDynamicPageView *)page;  

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INDynamicPagesCategoryItem : INObject2 {
@private
    INDynamicPagesViewController * _mainController; 
    UIView * _contentView;
}

- (void)reloadContentView;

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum {
    INDynamicPageShiftedOverParentOpenMode,            // default       
    INDynamicPageSideBySideWithParentOpenMode,
    INDynamicPageOverParentOpenMode              //       
} INDynamicPageOpenMode;

@interface INDynamicPageView : UIView<UIScrollViewDelegate> {
@private
    NSInteger _comingState;
    NSInteger _level;
    NSInteger _state;
    INDynamicPageView * _childPage;
    INDynamicPageView * _parentPage;
    UIView * _contentView;
    UIScrollView * _scrollView;
    INDynamicPagesViewController * _controller;
    id _context;
    NSInteger _draggingState;
    UIImageView * _shadowImageViews[INDynamicPageShadowImageLast];
    BOOL _canCompletelyOverlaysParent;
}

- (INDynamicPageView *)openChildPageWithContext:(id)context;
- (INDynamicPageView *)openChildPageWithContext:(id)context mode:(INDynamicPageOpenMode)mode;
- (void)closeChildPage;
   
@property (nonatomic) BOOL canCompletelyOverlaysParent;
@property (nonatomic,readonly) id context;
@property (nonatomic,readonly) UIView * contentView;
@property (nonatomic,readonly) NSInteger level;
@property (nonatomic,readonly) INDynamicPageView * childPage;
@property (nonatomic,readonly) INDynamicPageView * parentPage;

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum { 
    INDynamicPageTransitionFromUpToDown,
    INDynamicPageTransitionFromDownToUp
} INDynamicPageTransition;


@interface INDynamicPagesViewController : UIViewController {
@private
    id<INDynamicPagesDelegate> _delegate;
    BOOL _currentOrientationIsPortrait;

    UIView * _categoryPanel;
    BOOL _categoryPanelExpanded;   
    NSArray * _categoryItems;   
    UITableView * _categoryTable;
    NSIndexPath * _selectedCategoryItemPath;
        
    UIScrollView * _mainScrollView;
    INDynamicPageView * _rootPage;
    
    UIView * _draggingView;
    UIView * _draggingFrame1;
    UIView * _draggingFrame2;

    UIImage * _shadowImages[INDynamicPageShadowImageLast];
}

@property(nonatomic,assign) IBOutlet id<INDynamicPagesDelegate> delegate;   
@property(nonatomic,readonly) BOOL currentOrientationIsPortrait;

// Это для небольшой настройки UI, вроде backgroundColor, не более того
@property(nonatomic,readonly) UIView * categoryPanel;
@property(nonatomic,readonly) UITableView * categoryTableView;
@property(nonatomic,readonly) INDynamicPageView * rootPage;
- (void)reloadCategoryTable;

- (void)setShadowImage:(UIImage *)image withID:(INDynamicPageShadowImageID)imageID;

// An array of sections (INDynamicPagesCategoryItem) with items: INDynamicPagesCategoryItem
@property(nonatomic,retain) NSArray * categoryItems;
- (void)selectCategoryItemWithPath:(NSIndexPath *)path emulateUserTouch:(BOOL)emulateUserTouch;
- (void)setCategoryItems:(NSArray *)items tryToPreserveSelection:(BOOL)tryToPreserveSelection;

- (void)openPageWithContext:(id)context transition:(INDynamicPageTransition)transition;
- (void)closePageWithTransition:(INDynamicPageTransition)transition;

// Иногда по вьюхе нужно найти на какой странице она лежит
- (INDynamicPageView *)parentPageForView:(UIView *)view; 
- (INDynamicPageView *)topVisiblePage;

@end
