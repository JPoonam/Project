
#import "BH.h"
#import "BHMigrainStep3ViewController.h"
#import "BHMigrainStep4ViewController.h"

@implementation BHMigrainStep3ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = 
            [NSArray arrayWithObjects:
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_WARNING title:CELL_TITLE_WARNING addTitle:CELL_TITLE_ADD_WARNING],
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_SYMPTOM title:CELL_TITLE_SYMPTOM addTitle:CELL_TITLE_ADD_SYMPTOM],
                 nil];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
} 

//---------------------------------------------------------------------------------------------------------------------------------
 
- (void)goToStep4 {
    [self goToNextStep:BHMigrainStep4ViewController.class];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _backButton) { 
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender == _nextButton) { 
        [self goToStep4];
    }
}

@end
