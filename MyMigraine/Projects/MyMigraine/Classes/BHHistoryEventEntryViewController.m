
#import "BHHistoryEventEntryViewController.h"
#import "BH.h"

@implementation BHHistoryEventEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reloadData { 
    if (_event.hasHeadache.boolValue) { 
        self.sections = 
            [NSArray arrayWithObjects:
                [BHMigrainEventTableSectionInfo_Date info],
                [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_PainIntense],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_LOCATION title:CELL_TITLE_LOCATION addTitle:CELL_TITLE_ADD_LOCATION],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_WARNING title:CELL_TITLE_WARNING addTitle:CELL_TITLE_ADD_WARNING],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_SYMPTOM title:CELL_TITLE_SYMPTOM addTitle:CELL_TITLE_ADD_SYMPTOM],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_TREATMENT title:CELL_TITLE_TREATMENT addTitle:CELL_TITLE_ADD_TREATMENT],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_RELIEF title:CELL_TITLE_RELIEF addTitle:CELL_TITLE_ADD_RELIEF],
                [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_Food],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_FOOD title:CELL_TITLE_FOOD addTitle:CELL_TITLE_ADD_FOOD],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_LIFESTYLE title:CELL_TITLE_LIFESTYLE addTitle:CELL_TITLE_ADD_LIFESTYLE],
                [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_ENVIRONMENT title:CELL_TITLE_ENVIRONMENT addTitle:CELL_TITLE_ADD_ENVIRONMENT],
                [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_Pms],
                [BHMigrainEventTableSectionInfo_Notes info],
                nil];
    } else { 
        self.sections = 
            [NSArray arrayWithObjects:
                 [BHMigrainEventTableSectionInfo_Date info],
                 [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_Food],
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_FOOD title:CELL_TITLE_FOOD addTitle:CELL_TITLE_ADD_FOOD],
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_LIFESTYLE title:CELL_TITLE_LIFESTYLE addTitle:CELL_TITLE_ADD_LIFESTYLE],
                 [BHMigrainEventTableSectionInfo_CollectionItems infoWithEntity:ENTITY_ENVIRONMENT title:CELL_TITLE_ENVIRONMENT addTitle:CELL_TITLE_ADD_ENVIRONMENT],
                 [BHMigrainEventTableSectionInfo_CustomCell infoWithID:BHMigrainEventTableCell_Pms],
                 [BHMigrainEventTableSectionInfo_Notes info],
                 nil];
    }
    [super reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_cancelButton release];
    [_doneButton release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_style_shouldShowSideShadows { 
    return YES;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_style_setupHeader { 
    [self bh_setStandardCaptionForNavItem];
    self.navigationItem.hidesBackButton = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO];
    self.navigationItem.leftBarButtonItem = _cancelButton;   
    
    self.navigationItem.rightBarButtonItem = _doneButton;
    [self reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_cancelButton release];
    _cancelButton = nil;
    [_doneButton release];
    _doneButton = nil;
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender {
    if (_cancelButton == sender) { 
        _event.userWantNotToBeAskedOfMenstruations = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (_doneButton == sender) { 
        if ([g_BH prepareAndSaveEvent:_event]) { 
            _event.userWantNotToBeAskedOfMenstruations = NO;
           [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
