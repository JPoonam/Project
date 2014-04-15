//!
//! @file INTabbedNavigationController.m
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

#import "INTabbedNavigationController.h"
#import "INView.h"

//==================================================================================================================================
//==================================================================================================================================

@implementation INTabbedNavigationController

@synthesize tabViewControllers = _tabViewControllers;
@synthesize tabbedDelegate = _tabbedDelegate;
@synthesize titleLine = _titleLine;
@synthesize titleView = _rootTitleView;

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)getTextureForIndex:(NSInteger)anIndex {
    if ([_tabbedDelegate respondsToSelector:@selector(lineTextureForTabbedNavigation:andIndex:)]){
        return [_tabbedDelegate lineTextureForTabbedNavigation:self andIndex:anIndex];
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tabCountNonZero {
    NSInteger result = _tabViewControllers.count;
    return result > 0 ? result :1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)titleLineHeight { 
    return _titleLine.bounds.size.height;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setTabViewControllers:(NSArray *)aNewControllers {
	if (aNewControllers == _tabViewControllers){
		return;
	}
	[_tabViewControllers autorelease];
	_tabViewControllers = [aNewControllers retain];

	UIViewController *rootViewController = (UIViewController*)[self.viewControllers objectAtIndex:0];
	INTabbedNavigationTitleView * rootTitleView = (INTabbedNavigationTitleView *)(rootViewController.navigationItem.titleView);
	[rootTitleView setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithRootViewController:(UIViewController*)aViewController {
	if (self = ([super initWithRootViewController:aViewController])){
		_rootTitleView = [[INTabbedNavigationTitleView alloc] initWithFrame:
                                CGRectMake(0, 0, aViewController.view.bounds.size.width, 44)];
		_rootTitleView.delegate = self;
        
        //TODO:
        /* 
           mk:should be reviewed to autocalculate a height of status bar (20 px)
               because it works only for status-bar'ed windows for now
        */ 
        int statusBarHeight = 20;
/*        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200	
        if (INIPadInterface()){
            statusBarHeight = 0;
        }
#endif	
*/        
        CGRect r = CGRectMake(0, _rootTitleView.frame.size.height + statusBarHeight, _rootTitleView.frame.size.width, 5);
 		_titleLine = [[INTitleLine alloc] initWithFrame:r];
        // _titleLine.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
		[self.view addSubview:_titleLine];
  		
        self.navigationBar.tintColor = [UIColor blackColor];
		self.delegate = self;
        self.toolbar.barStyle = UIBarStyleBlack;
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	
	return self;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated { 
    UIViewController * controller = [super popViewControllerAnimated:animated];
    if ([_tabbedDelegate respondsToSelector:@selector(tabbedNavigation:popViewController:animated:)]){
        [_tabbedDelegate tabbedNavigation:self 
                        popViewController:controller
                                 animated:animated];
    }
    return controller;
}
//----------------------------------------------------------------------------------------------------------------------------------

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSInteger rootIndex = [_tabViewControllers indexOfObject:[self.viewControllers objectAtIndex:0]];
	BOOL tabController = [self.viewControllers count] == 1; 
    if (! tabController){
		[_titleLine updateSliderWithTexture:[self getTextureForIndex:rootIndex] animated:YES];
	} else {
		NSRange r = [_rootTitleView positionForTab:rootIndex withRecalculation:YES]; 
        [_titleLine updateSliderWithTexture: [self getTextureForIndex:rootIndex]  
                                      startX:r.location 
                                     andEndX:r.location + r.length
                                    animated:YES ]; 
    }
    
    if ([_tabbedDelegate respondsToSelector:@selector(tabbedNavigation:willShowViewController:isTabController:)]){
        [_tabbedDelegate tabbedNavigation:self 
             willShowViewController:viewController
                    isTabController:tabController];
    }
    
    // 
    // Apply a special patch. see here for details.
    // http://davidebenini.it/2009/01/03/viewwillappear-not-being-called-inside-a-uinavigationcontroller/
    // 
    // todo:review again it when Apple will fix that bug
    // 
    if ([viewController respondsToSelector:@selector(inru_viewWillAppear:)]){
        NSInteger v = animated;
        [viewController performSelector:@selector(inru_viewWillAppear:)withObject:(id)v]; 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)selectedTab { 
    return [_rootTitleView selectedTab];
}
    
//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelectedTab:(NSInteger)value { 
    [self selectTab:value]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)selectTab:(NSInteger)aNewTabIndex {
    if (0 <= aNewTabIndex && aNewTabIndex < _tabViewControllers.count){
        UIViewController * vc = [_tabViewControllers objectAtIndex:aNewTabIndex];
        if ([_tabbedDelegate respondsToSelector:
              @selector(tabbedNavigation:willSwitchToTab:withController:)]){ 
            [_tabbedDelegate tabbedNavigation:self 
                              willSwitchToTab:aNewTabIndex
                               withController:vc];
        }
	    [self setViewControllers:[NSArray arrayWithObject:vc] animated:NO];
	    self.topViewController.navigationItem.titleView = _rootTitleView;
        _rootTitleView.selectedTab = aNewTabIndex;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_rootTitleView release];
	[_tabViewControllers release];
    [_titleLine release];
    // self.tabbedDelegate = nil;
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tabCountForTabbedTitle:(INTabbedNavigationTitleView *)tabbedTitle {
    return [self tabCountNonZero];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)tabCaptionForTabbedTitle:(INTabbedNavigationTitleView *)tabbedTitle  
                               andIndex:(NSInteger)tabIndex {
    if (0 <= tabIndex && tabIndex < _tabViewControllers.count){
        UIViewController * vc = [_tabViewControllers objectAtIndex:tabIndex]; 
        return [vc title];
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tabChangedToIndex:(NSInteger)tabIndex 
         forForTabbedTitle:(INTabbedNavigationTitleView *)tabbedTitle {
    [self selectTab:tabIndex];        
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)frameWithoutTitleLineForViewController:(UIViewController *)controller {
    CGRect r = controller.view.bounds;
    r.origin.y += _titleLine.bounds.size.height;
    r.size.height -= _titleLine.bounds.size.height; 
    return r;
}

@end
