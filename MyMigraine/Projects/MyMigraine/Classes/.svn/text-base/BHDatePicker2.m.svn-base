
#import "BHDatePicker2.h"

@implementation BHDatePicker2 

+ (id)controllerForDelegate:(id<BHDatePicker2Delegate>)delegate startDate:(BHStartDate)startDate { 
    BHDatePicker2 * result = [self new];
    result->_startDate = startDate;
    result->_delegate = [delegate retain];
    return [result autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dates = [NSMutableArray new];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    //[_titleLabel release];
    [_delegate release];
    [_doneButton release];
    [_cancelButton release];
    [_pickerView release];
    [_dateLabel release];
    [_dates release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

static NSInteger _CompareDatesDesc(NSDate * d1, NSDate * d2, void * context) {
    return [d2 compare:d1];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_style_setupHeader { 
    [self bh_setCaption:@"Period"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_style_shouldShowSideShadows { 
    return YES;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad { 
    [super viewDidLoad];
    
    ((BHControlFrame *)_dateLabel.superview).frameStyle = BHControlFrameRounded; 
    
    [_dates removeAllObjects];
    NSDate * today = [[NSDate date] inru_trimTime]; 

    for (int i = 0; i < BH_MAX_DAYS_AGO; i++) {
        NSDate * d = [today inru_incDay:-i];
        [_dates addObject:d];
    }
    [_dates sortUsingFunction:_CompareDatesDesc context:nil];
    
    NSInteger row = -1;
    if (_startDate.dateKind < BHStartDateIndividualDate) { 
        row = _startDate.dateKind;
    } else { 
        NSUInteger index = [_dates indexOfObject:[NSDate inru_dateFromComponents:_startDate.ymd]];
        if (index != NSNotFound) { 
            row = BHStartDateIndividualDate + index;
        }
    }
    if (index >= 0) { 
        [_pickerView selectRow:row inComponent:0 animated:NO];
    }
    _dateLabel.text = BHStartDateToString(_startDate); 

    self.navigationItem.leftBarButtonItem = _cancelButton;    
    self.navigationItem.rightBarButtonItem = _doneButton;    
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BHStartDate)dateForSelectedRow:(NSInteger)row {
    BHStartDate result = {}; 
    if (row < BHStartDateIndividualDate) { 
        result.dateKind = row;
    } else { 
        result.dateKind= BHStartDateIndividualDate;
        result.ymd = [[_dates objectAtIndex:row - BHStartDateIndividualDate] inru_components];
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender { 
   if (sender == _doneButton) {
       [_delegate datePicker2:self didSelectDate:[self dateForSelectedRow:[_pickerView selectedRowInComponent:0]]];
   } 
   if ([self.navigationController.viewControllers objectAtIndex:0] == self) { 
       [self dismissModalViewControllerAnimated:YES];
   } else { 
       [self.navigationController popViewControllerAnimated:YES];
   }
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { 
   return 1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _dates.count + BHStartDateIndividualDate;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _dateLabel.text = BHStartDateToString([self dateForSelectedRow:row]);  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component { 
    return 300;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)pickerView: (UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView: (UIView *)view {

    BHStartDate date = [self dateForSelectedRow:row];

    UIView * v = [[UIView alloc] initWithFrame: CGRectMake(0,0,[self pickerView:pickerView widthForComponent:component],100)];
    UILabel * label = [[UILabel alloc] initWithFrame: INRectInset(v.bounds, 50,0,20,0)];
    label.text = BHStartDateToString(date);
    label.opaque = NO;
    label.autoresizingMask = INFlexibleWidthHeight;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize: 22];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0,1);
    label.minimumFontSize = 15;
    label.adjustsFontSizeToFitWidth = YES;

    if (BHStartDatesAreEqual(_startDate,date)) {
        label.textColor = [UIColor inru_colorFromRGBA:0x324e84ff];
    }
    //  label.textAlignment = UITextAlignmentCenter;
    [v addSubview:label];
    [label release];
    return [v  autorelease];
}

@end 
