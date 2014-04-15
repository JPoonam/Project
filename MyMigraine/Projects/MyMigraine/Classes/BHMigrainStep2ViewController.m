
#import "BHMigrainStep2ViewController.h"
#import "BH.h"
#import "BHMigrainStep3ViewController.h"

@implementation BHMigrainStep2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = 
           [NSArray arrayWithObjects:
                [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_PainIntense],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_LOCATION title:CELL_TITLE_LOCATION addTitle:CELL_TITLE_ADD_LOCATION],
                nil];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)goToStep3 {
    [self goToNextStep:BHMigrainStep3ViewController.class];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _backButton) { 
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender == _nextButton) { 
        [self goToStep3];
    }    
}

@end
