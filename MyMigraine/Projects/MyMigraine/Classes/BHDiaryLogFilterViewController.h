
#import "BHUIComponents.h"
#import "BHDatePicker2.h"

typedef struct {
    BHStartDate startDate;
    NSInteger itemMask;   
} BHFilterOptions;

@class BHDiaryLogFilterViewController;

//==================================================================================================================================
//==================================================================================================================================

@protocol BHDiaryLogFilterViewControllerDelegate 

- (void)diaryLogFilter:(BHDiaryLogFilterViewController *)filter didSelectNewFilterOptions:(BHFilterOptions)options;

@end

//==================================================================================================================================
//==================================================================================================================================


@interface BHDiaryLogFilterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, 
                                                             BHButtonedCellDelegate, BHDatePicker2Delegate> { 
    IBOutlet UITableView * _tableView;
    IBOutlet BHBarButtonItem_Cancel * _cancelButton;
    IBOutlet BHBarButtonItem_Done * _doneButton;
    id<BHDiaryLogFilterViewControllerDelegate> _delegate;
    BHFilterOptions _options;
}

- (IBAction)buttonPressed:(id)sender;
+ (id)filterForDelegate:(id<BHDiaryLogFilterViewControllerDelegate>)delegate options:(BHFilterOptions)options;

@end


