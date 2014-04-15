//!
//! @file INReusableNavigationController.m
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

#import "INReusableNavigationController.h"

//==================================================================================================================================
//==================================================================================================================================

/* 
    Reusable controller info. Contains either real controller or 
    controller unique key and class 
*/ 
 
@interface INReusableControllerInfo : NSObject {
@package 
    // the real, existing controller 
    UIViewController * _controller;
    
    // "cached" controller info. nils, then _controller is assigned
    id _controllerKey;
    Class _controllerClass;
}

    @property (retain, nonatomic) UIViewController * controller;
    @property (retain, nonatomic) id controllerKey;
@end

//==================================================================================================================================

@implementation INReusableControllerInfo

@synthesize controller = _controller;
@synthesize controllerKey = _controllerKey;

//----------------------------------------------------------------------------------------------------------------------------------

- (id) initWithController: (UIViewController * ) aController {
    NSAssert(aController, @"15c0305d_cd82_43c6_b68c_70af9dffef89 bad aController");
    self.controller = aController;
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *) description {
    if (_controller) {
        return [NSString stringWithFormat: @"%@", _controller];
    } else {
        return [NSString stringWithFormat: @"cached (%@ %@)", _controllerClass, _controllerKey];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    self.controller = nil;
    self.controllerKey = nil;
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIViewController *) restoredController { 
    // restore controller on demand
    if (!_controller) {
        _controller = [[_controllerClass alloc] initWithControllerKey: _controllerKey];
    }
    return _controller;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) putInCache { 
    if (_controller && [_controller conformsToProtocol: @protocol(INReusableViewController)]) {
        id<INReusableViewController> ctrl = (id<INReusableViewController>)_controller;
        self.controllerKey = [[[ctrl controllerKey] copyWithZone: nil] autorelease];
        _controllerClass = [_controller class];
        NSAssert(_controllerKey, @"77abbc97_1170_4f5c_95b5_d68d5adc3d32 Empty controller key");
        self.controller = nil;
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INReusableNavigationController

@synthesize liveControllersCount = _liveStackSize;

//----------------------------------------------------------------------------------------------------------------------------------

-(NSArray *) internalStack { return _internalStack; }

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        _internalStack = [[NSMutableArray array] retain];
        _liveStackSize = 0;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [_internalStack release]; 
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) rebuildViewControllersAnimated: (BOOL) animated 
                 estimatedLiveStackSize: (NSInteger) estimatedLiveStackSize { 
    NSMutableArray * a = [NSMutableArray array];
    
    // estimatedLiveStackSize allows not to restore extra controllers. For instance, if we returns to root,
    // then we need only root, not the last _liveStackSize items
    int howManyControllersPutInStack;
    if (_liveStackSize < 2) {
        howManyControllersPutInStack = _internalStack.count;
    } else {
        howManyControllersPutInStack = estimatedLiveStackSize;
        if (howManyControllersPutInStack > _internalStack.count) { 
            howManyControllersPutInStack = _internalStack.count;    
        }
    }
    int startFrom = _internalStack.count - howManyControllersPutInStack;
    
    int deleteBefore = 0;
    if (_liveStackSize >= 2) {
        deleteBefore = _internalStack.count - _liveStackSize;
    }

    // insert live controllers in the stack   
    for (int i = startFrom; i < _internalStack.count; i++) {
        [a addObject: [[_internalStack objectAtIndex: i] restoredController]];
    }
    [super setViewControllers: a animated: animated];
    
    // archive extra controllers, if possible
    for (int i = 0; i < deleteBefore; i++) { 
        INReusableControllerInfo * info = [_internalStack objectAtIndex: i];
        [info putInCache];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    // just replace our internal stack
    [_internalStack removeAllObjects];
    for (id controller in viewControllers) {
        INReusableControllerInfo * info = [[INReusableControllerInfo alloc] initWithController: controller];
        [_internalStack addObject: [info autorelease]];    
    }
    [self rebuildViewControllersAnimated: animated estimatedLiveStackSize: 2];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) pushViewController: (UIViewController *)viewController animated:(BOOL)animated {
    INReusableControllerInfo * info = [[INReusableControllerInfo alloc] initWithController: viewController];
    [_internalStack addObject: [info autorelease]];
    [self rebuildViewControllersAnimated: animated estimatedLiveStackSize: 2];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (_internalStack.count) {
        [self rebuildViewControllersAnimated: NO estimatedLiveStackSize: 3];
    }
    UIViewController * ctrl = [super popViewControllerAnimated: animated];
    if (_internalStack.count) {
        [_internalStack removeLastObject];
    }
    return ctrl;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger) indexOfControllerInInternalStack: (UIViewController *) viewController {
    int i;
    for (i = 0; i < _internalStack.count; i++) { 
        INReusableControllerInfo * info = [_internalStack objectAtIndex: i];
        if (info->_controller /* will not restore controller here */ == viewController) { 
            return i;
        }
    }
    return NSNotFound;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSArray *) popToViewController: (UIViewController *)viewController animated:(BOOL)animated {
    int i = [self indexOfControllerInInternalStack: viewController];
    if (i != NSNotFound) { 
        while (_internalStack.count > i+1) {
            [_internalStack removeLastObject];    
        }
        [self rebuildViewControllersAnimated: animated 
                      estimatedLiveStackSize: 2];
    }
    // returns nil. it's ok, if you do not want to restore entire hierarchy from cache  
    return nil; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated { 
    while (_internalStack.count > 1) {
        [_internalStack removeLastObject];  
    }
    [self rebuildViewControllersAnimated: animated 
                  estimatedLiveStackSize: 1];
    // returns nil. it's ok, if you do not want to restore entire hierarchy from cache  
    return nil; 
}
    
@end

