
#import "BHMigrainStep6ViewController.h"
#import "BH.h"
#import "BHMyDiaryViewController.h"
#import "BHAppDelegate.h"

@implementation BHMigrainStep6ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sections = 
            [NSArray arrayWithObjects:
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_ENVIRONMENT title:CELL_TITLE_ENVIRONMENT addTitle:CELL_TITLE_ADD_ENVIRONMENT],
                 [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_Pms],
                 [BHMigrainEventTableSectionInfo_Notes info],
                 nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingChanged:) name:BH_SHARED_SETTINGCHANGED_NOTIFICATION object:nil];
    }
    return self;
}

- (void)settingChanged:(id)ntf
{
    [self reloadData];
}
//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] postNotificationName:BH_SHARED_SETTINGCHANGED_NOTIFICATION object:nil
    [_saveButton setBackgroundImage:[[UIImage imageNamed:@"big_button.png"]
        stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateNormal];
} 

//----------------------------------------------------------------------------------------------------------------------- [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingChanged:) name:BH_SHARED_SETTINGCHANGED_NOTIFICATION object:nil];----------

- (void)dealloc {
    [_saveCell release];
    [_saveButton release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return [super numberOfSectionsInTableView:tableView] + 1;      
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == [self numberOfSectionsInTableView:tableView] - 1) { 
        return 1;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) { 
        return _saveCell;
    }
      
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1) { 
        return 80;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) { 
        [(BHMyDiaryViewController *)[self.navigationController.viewControllers objectAtIndex:0] startNewEvent];
    } else { 
        [(BHMyDiaryViewController *)[self.navigationController.viewControllers objectAtIndex:0] startNewEventOpenOldInHistory];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)saveEntry {
    BHMigrainEvent * event = _event; 
    event.isCompleted = BHBoolNumber(YES);
    if ([g_BH prepareAndSaveEvent:event]) { 
        UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Your entry was saved." 
                                                          message:@"Would you like to view your entry?" delegate:self 
                                                cancelButtonTitle:@"Done" otherButtonTitles:@"View Now", nil] autorelease];
        alert.delegate = self;
        [alert show];
    } else {
        event.isCompleted = BHBoolNumber(NO);        
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _backButton) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (sender == _saveButton) {
        [self saveEntry];
    }
}

@end
