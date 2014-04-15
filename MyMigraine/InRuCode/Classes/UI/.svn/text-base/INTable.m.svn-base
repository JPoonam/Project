//!
//! @file INTable.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
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
//+

#import "INTable.h"
#import "INCommonTypes.h"

/* 
#warning mk:todo:переименовать все методы с copy в INTableViewCellDelegate

@implementation INTableViewCell

@synthesize delegate = _delegate;
@synthesize indexPath = _indexPath;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_indexPath release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)copyAbilityEnabled {
    return [_delegate respondsToSelector:@selector(copyAbilityEnabledForCell:)] &&
           [_delegate copyAbilityEnabledForCell:self];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canBecomeFirstResponder {
    return self.copyAbilityEnabled;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.copyAbilityEnabled) { 
        if (action == @selector(copy:)) {
            return YES;
        }
    }
    return NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)copy:(id)sender {
    if (self.copyAbilityEnabled) {
        NSString * data = nil;
        if ([_delegate respondsToSelector:@selector(copyContentForCell:)]) { 
            data = [_delegate copyContentForCell:self];
           //  NSLog(@"------------- %@ ----------------", data);
        }
        if (data.length) { 
            [[UIPasteboard generalPasteboard] inru_setString:data];
        }     
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)showMenu {
    if (self.copyAbilityEnabled) { 
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] update];
        [[UIMenuController sharedMenuController] setTargetRect:CGRectZero inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)menuClosed { 
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self  name: UIMenuControllerWillHideMenuNotification object: nil];
    self.selected = NO;    
    self.selectionStyle = _tempStoredStyle; 
    _touchedMenuShown = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)showMenuInTouch {
    // NSLog(@"otuch");
    _tempStoredStyle = self.selectionStyle; 
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.selected = YES;
    // [self.backgroundView setNeedsDisplay];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(menuClosed) 
                   name: UIMenuControllerWillHideMenuNotification 
                 object: nil];
    _touchedMenuShown = YES;
    [self showMenu];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * t = [touches anyObject];
  	if (CGRectContainsPoint(self.contentView.bounds, [t locationInView:self.contentView])) {
        // !!! workd only since 3.1 (not 3.0) - so it will not work for selectable cells in 3.0 version (non-celectable cells are ok)
  		[self performSelector:@selector(showMenuInTouch) withObject: nil afterDelay:0.8f]; 
                      // inModes:[NSArray arrayWithObjects: NSDefaultRunLoopMode, NSConnectionReplyMode, nil]];
    }
    [super touchesBegan: touches withEvent: event];
}

//----------------------------------------------------------------------------------------------------------------------------------
- (void)cancelTouch { 
  	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showMenuInTouch) object:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  	// NSLog(@"end");
    [self cancelTouch];
    if (!_touchedMenuShown) { 
        [super touchesEnded: touches withEvent: event];
    } else {
        [super touchesCancelled: touches withEvent: event];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  	// NSLog(@"canceled");
    [self cancelTouch];
    [super touchesCancelled: touches withEvent: event];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  	// NSLog(@"moved");
    [self cancelTouch];
    [super touchesMoved: touches withEvent: event];
}

//----------------------------------------------------------------------------------------------------------------------------------

@end

*/

@implementation INPullToRefreshTableHeaderView 

@synthesize arrowImageView = _arrowImageView;
@synthesize activityIndicator = _activityIndicator;
@synthesize titleLabel = _titleLabel;
@synthesize subtitleLabel = _subtitleLabel;
@synthesize delegate = _delegate;
@synthesize dragDownThresholdOffset = _dragDownThresholdOffset;
@synthesize state = _state;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    // self.backgroundColor = [UIColor redColor];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_arrowImageView release];
    [_activityIndicator release];
    [_titleLabel release];
    [_subtitleLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableView *)tableView {
    UITableView * tv = (id)self.superview;
    NSAssert([tv isKindOfClass:UITableView.class], @"mk_6a4cdcc5_fc5c_43b0_9c93_d11a5b0d6574");
    return tv;
}

//- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context { 
    
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setState:(INPullToRefreshState)newState force:(BOOL)force animated:(BOOL)animated updateInsets:(BOOL)updateInsets {
    if (newState == _state && !force) { 
        return;
    }
    
    BOOL showActivity = NO;
    BOOL showArrow = NO;
    UIEdgeInsets tvInsets = self.tableView.contentInset;
    tvInsets.top = 0;
    CGAffineTransform transform = CGAffineTransformIdentity;
    _state = newState;
    switch(_state) { 
        case INPullToRefreshStateAnnounce:
            showArrow = YES;
            break;

        case INPullToRefreshStateReleaseToRefresh:
            showArrow = YES;
            transform = CGAffineTransformMakeRotation(M_PI);
            break;
            
        case INPullToRefreshStateProcessing:
            tvInsets.top = _dragDownThresholdOffset;
            showActivity = YES;
            break;
    }
    if (!showActivity) { 
        _activityIndicator.hidden = YES;
        [_activityIndicator stopAnimating];
    } else { 
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
    }
    
    if (showArrow) { 
        _arrowImageView.hidden = NO;
    } else { 
        _arrowImageView.hidden = YES;
    }
    
    if (animated) { 
        [UIView beginAnimations:@"INPullToRefreshTableHeaderViewChangeState" context:nil];
        // [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        // [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
    }

    _arrowImageView.transform = transform;
    if (updateInsets) { 
        self.tableView.contentInset = tvInsets;
    }
    if (animated) {
        [UIView commitAnimations];
    }
    
    [_delegate inpullToRefreshView:self updateForState:_state];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateStateAnimated:(BOOL)animated { 
    UITableView * tv = self.tableView;

    BOOL loading = [_delegate inpullToRefreshViewCheckForProcessing:self];
    if (loading) { 
        [self setState:INPullToRefreshStateProcessing force:NO animated:animated updateInsets:NO];
    } else { 
        switch (_state) { 
            case INPullToRefreshStateReleaseToRefresh:
                if (tv.contentOffset.y > -_dragDownThresholdOffset && tv.contentOffset.y < 0.0f) {
                    [self setState:INPullToRefreshStateAnnounce force:NO animated:animated updateInsets:YES];
                }
                break;
                
            case INPullToRefreshStateAnnounce:
                if (tv.contentOffset.y < -_dragDownThresholdOffset) {
                    [self setState:INPullToRefreshStateReleaseToRefresh force:NO animated:animated updateInsets:YES];
                }
                break;
                
            case INPullToRefreshStateProcessing:
                [self setState:INPullToRefreshStateAnnounce force:NO animated:animated updateInsets:YES];
                break;
                
            default:
                break;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleDidScrollDelegateMethod { 
    UITableView * tv = self.tableView;
    if (tv.isDragging) {
        [self updateStateAnimated:YES];
	}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleDidEndDraggingDelegateMethod { 
    UITableView * tv = self.tableView;
    
    BOOL loading = [_delegate inpullToRefreshViewCheckForProcessing:self];
	if (tv.contentOffset.y <= - _dragDownThresholdOffset && !loading) {
        if ([_delegate inpullToRefreshViewDidTriggerProcessing:self]) { 
            [self setState:INPullToRefreshStateProcessing force:NO animated:YES updateInsets:YES];
        }    
	}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addToTableView:(UITableView *)tableView { 
    NSParameterAssert(tableView);
    CGRect tR = INRectFromSize(tableView.frame.size);
    CGRect r = self.bounds;
    r.origin.x = 0;
    r.origin.y = -r.size.height;
    r.size.width = tR.size.width;
    self.frame = r;
    [tableView addSubview:self];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _dragDownThresholdOffset = r.size.height;
    tableView.alwaysBounceVertical = YES;
    BOOL loading = [_delegate inpullToRefreshViewCheckForProcessing:self];
    if (loading) { 
        [self setState:INPullToRefreshStateProcessing force:YES animated:NO updateInsets:NO];
    } else { 
        [self setState:INPullToRefreshStateAnnounce force:YES animated:NO updateInsets:NO];
    }
}

@end
