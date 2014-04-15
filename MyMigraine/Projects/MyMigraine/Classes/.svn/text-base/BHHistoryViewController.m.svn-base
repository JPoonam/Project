
#import "BHHistoryViewController.h"
#import "BH.h"
#import "BHHistoryEventEntryViewController.h"

@implementation BHHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbChanged:) name:BH_RECORD_SAVED_IN_CONTEXT_NOTIFICATION object:nil];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadData2 {
    if (_fetchedResults) { 
       [_fetchedResults release];
    }
    _fetchedResults = [[g_BH fetchedResultsControllerForEventWithStyle:BHFetchStyleHistory sinceDate:[NSDate distantPast]] retain];
    [_tableView reloadData];
    [_activityIndicator setHidden:YES withAnimation:YES];
    _validated = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadData {
    if (!_validated) { 
        [_activityIndicator popupWithAnimation:YES andAutoHideOnDelay:0];    
        [self performSelector:@selector(loadData2) withObject:nil afterDelay:0.2];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dbChanged:(id)ntf {
    _validated = NO;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self loadData];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_style_shouldShowSideShadows { 
    return YES;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.rowHeight = COMMON_CELL_HEIGHT;    
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO]; 
    self.navigationItem.leftBarButtonItem = _backButton;
    [_tableView enableExtraScrollingSpace2];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_backButton release];
    _backButton = nil;
    [_tableView release];
    _tableView = nil;
    [_activityIndicator release];
    _activityIndicator = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    [_backButton release];
    [_tableView release];
    [_fetchedResults release];
    [_activityIndicator release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender {
    if (sender == _backButton) { 
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    
    return [[_fetchedResults sections] count];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResults sections] objectAtIndex:section];
    return [sectionInfo name];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResults sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BHMigrainEvent * event = [_fetchedResults objectAtIndexPath:indexPath];
    BHHistoryCell * cell;
    BOOL justLoaded;
    if (event.hasHeadache.boolValue) { 
        cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHHistoryHACell" 
                                                                   reuseIdentifier:@"haCell" justLoaded:&justLoaded];
        cell.timeCellLabel.text = [NSString stringWithFormat:@"%@ lasted %@",  
                                   [event startHourString],
                                   [event durationString:YES]];   
        cell.intencityIndicator.backgroundColor = BHColorForPainIntense(event.intensity.intValue);
    } else { 
        cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHHistoryCell" 
                                                    reuseIdentifier:@"cell" justLoaded:&justLoaded];
    }
    cell.captionLabel.text = BHDateToString(event.timestamp, BHdateFormatLong);
    [cell setRow:indexPath.row ofTotal:[self tableView:nil numberOfRowsInSection:indexPath.section]];
    return cell; 
}

//----------------------------------------------------------------------------------------------------------------------------------
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BHMigrainEventTableSectionInfo * info = [_sections objectAtIndex:indexPath.section];
    return [info heightForRow:indexPath.row];
}
*/
//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BHHistoryEventEntryViewController * ctrl = [BHHistoryEventEntryViewController new];
    BHMigrainEvent * event = [_fetchedResults objectAtIndexPath:indexPath];
    ctrl.event = event;
    [self.navigationController pushViewController:ctrl animated:YES];
    [ctrl release];
}

@end

