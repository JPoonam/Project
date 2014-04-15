
#import "BHMigraineBaseViewController.h"
#import "BHNotePicker.h"

@interface BHMigrainStep6ViewController : BHMigraineBaseViewController <UIAlertViewDelegate> {
    IBOutlet UITableViewCell * _saveCell;
    IBOutlet UIButton * _saveButton;
}

- (IBAction)buttonPressed:(id)sender;

@end
