
#import "BHMigrainStep4ViewController.h"
#import "BHMigrainStep5ViewController.h"
#import "BH.h"

@implementation BHMigrainStep4ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = 
            [NSArray arrayWithObjects:
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_TREATMENT title:CELL_TITLE_TREATMENT addTitle:CELL_TITLE_ADD_TREATMENT],
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_RELIEF title:CELL_TITLE_RELIEF addTitle:CELL_TITLE_ADD_RELIEF],
                 nil];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
} 

//---------------------------------------------------------------------------------------------------------------------------------
 
- (void)goToStep5 {
    [self goToNextStep:BHMigrainStep5ViewController.class];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _backButton) { 
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender == _nextButton) { 
        [self goToStep5];
    }
}

@end
