
#import "BHLearnTabViewController.h"
#import "BHCategoryItemPicker.h"
#import "BHWebViewController.h"
#import "BH.h"
#import "BHAppDelegate.h"

@implementation BHLearnTabViewController

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

/* 
- (void)updateBannerStyle { 
    if (!self.isViewLoaded) { 
        return;   
    }
    CGRect brect  = _bottomBanner.frame; 
    CGRect learnRect = _learnLabel.frame; 
    switch (_bannerStyle) { 
        case BHBottomBannerFirstStart:
            //_bottomBanner.backgroundColor = [UIColor redColor];
            // _bottomBanner.image = [UIImage imageNamed:@"graybox_first_time.png"];
            brect.origin.y = 180;
            learnRect.origin.y = 198;
            learnRect.origin.x = _bannerLabel.frame.origin.x;
            _bannerLabel.hidden = YES; 
            [self.view addSubview:_learnLabel];
            break;
            
        case BHBottomBannerRegular:
            //_bottomBanner.backgroundColor = [UIColor yellowColor];
            // _bottomBanner.image = [UIImage imageNamed:@"graybox.png"];
            brect.origin.y = 238;
            _bannerLabel.hidden = NO; 
            break;
            
        default:
            NSAssert(0,@"mk_a25747f5_7c36_48fe_bb67_c935bf4b01a0");
    }
    _learnLabel.hidden = ! _bannerLabel.hidden; 
    _learnLabel.frame = learnRect;
    _bottomBanner.frame = brect;
    [_tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBottomBanner:(NSInteger)bannerStyle { 
    if (_bannerStyle != bannerStyle) {
        _bannerStyle = bannerStyle;
        [self updateBannerStyle];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_becomeActiveTab:(BOOL)firstTime { 
    [self setBottomBanner:firstTime ? BHBottomBannerFirstStart : BHBottomBannerRegular]; 
    self.bh_tabFirstTimeOpened = NO;
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    
   // self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"product-bg-static.png"]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    _tableView.backgroundColor = [UIColor clearColor];
    [self bh_setStyleWithCoolBackground:NO topShadow:YES havingOwnNavBar:NO]; 
    // [self updateBannerStyle];
} 

//----------------------------------------------------------------------------------------------------------------------------------

//- (BOOL)bh_style_shouldHideHeader { 
//    return YES;
// }

//----------------------------------------------------------------------------------------------------------------------------------


enum {
    CELL_WHAT,
    CELL_COPING,
    CELL_TRIGGERS,
    CELL_LAST
};

enum {
    SECTION_ARTICLES,
    SECTION_USING,
    SECTION_LAST
};

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return SECTION_LAST;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) { 
        case SECTION_USING:
            return 1; // _bannerStyle == BHBottomBannerFirstStart ? 1 : 0;
            
        case SECTION_ARTICLES:
            return CELL_LAST;
            
        default:
            NSAssert(0,@"mk_a25747f5_7c36_48fe_bb67_c935bf4b01a1");
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL justLoaded;
    BHFramedCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHFramedDisclosureCell" 
                                                reuseIdentifier:@"dcell" justLoaded:&justLoaded];
    cell.backgroundView = nil; // no textures here
    if (indexPath.section == SECTION_ARTICLES) { 
        switch (indexPath.row) { 
            case CELL_WHAT:
                cell.frameControl.frameStyle = BHControlFrameTopRounded;
                cell.captionLabel.text = @"What is a Migraine?";  
                break;
                
            case CELL_COPING:
                cell.frameControl.frameStyle = BHControlFrameSquare;            
                cell.captionLabel.text = @"Coping with Migraines";  
                break;
                
            case CELL_TRIGGERS:
                cell.frameControl.frameStyle = BHControlFrameBottomRounded;
                cell.captionLabel.text = @"Migraine Triggers";  
                break;
                
            default:
                NSAssert(0,@"mk_1b9270c7_a42a_4655_814b_ce455160c7b2");
        }
        [cell setRow:indexPath.row ofTotal:CELL_LAST];
        
    } else { 
        cell.captionLabel.text = @"Using this Application";  
        cell.frameControl.frameStyle = BHControlFrameRounded;
    }
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) { 
        case SECTION_USING:
        case SECTION_ARTICLES:
            return COMMON_CELL_HEIGHT;
            
        default:
            NSAssert(0,@"mk_a25747f5_7c36_48fe_bb67_c935bf4b01a2");
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section { 
    if (section == SECTION_USING) { 
        return 21;
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section { 
    if (section == SECTION_USING) { 
        UIView * v = [[UIView alloc] initWithFrame:CGRectZero];
        v.backgroundColor = [UIColor clearColor];
        return [v autorelease];
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * articleName = nil;
    if (indexPath.section == SECTION_ARTICLES) { 
        switch (indexPath.row) { 
            case CELL_WHAT:
                articleName = @"what-is-migraine";  
                break;
                
            case CELL_COPING:
                articleName = @"coping-with-migraine";  
                break;
                
            case CELL_TRIGGERS:
                articleName = @"migraine-triggers";  
                break;
                
            default:
                NSAssert(0,@"mk_1b9270c7_a42a_4655_814b_ce455160c7b3");
        }
        
    } else { 
        // g_AppDelegate.rootTabBarController.selectedIndex = 1;
        articleName = @"using-this-application";    
    }
    BHArticleWebViewController * ctrl = [BHArticleWebViewController controllerWithDocument:articleName];
    [self.navigationController pushViewController:ctrl animated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    /*  
    [_bottomBanner release];
    _bottomBanner = nil;
    [_bannerLabel release];
    _bannerLabel = nil;
    [_getStartedCell release];
    _getStartedCell = nil;
    [_learnLabel release];
    _learnLabel = nil;
    */
    [_tableView release];
    _tableView = nil;
    [super viewDidUnload];
}

@end
