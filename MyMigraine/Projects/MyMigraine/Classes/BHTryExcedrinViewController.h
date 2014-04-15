
#import "BHUIComponents.h"
#import <MessageUI/MessageUI.h>
#import "INIPad.h"


#import "JSONParser.h"

@interface BHTryExcedrinViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EmailMessageDelegate,
MFMailComposeViewControllerDelegate> {
    IBOutlet UIButton * _rebateButton;
    IBOutlet UIImageView * _contentImageView;
    IBOutlet UITableView * _tableView;
    IBOutlet UIScrollView * _scrollView;
    
    IBOutlet UITextField *txtEmailID;
}

// @property (weak, nonatomic) IBOutlet UITextField *txtEmailID;
@property (nonatomic, retain)UIImageView * overlayImage;
@property (nonatomic, retain)UIActivityIndicatorView * spinner;
@property (nonatomic, retain)UILabel * lblLoading;


- (IBAction)buttonPressed:(id)sender;

-(void)sendEmail;
-(void)removeWaitOverlay;
-(void)createWaitOverlay;
-(void)stopSpinner;
-(void)startSpinner;



@end
