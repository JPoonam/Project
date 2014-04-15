
#import "BHTryExcedrinViewController.h"
#import "BHWebViewController.h"
#import "BH.h"
#import "BHAppDelegate.h"
#import "Reachability.h"
#import "JSONParser.h"

@interface BHTryExcedrinWebViewController : BHWebViewController {
    
}

@end

//============================================================================================

@implementation BHTryExcedrinWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"BHWebViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        // _nibLoader = [INNibLoader new];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _webView.scalesPageToFit = YES;
}

@end


//==================================================================================================================================
//==================================================================================================================================


@implementation BHTryExcedrinViewController

@synthesize overlayImage,spinner,lblLoading;

  // DMI: Eamil sending without showing compose screen.
#pragma mark Get Coupone email

- (IBAction)buttonPressed:(id)sender {
    if (sender == _rebateButton) {
        
        [txtEmailID resignFirstResponder];
                  
        if (txtEmailID.text.length==0) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter an email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if ([self NSStringIsValidEmail:txtEmailID.text])
        {
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus internetStatus = [reachability currentReachabilityStatus];
            if (internetStatus != NotReachable)
            {
                _scrollView.scrollEnabled=FALSE;
                _rebateButton.enabled=FALSE;
                txtEmailID.enabled=FALSE;
                [self createWaitOverlay]; 
                [self performSelector:@selector(sendEmail) withObject:nil afterDelay:0.5];
               
                
            }
            else 
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"No network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            
            // Verify the e-mail address format.
        }
        

    
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [txtEmailID resignFirstResponder];
    
    return TRUE;
}
-(void)sendEmail{
	
    // create soft wait overlay so the user knows whats going on in the background.
     JSONParser *sendMailParser=[[JSONParser alloc] init];
    [sendMailParser setDelegate:self];
    [sendMailParser sendEmail:txtEmailID.text];


    
   
	
}





-(void)messageSent:(NSString *)message
{
    _scrollView.scrollEnabled=TRUE;
    _rebateButton.enabled=TRUE;
     txtEmailID.enabled=TRUE;
    //message has been successfully sent . you can notify the user of that and remove the wait overlay
    [self removeWaitOverlay];	
	
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:message
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    txtEmailID.text=@"";
    
}

-(void)messageFailed:(NSString *)message error:(NSError *)error;
{
     _scrollView.scrollEnabled=TRUE;
    _rebateButton.enabled=TRUE;
     txtEmailID.enabled=TRUE;
    [self removeWaitOverlay];
	
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
	
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Error" message:message
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}

#pragma mark ------

-(void)createWaitOverlay {
	
    // fade the overlay in
    
    lblLoading=[[UILabel alloc]initWithFrame:CGRectMake(45, 280, 230, 20)];
    lblLoading.textColor=[UIColor whiteColor];
    lblLoading.backgroundColor=[UIColor clearColor];
    lblLoading.textAlignment=UITextAlignmentCenter;
    lblLoading.text=@"Sending...";
    
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


- (void)dealloc {
    [_rebateButton release];
    [_tableView release];
    [_contentImageView release];
    [_scrollView release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
    [_rebateButton release];
    _rebateButton = nil;
    [_tableView release];
    _tableView = nil;
    [_contentImageView release];
    _contentImageView = nil;
    [_scrollView release];
    _scrollView = nil;
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect r = _contentImageView.frame;
    _scrollView.contentSize = r.size;
    _scrollView.frame = self.view.bounds;
    [self.view addSubview:_scrollView];
    [self bh_setStyleWithCoolBackground:YES topShadow:YES havingOwnNavBar:NO];
    
    //_rebateButton.frame = CGRectOffset(_rebateButton.frame, 0, -r.origin.y);
    //_tableView.frame = CGRectOffset(_tableView.frame, 0, -r.origin.y);
    // _contentImageView.frame = CGRectOffset(_contentImageView.frame, 0, -r.origin.y);
    // [(id)self.view setContentSize:r.size];
    // [(id)self.view setBounces:NO];
}

//----------------------------------------------------------------------------------------------------------------------------------

enum {
    // CELL_GELTABS,
    // CELL_TABLETS,
    CELL_CAPLETS,
    CELL_LAST
};

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CELL_LAST;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL justLoaded;
    BHFramedCell * cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView nibFile:@"BHFramedDisclosureCell"
                                                               reuseIdentifier:@"dcell" justLoaded:&justLoaded];
    cell.backgroundView = nil; // no textures here
    switch (indexPath.row) {
            /*
             case CELL_GELTABS:
             cell.frameControl.frameStyle = BHControlFrameTopRounded;
             cell.captionLabel.text = @"Geltabs";
             break;
             
             case CELL_TABLETS:
             cell.frameControl.frameStyle = BHControlFrameSquare;
             cell.captionLabel.text = @"Tablets";
             break;
             */
        case CELL_CAPLETS:
            cell.frameControl.frameStyle = BHControlFrameRounded;
            cell.captionLabel.text = @"Caplets";
            break;
            
        default:
            NSAssert(0,@"mk_1b9270c7_a42a_4655_814b_ce455160c7b2");
    }
    [cell setRow:indexPath.row ofTotal:CELL_LAST];
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return COMMON_CELL_HEIGHT;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
     NSString * articleName = nil;
     switch (indexPath.row) {
     case CELL_GELTABS:
     articleName = @"Excedrin-Migraine-Geltabs";
     break;
     
     case CELL_TABLETS:
     articleName = @"Excedrin-Migraine-Tablets";
     break;
     
     case CELL_CAPLETS:
     articleName = @"Excedrin-Migraine-Caplets";
     break;
     
     default:
     NSAssert(0,@"mk_1b9270c7_a42a_4655_814b_ce455160c7b3");
     }
     
     NSURL * URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:articleName ofType:@"jpg"]];
     UIImage * img = [UIImage imageNamed:[articleName stringByAppendingString:@".jpg"]];
     CGFloat initialScale = 310 / img.size.width;
     NSString * htmlBody = [NSString stringWithFormat:@"<html><head>"
     @"<meta name=\"viewport\" content=\"initial-scale=%.2f,  maximum-scale=%.2f, user-scalable=yes\" />"
     @"<title></title></head><body><image src=\"%@\" /></body></html>",
     initialScale, 3.0,[URL absoluteString]];
     BHWebViewController * ctrl = [BHTryExcedrinWebViewController controllerWithBody:htmlBody];
     */
    //NSURL * URL = [[NSBundle mainBundle] URLForResource:@"Migraine Caplets" withExtension:@"pdf"];
    //NSString * htmlBody = [NSString stringWithFormat:@"<html><head>"
    //                           @"<meta name=\"viewport\" content=\"initial-scale=1,  maximum-scale=1, user-scalable=yes\" />"
    //                           @"<title></title></head><body style=\"margin:0;\"><iframe style=\"width:320px;height:480px;\" border=0 src=\"%@\" /></body></html>",
    //initialScale,
    //3.0,
    //                           [URL absoluteString]
    //                      ];
    //BHWebViewController * ctrl = [BHTryExcedrinWebViewController controllerWithBody:htmlBody];
    BHWebViewController * ctrl = [BHTryExcedrinWebViewController controllerWithURL:
                                  [[NSBundle mainBundle] URLForResource:@"Migraine Caplets" withExtension:@"pdf"]];
    [self.navigationController pushViewController:ctrl animated:YES];
}

//----------------------------------------------------------------------------------------------------------------------------------
/*
- (IBAction)buttonPressed:(id)sender {
    if (sender == _rebateButton) 
    {
//        if (![MFMailComposeViewController canSendMail]) {
//            [UIAlertView inru_showAlertWithTitle:TEXT_NO_EMAIL message:nil];
//            return;
//        }
//          MFMailComposeViewController * mailComposeViewController = [MFMailComposeViewController new];
//        mailComposeViewController.mailComposeDelegate = self;
//        [mailComposeViewController setSubject:@"Excedrin Migraine Coupon"];
//        NSString * path = [[NSBundle mainBundle] pathForResource:@"get-coupon-email-body" ofType:@"html"];
//        NSString * body = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//        [mailComposeViewController setMessageBody:body isHTML:YES];
//    
//        [g_AppDelegate.rootTabBarController presentModalViewController:mailComposeViewController animated:YES];
//    
//        [mailComposeViewController release];
        
        
        //by poonam
        
        [self sendEmail];        
        
    }
}

*/



//----------------------------------------------------------------------------------------------------------------------------------

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error  {
    [controller dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultFailed) {
        [g_BH  showError:error title:TEXT_EMAIL_FAILED explanation:error.localizedDescription forceShow:YES sender:@"MAIL"];
	}
}

@end
