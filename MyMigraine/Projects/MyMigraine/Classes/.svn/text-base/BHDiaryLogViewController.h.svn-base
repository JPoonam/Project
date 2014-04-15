
#import "BHUIComponents.h"
#import "INPopupView.h"
#import "BHHelpOverlayViewController.h"
#import "BHShareViewController.h"
#import "BHDiaryLogFilterViewController.h"

@interface BHDiaryLogViewController : UIViewController<BHShareViewControllerDelegate,
                                                       BHDiaryLogFilterViewControllerDelegate,
                                                       INOverlayViewControllerDelegate> { 

    IBOutlet UITableViewCell *_noResultsCell;
    IBOutlet UIBarButtonItem * _filterButton;
    IBOutlet BHTableView * _tableView;
    IBOutlet INPopupViewActivity *_progressIndicator;
    NSFetchedResultsController * _fetchedResults1;
    BOOL _validated;
    BOOL _noRecordsMode, _noDataMode;
    NSInteger _myYear;
    IBOutlet UILabel *_noResultLabel;
    IBOutlet BHBarButtonItem_Action *_shareButton;
    
    BHObject * _filteredData;
    BHHelpOverlayViewController * _helpOverlay;
}

- (IBAction)buttonPressed:(id)sender;

@end
