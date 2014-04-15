
#import "BHMyDiaryViewController.h"
#import "BH.h"
#import "BHAppDelegate.h"
#import "BHMigrainStep2ViewController.h"
#import "BHMigrainStep5ViewController.h"
#import "BHHistoryViewController.h"
#import "BHWebViewController.h"
#import "BHHistoryEventEntryViewController.h"

@implementation BHMyDiaryViewController

- (void)dealloc {
    [_cell0 release];
    [_tableView release];
    [_helpButton release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO]; 
    [_tableView enableExtraScrollingSpace];
    self.navigationItem.rightBarButtonItem = _helpButton;
    // _tableView.scrollEnabled = NO;

} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)goToStep2 {
    BHMigrainEvent * event; 
    if (!(event = [g_BH currentMigrainEvent:YES])) { 
        return;
    }
    event.hasHeadache = [NSNumber numberWithBool:YES];
    BHMigrainStep2ViewController * step2 = [BHMigrainStep2ViewController new];
    step2.event = event;
    step2.step = 1;
    step2.totalSteps = BH_WIZARD_TOTAL_STEPS_HAS_HA; 
    [self.navigationController pushViewController:step2 animated:YES];
    [step2 release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)goToStep5 {
    BHMigrainEvent * event; 
    if (!(event = [g_BH currentMigrainEvent:YES])) { 
        return;
    }
    event.hasHeadache = [NSNumber numberWithBool:NO];
    BHMigrainStep5ViewController * step5 = [BHMigrainStep5ViewController new];
    step5.step = 1;
    step5.totalSteps = BH_WIZARD_TOTAL_STEPS_HAS_NO_HA; 
    step5.event = event;
    [self.navigationController pushViewController:step5 animated:YES];
    [step5 release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)hasMigrainHistory { 
    return g_BH.hasRecords;
}

//----------------------------------------------------------------------------------------------------------------------------------

enum {
    CELL_0,
    CELL_DATE_TITLE,
    CELL_DATE,
    CELL_2,
    CELL_HAS_HA,
    CELL_HASNOT_HA,
    CELL_HISTORY_TITLE,
    CELL_HISTORY_VIEW,
    CELL_LAST
};

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return [[_items objectAtIndex:section] count];
    if (self.hasMigrainHistory) { 
        return CELL_LAST;
    } else { 
        return CELL_HISTORY_TITLE; 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL justLoaded; 
    UITableViewCell * cell = nil;
    
    switch (indexPath.row) { 
        case CELL_0: 
            cell = _cell0;
            break;

        case CELL_2: 
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_HAS_HA tableView:tableView condensed:self.hasMigrainHistory];
            break;

        case CELL_DATE_TITLE: 
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_CHOOSE_DATE tableView:tableView  condensed:self.hasMigrainHistory];
            break;
         
        case CELL_HISTORY_TITLE:
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_EDIT_HIST tableView:tableView  condensed:self.hasMigrainHistory];
            break;
    }
    
    if (!cell) {
        cell = [[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHFramedDisclosureCell" 
                     reuseIdentifier:@"dcell" justLoaded:&justLoaded];
    }

    switch (indexPath.row) { 
        case CELL_DATE:
            { 
                BHMigrainEvent * event = [g_BH currentMigrainEvent:NO];
                ((BHFramedCell *)cell).captionLabel.text = BHDateToString(event.timestamp, BHdateFormatSimple);
                [(BHFramedCell *)cell setRow:0 ofTotal:1];
                ((BHFramedCell *)cell).frameControl.frameStyle = BHControlFrameRounded; 
            }
            break;
            
        case CELL_HISTORY_VIEW:
            ((BHFramedCell *)cell).captionLabel.text = @"View previous entries";
            [(BHFramedCell *)cell setRow:0 ofTotal:1];
            ((BHFramedCell *)cell).frameControl.frameStyle = BHControlFrameRounded; 
            break;

        case CELL_HAS_HA:
            ((BHFramedCell *)cell).captionLabel.text = @"Yes, I had a headache";
            [(BHFramedCell *)cell setRow:0 ofTotal:2];
            ((BHFramedCell *)cell).frameControl.frameStyle = BHControlFrameTopRounded; 
            break;

        case CELL_HASNOT_HA:
            ((BHFramedCell *)cell).captionLabel.text = @"No, I did not";
            [(BHFramedCell *)cell setRow:1 ofTotal:2];
            ((BHFramedCell *)cell).frameControl.frameStyle = BHControlFrameBottomRounded; 
            break;
    }
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) { 
        case CELL_0: 
            return self.hasMigrainHistory ? 73 : 93;

        case CELL_DATE_TITLE: 
            return [BHTitleCell heightForTitle:CELL_TITLE_CHOOSE_DATE  condensed:self.hasMigrainHistory];

        case CELL_HISTORY_TITLE: 
            return [BHTitleCell heightForTitle:CELL_TITLE_EDIT_HIST  condensed:self.hasMigrainHistory];

        case CELL_2: 
            return [BHTitleCell heightForTitle:CELL_TITLE_HAS_HA condensed:self.hasMigrainHistory];
    }
    return COMMON_CELL_HEIGHT;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) { 
        case CELL_DATE:
            { 
                BHDatePicker * picker = [BHDatePicker controllerForDelegate:self startDate:[g_BH currentMigrainEvent:NO].timestamp];
                [g_AppDelegate.rootTabBarController presentModalViewController:picker animated:YES];  
            }   
            break;
            
        case CELL_HAS_HA:
            [self goToStep2];
            break;
            
        case CELL_HASNOT_HA:
            [self goToStep5];
            break;

        case CELL_HISTORY_VIEW:
            { 
                if ([g_BH prepareAndSaveEvent:[g_BH currentMigrainEvent:NO]]) { 
                    BHHistoryViewController * history = [BHHistoryViewController new];
                    [self.navigationController pushViewController:history animated:YES];
                    [history release]; 
                }
            }  
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewWillAppear:(BOOL)animated {  
    [super viewWillAppear:animated];
    [g_BH currentMigrainEvent:YES];
    [_tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)datePicker:(BHDatePicker *)picker didSelectDate:(NSDate *)date { 
    [g_BH currentMigrainEvent:NO].timestamp = date;
    [_tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_style_shouldShowSideShadows { 
    return YES;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)startNewEvent { 
    [g_BH releaseCurrentEvent];    
    [_tableView reloadData];
    [self.navigationController popToRootViewControllerAnimated:YES]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)startNewEventOpenOldInHistory { 
    BHMigrainEvent * oldEvent = [[g_BH.currentMigrainEvent retain] autorelease];
    [g_BH releaseCurrentEvent];    
    [_tableView reloadData];
    
    BHHistoryEventEntryViewController * ctrl = [BHHistoryEventEntryViewController new];
    ctrl.event = oldEvent;
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:self, ctrl, nil] animated:YES]; 
    [ctrl release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)helpButtonPresseD:(id)sender {
    BHArticleWebViewController * ctrl = [BHArticleWebViewController controllerWithDocument:@"using-this-application"];
    [self.navigationController pushViewController:ctrl animated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_helpButton release];
    _helpButton = nil;
    [super viewDidUnload];
}

@end


