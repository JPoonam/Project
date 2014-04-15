
#import "BHMigrainStep5_2ViewController.h"
#import "BHMigrainStep6ViewController.h"
#import "BH.h"

@implementation BHMigrainStep5_2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = 
            [NSArray arrayWithObjects:
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_LIFESTYLE title:CELL_TITLE_LIFESTYLE addTitle:CELL_TITLE_ADD_LIFESTYLE],
                 nil];
    }
    return self;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
} 

//---------------------------------------------------------------------------------------------------------------------------------

- (void)goToStep6 {
    [self goToNextStep:BHMigrainStep6ViewController.class];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _backButton) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender == _nextButton) { 
        [self goToStep6];
    }
}

@end
