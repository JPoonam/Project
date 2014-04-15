
#import "BHUIComponents.h"
#import "BHClasses.h"

@class BHNotePicker;

//==================================================================================================================================
//==================================================================================================================================

@protocol BHNotePickerDelegate<NSObject>

- (void)notePicker:(BHNotePicker *)picker didSelectNote:(NSString *)note;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHNotePicker : UIViewController<UITextViewDelegate> { 
    id<BHNotePickerDelegate> _delegate;
    NSDate * _startDate;
    IBOutlet BHModalNavigationBar * _navBar;
    IBOutlet UIBarButtonItem * _doneButton;
    IBOutlet UIBarButtonItem * _cancelButton;
    IBOutlet UITextView * _textView;
    NSString * _text;
}

+ (id)controllerForDelegate:(id<BHNotePickerDelegate>)delegate text:(NSString *)text;
- (IBAction)buttonPressed:(id)sender;

@end

