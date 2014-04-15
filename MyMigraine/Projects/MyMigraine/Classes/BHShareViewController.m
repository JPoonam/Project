
#import "BHShareViewController.h"
#import "BHAppDelegate.h"
#import "BH.h"
#import "BHReports.h"
#import "Reachability.h"

enum {
    ACTION_NONE,
    ACTION_EMAIL,
    ACTION_PRINT
};

//==================================================================================================================================
//==================================================================================================================================

@interface BHShareViewController ()

@end

//==================================================================================================================================

@implementation BHShareViewController
@synthesize overlayImage,spinner,lblLoading;
+ (id)shareDialogForDelegate:(id<BHShareViewControllerDelegate>)delegate options:(BHShareOptions)options { 
    BHShareViewController * result = [BHShareViewController new];
    result->_delegate = delegate;
    result->_options = options;
     
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:result];
    navController.delegate = g_AppDelegate;
    [result bh_setNavBarBackground];
    [result release];
    return [navController autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = _cancelButton;
    UIColor * greenColor = [UIColor inru_colorFromRGBA:0x008426ff];
    _includeAllChartsSwitcher.customColor = greenColor;
    _includeAllChartsSwitcher.on = _options.includeAllCharts;
    [_includeAllChartsSwitcher addTarget:self action:@selector(changeAllCharts:) forControlEvents:UIControlEventValueChanged];
    
    _includeHistoryFileSwitcher.customColor = greenColor;
    _includeHistoryFileSwitcher.on = _options.includeHistory;
    [_includeHistoryFileSwitcher addTarget:self action:@selector(changeHistory:) forControlEvents:UIControlEventValueChanged];
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO]; 
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)changeAllCharts:(INSwitch *)sender { 
    _options.includeAllCharts = sender.on;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)changeHistory:(INSwitch *)sender { 
    _options.includeHistory = sender.on;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_style_setupHeader { 
    [self bh_setCaption:@"Share"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_style_shouldShowSideShadows { 
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_tableView release];
    _tableView = nil;
    [_cancelButton release];
    _cancelButton = nil;
    [_printButton release];
    _printButton = nil;
    [_emailButton release];
    _emailButton = nil;
    [_actionCell release];
    _actionCell = nil;
    [_includeAllChartsSwitcher release];
    _includeAllChartsSwitcher = nil;
    [_includeHistoryFileSwitcher release];
    _includeHistoryFileSwitcher = nil;
    [_includeHistoryCell release];
    _includeHistoryCell = nil;
    [_includeChartsCell release];
    _includeChartsCell = nil;
    [_progressIndicator release];
    _progressIndicator = nil;
    [super viewDidUnload];
}
-(void)viewWillAppear:(BOOL)animated
{
     [_cancelButton setEnabled:TRUE];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_cancelButton setEnabled:FALSE];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc
{
    [_reportPDF release];
    [_tableView release];
    [_cancelButton release];
    [_printButton release];
    [_emailButton release];
    [_actionCell release];
    [_includeAllChartsSwitcher release];
    [_includeHistoryFileSwitcher release];
    [_includeHistoryCell release];
    [_includeChartsCell release];
    [_progressIndicator release];
    [_mailController release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

enum {
    CELL_TITLE,
    CELL_DATE_TITLE,
    CELL_DATE,
    CELL_SEP_AFTER_DATE,
    CELL_ALL_CHARTS,
    CELL_SEP_AFTER_CHARTS,
    CELL_HISTORY,
    CELL_SEP_AFTER_HISTORY,
    CELL_ACTION,
    CELL_LAST
};

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CELL_LAST;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL justLoaded; 
    UITableViewCell * cell = nil;
    
    switch (indexPath.row) { 
        case CELL_TITLE: 
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_SHARE tableView:tableView condensed:YES];
            ((BHTitleCell *)cell).captionLabel.textColor = [BHReusableObjects blueLabelColor]; 
            break;
            
        case CELL_DATE_TITLE: 
            cell = [BHTitleCell cellWithTitle:CELL_TITLE_SHARE_CHOOSE_START_DATE tableView:tableView condensed:YES];
            break;
            
        case CELL_SEP_AFTER_DATE:
        case CELL_SEP_AFTER_CHARTS:
            cell = [BHSeparatorCell cellWithDivider:YES tableView:tableView];
            break;
            
        case CELL_DATE:
            cell = [[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHFramedDisclosureCell" 
                                                    reuseIdentifier:@"dcell" justLoaded:&justLoaded];
            ((BHFramedCell *)cell).captionLabel.text = BHStartDateToString(_options.startDate);
            [(BHFramedCell *)cell setRow:0 ofTotal:1];
            ((BHFramedCell *)cell).frameControl.frameStyle = BHControlFrameRounded; 
            break;
            
        case CELL_ALL_CHARTS:
            cell = _includeChartsCell;
            break;
            
        case CELL_HISTORY:
            cell = _options.showHistorySwitcher ? _includeHistoryCell : [BHSeparatorCell cellWithDivider:NO tableView:tableView];;
            break;
            
        case CELL_SEP_AFTER_HISTORY:
            cell = [BHSeparatorCell cellWithDivider:_options.showHistorySwitcher tableView:tableView];
            break;
        
        case CELL_ACTION:
            cell = _actionCell;
            break;
            
        default:
            NSAssert(0, @"mk_a6c724a3_75c7_4480_bb61_a241ecb4836b");
    }
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) { 
        case CELL_TITLE: 
            return [BHTitleCell heightForTitle:CELL_TITLE_SHARE condensed:YES];
            
        case CELL_DATE_TITLE: 
            return [BHTitleCell heightForTitle:CELL_TITLE_SHARE_CHOOSE_START_DATE  condensed:YES];
            
        case CELL_DATE:
            return COMMON_CELL_HEIGHT;
            
        case CELL_ALL_CHARTS:
            return 39;
            
        case CELL_HISTORY:
            return 52;
            
        case CELL_SEP_AFTER_CHARTS:
        case CELL_SEP_AFTER_HISTORY:
        case CELL_SEP_AFTER_DATE:
            {
                CGFloat h = [BHTitleCell heightForTitle:CELL_TITLE_SHARE condensed:YES];
                return h < 60 ? 36 : 30; // 
            }
            
        case CELL_ACTION:
            return 77;
            
    }
    return COMMON_CELL_HEIGHT;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) { 
        case CELL_DATE:
            { 
                BHDatePicker2 * picker2 = [BHDatePicker2 controllerForDelegate:self startDate:_options.startDate];
                [self.navigationController pushViewController:picker2 animated:YES];  
            }   
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)datePicker2:(BHDatePicker2 *)picker didSelectDate:(BHStartDate)date { 
    _options.startDate = date;
    [_tableView reloadData];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)doPrintAction { 
    UIPrintInteractionController * printController = [UIPrintInteractionController sharedPrintController];

    // Instruct the printing concierge to use our custom UIPrintPageRenderer subclass when printing this job
    printController.printingItem = _reportPDF;
    printController.showsPageRange = YES;

    // Ask for a print job object and configure its settings to tailor the print request
    UIPrintInfo *info = [UIPrintInfo printInfo];
    info.outputType = UIPrintInfoOutputGeneral;
    info.jobName = PDF_HEADER;
    printController.printInfo = info;

    // Present the standard iOS Print Panel that allows you to pick the target Printer, number of pages, double-sided, etc.
    [printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {}];
    [_cancelButton setEnabled:TRUE];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)doEmailAction {
    if (_mailController) { 
        return;
    }
    
    MFMailComposeViewController * mailComposeViewController = [MFMailComposeViewController new];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:PDF_EMAIL_SUBJ];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"send-diary-email-body" ofType:@"html"];
    NSString * body = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]; 
    [mailComposeViewController setMessageBody:body isHTML:YES];
    [mailComposeViewController addAttachmentData:_reportPDF mimeType:@"application/pdf" fileName:PDF_FILENAME];
    
    _mailController = mailComposeViewController;
    CGRect r = g_AppDelegate.rootTabBarController.view.frame;
    _mailController.view.frame = CGRectOffset(r, 0, r.size.height);
    [self.view.window addSubview:_mailController.view];
    [UIView beginAnimations:@"mail" context:nil];
    [UIView setAnimationDuration:0.4];
    _mailController.view.frame = r;
    [UIView commitAnimations];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context { 
    [_mailController.view removeFromSuperview];
    [_mailController release];
    _mailController = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------
    
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
      [_cancelButton setEnabled:TRUE];
    NSAssert(controller == _mailController, @"mk_056f5e3e_6448_459c_8d73_e4e88853c648");
    CGRect r = g_AppDelegate.rootTabBarController.view.frame;
    [self.view addSubview:_mailController.view];
    [UIView beginAnimations:@"mail" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDelegate:self];
    _mailController.view.frame = CGRectOffset(r, 0, r.size.height);
    [UIView commitAnimations];
   
    if (result == MFMailComposeResultFailed)
    {
       
        [g_BH showError:error title:TEXT_EMAIL_FAILED explanation:error.localizedDescription forceShow:YES sender:@"MAIL"];
    }
    [_reportPDF release];
    _reportPDF = nil;
//    [_cancelButton setEnabled:TRUE];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setAction:(NSInteger)action { 
    _action = action;
    if (_action == ACTION_NONE)
    { 
       // [_progressIndicator setHidden:YES withAnimation:YES];
        [self removeWaitOverlay];
    } else 
    { 
      //  [_progressIndicator popupWithAnimation:YES andAutoHideOnDelay:0];
        [self createWaitOverlay];
    }
}


#pragma mark ------

-(void)createWaitOverlay {
	
    // fade the overlay in
    
 
    lblLoading=[[UILabel alloc]initWithFrame:CGRectMake(45, 280, 230, 20)];
    lblLoading.textColor=[UIColor whiteColor];
    lblLoading.backgroundColor=[UIColor clearColor];
    lblLoading.textAlignment=UITextAlignmentCenter;
    lblLoading.text=@"Loading...";
    
    overlayImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,568)];
    overlayImage.image = [UIImage imageNamed:@"waiting.png"];
    [self.view addSubview:overlayImage];
    [overlayImage addSubview:lblLoading];
    lblLoading.alpha=0;
    overlayImage.alpha = 0;
   	
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:.5];
    overlayImage.alpha = 1;
    lblLoading.alpha=1;
    
    [UIView commitAnimations];
    [self startSpinner];

	
    
	
}

-(void)removeWaitOverlay {
	
    //fade the overlay out
	
    [UIView beginAnimations: @"Fade Out" context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:.5];
    overlayImage.alpha = 0;
    lblLoading.alpha=0;
    [UIView commitAnimations];
    [self stopSpinner];
	
	
}

-(void)startSpinner {
	    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidden = FALSE;
    spinner.frame = CGRectMake(125, 200, 60, 60);
    [spinner setHidesWhenStopped:YES];
    [self.view addSubview:spinner];
    [self.view bringSubviewToFront:spinner];
    [spinner startAnimating];
}

-(void)stopSpinner
{
	 [spinner stopAnimating];
     [spinner removeFromSuperview];
}





//----------------------------------------------------------------------------------------------------------------------------------

- (void)createReportWithAction:(NSInteger)action {
    NSAssert(g_BH.hasRecords, @"mk_58e0d68a_67c1_4044_9be9_96acfa519030");
    /* 
    if (!g_BH.hasRecords) {
        [UIAlertView inru_showAlertWithTitle:TEXT_NO_RECORDS message:nil];
        _action = ACTION_NONE;
        return;
    }
    */
    self.action = action;
    [self performSelector:@selector(createReport2) withObject:nil afterDelay:0.2];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)createReport2 { 
    [_reportPDF release];
    _reportPDF = nil;

    BHReportGenerator * rg = [BHReportGenerator new];
    _reportPDF = [[rg createReportWithOptions:_options] retain];
    [rg release];

    if (_reportPDF) { 
        switch (_action) {
            case ACTION_EMAIL:
                [self doEmailAction];
                break;

            case ACTION_PRINT:
                [self doPrintAction];
                break;

            default:
                NSAssert(0,@"mk_a708ba9b_e766_42b6_90a3_2a2f0c9ec9bb");
                break;
        }  
    } else { 
        [UIAlertView inru_showAlertWithTitle:TEXT_SHARE_NOTHING_TO_PDF message:nil]; 
    }
    self.action = ACTION_NONE;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)doPrint {
    if (![BHReportGenerator canPrint]) { 
        [UIAlertView inru_showAlertWithTitle:TEXT_NO_PRINTING message:nil];
        return;
    }
    [self createReportWithAction:ACTION_PRINT];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)doEmail { 
    
    if (![MFMailComposeViewController canSendMail]) 
    {
        [_cancelButton setEnabled:TRUE];
        [UIAlertView inru_showAlertWithTitle:TEXT_NO_EMAIL message:nil];
        return;
    }
    [self createReportWithAction:ACTION_EMAIL];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender 
{
    if (_action == ACTION_NONE) { 
        if (sender == _cancelButton)
        {
            [_delegate shareDialog:self didCompleteWithOptions:_options]; 
            [self dismissModalViewControllerAnimated:YES];
            return;
            // [self.navigationController popViewControllerAnimated:YES];
        }

        
        if(!_includeAllChartsSwitcher.on && !_includeHistoryFileSwitcher.on)
        {
           UIAlertView * alert =[[[UIAlertView alloc] initWithTitle:@"My Migraine Triggers" message:@"Please enable at least one option" delegate:nil 
                              cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
            [alert show];
            
        }
        else
        {
        
        if (sender == _emailButton) 
        { 
            [_cancelButton setEnabled:FALSE];
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus internetStatus = [reachability currentReachabilityStatus];
            if (internetStatus != NotReachable) {
                
                [self doEmail];
                
            }
            else {
                 [_cancelButton setEnabled:TRUE];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"No network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            
            
        }
        
        
        if (sender == _printButton)
        { 
            [_cancelButton setEnabled:FALSE];           
            [self doPrint];
        }
        }
    }
}

@end

/*
    BHChartSeriesCollection * collection = [BHChartSeriesCollection collectionSinceDate:g_BH.sharedStartDate];
    
    for (int i = 0; i < BHChartSeriesLast; i++) {  
        _pageInfo[i].series = [collection itemAtIndex:i];
        [_pageInfo[i] updateView];
    }
*/
