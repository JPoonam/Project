
#import "BHCategoryItemPicker.h"
#import "BH.h"
#import "BHAppDelegate.h"

@interface BHCategoryItemPicker()

@property(nonatomic,retain) NSString * ownChoice;

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHCategoryItemPicker 

@synthesize ownChoice = _ownChoice;
@synthesize entityName = _entityName;
@synthesize tag = _tag;

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)pickerForDelegate:(id<BHCategoryItemPickerDelegate>)delegate entityName:(NSString *)entityName title:(NSString *)title  tag:(NSInteger)tag{ 
    
    NSFetchedResultsController * fr = [g_BH fetchedResultsControllerForCategoryWithEntityName:entityName style:BHFetchStyleCategoryItem params:nil];
    if (fr) { 
        BHCategoryItemPicker * result = [self new];
        result->_delegate = [delegate retain];
        result->_fetchedResults = [fr retain];
        result->_entityName = entityName;
        result->_tag = tag;
        result.title = title;
        fr.delegate = result;
        
        result->_originalUndoManager = [fr.managedObjectContext.undoManager retain];
        fr.managedObjectContext.undoManager = [[NSUndoManager new] autorelease];
        [fr.managedObjectContext.undoManager beginUndoGrouping];
        return [result autorelease];
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)presentPickerForDelegate:(id<BHCategoryItemPickerDelegate>)delegate entityName:(NSString *)entityName  title:(NSString *)title  tag:(NSInteger)tag{  
    id ctrl = [self pickerForDelegate:delegate entityName:entityName title:title tag:tag];
    [g_AppDelegate.rootTabBarController presentModalViewController:ctrl animated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    _fetchedResults.managedObjectContext.undoManager = [_originalUndoManager autorelease];
    [_entityName release];
    [_navBar release];
    [_tableView release];
    [_tableHeader release];
    [_textField release];
    [_delegate release];
    [_fetchedResults release];
    [_ownChoice release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateControls { 
    // _doneButton.enabled = _ownChoice.length != 0;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    [_doneButton setEnabled:FALSE];
    _tableView.tableHeaderView = _tableHeader;
    
    //DMI ios7 Change
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:YES];
    }
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 4, 0);
    _tableView.rowHeight = COMMON_CELL_HEIGHT;
    _titleLabel.text = self.title;
    if (![self tableView:_tableView numberOfRowsInSection:0]) { 
        [_textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.2];
    }
    [self updateControls];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applyChanges {
    BHCollectionItem * item = nil;
    
    if (_ownChoice.length) { 
        // 
        NSFetchedResultsController * f1 = [g_BH fetchedResultsControllerForCategoryWithEntityName:_entityName style:BHFetchStyleItemByName params:_ownChoice];
        if (!f1) { 
            return;
        }
        NSInteger count = [[[f1 sections] objectAtIndex:0] numberOfObjects];
        
        if (count) { 
            NSAssert(count == 1,@"mk_f1b16b43_9835_4f53_ae9d_1541d85f0a35");
            item = [f1 objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            //  
            if (! item.recordDeleted.boolValue) { 
                [UIAlertView inru_showAlertWithTitle:@"Record already exists" 
                     message:[NSString stringWithFormat:@"There is similar record '%@' in the list. Enter other description",
                                                             item.displayName]];
                return;
            }
            
            // 
            item.recordDeleted = BHBoolNumber(NO);
        } else {
            //
            NSExpression *expression = [NSExpression expressionForFunction:@"max:" arguments: // Create an expression to represent the function you want to apply
                [NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"orderNo"]]];
     
            // Create an expression description using the minExpression and returning a date.
            // The name is the key that will be used in the dictionary for the return value.
            NSExpressionDescription *expressionDescription = [[NSExpressionDescription new] autorelease];
            [expressionDescription setName:@"maxOrderNo"];
            [expressionDescription setExpression:expression];
            [expressionDescription setExpressionResultType:NSInteger32AttributeType]; // For example, NSDateAttributeType

            // Set the request's properties to fetch just the property represented by the expressions.
            NSFetchRequest * request = [[NSFetchRequest new] autorelease];
            [request setEntity:[g_BH entityWithName:_entityName]];
            [request setResultType:NSDictionaryResultType]; // Specify that the request should return dictionaries.
            [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
     
            // Execute the fetch.
            NSError * error = nil;
            id requestedValue = nil;
            NSArray * objects = [_fetchedResults.managedObjectContext executeFetchRequest:request error:&error];
            if (objects == nil) {
                [g_BH showError:error titleKey:@"ERR_FETCH_DB" explanationKey:@"ERR_FETCH_DB_D" forceShow:YES sender:@"FETCH"];
                return;
            }
            if ([objects count] > 0) {
                requestedValue = [[objects objectAtIndex:0] valueForKey:@"maxOrderNo"];
            }
        
            item = [NSEntityDescription insertNewObjectForEntityForName:_entityName inManagedObjectContext:f1.managedObjectContext];
            item.orderNo   = [NSNumber numberWithInt:[requestedValue intValue] + 1];
            item.isDefault = [NSNumber numberWithBool:NO];
            item.name      = _ownChoice;
        }
    }
    
    [_fetchedResults.managedObjectContext.undoManager endUndoGrouping];
    [_delegate categoryItemPickerDidChangeList:self withAddedObject:item];
    [self dismissModalViewControllerAnimated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender 
{ 
    if (sender == _cancelButton) { 
        _fetchedResults.delegate = nil;
        [_fetchedResults.managedObjectContext.undoManager endUndoGrouping];
        [_fetchedResults.managedObjectContext.undoManager undo];
        [self dismissModalViewControllerAnimated:YES];
    }
    if (sender == _doneButton) { 
        /*  
        [_fetchedResults.managedObjectContext.undoManager undo];
        [self.navigationController popViewControllerAnimated:YES];
        */
        [self applyChanges];
        
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResults sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BHCollectionItem  * item = [_fetchedResults objectAtIndexPath:indexPath];

    BOOL justLoaded; 
    BHButtonedCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHButtonedCell" reuseIdentifier:@"cell" justLoaded:&justLoaded];
    cell.delegate = self;
    cell.object = item;
    [cell hideRightButton]; 
    cell.captionLabel.text = item.displayName;
    cell.itemButton.style = BHItemButtonDelete;
    [cell setRow:indexPath.row ofTotal:[self tableView:tableView numberOfRowsInSection:indexPath.section]];
    // NSLog(@"reload %@", indexPath);

    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// ----------------------------------------------------------------------------------------------------------------------------------

- (void)bhcellWithTag:(NSInteger)cellTag didPressButton:(UIButton *)button forObject:(BHCollectionItem *)item  { 
    item.recordDeleted = BHBoolNumber(YES);
    [_tableView reloadData];
    // [_fetchedResults.managedObjectContext deleteObject:object];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
                
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
             [_doneButton setEnabled:TRUE];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            // [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        //case NSFetchedResultsChangeMove:
        //    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
        //    break;
        
        default:
            NSAssert1(0,@"mk_2bc210e5_2b99_4193_a0d7_8143cb384d28     type %d", type);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

/*
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            // [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
*/
//----------------------------------------------------------------------------------------------------------------------------------

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark TextField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  
{
    
    NSString * newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if([newString isEqualToString:@""] || newString== nil )
        
    {
        [_doneButton setEnabled:FALSE];   
    }
    else
    {
        [_doneButton setEnabled:TRUE]; 
    }
    self.ownChoice = [newString inru_trim];
    [self updateControls];
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldClear:(UITextField *)textField 
{  [_doneButton setEnabled:FALSE];
    self.ownChoice = nil;
    [self updateControls];
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField.text isEqualToString:@""] || textField.text== nil )
        
    {
        [_doneButton setEnabled:FALSE];   
    }
    else
    {
        [_doneButton setEnabled:TRUE]; 
    }
    [textField resignFirstResponder];
    return YES;    
}
//------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField.text isEqualToString:@""] || textField.text== nil )
        
    {
        [_doneButton setEnabled:FALSE];   
    }
    else
    {
        [_doneButton setEnabled:TRUE]; 
    }
   
    return YES;    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField.text isEqualToString:@""] || textField.text== nil )
        
    {
        [_doneButton setEnabled:FALSE];   
    }
    else
    {
        [_doneButton setEnabled:TRUE]; 
    }      
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if([textField.text isEqualToString:@""] || textField.text== nil )
        
    {
        [_doneButton setEnabled:FALSE];   
    }
    else
    {
        [_doneButton setEnabled:TRUE]; 
    }
    
    return YES;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField.text isEqualToString:@""] || textField.text== nil )

    {
      [_doneButton setEnabled:FALSE];   
    }
   else
    {
       [_doneButton setEnabled:TRUE]; 
    }
    [textField resignFirstResponder];
      
}

@end 
