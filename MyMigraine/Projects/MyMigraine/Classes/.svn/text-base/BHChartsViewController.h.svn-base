
#import "BHUIComponents.h"
#import "INPopupView.h"
#import "BHChart_PageView.h"
#import "BHHelpOverlayViewController.h"
#import "BHShareViewController.h"
#import "BHDatePicker2.h"
#import "BHCharts.h"

@interface BHChartPageInfo : NSObject {
    BHChart_PageView * _view;
    BHChartSeries * _series;
    NSString * _nibName;
}

@property(nonatomic,retain) BHChart_PageView * view; 
@property(nonatomic,retain) BHChartSeries * series;
@property(nonatomic,retain) NSString * nibName; 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChartsViewController : UIViewController<UIScrollViewDelegate, BHShareViewControllerDelegate, 
                                                       INOverlayViewControllerDelegate, BHDatePicker2Delegate> { 
    IBOutlet INPopupViewActivity *_progressIndicator;
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIPageControl *_pager;
    
    BHChartPageInfo * _pageInfo[BHChartSeriesLast];

    BHHelpOverlayViewController * _helpOverlay;
    IBOutlet BHBarButtonItem_Filter *_filterButton;
    IBOutlet BHBarButtonItem_Action *_shareButton;
    
    // BOOL _noRecordsMode, _noDataMode;
    BOOL _validated;
}

- (IBAction)pagerChanged:(id)sender;
- (IBAction)buttonPressed:(id)sender;

@end

