
#import "BHUIComponents.h"

@interface BHWebViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UIBarButtonItem * _backButton;
    IBOutlet UIWebView * _webView;
    NSURL * _initialURL;
    NSString * _body;
}

+ (id)controllerWithURL:(NSURL *)URL;
+ (id)controllerWithBody:(NSString *)body;
+ (id)controllerWithDocument:(NSString *)documentName;

- (IBAction)buttonPressed:(id)sender;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHArticleWebViewController : BHWebViewController {
    
}

@end

