//!
//! @file INDynamicPages.m
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

#import "INDynamicPages.h"
#import "INCommonTypes.h"
#import "INGraphics.h"
#import <QuartzCore/QuartzCore.h>

#define ANIM_DURATION  0.2
// #define PGDEBUG

#ifdef PGDEBUG
    #import "INView.h"
#endif

@interface INDynamicPagesViewController()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

- (BOOL)switchExpandedModeTo:(BOOL)expanded onlyCategoryPanel:(BOOL)onlyCategoryPanel;
- (void)setPageActive:(INDynamicPageView *)page;

- (void)layoutCategoryPanelAnimated:(BOOL)animated;
- (void)layoutMainScrollPanelAnimated:(BOOL)animated;
- (void)layoutViews:(BOOL)forceUpdate animated:(BOOL)animated;

- (CGRect)frameForMainScrollView;
- (CGFloat)scrollOffsetThreshold; 

- (void)startAnimation:(NSString *)animationName context:(void *)context;
- (void)setDraggingState:(NSInteger)newState forceUpdate:(BOOL)forceUpdate animated:(BOOL)animated;

- (UIScrollView *)mainScrollView;
- (UIImage *)shadowImageWithID:(INDynamicPageShadowImageID)imageID;

- (void)reloadCategoryItem:(INDynamicPagesCategoryItem *)item;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface _INDynamicPagesRootView : UIView { 
    INDynamicPagesViewController * _controller;
}

@property (nonatomic,assign) INDynamicPagesViewController * controller;

@end

//==================================================================================================================================

@implementation _INDynamicPagesRootView

@synthesize controller = _controller;

- (void)layoutSubviews { 
    [super layoutSubviews];
    [_controller layoutViews:NO animated:NO];
    // NSLog(@"----");
}

@end

//==================================================================================================================================
//==================================================================================================================================

//  состояние страницы применительно к движению
enum { 
    PAGE_COMING_STATE_IDLE,
    PAGE_COMING_STATE_COMING,
    PAGE_COMING_STATE_OUTGOING
}; 

enum { 
    // состояния самой первой страницы по отношению к главной вьюхе контроллера, уровень 0 
    PAGE_STATE_0_EXPANDED,       
    PAGE_STATE_0_COLLAPSED_MULTI, // MULTI указывает на то, что сжатое состояние имеет смысл только при наличии дочерних страниц
    
    // состояние каждой последующей странице, по отношению к предыдущей 
    PAGE_STATE_1_OVER_FULL,       // полностью перекрывает родителя 
    PAGE_STATE_1_OVER_BOOKMARK,   // частично перекрывает родителя, слева остается полоска с шириной, устанавливаемой через делегат. Значение по умолчанию при создании новой дочерней страницы
    PAGE_STATE_1_SIDE_BY_SIDE,    // не перекрывает родителя, располагается справа
};


enum { 
    DRAGGING_STATE_NONE, 
    DRAGGING_STATE_IN, 
    DRAGGING_STATE_OUT,
    DRAGGING_STATE_OUT_COLLAPSE
};

@interface INDynamicPageView()

@property (nonatomic) NSInteger comingState;
@property (nonatomic) NSInteger state;
@property (nonatomic,assign) INDynamicPagesViewController * controller;
@property (nonatomic) BOOL isActive;
@property (nonatomic) NSInteger draggingState;

- (CGFloat)contentWidthForPageWithContext:(id)context level:(NSUInteger)level;


@end

//==================================================================================================================================

//#define SHADOW_WIDTH           30
// #define LINE_WIDTH   80
// #define BLUR         100
//#define SHADOW_START_OPACITY   0.8 

@implementation INDynamicPageView

@synthesize comingState = _comingState;
@synthesize state = _state;
@synthesize controller = _controller;
@synthesize parentPage = _parentPage;
@synthesize childPage = _childPage;
@synthesize context = _context;
@synthesize draggingState = _draggingState;
@synthesize contentView = _contentView;
@synthesize level = _level;
@synthesize canCompletelyOverlaysParent = _canCompletelyOverlaysParent;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit {
    CGRect r = self.bounds;
    CGRect cvRect = r;
    
    cvRect.size.width = [self contentWidthForPageWithContext:_context level:_level];
    
#ifdef PGDEBUG
    cvRect = CGRectInset(cvRect,0,10);
#endif

    _contentView = [[UIView alloc] initWithFrame:cvRect];
    _contentView.backgroundColor = [UIColor whiteColor];
    //_contentView.layer.borderColor = [UIColor redColor].CGColor;
    //_contentView.layer.borderWidth = 1;
    [self addSubview:_contentView];
    
    

    /* 
    _contentView.layer.shadowRadius = 20;
    _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contentView.layer.shadowOpacity = 1.0;
    */
    
    /*
    static UIImage * leftShadowImage = nil;
    static UIImage * rightShadowImage = nil;
    if (!leftShadowImage) {
        CGRect r = CGRectMake(0,0,SHADOW_WIDTH,10);
        //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
       // static const CGFloat gradientColors[] = { 
        //     0,0,0, 0,
        //     0,0,0, SHADOW_START_OPACITY
        //};
        //CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColors, nil, 2);

        {        
            // left image 
            INGraphicsBeginImageContext(r.size);
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                // CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, 0), CGPointMake(r.size.width,0), 0);
                
                CGContextSetShadowWithColor (ctx, CGSizeMake(0,0), BLUR, [UIColor blackColor].CGColor);
                CGContextSetLineWidth(ctx, LINE_WIDTH);
                CGPoint line[2] = {
                    CGPointMake(r.size.width + LINE_WIDTH / 2,0), 
                    CGPointMake(r.size.width + LINE_WIDTH / 2,r.size.height)
                };
                CGContextStrokeLineSegments(ctx, line, 2);
                leftShadowImage = [UIGraphicsGetImageFromCurrentImageContext() retain];               
            }
            UIGraphicsEndImageContext();

            // right image 
            INGraphicsBeginImageContext(r.size);
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                // CGContextDrawLinearGradient(ctx, gradient, CGPointMake(r.size.width, 0), CGPointMake(0,0), 0);
                 
                CGContextSetShadowWithColor (ctx, CGSizeMake(0,0), 100, [UIColor blackColor].CGColor);
                CGContextSetLineWidth(ctx, LINE_WIDTH);
                CGPoint line[2] = {
                    CGPointMake(- LINE_WIDTH / 2,0), 
                    CGPointMake(- LINE_WIDTH / 2,r.size.height)
                };
                CGContextStrokeLineSegments(ctx, line, 2);
                
                //rightShadowImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
                //[rightShadowImage inru_saveAsPNG:@"/Users/murad/Desktop/1.png"];               
            }
            UIGraphicsEndImageContext();
        }
        //CGGradientRelease(gradient);
        //CGColorSpaceRelease(colorSpace);
    } 
    */   
        
    // #ifndef PGDEBUG
    for (int i = 0; i < INDynamicPageShadowImageLast; i++) { 
        UIImage * img = [_controller shadowImageWithID:i];
        if (img) { 
            CGSize sz = img.size;
            CGRect r1 = INRectFromSize(sz);
            NSInteger aMask = 0;
            switch (i) { 
                 case INDynamicPageLeftShadowImage:
                     r1.origin.x = -sz.width;
                     r1.size.height = r.size.height;
                     aMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
                     break;
                     
                 case INDynamicPageRightShadowImage:
                     r1.origin.x = r.size.width;
                     r1.size.height = r.size.height;
                     aMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
                     break;
                     
                 default:
                     NSAssert(0,@"mk_a7921eda_33f5_4684_af76_532eea38cb65");
            }
            _shadowImageViews[i] = [[UIImageView alloc] initWithFrame:r1];
            [self addSubview:_shadowImageViews[i]];
            _shadowImageViews[i].autoresizingMask = aMask;
            _shadowImageViews[i].image = img;
            [_shadowImageViews[i] release];
        }
    }
    // #endif 
    
    #ifdef PGDEBUG
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(100,100,80,37);
        [button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside]; 
        [_contentView addSubview:button];
    }
    #endif

    #ifdef PGDEBUG
    {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        button.frame = CGRectMake(r.size.width - 100,100,80,37);
        [button addTarget:self action:@selector(btnPressed2:) forControlEvents:UIControlEventTouchUpInside]; 
        [_contentView addSubview:button];
    }
    #endif
}

/*
//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame controller:(id)controller context:(id)context level:(NSInteger)level {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _controller = controller;
        _context = [context retain];
        _level = level;
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    // NSLog(@"INDynamicPageView dealloc");
    [_context release];
    [_childPage release];
    [_scrollView release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isActive { 
    UIScrollView * parentScroll = (id)[self superview];
    return parentScroll.alwaysBounceHorizontal = YES;
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setIsActive:(BOOL)value { 
    UIScrollView * parentScroll = (id)[self superview];
    NSAssert([parentScroll isKindOfClass:UIScrollView.class], @"mk_363ca75d_8b58_42e4_813a_c03f381890b8");
    parentScroll.alwaysBounceHorizontal = value;
#ifdef PGDEBUG
    _contentView.backgroundColor = value ? [UIColor lightGrayColor] : [UIColor whiteColor];
#endif

}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)setContext:(id)context { 
    [_context autorelease];
    _context = [context retain];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)contentWidthForPageWithContext:(id)context level:(NSUInteger)level { 
    if ([_controller.delegate respondsToSelector:@selector(indynamicPages:contentWidthForPageWithContext:level:portraitOrientation:)]) {
        return [_controller.delegate indynamicPages:_controller contentWidthForPageWithContext:context level:level portraitOrientation:_controller.currentOrientationIsPortrait];
    }
    if (_controller.currentOrientationIsPortrait) { 
        return 460;
    } else { 
        return 583;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForContentViewContext:(id)context level:(NSInteger)level { 
    CGRect r = self.bounds;
    r.size.width = [self contentWidthForPageWithContext:context level:level];
#ifdef PGDEBUG
    return CGRectInset(r,0,10);
#else 
    return r;
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForContentView {
    return [self frameForContentViewContext:_context level:_level]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)widthForChildOffset {
    if ([_controller.delegate respondsToSelector:@selector(indynamicPages:childOffsetInBoorkmarkStateForPage:portraitOrientation:)]) { 
        return [_controller.delegate indynamicPages:_controller childOffsetInBoorkmarkStateForPage:self portraitOrientation:_controller.currentOrientationIsPortrait];
    }
    return 200;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForChildScrollViewAtState:(NSInteger)state context:(id)context level:(NSUInteger)level{
    
    // CGPoint pt = [self convertPoint:CGPointMake(0,0) toView 
    // CGRect rP = [_controller.rootPage convertRect:_controller.rootPage.bounds toView:self]; 
    // CGRect r = [self frameForContentView];
    CGRect r = self.bounds;
    
    switch (state) { 
        case PAGE_STATE_1_OVER_BOOKMARK:
            r = INRectInset(r, self.widthForChildOffset,0,0,0);
            break;
            
        case PAGE_STATE_1_OVER_FULL:
            break;
            
        case PAGE_STATE_1_SIDE_BY_SIDE:
            r.origin.x += [self contentWidthForPageWithContext:_context level:_level];
            break;
            
        default:
            NSAssert(0,@"mk_d848acb5_9774_4046_8613_01f0eb388917");
    }
    r.size.width = _controller.rootPage.bounds.size.width;
             
#ifdef PGDEBUG
    return CGRectInset(r,0,10);
#else 
    return r;
#endif

} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)layoutContent { 
    // right shadow + content view
    { 
        CGRect r = [self frameForContentView]; 
        _contentView.frame = r;
        
        for (int i = 0; i < INDynamicPageShadowImageLast; i++) { 
            UIImageView * iv = _shadowImageViews[i];
            if (iv) { 
                CGRect r1 = iv.frame;
                switch (i) { 
                     case INDynamicPageLeftShadowImage:
                         break;
                         
                     case INDynamicPageRightShadowImage:
                         r1.origin.x = CGRectGetMaxX(r);
                         break;
                         
                     default:
                         NSAssert(0,@"mk_a7921eda_33f5_4684_af76_532eea38cb65");
                }
                iv.frame = r1;
            }
        }
    }
    
    // выравниваем детей 
    if (_childPage || _scrollView) { 
        NSAssert(_childPage && _scrollView, @"mk_f6b5af9c_98f2_4eb0_b32f_76b1533477ff");
        CGRect r = [self frameForChildScrollViewAtState:_childPage.state context:_childPage.context level:_childPage->_level];
        _scrollView.frame = r;
        _scrollView.contentSize = r.size;
        _childPage.frame = INRectFromSize(r.size); //   r.size);
        [_childPage layoutContent];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)scrollFrameForState:(NSInteger)state { 
    CGRect r = self.bounds; 
    r = INRectInset(r, 100, 0, 0, 0);
    return r;
}
    
//----------------------------------------------------------------------------------------------------------------------------------

- (void)closeChildPage {
    if (_childPage) {  
        // страница уходит независимо от новой, т.е. уходит вместе со скроллвьюхой
        CGRect r = _scrollView.frame; 
        
        r.origin.x += r.size.width;
        _scrollView.delegate = nil;
        [_controller startAnimation:@"closeChildPageWithScroll" context:[_scrollView retain]];
        {   
            [_scrollView release];
            _scrollView.frame = r;
            _scrollView = nil;
            [_childPage release];
            _childPage = nil;
        }
        [UIView commitAnimations];    
    }
}

//- (id)retain { 
//    return [super retain];
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notifyPageCreated {
    if ([_controller.delegate respondsToSelector:@selector(indynamicPages:didCreatePage:)]) { 
        [_controller.delegate indynamicPages:_controller didCreatePage:self];      
    }
#ifdef PGDEBUG
    self.backgroundColor = [UIColor inru_colorFromRGBA:0x336699FF];
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1;
    self.clipsToBounds = NO;
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notifyNewPageLayedOut {
    if ([_controller.delegate respondsToSelector:@selector(indynamicPages:didPageLayOutAfterCreation:)]) { 
        [_controller.delegate indynamicPages:_controller didPageLayOutAfterCreation:self];      
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDynamicPageView *)openChildPageWithContext:(id)context{
    return [self openChildPageWithContext:context mode:INDynamicPageShiftedOverParentOpenMode]; 
}
 
//----------------------------------------------------------------------------------------------------------------------------------

- (INDynamicPageView *)openChildPageWithContext:(id)context mode:(INDynamicPageOpenMode)mode { 
    [self closeChildPage];
   
    NSAssert(_childPage == 0,@"mk_44f1f99a_ac1a_43d0_be8f_44835241f9ff");
    NSAssert(_scrollView == 0,@"mk_44f1f99a_ac1a_43d0_be8f_44835241f9ff");
   
    // [UIView setAnimationsEnabled:NO];
    // Страница будет располагаться сбоку от родиительской....
    CGRect scrollViewFrame = [self frameForChildScrollViewAtState:PAGE_STATE_1_SIDE_BY_SIDE context:context level:_level+1];
   
    // создаем скролл (если еще не)
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        
        #ifdef PGDEBUG
            _scrollView.backgroundColor = [UIColor inru_colorFromRGBA:0xFFFF0020];
        #endif 
        // _scrollView.backgroundColor = [UIColor inru_colorFromRGBA:0xFFFF0020];
        _scrollView.delegate = self;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.clipsToBounds = NO;
        [self addSubview:_scrollView];
    }
   
    // Создаем страницу
    CGRect childFrame = INRectFromSize(scrollViewFrame.size);
    _childPage = [[INDynamicPageView alloc] initWithFrame:childFrame controller:_controller context:context level:_level+1];
    // _childPage.backgroundColor = [UIColor inru_colorFromRGBA:0xFF00FFFF];
    _childPage->_parentPage = self;
    [_scrollView addSubview:_childPage];
    
    
    [_childPage notifyPageCreated];
    
    #ifdef PGDEBUG 
        UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(20,20,200,20)];
        lbl.text = [NSString stringWithFormat:@"%d %@", _childPage->_level, _childPage.context];
        [_childPage addSubview:lbl];
    #endif  

    // [UIView setAnimationsEnabled:YES];

    // а мы, если мы не рутовая страница, переедем строго поверх предыдущей
    if (_level) { 
        _state = PAGE_STATE_1_OVER_FULL;   
    }
    _scrollView.frame = scrollViewFrame;

    switch (mode) {
        case INDynamicPageSideBySideWithParentOpenMode:
            _childPage.state = PAGE_STATE_1_SIDE_BY_SIDE; 
            [_controller setPageActive:self];
            break;        

        case INDynamicPageOverParentOpenMode:
            _childPage.state = PAGE_STATE_1_OVER_FULL;
            _childPage.canCompletelyOverlaysParent = YES; 
            [_controller setPageActive:_childPage];
            break;        
    
        default: 
            // страница при верстке будете наезжать поверх
            _childPage.state = PAGE_STATE_1_OVER_BOOKMARK;
            [_controller setPageActive:_childPage];
            break;
    }
     
    // выравниваем ее  
    // [self layoutContent];
   
    // переходим в сжатую форму или просто об
    if (![_controller switchExpandedModeTo:NO onlyCategoryPanel:NO]) {
        [_controller layoutViews:YES animated:YES];
    }
    
    [_childPage notifyNewPageLayedOut];
    return _childPage;
}



//----------------------------------------------------------------------------------------------------------------------------------

#ifdef PGDEBUG

- (void)btnPressed:(id)sender { 
    [self openChildPageWithContext:nil];
}

- (void)btnPressed2:(id)sender { 
    [_controller.mainScrollView inru_dumpSubviews];
}

#endif

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)scrollOffsetThreshold { 
    return 100;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate { 
    NSAssert(scrollView == _scrollView, @"mk_0ad8a375_a827_4b17_9aa2_44f2c2227bd5");
   
    // NSLog(@"end draggung %d %@ %d", decelerate, scrollView, _level);
    if (decelerate && _childPage) {
        if (scrollView.contentOffset.x <= 0) { 
            if (-scrollView.contentOffset.x > self.scrollOffsetThreshold) { 
                _childPage.state = PAGE_STATE_1_SIDE_BY_SIDE;
                [_controller layoutViews:YES animated:YES];
                [_controller setPageActive:self];
                // NSLog(@"YES!!!");
            }
        } else {
            if (scrollView.contentOffset.x > self.scrollOffsetThreshold) {
                INDynamicPageView * _grandChild = _childPage.childPage; 
                
                if (_childPage.canCompletelyOverlaysParent && _childPage.state == PAGE_STATE_1_OVER_BOOKMARK) { 
                    _childPage.state = PAGE_STATE_1_OVER_FULL;
                    [_controller layoutViews:YES animated:YES];
                    [_controller setPageActive:_childPage];
                } else
                if (_grandChild) {
                    _grandChild.state = PAGE_STATE_1_OVER_BOOKMARK;
                    _childPage.state = PAGE_STATE_1_OVER_FULL;
                    [_controller layoutViews:YES animated:YES];
                    [_controller setPageActive:_grandChild];
                }
            }
        }
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INDynamicPagesCategoryItem()

@property(nonatomic,retain) UIView * contentView;
@property(nonatomic,assign) INDynamicPagesViewController * mainController; 

@end

//==================================================================================================================================

@implementation INDynamicPagesCategoryItem 

@synthesize contentView  = _contentView;
@synthesize mainController = _mainController;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {

    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_contentView release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reloadContentView { 
    [_mainController reloadCategoryItem:self]; 
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INDynamicPagesViewController

@synthesize categoryPanel = _categoryPanel;
@synthesize delegate = _delegate;
@synthesize categoryItems = _categoryItems;
@synthesize categoryTableView = _categoryTable;
@synthesize rootPage = _rootPage;

// private properties
@synthesize currentOrientationIsPortrait = _currentOrientationIsPortrait;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSAssert(INIPadInterface(), @"INDynamicPagesViewController is designed for iPad only");
        _categoryPanelExpanded = YES;
        _currentOrientationIsPortrait = 2; // neither YES nor NO
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_rootPage release];
    [_selectedCategoryItemPath release];
    for (int i = 0; i < INDynamicPageShadowImageLast; i++) { 
        [_shadowImages[i] release];
    }
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES; // all orientations for IPad
}


//----------------------------------------------------------------------------------------------------------------------------------

enum {  
    PAGE0_FRAME_NORMAL,
    PAGE0_FRAME_COME_FROM,
    PAGE0_FRAME_GO_TO,
};

- (CGRect)frameForPageForPosition:(NSInteger)remotePosition forView:(UIView *)view transition:(INDynamicPageTransition)transition { 
    CGRect r = INRectFromSize(self.frameForMainScrollView.size);
    switch (remotePosition) { 
        case PAGE0_FRAME_NORMAL:
            break;
            
        case PAGE0_FRAME_COME_FROM:
            // r.origin.x += r.size.width;
            switch (transition) {
                case INDynamicPageTransitionFromUpToDown:
                    r.origin.y -= r.size.height;
                    break;
                    
                case INDynamicPageTransitionFromDownToUp:
                    r.origin.y += r.size.height;
                    break;
                    
                default:
                    NSAssert(0,@"mk_bb557a7c_313b_4474_b591_64a916d7711f");
            }
            break;
            
        case PAGE0_FRAME_GO_TO:
            switch (transition) {
                case INDynamicPageTransitionFromUpToDown:
                    r.origin.y += r.size.height;
                    break;
                    
                case INDynamicPageTransitionFromDownToUp:
                    r.origin.y -= r.size.height;
                    break;
                    
                default:
                    NSAssert(0,@"mk_bb557a7c_313b_4474_b591_64a916d7711f");
            }
            break;
            
        default:
            NSAssert(0,@"mk_9aa17486_9b26_48df_ae85_7f8d0303d884");
    }
    return [_mainScrollView convertRect:r toView:view];
}

//----------------------------------------------------------------------------------------------------------------------------------
// возможно, придется задавать размеры явно
- (CGRect)workArea { 
    CGRect r = self.view.bounds;
    return r;
}

//----------------------------------------------------------------------------------------------------------------------------------

enum {
    METRIC_CATPANEL_WIDTH,
    METRIC_MAINSCROLL_WIDTH
};

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)metricForType:(NSInteger)metric expandedState:(BOOL)expandedState {
    switch (metric) { 
        case METRIC_CATPANEL_WIDTH:
        case METRIC_MAINSCROLL_WIDTH:
            {
                CGFloat width = 0;
                if ([_delegate respondsToSelector:@selector(indynamicPages:widthForCategoryPanelExpanded:portraitOrientation:)]) { 
                    width = [_delegate indynamicPages:self widthForCategoryPanelExpanded:expandedState portraitOrientation:_currentOrientationIsPortrait];
                } else {
                    if (_currentOrientationIsPortrait) {  
                        if (expandedState ) { 
                            width = 250;
                        } else { 
                            width = 100;
                        }
                    } else { 
                        if (expandedState ) { 
                            width = 320;
                        } else { 
                            width = 100;
                        }
                    }
                }
                if (metric == METRIC_CATPANEL_WIDTH) { 
                    return width;
                }  else { 
                    return self.workArea.size.width - width;
                }
            }
            break;
        default:
            NSAssert(0,@"mk_573dee27_0be2_494e_a890_2a5b1250cbb9");
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForCategoryPanel {  
    CGRect rCategoryPanel = self.workArea;
    rCategoryPanel.size.width = [self metricForType:METRIC_CATPANEL_WIDTH expandedState:_categoryPanelExpanded];
    return rCategoryPanel;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameForMainScrollView { 
    CGRect r = self.frameForCategoryPanel;
    r.origin.x += r.size.width;
    r.size.width = [self metricForType:METRIC_MAINSCROLL_WIDTH expandedState:_categoryPanelExpanded];
    return r;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)layoutCategoryPanelAnimated:(BOOL)animated {

    CGRect r = self.frameForCategoryPanel;
    
    // animation start
    if (animated) {
        [self startAnimation:@"categoryPanelLayout" context:nil];   
    }

    // panel 
    _categoryPanel.frame = r;

    // category table 
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([_delegate respondsToSelector:@selector(indynamicPages:categoryTableInsetsForPortraitOrientation:expanded:)]) { 
        insets = [_delegate indynamicPages:self categoryTableInsetsForPortraitOrientation:_currentOrientationIsPortrait expanded:_categoryPanelExpanded];
    }
    _categoryTable.frame = UIEdgeInsetsInsetRect(INRectFromSize(r.size), insets);

    // extra layout 
    if ([_delegate respondsToSelector:@selector(indynamicPages:layoutCategoryPanelExpanded:portraitOrientation:animated:)]) { 
        [_delegate indynamicPages:self layoutCategoryPanelExpanded:_categoryPanelExpanded portraitOrientation:_currentOrientationIsPortrait animated:animated];
    }

    // animation end
    if (animated) {  
        [UIView commitAnimations];  
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)layoutMainScrollPanelAnimated:(BOOL)animated {

    CGRect r = self.frameForMainScrollView;
    
    // animation start
    if (animated) {
        [self startAnimation:@"mainScrollLayout" context:nil];   
    }

    // scroll view 
    _mainScrollView.frame = r;
    _mainScrollView.contentSize = r.size;

    // dragging view
    CGRect dv = _draggingView.bounds;
    dv.origin.x = r.origin.x;
    dv.origin.y = round((r.size.height - dv.size.height) / 2); 
    _draggingView.frame = dv;

    // animation end
    if (animated) {  
        [UIView commitAnimations];  
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setPageActive:(INDynamicPageView *)page { 
    // disable previous scrolls
    INDynamicPageView * p = page;
    while ((p = p.parentPage)) { 
        p.isActive = NO;
    }

    p = page;
    while ((p = p.childPage)) { 
        p.isActive = NO;
    }
    
    page.isActive = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------
 
- (void)startAnimation:(NSString *)animationName context:(void *)context { 
   [UIView beginAnimations:animationName context:context];
   [UIView setAnimationDuration:ANIM_DURATION];
   [UIView setAnimationDelegate:self];
   [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
   [UIView setAnimationWillStartSelector:@selector(animationDidStart:context:)];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)layoutViews:(BOOL)forceUpdate animated:(BOOL)animated { 

    // check for orientation - will relayout only for rotated interface
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    if (_currentOrientationIsPortrait == isPortrait && !forceUpdate) {
        return;
    }
    
    if (animated) { 
        [self startAnimation:@"layoutViews" context:nil];   
    }

    // start relayout
    // NSLog(@"---- doLayoutViews %d", animated);   
    _currentOrientationIsPortrait = isPortrait;

    // category panel
    [self layoutCategoryPanelAnimated:animated];
        
    // scroll view
    [self layoutMainScrollPanelAnimated:animated];
    
    // pages 
    if (_rootPage) { 
        if (_rootPage.comingState != PAGE_COMING_STATE_OUTGOING) { 
            // [_rootPage.layer removeAllAnimations];
            _rootPage.frame = [self frameForPageForPosition:PAGE0_FRAME_NORMAL forView:_mainScrollView transition:-1];  
        }
        [_rootPage layoutContent];
    }
    
    if (animated) { 
        [UIView commitAnimations];
    }

}

//----------------------------------------------------------------------------------------------------------------------------------


- (void)loadView {
    // root view 
    CGRect r = INRectInset([[UIScreen mainScreen] bounds], 0, [UIApplication sharedApplication].statusBarFrame.size.height, 0, 0);
    _INDynamicPagesRootView * rootView = [[_INDynamicPagesRootView alloc] initWithFrame:r];
    rootView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    rootView.controller = self;
    
    // categoryPanel
    _categoryPanel = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    _categoryPanel.backgroundColor = [UIColor lightGrayColor];
    _categoryPanel.autoresizingMask = 0;
    [rootView addSubview:_categoryPanel];
    [_categoryPanel release];
    
    // category table
    _categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    _categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _categoryTable.autoresizingMask = 0;
    _categoryTable.delegate = self;
    _categoryTable.dataSource = self;
    _categoryTable.backgroundColor = [UIColor darkGrayColor];
    [_categoryPanel addSubview:_categoryTable];
    [_categoryTable release]; 

    // dragging view
    _draggingView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.scrollOffsetThreshold, 100)];
    _draggingView.backgroundColor = [UIColor clearColor];
    _draggingView.autoresizingMask = 0;
    [rootView addSubview:_draggingView];
    [_draggingView release];

    _draggingFrame1 = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 50, 80)];
    _draggingFrame1.layer.cornerRadius = 7; 
    _draggingFrame1.layer.borderWidth = 2; 
    _draggingFrame1.layer.borderColor = [UIColor inru_colorFromRGBA:0x5F5F5F80].CGColor;
    _draggingFrame1.backgroundColor = [UIColor inru_colorFromRGBA:0x00000040];
    [_draggingView addSubview:_draggingFrame1];
    [_draggingFrame1 release];

    _draggingFrame2 = [[UIView alloc] initWithFrame:CGRectOffset(_draggingFrame1.frame, 10, 10)];
    _draggingFrame2.layer.cornerRadius = 7; 
    _draggingFrame2.layer.borderWidth = 2; 
    _draggingFrame2.layer.borderColor = _draggingFrame1.layer.borderColor; // [UIColor lightGrayColor].CGColor; 
    _draggingFrame2.backgroundColor =  _draggingFrame1.backgroundColor; // [UIColor inru_colorFromRGBA:0x00000040];
    [_draggingView addSubview:_draggingFrame2];
    [_draggingFrame2 release];
    
    // main scroll view 
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    // _mainScrollView.backgroundColor = [UIColor inru_colorFromRGBA:0x00FF0020];
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.clipsToBounds = NO;
    [rootView addSubview:_mainScrollView];
    [_mainScrollView release];
    
    [self setDraggingState:DRAGGING_STATE_NONE forceUpdate:YES  animated:NO];
    
    self.view = rootView;
    [rootView release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [super viewDidUnload];
    _categoryPanel = nil;
    _mainScrollView = nil;
    _categoryTable = nil;
    _draggingView = nil;
    [_rootPage release];
    _rootPage = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutViews:NO animated:NO];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)reloadCategoryItem:(INDynamicPagesCategoryItem *)item { 
    NSMutableArray * array = [NSMutableArray array];
    NSMutableArray * selectedItems = [NSMutableArray array];
    int section1 = 0;
    for (id section in _categoryItems) { 
        int row = 0;
        for (INDynamicPagesCategoryItem * item1 in section) { 
            if (item == item1) {
                NSIndexPath * path = [NSIndexPath indexPathForRow:row inSection:section1];
                [array addObject:path];
                if ([_selectedCategoryItemPath isEqual:path]) { 
                    [selectedItems addObject:path];
                }
            }
            row++;
        }
        section1++;
    }
    if (array.count) { 
        [_categoryTable reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    }
    for (NSIndexPath * path in selectedItems) {
        [_categoryTable selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];   
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDynamicPagesCategoryItem *)itemFromPath:(NSIndexPath *)indexPath  {
    if (indexPath) { 
        if (indexPath.section < _categoryItems.count) {
            INDynamicPagesCategoryItem * section = [_categoryItems objectAtIndex:indexPath.section];
            if (indexPath.row < section.items.count) {
                return [section itemAtIndex:indexPath.row];
            }
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedCategoryItemPath:(NSIndexPath *)path animated:(BOOL)animated { 
    if (path != _selectedCategoryItemPath) {
        if ([self itemFromPath:_selectedCategoryItemPath]) { 
            [_categoryTable deselectRowAtIndexPath:_selectedCategoryItemPath animated:animated];
        }
        [_selectedCategoryItemPath release];
        _selectedCategoryItemPath = [path retain];
        if ([self itemFromPath:path]) { 
            [_categoryTable selectRowAtIndexPath:path animated:animated scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)selectCategoryItemWithPath:(NSIndexPath *)path emulateUserTouch:(BOOL)emulateUserTouch { 
    INDynamicPagesCategoryItem * item = [self itemFromPath:path];
    if (item) { 
        [self setSelectedCategoryItemPath:path animated:NO]; 
        if (emulateUserTouch) {
            // [_categoryTable selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone]; 
            [self tableView:_categoryTable didSelectRowAtIndexPath:path];
        //} else { 
        //    [self setSelectedCategoryItemPath:path animated:NO]; 
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setCategoryItems:(NSArray *)items {
    [self setCategoryItems:items tryToPreserveSelection:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setCategoryItems:(NSArray *)items tryToPreserveSelection:(BOOL)tryToPreserveSelection { 
    if (items != _categoryItems) { 
        
        // детачим старые контролы
        for (id section in _categoryItems) { 
            for (INDynamicPagesCategoryItem * item in section) { 
                [item.contentView removeFromSuperview];
                item.contentView = nil;
                item.mainController = nil;
            }
        }
                
        // аттачим новые контролы 
        for (id section in items) { 
            for (INDynamicPagesCategoryItem * item in section) { 
                item.mainController = self;
            }
        }
        
        // try to calculate new position of the old selected item 
        NSIndexPath * _newIndexPath = nil;
        if (tryToPreserveSelection) {  
            INDynamicPagesCategoryItem * selectedItem = [self itemFromPath:_selectedCategoryItemPath];
            if (selectedItem) {
                int i = 0;
                for (id section in items) { 
                    int j = 0;
                    for (INDynamicPagesCategoryItem * item in section) { 
                        if ([item isEqual:selectedItem]) { 
                            _newIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                            goto exit_enumeration;
                        }
                        j++;
                    }
                    i++;
                }
            }
        }
    
exit_enumeration:
        [_categoryItems autorelease];
        _categoryItems = [items retain];
        [_categoryTable reloadData];
        
        [self setSelectedCategoryItemPath:_newIndexPath animated:NO];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark - Category table delegates implemenation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_categoryItems objectAtIndex:section] items] count];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _categoryItems.count; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    UIView * cv = cell.contentView;
    INDynamicPagesCategoryItem * item = [self itemFromPath:indexPath];
    UIView * itemV = [_delegate indynamicPages:self viewForCategoryItem:item expanded:_categoryPanelExpanded reusingView:item.contentView];
    item.contentView = itemV;
    UIView * cellV = nil;
    if (cv.subviews.count) { 
        cellV = [cv.subviews objectAtIndex:0];
    }
    if (cellV != itemV) { 
        [cellV removeFromSuperview];
        [cv addSubview:itemV];
    }
    itemV.autoresizingMask = 18;
    itemV.frame = cv.bounds;
    
    if ([_delegate respondsToSelector:@selector(indynamicPages:backgroundViewForCategoryItem:expanded:selected:)]) { 
        cell.backgroundView = [_delegate indynamicPages:self backgroundViewForCategoryItem:item expanded:_categoryPanelExpanded selected:NO];
        cell.selectedBackgroundView = [_delegate indynamicPages:self backgroundViewForCategoryItem:item expanded:_categoryPanelExpanded selected:YES];
    }
      
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   INDynamicPagesCategoryItem * item = [[_categoryItems objectAtIndex:indexPath.section] itemAtIndex:indexPath.row];
    if ([_delegate respondsToSelector:@selector(indynamicPages:heightForCategoryItem:expanded:)]) {
        return  [_delegate indynamicPages:self heightForCategoryItem:item expanded:_categoryPanelExpanded];
    }
    return _categoryPanelExpanded ? 44 : 100; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    INDynamicPagesCategoryItem * item = [self itemFromPath:indexPath];

    // notify delegate, exit if if does not want to make item selected
    if ([_delegate respondsToSelector:@selector(indynamicPages:willSelectCategoryItem:selectedItem:)]) { 
        if (![_delegate indynamicPages:self willSelectCategoryItem:item selectedItem:[self itemFromPath:_selectedCategoryItemPath]]) {
            if (![indexPath isEqual:_selectedCategoryItemPath]) {     
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                if (_selectedCategoryItemPath) { 
                    [tableView selectRowAtIndexPath:_selectedCategoryItemPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }
            return;
        }
    }
    
    // deleselect previous item, select new one
    [self setSelectedCategoryItemPath:indexPath animated:YES];
    [_delegate indynamicPages:self didSelectCategoryItem:item];
}


#pragma mark -
#pragma mark - Page manipulation 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(id)pageView {
    // NSLog(@"%@: STOPPED %@", animationID, finished.boolValue ? @"OK" : @"BROKEN");
    
    // open page 
    if ([animationID isEqualToString:@"openPage"]) {
        switch ([pageView comingState]) { 
            case PAGE_COMING_STATE_COMING:
                // NSAssert(pageView == _rootPage,@"mk_8a93ab0c_b2d3_4859_95a0_74a13e40bcd8");
                //pageView.frame = [self frameForPageAtRemotePosition:NO forView:_mainScrollView];
                //[_mainScrollView addSubview:pageView];
                break;
                
            case PAGE_COMING_STATE_IDLE:
            case PAGE_COMING_STATE_OUTGOING:
                [pageView removeFromSuperview];
                break;
            
            default:
                NSAssert(0,@"mk_ba92358a_b34f_40b7_be53_967259c5e1ce");
        }
        [pageView setComingState:PAGE_COMING_STATE_IDLE];
        [pageView release];
        return;    
    } else 
    if ([animationID isEqualToString:@"closePage"]) {
        [pageView removeFromSuperview];
        [pageView release];
        return;  
    } else 
    if ([animationID isEqualToString:@"closeChildPageWithScroll"]) {
        [pageView removeFromSuperview]; // pageView is actuall scroll view here
        [pageView release];
       return;  
    }
}

- (void)animationDidStart:(NSString *)animationID context:(INDynamicPageView *)pageView {
    // NSLog(@"%@: STARTED", animationID);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)closePageWithTransition:(INDynamicPageTransition)transition {
    if (_rootPage) {
        //NSLog(@"close 1");
        // [_rootPage setState:PAGE_COMING_STATE_OUTGOING];        
        //[self.view.layer removeAnimationForKey:@"openPage"];
        //NSLog(@"close 2");
        [self startAnimation:@"closePage" context:[_rootPage retain]];   
        {
            _rootPage.frame = [self frameForPageForPosition:PAGE0_FRAME_GO_TO forView:_mainScrollView transition:transition]; 
        }
        [UIView commitAnimations];    
        [_rootPage autorelease];
        _rootPage = nil;
        //[self.view addSubview:pageView];
        //CGRect endRect = [self frameForPageAtRemotePosition:YES forView:self.view]; 
                   
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)openPageWithContext:(id)context transition:(INDynamicPageTransition)transition { 
   //if (_rootPage.childPage) { 
   //   [self closePage];
   //   return;
   //}
   [self closePageWithTransition:transition];
    
   NSAssert(_rootPage == nil,@"mk_41c46172_4765_46a0_9ecd_dca101276fff");
    
   CGRect startRect = [self frameForPageForPosition:PAGE0_FRAME_COME_FROM forView:_mainScrollView transition:transition]; 
   // CGRect endRect = [self frameForPageForPosition:PAGE0_FRAME_NORMAL forView:_mainScrollView]; 
   _rootPage = [[INDynamicPageView alloc] initWithFrame:startRect controller:self context:context level:0];
   [_rootPage setComingState:PAGE_COMING_STATE_COMING];
   [_rootPage layoutContent];
   [_rootPage notifyPageCreated];
   [_mainScrollView addSubview:_rootPage];
   [self setPageActive:_rootPage];
   [self switchExpandedModeTo:YES onlyCategoryPanel:YES];
   [self setDraggingState:DRAGGING_STATE_NONE forceUpdate:YES animated:NO];
   
   [self startAnimation:@"openPage" context:[_rootPage retain]];   
   {
       _rootPage.frame = [self frameForPageForPosition:PAGE0_FRAME_NORMAL forView:_mainScrollView transition:transition]; // фрейм надо вычислять тутЁ так как он с учетом схлопывания
   }
   [UIView commitAnimations];
   [_rootPage notifyNewPageLayedOut];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reloadCategoryTable { 
    [_categoryTable reloadData];
    if (_selectedCategoryItemPath) { 
        NSIndexPath * p = [_selectedCategoryItemPath retain];
        [self setSelectedCategoryItemPath:nil animated:NO];
        [self setSelectedCategoryItemPath:p animated:NO];
        [p release];
    }
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)switchExpandedModeTo:(BOOL)expanded onlyCategoryPanel:(BOOL)onlyCategoryPanel { 
    if (_categoryPanelExpanded == expanded) { 
        return NO;
    }
    _categoryPanelExpanded = expanded;
    
    if (onlyCategoryPanel) { 
        [self layoutCategoryPanelAnimated:YES];
        [self layoutMainScrollPanelAnimated:YES];
    } else { 
        [self layoutViews:YES animated:YES];
    }

    [self reloadCategoryTable];
    return YES;
}

#pragma mark -
#pragma mark - Page 0 dragging  manipulation 

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)scrollOffsetThreshold { 
    return 100;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setDraggingState:(NSInteger)newState forceUpdate:(BOOL)forceUpdate animated:(BOOL)animated {
    if (newState != _rootPage.draggingState || forceUpdate) { 
        _rootPage.draggingState = newState;
        if (animated) { 
            [self startAnimation:@"dragginIndicator" context:nil];
        }

        switch (newState) { 
            case  DRAGGING_STATE_OUT:
                _draggingView.alpha = 1.0;
                _draggingFrame2.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(50,0), (10.0 * M_PI/ 180.0));     
                _draggingFrame2.alpha = 0.8;
                break;
                
            case  DRAGGING_STATE_IN:
                // _draggingView.backgroundColor = [UIColor yellowColor]; 
                _draggingFrame2.transform = CGAffineTransformIdentity;  
                _draggingView.alpha = 1.0;
                _draggingFrame2.alpha = 1.0;
                break;
                
            case DRAGGING_STATE_OUT_COLLAPSE:
                _draggingView.alpha = 0;
                break;

            case DRAGGING_STATE_NONE:
                _draggingView.alpha = 0;
                break;
                
            default:
                NSAssert(0,@"mk_923eb2df_7b3b_4079_ab6d_6795562a52cd");
        }
        // NSLog(@"draggin state %d", newState);
        
        if (animated) {
            [UIView commitAnimations];
        }
    }     
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollView) { 
        if (scrollView.dragging && _rootPage) { 
            if (_rootPage.childPage) {
                if (scrollView.contentOffset.x <= 0) { 
                    if (-scrollView.contentOffset.x > self.scrollOffsetThreshold) { 
                        [self setDraggingState:DRAGGING_STATE_OUT forceUpdate:NO animated:YES];
                    } else { 
                        [self setDraggingState:DRAGGING_STATE_IN forceUpdate:NO animated:YES];
                    }
                } else { 
                    if (scrollView.contentOffset.x > _rootPage.scrollOffsetThreshold) { 
                        [self setDraggingState:DRAGGING_STATE_OUT_COLLAPSE forceUpdate:NO animated:YES];
                    } else { 
                        [self setDraggingState:DRAGGING_STATE_IN forceUpdate:NO animated:YES];
                    }
                }
            }
        } else { 
            [self setDraggingState:DRAGGING_STATE_NONE forceUpdate:NO animated:YES];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate { 
    if (scrollView == _mainScrollView) { 
        if (decelerate && _rootPage.childPage) {
            if (_rootPage.draggingState == DRAGGING_STATE_OUT) { 
                [_rootPage closeChildPage];
                [self switchExpandedModeTo:YES onlyCategoryPanel:NO]; 
                [self setPageActive:_rootPage];
            } else
            if (_rootPage.draggingState == DRAGGING_STATE_OUT_COLLAPSE) {
                _rootPage.childPage.state = PAGE_STATE_1_OVER_BOOKMARK;
                [self layoutViews:YES animated:YES];
                [self setPageActive:_rootPage.childPage];
            }
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDynamicPageView *)parentPageForView:(UIView *)view {
     id p = view.superview; 
     while (p) { 
        if ([p isKindOfClass:INDynamicPageView.class]) { 
            if ([p controller] == self) { 
                return p;
            } else { 
                return nil;
            }
        }
        p = [p superview];
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDynamicPageView *)topVisiblePage {
    INDynamicPageView * p = self.rootPage;
    while (p.childPage) {
         p = p.childPage;
    }
    return p;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIScrollView *)mainScrollView { 
    return _mainScrollView;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setShadowImage:(UIImage *)image withID:(INDynamicPageShadowImageID)imageID { 
    [_shadowImages[imageID] release];
    _shadowImages[imageID] = [image retain];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)shadowImageWithID:(INDynamicPageShadowImageID)imageID { 
    return _shadowImages[imageID];
}

@end
