
#import "BHWebViewController.h"

@interface BHIntroViewController : BHWebViewController<UIWebViewDelegate> { 
    IBOutlet UIButton * _acceptButton;
}

@property(nonatomic,retain) IBOutlet UIButton * _acceptButton;


- (void)buttonPressed:(id)sender;

@end
