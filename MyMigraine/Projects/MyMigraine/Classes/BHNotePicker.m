
#import "BHNotePicker.h"

@implementation BHNotePicker

+ (id)controllerForDelegate:(id<BHNotePickerDelegate>)delegate text:(NSString *)text { 
    BHNotePicker * result = [self new];
    result->_text = [text retain];
    result->_delegate = [delegate retain];
    return [result autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_delegate release];
    [_startDate release];
    [_doneButton release];
    [_navBar release];
    [_cancelButton release];
    [_textView release];
    [_text release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    // self.navigationItem.hidesBackButton = YES;
    _navBar.topItem.title = nil;
    // _titleLabel.text = self.title;
    ((BHControlFrame *)_textView.superview).frameStyle = BHControlFrameRounded; 
    _textView.text = _text;
    
    //DMI ios7 Change
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:YES];
    }
    [_textView becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _doneButton) {
        [_delegate notePicker:self didSelectNote:_text];
    } 
    [self dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString * newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [_text release];
    _text = [newString retain];
    return YES;
}

@end 

