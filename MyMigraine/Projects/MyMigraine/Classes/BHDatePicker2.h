
#import "BHUIComponents.h"
#import "BHClasses.h"

@class BHDatePicker2;

//==================================================================================================================================
//==================================================================================================================================

@protocol BHDatePicker2Delegate<NSObject>

- (void)datePicker2:(BHDatePicker2 *)picker didSelectDate:(BHStartDate)date;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHDatePicker2 : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource> { 
    id<BHDatePicker2Delegate> _delegate;
    BHStartDate _startDate;
    IBOutlet UIBarButtonItem * _doneButton;
    IBOutlet UIBarButtonItem * _cancelButton;
    IBOutlet UIPickerView * _pickerView;
    IBOutlet UILabel * _dateLabel;
    NSMutableArray * _dates;
}

+ (id)controllerForDelegate:(id<BHDatePicker2Delegate>)delegate startDate:(BHStartDate)startDate;
- (IBAction)buttonPressed:(id)sender;

@end

