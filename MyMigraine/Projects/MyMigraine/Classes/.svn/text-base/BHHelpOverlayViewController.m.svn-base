
#import "BHHelpOverlayViewController.h"

@interface BHHelpOverlayViewController ()

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHHelpOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_doneButton release];
    _doneButton = nil;
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc {
    [_doneButton release];
    [super dealloc];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissWithCode:BHHelpOverlayDoneExitCode animated:YES];
}

@end
