
#import "BHChartsViewController.h"
#import "BHReports.h"
#import "BHAppDelegate.h"
#import "BH.h"
#import "INView.h"

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChartPageInfo

@synthesize view = _view;
@synthesize series = _series;
@synthesize nibName = _nibName;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_view release];
    [_series release];
    [_nibName release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateView { 
    [self.view setSeries:_series startDate:g_BH.sharedStartDate];
}

@end

//==================================================================================================================================
//==================================================================================================================================


@implementation BHChartsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbChanged:) name:BH_RECORD_SAVED_IN_CONTEXT_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDateChanged:) name:BH_SHARED_START_DATE_CHANGED_NOTIFICATION object:nil];
        
        for (int i =0; i < BHChartSeriesLast; i++) {
            _pageInfo[i] = [BHChartPageInfo new];
            switch (i) {
                case BHTriggerExposureChartSeries:
                    _pageInfo[i].nibName = @"BHChart_PiePageView";
                    break;

                case BHPainLevelChartSeries:
                    _pageInfo[i].nibName = @"BHChart_PiePageView2";
                    break;

                default: 
                    _pageInfo[i].nibName = @"BHChart_BarPageView";
                    break;
            }
        }
    }
    return self;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_helpOverlay release];

    for (int i = 0; i < BHChartSeriesLast; i++) { 
        [_pageInfo[i] release];
    }

    [_progressIndicator release];
    [_scrollView release];
    [_pager release];
    [_filterButton release];
    [_shareButton release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_helpOverlay release];
    _helpOverlay = nil;

    [_progressIndicator release];
    _progressIndicator = nil;
    [_scrollView release];
    _scrollView = nil;
    [_pager release];
    _pager = nil;
    
    for (int i = 0; i < BHChartSeriesLast; i++) { 
        _pageInfo[i].view = nil;
    }
    
    [_filterButton release];
    _filterButton = nil;
    [_shareButton release];
    _shareButton = nil;
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadPage:(NSInteger)pageID { 
    if (0 <= pageID && pageID < BHChartSeriesLast) { 
        if (_pageInfo[pageID].view) { 
            return;       
        }
        NSString * nibFile = _pageInfo[pageID].nibName;
        BHChart_PageView * page = (id)[[INNibLoader sharedLoader] loadViewFromNib:nibFile];
        CGRect r = _scrollView.frame;
        r.origin.y = 0;
        r.origin.x = pageID * r.size.width;
        page.frame = r;
        [_scrollView addSubview:page];
        _pageInfo[pageID].view = page;
        [_pageInfo[pageID] updateView];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

// static NSInteger _ChangesCounter = 1;

- (void)loadData2 {
        
    BHChartSeriesCollection * collection = [BHChartSeriesCollection collectionSinceDate:g_BH.sharedStartDate];
    
    BOOL hasData = NO;
    for (int i = 0; i < BHChartSeriesLast; i++) {  
        _pageInfo[i].series = [collection itemAtIndex:i];
        [_pageInfo[i] updateView];
        if (_pageInfo[i].series.dataState != BHChartSeriesHasNoDataState) {
            hasData = YES;
        }
    }
    
    if (!hasData) { 
        // self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    } else {
        // self.navigationItem.rightBarButtonItem = _filterButton;
        self.navigationItem.leftBarButtonItem = _shareButton;
    }
    [_progressIndicator setHidden:YES withAnimation:YES];
    _validated = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dbChanged:(id)ntf {
    _validated = NO;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)startDateChanged:(id)ntf {
    _validated = NO;
    #ifdef DEBUG_LOG
        NSLog(@"Charts: start date has been changed, mark UI as dirty");
    #endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadData {
    if (!_validated) { 
        [_progressIndicator popupWithAnimation:YES andAutoHideOnDelay:0];
        [self performSelector:@selector(loadData2) withObject:nil afterDelay:0.2];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self loadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    [self bh_setStyleWithCoolBackground:NO topShadow:YES havingOwnNavBar:NO]; 

    CGRect r = _scrollView.frame;
    _scrollView.contentSize = CGSizeMake(BHChartSeriesLast * r.size.width, r.size.height);
    _pager.numberOfPages = BHChartSeriesLast;
    [self loadPage:0];
    
    self.navigationItem.rightBarButtonItem = _filterButton;
    self.navigationItem.leftBarButtonItem = _shareButton;
    
    if (_helpOverlay) { 
        [_helpOverlay layOverViewController:self.navigationController delegate:self animated:NO];
    }
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)pagerChanged:(id)sender {
    CGRect r = _scrollView.frame;
    // for (int i =0; i <= _pager.currentPage; i++) {
    //    [self loadPage:i];
    //}
    [_scrollView setContentOffset:CGPointMake(_pager.currentPage * r.size.width, 0) animated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender {
    if (sender == _filterButton) { 
        BHDatePicker2 * picker2 = [BHDatePicker2 controllerForDelegate:self startDate:g_BH.sharedStartDate];
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:picker2];
        navController.delegate = g_AppDelegate;
        [picker2 bh_setNavBarBackground];
        [g_AppDelegate.rootTabBarController presentModalViewController:[navController autorelease] animated:YES];
    }
    if (sender == _shareButton) {
        BHShareOptions options = { 
            .includeAllCharts = YES, 
            .includeHistory = YES,
            .showHistorySwitcher = YES,
            .startDate = g_BH.sharedStartDate,
            .singleChartKind = _pager.currentPage   
        };
        id controller = [BHShareViewController shareDialogForDelegate:self options:options];
        [g_AppDelegate.rootTabBarController presentModalViewController:controller animated:YES];
        // [self.navigationController pushViewController:controller animated:YES];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)datePicker2:(BHDatePicker2 *)picker didSelectDate:(BHStartDate)date { 
    g_BH.sharedStartDate = date;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)shareDialog:(BHShareViewController *)controller didCompleteWithOptions:(BHShareOptions)options { 
    g_BH.sharedStartDate = options.startDate;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView { 
    NSInteger offset = scrollView.contentOffset.x;
    NSInteger pageWidth = scrollView.frame.size.width;
    NSInteger pageLeft =  offset / pageWidth;
    [self loadPage:pageLeft];
    [self loadPage:pageLeft+1];
    _pager.currentPage = (offset + pageWidth / 2) / pageWidth;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_becomeActiveTab:(BOOL)firstTime {
    if (firstTime) { 
        if (!_helpOverlay) { 
            _helpOverlay = [[BHHelpOverlayViewController alloc] initWithNibName:@"BHHelpOverlayViewController_Charts" bundle:nil];
            [_helpOverlay layOverViewController:self.navigationController delegate:self animated:NO];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inoverlayController:(INOverlayViewController *)overlayController dismissedWithCode:(INOverlayDismissCode)code {
    if (code == BHHelpOverlayDoneExitCode) { 
        self.bh_tabFirstTimeOpened = NO;    
    }
    [_helpOverlay release];
    _helpOverlay = nil;
}


@end

