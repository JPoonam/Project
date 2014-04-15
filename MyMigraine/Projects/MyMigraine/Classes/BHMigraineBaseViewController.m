
#import "BHMigraineBaseViewController.h"
#import "BH.h"
#import "BHAppDelegate.h"
#import "INView.h"
#import "INCoreData.h"

//==================================================================================================================================
//==================================================================================================================================

@implementation BHDateCell

@synthesize event = _event;
@synthesize info = _info;

/* 
 : UITableViewCell { 
    BHMigrainEvent * _event;
    IBOutlet INButton * _btnHasHeadache;    
    IBOutlet INButton * _btnHasNoHeadache;    
} 

@property(nonatomic,retain) BHMigrainEvent * event;
- (IBAction)buttonPressed:(id)sender;
*/

enum { 
    GROUP_HA = 1
};

//----------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib { 
    _btnHasHeadache.groupIndex = GROUP_HA;
    _btnHasNoHeadache.groupIndex = GROUP_HA;
    
    for (UIView * v in self.contentView.subviews) { 
        v.backgroundColor = [BHReusableObjects texturedColor];
        v.opaque = YES;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateControls { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f4");
    if (event.hasHeadache.boolValue) { 
        _btnHasHeadache.selected = YES;
    } else { 
        _btnHasNoHeadache.selected = YES; 
    }
    // [_dateButton setTitle: BHDateToString(event.timestamp) forState:UIControlStateNormal];
    // The date of entry
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setEvent:(BHMigrainEvent *)event  {
    if (event != _event) { 
        [_event release];
        _event = [event retain];
        [self updateControls];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_btnHasHeadache release];
    [_btnHasNoHeadache release];
    [_event release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    if (sender == _btnHasNoHeadache || sender == _btnHasHeadache) { 
        INPlayControlTockSound();
        [sender setSelected: ![sender isSelected]];
        BHMigrainEvent * event = _event;
        event.hasHeadache  = BHBoolNumber(_btnHasHeadache.selected);
        [_info.viewController reloadData];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHPmsCell

@synthesize event = _event;

enum { 
    GROUP_PMS = 1
};

//----------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib { 
    _btnPMSYes.groupIndex = GROUP_PMS;
    _btnPMSNo.groupIndex = GROUP_PMS;
    _btnPMSDontAsk.groupIndex = GROUP_PMS;
    
    for (UIView * v in self.contentView.subviews) { 
        v.backgroundColor = [BHReusableObjects texturedColor];
        v.opaque = YES;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateControls { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f4"); 
    if (g_BH.askMenstruations) { 
        switch (event.menstruating.intValue) { 
            case BHMenstruatingYes:
                _btnPMSYes.selected = YES;
                break;
                
            case BHMenstruatingNo:
                _btnPMSNo.selected = YES;
                break;
                
            default:
                if (event.userWantNotToBeAskedOfMenstruations) {
                    _btnPMSDontAsk.selected = YES;
                }
        }
    }
    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setEvent:(BHMigrainEvent *)event  {
    if (event != _event) { 
        [_event release];
        _event = [event retain];
        [self updateControls];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_btnPMSYes release];
    [_btnPMSNo release];
    [_btnPMSDontAsk release];
    [_event release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    
    INPlayControlTockSound();
    
    if (sender == _btnPMSYes || sender == _btnPMSNo || sender == _btnPMSDontAsk) { 
        [sender setSelected: ![sender isSelected]];
        BHMigrainEvent * event = _event;
        event.userWantNotToBeAskedOfMenstruations = NO;
        if (sender == _btnPMSYes && [sender isSelected]) { 
            event.menstruating  = [NSNumber numberWithInt:BHMenstruatingYes];
        } else 
            if (sender == _btnPMSNo  && [sender isSelected]) { 
                event.menstruating  = [NSNumber numberWithInt:BHMenstruatingNo];
            } else {
                event.menstruating  = [NSNumber numberWithInt:BHMenstruatingNoInfoProvided];
                if (sender == _btnPMSDontAsk && [sender isSelected]) { 
                    event.userWantNotToBeAskedOfMenstruations = YES;
                }
            }
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHFoodCell

@synthesize event = _event;

enum { 
    GROUP_FASTING = 1
};

//----------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib { 
    _btnFastingYes.groupIndex = GROUP_FASTING;
    _btnFastingNo.groupIndex = GROUP_FASTING;
    
    for (UIView * v in self.contentView.subviews) { 
        v.backgroundColor = [BHReusableObjects texturedColor];
        v.opaque = YES;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)saveChanges { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_5f6fa5a8_9eb2_4266_89dd_79d26b534a6d");
    
    event.fasting = BHBoolNumber(_btnFastingYes.selected);
    event.skippedBreakfast = BHBoolNumber(_btnBreakfast.selected);
    event.skippedDinner = BHBoolNumber(_btnDinner.selected);
    event.skippedLunch = BHBoolNumber(_btnLunch.selected);
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateControls { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f1"); 
    
    if (event.fasting.boolValue) { 
        _btnFastingYes.selected = YES;    
    } else { 
        _btnFastingNo.selected = YES;    
    }
    _btnBreakfast.selected = event.skippedBreakfast.boolValue;
    _btnDinner.selected = event.skippedDinner.boolValue;
    _btnLunch.selected = event.skippedLunch.boolValue;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setEvent:(BHMigrainEvent *)event  {
    if (event != _event) { 
        [_event release];
        _event = [event retain];
        [self updateControls];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_btnBreakfast release];
    [_btnLunch release];
    [_btnFastingYes release];
    [_btnDinner release];
    [_btnFastingNo release];
    [_event release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    
    INPlayControlTockSound();
    
    if (sender == _btnFastingYes || sender == _btnFastingNo) { 
        [sender setSelected:YES];
        [self saveChanges];
    }
    if (sender == _btnBreakfast || sender == _btnLunch || sender == _btnDinner) { 
        [sender setSelected: ![sender isSelected]];
        [self saveChanges];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHPainIntenseCell

@synthesize event = _event;

enum { 
    GROUP_INTENSE = 1
};

//----------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib { 
    _veryButton.groupIndex = GROUP_INTENSE;
    _moderateButton.groupIndex = GROUP_INTENSE;
    _painfulButton.groupIndex = GROUP_INTENSE;
    
    _veryButton.intense = BHPainIntenseVeryPainful;
    _moderateButton.intense = BHPainIntenseModerate;
    _painfulButton.intense = BHPainIntensePainful;
    
    for (UIView * v in self.contentView.subviews) { 
         v.backgroundColor = [BHReusableObjects texturedColor];
         v.opaque = YES;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateStartFrame { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f9");
    _startLabel.text = [NSString stringWithFormat:@"Started %@", event.startHourString];
    // _startLeftButton.enabled = hour <= 0;
    // _startRightButton.enabled = hour >= 23;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateDurationFrame { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f7"); 
    _durationLabel.text = [event durationString: NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateControls { 
    BHMigrainEvent * event = _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f5"); 
    
    // initial values
    if (!event.startHour) { 
        INDateComponents comps = [[NSDate date] inru_components];
        event.startHour = [NSNumber numberWithInt:comps.hour];   
    }
    if (!event.duration) { 
        event.duration = [NSNumber numberWithInt:60 * 3];   
    }
    
    switch (event.intensity.intValue) { 
        case BHPainIntenseModerate:
            _moderateButton.selected = YES;
            break;
            
        case BHPainIntensePainful:
            _painfulButton.selected = YES;
            break;
            
        case BHPainIntenseVeryPainful:
            _veryButton.selected = YES;
            break;
            
        default:
            NSAssert(0,@"mk_9f65c58a_2ef4_4677_b7c0_55448cbd39ae");
    }
    
    [self updateStartFrame];
    [self updateDurationFrame];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setEvent:(BHMigrainEvent *)event  {
    if (event != _event) { 
        [_event release];
        _event = [event retain];
        [self updateControls];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_veryButton release];
    [_moderateButton release];
    [_painfulButton release];
    [_startLeftButton release];
    [_startRightButton release];
    [_startLabel release];
    [_durationLeftButton release];
    [_durationRightButton release];
    [_durationLabel release];
    [_event release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
    BHMigrainEvent * event =  _event;
    NSAssert(_event,@"mk_2171db4e_3c8f_412a_b3e1_801471c9e4f4");

    INPlayControlTockSound();
    
    if (sender == _moderateButton || sender == _veryButton || sender == _painfulButton) { 
        [sender setSelected:YES];
        event.intensity = [NSNumber numberWithInt:[(BHPainIntenseButton *)sender intense]];
    }
    
    if (sender == _startLeftButton || sender == _startRightButton) {
        NSInteger hour = event.startHour.intValue;
        if (sender == _startLeftButton) { 
            if (hour == 0) {
                hour = 23;
            } else { 
                hour --;
            }
        } else { 
            if (hour == 23) {
                hour = 0;
            } else { 
                hour++;
            }
        }    
        event.startHour = [NSNumber numberWithInt:hour];
        [self updateStartFrame];
    }
    
    
    if (sender == _durationLeftButton || sender == _durationRightButton) {
        NSInteger hours = event.duration.intValue / 60;
        if (sender == _durationLeftButton) { 
            if (hours == 1) {
                hours = 24;
            } else { 
                hours --;
            }
        } else { 
            if (hours == 24) {
                hours = 1;
            } else { 
                hours++;
            }
        }    
        event.duration = [NSNumber numberWithInt:hours * 60];
        [self updateDurationFrame];
    }
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHMigrainEventTableSectionInfo

@synthesize viewController = _viewController;

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)rowCount { 
    NSAssert(0,@"override it! mk_3d077285_d682_4d27_af1b_f4c1d8a289cd");
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)cellForRow:(NSUInteger)rowIndex  {
     NSAssert(0,@"override it! mk_7a8936f7_4673_4573_b5e6_0cd64f4bd1c1");
     return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)heightForRow:(NSUInteger)rowIndex { 
    NSAssert(0,@"override it!  mk_dc9a2d58_dab8_4921_9a64_daccc4c2a320");
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleTouchForRow:(NSUInteger)rowIndex { 
    // just ignoring in the base class 
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHMigrainEventTableSectionInfo_CustomCell

+ (id)infoWithID:(NSInteger)ID { 
    BHMigrainEventTableSectionInfo_CustomCell * result = [BHMigrainEventTableSectionInfo_CustomCell new];
    result->_ID = ID;
    return [result autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)rowCount { 
    if (_ID == BHMigrainEventTableCell_Pms) { 
       return g_BH.askMenstruations ? 1 : 0;
    }
    return 1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)cellForRow:(NSUInteger)rowIndex { 
    UITableView * tableView = _viewController.tableView;
    BHMigrainEvent * event = _viewController.event;
    NSAssert(tableView && event, @"mk_93b8a8bb_afdc_4739_8dec_1681ad938897");
    
    BOOL justLoaded;
    switch (_ID) { 
        case BHMigrainEventTableCell_PainIntense:
            {
                BHPainIntenseCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView 
                                                   nibFile:@"BHPainIntenseCell" reuseIdentifier:@"BHPainIntenseCell"
                                                                                 justLoaded:&justLoaded];
                cell.event = event;
                return cell;     
            }   
            break;

        case BHMigrainEventTableCell_Food:
            {
                BHFoodCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView 
                                                nibFile:@"BHFoodCell" reuseIdentifier:@"BHFoodCell"
                                                       justLoaded:&justLoaded];
                cell.event = event;
                return cell;     
            }   
            break;
            
        case BHMigrainEventTableCell_Pms:
            {
                BHPmsCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView 
                                                nibFile:@"BHPmsCell" reuseIdentifier:@"BHPmsCell"
                                                       justLoaded:&justLoaded];
                cell.event = event;
                return cell;     
            }   
            break;
                       
        default: 
            NSAssert(0,@"mk_02ccb182_593b_4f87_be35_6e3c69219908");
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)heightForRow:(NSUInteger)rowIndex { 
    switch (_ID) { 
        case BHMigrainEventTableCell_PainIntense:
            return 282;
        
        case BHMigrainEventTableCell_Food:
            return 179;
            
        case BHMigrainEventTableCell_Pms:
            return 141;
            
        default: 
            NSAssert(0,@"mk_080d92d2_dbd0_45fa_b507_279488005e4e");
    }
    return 0;
}

@end

//==================================================================================================================================

@implementation BHMigrainEventTableSectionInfo_Date

+ (id)info { 
    BHMigrainEventTableSectionInfo_Date * result = [BHMigrainEventTableSectionInfo_Date new];
    return [result autorelease];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)rowCount {
    return 3;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)cellForRow:(NSUInteger)rowIndex { 
    UITableViewCell * cell = nil;
    UITableView * tableView = _viewController.tableView;
    BHMigrainEvent * event = _viewController.event;
    
    switch (rowIndex) {
        case 0: 
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_DATE tableView:tableView condensed:NO];
            break;
            
        case 1:
            {
                BOOL justLoaded;
                cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHFramedDisclosureCell" 
                                                            reuseIdentifier:@"dcell" justLoaded:&justLoaded];
                [(id)cell setRow:1 ofTotal:2];
                [(id)cell captionLabel].text = BHDateToString(event.timestamp, BHdateFormatSimple);
                [(id)cell captionLabel].textColor = [UIColor blackColor];
            }
            break;
            
        case 2:
            {
                BOOL justLoaded;
                BHDateCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView 
                                                nibFile:@"BHDateCell" reuseIdentifier:@"BHDateCell"
                                                       justLoaded:&justLoaded];
                cell.event = event;
                cell.info = self;
                return cell;     
            }
            break;   
    }
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)heightForRow:(NSUInteger)rowIndex {
    switch (rowIndex) { 
        case 0:
            return [BHTitleCell heightForTitle:CELL_TITLE_NOTES condensed:NO];
            
        case 1:
            return COMMON_CELL_HEIGHT;
            
        case 2:
            return 105;
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)datePicker:(BHDatePicker *)picker didSelectDate:(NSDate *)date { 
    _viewController.event.timestamp = [date inru_trimTime];
    [_viewController reloadSectionInfo:self];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleTouchForRow:(NSUInteger)rowIndex {
    switch (rowIndex) { 
        case 1:
            {
                BHDatePicker * picker = [BHDatePicker controllerForDelegate:self startDate:_viewController.event.timestamp];
                [g_AppDelegate.rootTabBarController presentModalViewController:picker animated:YES];  
            }
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notePicker:(BHNotePicker *)picker didSelectNote:(NSString *)note { 
    _viewController.event.note = note;
    [_viewController reloadSectionInfo:self];
}

@end

//==================================================================================================================================

@implementation BHMigrainEventTableSectionInfo_Notes

+ (id)info { 
    BHMigrainEventTableSectionInfo_Notes * result = [BHMigrainEventTableSectionInfo_Notes new];
    return [result autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)rowCount {
    return 2;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)cellForRow:(NSUInteger)rowIndex { 
    UITableViewCell * cell = nil;
    UITableView * tableView = _viewController.tableView;
    BHMigrainEvent * event = _viewController.event;
    
    switch (rowIndex) {
        case 0: 
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_NOTES tableView:tableView condensed:NO];
            break;
            
        case 1:
            {
                BOOL justLoaded;
                cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHAddOwnCell" 
                                                                           reuseIdentifier:@"ownAnswerCell" justLoaded:&justLoaded];
                [(id)cell setRow:1 ofTotal:2];
                if (event.note.length) { 
                    [(id)cell captionLabel].text = CELL_TITLE_NOTES_VIEW;
                } else {
                    [(id)cell captionLabel].text = CELL_TITLE_NOTES_ADD;
                }
            }
            break;
    }
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)heightForRow:(NSUInteger)rowIndex { 
    if (rowIndex == 0) { 
       return [BHTitleCell heightForTitle:CELL_TITLE_NOTES condensed:NO];
    } else { 
        return COMMON_CELL_HEIGHT;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleTouchForRow:(NSUInteger)rowIndex {
    if (rowIndex == 0) { 
        return;
    }
    
    BHNotePicker * picker = [BHNotePicker controllerForDelegate:self text:_viewController.event.note];
    [g_AppDelegate.rootTabBarController presentModalViewController:picker animated:YES];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notePicker:(BHNotePicker *)picker didSelectNote:(NSString *)note { 
    _viewController.event.note = note;
    [_viewController reloadSectionInfo:self];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHMigrainEventTableSectionInfo_CollectionItems

+ (id)infoWithEntity:(NSString *)entity title:(NSString *)title addTitle:(NSString *)addTitle{ 
    BHMigrainEventTableSectionInfo_CollectionItems * result = [BHMigrainEventTableSectionInfo_CollectionItems new];
    
    result->_hasOwnItems = addTitle != nil;
    result->_fetchedResults = [[g_BH fetchedResultsControllerForCategoryWithEntityName:entity style:BHFetchStyleCheckList params:nil] retain];
    result->_fetchedResults.delegate = result;
    
    NSString * relationships = [[entity lowercaseString]stringByAppendingString:@"s"];
    INRelationshipInfo info = [NSManagedObject inru_infoForRelationshipWithName:relationships];

    result->_relationshipSelector = info.fetchSelector;
    result->_addSelector = info.addObjectSelector;
    result->_removeSelector = info.removeObjectSelector;
    result->_title = [title retain];
    result->_addTitle = [addTitle retain];
    result->_entity = [entity retain];
    return [result autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_fetchedResults release];
    [_title release];
    [_addTitle release];
    [_entity release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)rowCount {
    NSInteger result = 1; // title 
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResults sections] objectAtIndex:0];
    result += [sectionInfo numberOfObjects];

    if (_hasOwnItems) {  // tail
        result ++;
    }  
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)cellForRow:(NSUInteger)rowIndex { 
    BOOL justLoaded; 
    UITableView * tableView = _viewController.tableView;
    BHMigrainEvent * event = _viewController.event;
    NSAssert(tableView && event, @"mk_93b8a8bb_afdc_4739_8dec_1681ad938897");
    
    if (rowIndex == 0) { 
        UITableViewCell * cell = [BHTitleCell cellWithTitle:_title tableView:tableView condensed:NO];
        return cell;
    }
    
    if (_hasOwnItems && rowIndex == self.rowCount - 1) {
         BHFramedCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHAddOwnCell" 
                                                          reuseIdentifier:@"ownAnswerCell" justLoaded:&justLoaded];
         [cell setRow:1 ofTotal:2];
         // NSLog(@"%@ %@", cell, cell.captionLabel.text);
         return cell;
    } 

    // items  
    BHCollectionItem  * item = [_fetchedResults objectAtIndexPath:[NSIndexPath indexPathForRow:rowIndex-1 inSection:0]];
    BHButtonedCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHButtonedCell" 
                                       reuseIdentifier:@"cell" justLoaded:&justLoaded];
    cell.delegate = (id)self;
    cell.object = item;
    cell.captionLabel.text = item.displayName;
    cell.itemButton.style = BHItemButtonCheckbox;
    cell.itemButton.selected = [[event performSelector:_relationshipSelector] containsObject:item]; 
    cell.cellTag = rowIndex;
    if ([g_BH hasHelpText:item.tag.intValue]) {
        [cell showRightButtonWithStyle:BHItemButtonHelp];
    } else {
        [cell hideRightButton]; 
    }
    //if (_hasOwnItems) { 
    //    [cell setRow:rowIndex ofTotal:NSIntegerMax];
    //} else { 
        [cell setRow:rowIndex ofTotal:self.rowCount];
    //}
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)heightForRow:(NSUInteger)rowIndex { 
    if (rowIndex == 0) { 
        return [BHTitleCell heightForTitle:_title condensed:NO];
    }
    return COMMON_CELL_HEIGHT;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)toggleCheckboxedItem:(BHCollectionItem *)item { 
    id event = _viewController.event; 
    if ([[event performSelector:_relationshipSelector] containsObject:item]) { 
        [event performSelector:_removeSelector withObject:item];
    } else { 
        [event performSelector:_addSelector withObject:item];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bhcellWithTag:(NSInteger)cellTag didPressButton:(UIButton *)button forObject:(id)object { 
    [self toggleCheckboxedItem:object];
    [_viewController reloadSectionInfo:self ];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleTouchForRow:(NSUInteger)rowIndex {
    if (rowIndex == 0) { 
        return;
    }
    
    if (_hasOwnItems && rowIndex == self.rowCount - 1) {
        [BHCategoryItemPicker presentPickerForDelegate:self entityName:_entity title:_addTitle tag:0];
        return;
    }
    
    BHCollectionItem  * item = [_fetchedResults objectAtIndexPath:[NSIndexPath indexPathForRow:rowIndex-1 inSection:0]];
    [self toggleCheckboxedItem:item];
    [_viewController reloadSectionInfo:self ];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)categoryItemPickerDidChangeList:(BHCategoryItemPicker *)picker withAddedObject:(BHCollectionItem *)object {
    [_fetchedResults bh_performFetch];
    if (object) {
        [_viewController.event performSelector:_addSelector withObject:object]; 
    }
    [_viewController.tableView reloadData];
    [_viewController.tableView scrollToLastRowOfSection:[_viewController.sections indexOfObject:self]];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHMigraineBaseViewController

@synthesize step = _step;
@synthesize totalSteps = _totalSteps;
@synthesize sections = _sections;
@synthesize event = _event;
@synthesize tableView = _tableView;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_style_setupHeader { 
    [self bh_setCaptionWithStep:self.step ofTotal:self.totalSteps];
    self.navigationItem.hidesBackButton = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)goToNextStep:(Class)class { 
    BHMigraineBaseViewController * nextStepVC = [class new];
    nextStepVC.step = self.step + 1;
    nextStepVC.totalSteps = self.totalSteps;
    nextStepVC.event = _event;
    [self.navigationController pushViewController:nextStepVC animated:YES];
    [nextStepVC release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO]; 
    self.navigationItem.leftBarButtonItem = _backButton;
    self.navigationItem.rightBarButtonItem = _nextButton;
    [_tableView enableExtraScrollingSpace];
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidAppear:(BOOL)animated { 
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSections:(NSArray *)sections { 
    [_sections release];
    _sections = [sections retain];
    for (BHMigrainEventTableSectionInfo * info in sections) { 
        info.viewController = self;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_event release];
    [_backButton release];
    [_nextButton release];
    [_tableView release];
    [_sections release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------
/* 
- (void)toggleCheckbox:(NSFetchedResultsController *)fetchedResults path:(NSIndexPath *)path action:(SEL)action {  
    BHCollectionItem  * item = [fetchedResults objectAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:0]];
    [self performSelector:action withObject:item];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BHButtonedCell *)checkboxedCellForPath:(NSIndexPath *)path fetchedResults:(NSFetchedResultsController *)fetchedResults set:(NSSet *)set hasOwnAnswer:(BOOL)hasOwnAnswer {  
    BOOL justLoaded; 
    BHCollectionItem  * item = [fetchedResults objectAtIndexPath:[NSIndexPath indexPathForRow:path.row inSection:0]];
    BHButtonedCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:_tableView nibFile:@"BHButtonedCell" reuseIdentifier:@"cell" justLoaded:&justLoaded];
    cell.delegate = (id)self;
    cell.object = item;
    cell.captionLabel.text = item.displayName;
    cell.itemButton.style = BHItemButtonCheckbox;
    cell.itemButton.selected = [set containsObject:item]; 
    cell.cellTag = path.section;
    if (item.tag.intValue) {
        [cell showRightButtonWithStyle:BHItemButtonHelp];
    } else {
        [cell hideRightButton]; 
    }
    if (hasOwnAnswer) { 
        [cell setRow:path.row ofTotal:NSIntegerMax];
    } else { 
        [cell setRow:path.row ofTotal:[(id)self tableView:_tableView numberOfRowsInSection:path.section]];
    }
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BHFramedCell *)ownAnswerCell { 
    BOOL justLoaded;
    id cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:_tableView nibFile:@"BHAddOwnCell" 
                    reuseIdentifier:@"ownAnswerCell" justLoaded:&justLoaded];            
    [cell setRow:1 ofTotal:2];
    return cell;
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_style_shouldShowSideShadows { 
    return YES;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reloadData { 
    [_tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return _sections.count;      
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] rowCount];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     BHMigrainEventTableSectionInfo * info = [_sections objectAtIndex:indexPath.section];
     id cell = [info cellForRow:indexPath.row];
     return cell; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BHMigrainEventTableSectionInfo * info = [_sections objectAtIndex:indexPath.section];
    return [info heightForRow:indexPath.row];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reloadSectionInfo:(BHMigrainEventTableSectionInfo *)info { 
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:[_sections indexOfObject:info]]withRowAnimation:UITableViewRowAnimationNone];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BHMigrainEventTableSectionInfo * info = [_sections objectAtIndex:indexPath.section];
    [info handleTouchForRow:indexPath.row];
}

@end
