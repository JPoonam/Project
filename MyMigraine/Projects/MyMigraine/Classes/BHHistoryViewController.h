
#import "BHUIComponents.h"
#import "INPopupView.h"

@interface BHHistoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> { 

    IBOutlet BHTableView *_tableView;
    IBOutlet BHBarButtonItem_Back *_backButton;
    NSFetchedResultsController * _fetchedResults;
    IBOutlet INPopupViewActivity * _activityIndicator;
    BOOL _loadState;
    BOOL _validated;
}

- (IBAction)buttonPressed:(id)sender;

@end
