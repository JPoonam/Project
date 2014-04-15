
#import "BHGlobals.h"
#import "INSwitch.h"
#import "BHUIComponents.h"
#import <MessageUI/MessageUI.h>
#import "INPopupView.h"
#import "BHDatePicker2.h"
#import "BHCharts.h"

@class BHShareViewController;

typedef struct {
    BOOL includeAllCharts; 
    BOOL includeHistory;
    BOOL showHistorySwitcher;
    BHStartDate startDate; 
    BHChartSeriesKind singleChartKind; 
} BHShareOptions;


//==================================================================================================================================
//==================================================================================================================================

@protocol BHShareViewControllerDelegate 

- (void)shareDialog:(BHShareViewController *)controller didCompleteWithOptions:(BHShareOptions)options; 

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHShareViewController : UIViewController<MFMailComposeViewControllerDelegate, BHDatePicker2Delegate> { 
    id<BHShareViewControllerDelegate> _delegate;
    IBOutlet BHTableView *_tableView;
    IBOutlet BHBarButtonItem_Cancel *_cancelButton;
    IBOutlet BHGreenButton *_printButton;
    IBOutlet BHGreenButton *_emailButton;
    IBOutlet UITableViewCell *_actionCell;
    IBOutlet INSwitch *_includeAllChartsSwitcher;
    IBOutlet INSwitch *_includeHistoryFileSwitcher;
    IBOutlet UITableViewCell *_includeHistoryCell;
    IBOutlet UITableViewCell *_includeChartsCell;
    IBOutlet INPopupViewActivity *_progressIndicator;
    BHShareOptions _options; 
    NSData * _reportPDF;
    NSInteger _action;
    MFMailComposeViewController * _mailController;
}
@property (nonatomic, retain)UIImageView * overlayImage;
@property (nonatomic, retain)UIActivityIndicatorView * spinner;
@property (nonatomic, retain)UILabel * lblLoading;


+ (id)shareDialogForDelegate:(id<BHShareViewControllerDelegate>)delegate options:(BHShareOptions)options;
- (IBAction)buttonPressed:(id)sender;
-(void)removeWaitOverlay;
-(void)createWaitOverlay;
-(void)stopSpinner;
-(void)startSpinner;

@end
