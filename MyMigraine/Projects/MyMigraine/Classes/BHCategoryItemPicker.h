
#import "BHClasses.h"
#import "BHUIComponents.h"

@class BHCategoryItemPicker;

//==================================================================================================================================
//==================================================================================================================================

@protocol BHCategoryItemPickerDelegate<NSObject>

- (void)categoryItemPickerDidChangeList:(BHCategoryItemPicker *)picker withAddedObject:(BHCollectionItem *)object;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHCategoryItemPicker : UIViewController<UITableViewDelegate, UITableViewDataSource, 
                                                   UITextFieldDelegate, BHButtonedCellDelegate,
                                                   NSFetchedResultsControllerDelegate> {
    id<BHCategoryItemPickerDelegate> _delegate;
    IBOutlet BHModalNavigationBar * _navBar;
    IBOutlet UITableView * _tableView;
    IBOutlet UIView * _tableHeader;
    IBOutlet UILabel * _titleLabel;
    IBOutlet UITextField * _textField;
    NSFetchedResultsController * _fetchedResults;
    IBOutlet UIBarButtonItem * _cancelButton;
    IBOutlet UIBarButtonItem * _doneButton;
    NSString * _entityName;
    NSUndoManager * _originalUndoManager;
    NSString * _ownChoice;
    NSInteger _tag;
}

+ (id)pickerForDelegate:(id<BHCategoryItemPickerDelegate>)delegate entityName:(NSString *)entityName title:(NSString *)title tag:(NSInteger)tag;
+ (void)presentPickerForDelegate:(id<BHCategoryItemPickerDelegate>)delegate entityName:(NSString *)entityName title:(NSString *)title  tag:(NSInteger)tag;

- (IBAction)buttonPressed:(id)sender;

@property(nonatomic,readonly) NSString * entityName;
@property(nonatomic,readonly) NSInteger tag;

@end

