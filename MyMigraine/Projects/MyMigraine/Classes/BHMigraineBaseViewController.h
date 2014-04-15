
#import "BHUIComponents.h"
#import "BHCategoryItemPicker.h"
#import "BHClasses.h"
#import "BHNotePicker.h"
#import "BHDatePicker.h"

@class BHMigraineBaseViewController;

//==================================================================================================================================
//==================================================================================================================================

@interface BHMigrainEventTableSectionInfo : INObject2 { 
    BHMigraineBaseViewController * _viewController;
}

@property(nonatomic,assign) BHMigraineBaseViewController * viewController;

- (NSInteger)rowCount;
- (CGFloat)heightForRow:(NSUInteger)rowIndex;
- (UITableViewCell *)cellForRow:(NSUInteger)rowIndex; 
- (void)handleTouchForRow:(NSUInteger)rowIndex;

@end

//==================================================================================================================================

enum { 
    BHMigrainEventTableCell_PainIntense = 1,
    BHMigrainEventTableCell_Food,
    BHMigrainEventTableCell_Pms
};

@interface BHMigrainEventTableSectionInfo_CustomCell : BHMigrainEventTableSectionInfo { 
    NSInteger _ID;
}

+ (id)infoWithID:(NSInteger)ID;

@end

//==================================================================================================================================

@interface BHMigrainEventTableSectionInfo_CollectionItems : BHMigrainEventTableSectionInfo<
                                                                     NSFetchedResultsControllerDelegate, 
                                                                     BHButtonedCellDelegate,
                                                                     BHCategoryItemPickerDelegate> {
    BOOL _hasOwnItems;
    SEL _relationshipSelector;
    SEL _addSelector;
    SEL _removeSelector;
    NSFetchedResultsController * _fetchedResults;
    NSString * _title;
    NSString * _entity;
    NSString * _addTitle;
}

+ (id)infoWithEntity:(NSString *)entity title:(NSString *)title addTitle:(NSString *)addTitle;

@end

//==================================================================================================================================

@interface BHMigrainEventTableSectionInfo_Notes : BHMigrainEventTableSectionInfo<BHNotePickerDelegate> { 

}

+ (id)info;

@end

//==================================================================================================================================

@interface BHMigrainEventTableSectionInfo_Date : BHMigrainEventTableSectionInfo<BHDatePickerDelegate> { 
    
}

+ (id)info;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHPmsCell : UITableViewCell { 
    BHMigrainEvent * _event;
    IBOutlet INButton * _btnPMSYes;    
    IBOutlet INButton * _btnPMSNo;    
    IBOutlet INButton * _btnPMSDontAsk;    
} 

@property(nonatomic,retain) BHMigrainEvent * event; 

- (IBAction)buttonPressed:(id)sender;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHDateCell : UITableViewCell { 
    BHMigrainEvent * _event;
    IBOutlet INButton * _btnHasHeadache;    
    IBOutlet INButton * _btnHasNoHeadache;
    BHMigrainEventTableSectionInfo * info;    
    // IBOutlet UIButton *_dateButton;
} 

@property(nonatomic,retain) BHMigrainEvent * event;
@property(nonatomic,assign) BHMigrainEventTableSectionInfo * info;
 - (IBAction)buttonPressed:(id)sender;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHPainIntenseCell : UITableViewCell { 
    IBOutlet BHPainIntenseButton * _veryButton;
    IBOutlet BHPainIntenseButton * _painfulButton;
    IBOutlet BHPainIntenseButton * _moderateButton;
    IBOutlet UIButton * _startLeftButton;
    IBOutlet UIButton * _startRightButton;
    IBOutlet UILabel * _startLabel;
    IBOutlet UIButton * _durationRightButton;
    IBOutlet UILabel * _durationLabel;
    IBOutlet UIButton * _durationLeftButton;
    
    BHMigrainEvent * _event;
} 

@property(nonatomic,retain) BHMigrainEvent * event; 

- (IBAction)buttonPressed:(id)sender;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHFoodCell : UITableViewCell { 
    BHMigrainEvent * _event;
    IBOutlet INButton * _btnBreakfast;    
    IBOutlet INButton * _btnLunch;    
    IBOutlet INButton * _btnDinner;    
    
    IBOutlet INButton * _btnFastingYes;    
    IBOutlet INButton * _btnFastingNo;    
} 

@property(nonatomic,retain) BHMigrainEvent * event; 

- (IBAction)buttonPressed:(id)sender;

@end


//==================================================================================================================================
//==================================================================================================================================

@interface BHMigraineBaseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    IBOutlet UIBarButtonItem * _backButton;
    IBOutlet UIBarButtonItem * _nextButton;
    IBOutlet BHTableView * _tableView;
    NSInteger _totalSteps, _step;
    NSArray * _sections;
    BHMigrainEvent * _event; 
}

- (void)reloadSectionInfo:(BHMigrainEventTableSectionInfo *)info;

/*
- (void)toggleCheckbox:(NSFetchedResultsController *)fetchedResults path:(NSIndexPath *)path action:(SEL)action;
- (BHButtonedCell *)checkboxedCellForPath:(NSIndexPath *)path fetchedResults:(NSFetchedResultsController *)fetchedResults set:(NSSet *)set hasOwnAnswer:(BOOL)hasOwnAnswer;
- (BHFramedCell *)ownAnswerCell;
*/

@property(nonatomic,retain) NSArray * sections;
@property(nonatomic,retain) BHMigrainEvent * event;
@property(nonatomic,readonly) BHTableView * tableView; 
- (void)reloadData;

@property(nonatomic) NSInteger totalSteps;
@property(nonatomic) NSInteger step;
- (void)goToNextStep:(Class)class;


@end
