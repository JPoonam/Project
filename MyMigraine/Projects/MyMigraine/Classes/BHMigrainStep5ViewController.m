
#import "BH.h"
#import "BHMigrainStep5ViewController.h"
#import "BHMigrainStep5_2ViewController.h"

@implementation BHMigrainStep5ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = 
            [NSArray arrayWithObjects:
                 [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_Food],
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_FOOD title:CELL_TITLE_FOOD addTitle:CELL_TITLE_ADD_FOOD],
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
    [self goToNextStep:BHMigrainStep5_2ViewController.class];
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
