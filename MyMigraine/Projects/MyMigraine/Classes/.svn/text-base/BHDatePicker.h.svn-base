
#import "BHUIComponents.h"
#import "BHClasses.h"

@class BHDatePicker;

//==================================================================================================================================
//==================================================================================================================================

@protocol BHDatePickerDelegate<NSObject>

- (void)datePicker:(BHDatePicker *)picker didSelectDate:(NSDate *)date;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHDatePicker : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> { 
    id<BHDatePickerDelegate> _delegate;
    NSDate * _startDate;
    IBOutlet BHModalNavigationBar * _navBar;
    IBOutlet UIBarButtonItem * _doneButton;
    IBOutlet UIBarButtonItem * _cancelButton;
    IBOutlet UIPickerView * _pickerView;
    IBOutlet UILabel * _dateLabel;
    // IBOutlet UILabel * _titleLabel;
    NSMutableArray * _dates;
}

+ (id)controllerForDelegate:(id<BHDatePickerDelegate>)delegate startDate:(NSDate *)startDate;
- (IBAction)buttonPressed:(id)sender;

@end

