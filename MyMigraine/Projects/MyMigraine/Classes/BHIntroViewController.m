
#import "BHIntroViewController.h"
#import "BH.h"
#import "BHAppDelegate.h"

@implementation BHIntroViewController
@synthesize _acceptButton;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_acceptButton release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
  //  _acceptButton.enabled = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)buttonPressed:(id)sender {
    
    // DMI:change  show check box button.
    [_acceptButton setImage:[UIImage imageNamed:@"btn_checkbox_checked"] forState:UIControlStateNormal];
    [g_AppDelegate performSelector:@selector(handleTermsAccepted) withObject:nil afterDelay:1.0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)makeCoolBackground { 
    return NO;   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { 
    if ([request.URL.scheme isEqualToString:@"hottabytch"]) {
        _acceptButton.enabled = YES;
        return NO;
    }
    return YES;
}

@end
