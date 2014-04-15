//
//  Created by alex on 4/8/11.
//


#import <Foundation/Foundation.h>

#define NOTIFICATION_NETWORK_ACTIVITY_STARTED @"__NOTIFICATION_NETWORK_ACTIVITY_STARTED"
#define NOTIFICATION_NETWORK_ACTIVITY_ENDED @"__NOTIFICATION_NETWORK_ACTIVITY_ENDED"
#define NOTIFICATION_NETWORK_ERROR @"__NOTIFICATION_NETWORK_ERROR"

typedef enum {
    INResterRequestTypePOST,
    INResterRequestTypeGET
} INResterRequestType;

@protocol INResterCallback
    - (void)dataWasLoaded:(NSString*)aData forRequest:(NSURLRequest*)aRequest id:(NSObject*)aId;
@end

@interface INRester : NSObject {
    NSArray *_cookies;
    NSString *_userAgent;
    NSString *_referer;

    NSInteger _timeout;

    NSOperationQueue *_queue;
}

@property(copy, nonatomic) NSString *userAgent;
@property(copy, nonatomic) NSString *referer;

- (void)processRequestInBackgroundForURL:(NSString*)aURL parameters:(NSDictionary*)aParameters method:(INResterRequestType)aType callbackObject:(NSObject<INResterCallback>*)aCallbackObject callbackId:(NSObject*)aObject;
- (NSString *)processRequestForURL:(NSString*)aURL parameters:(NSDictionary*)aParameters method:(INResterRequestType)aType;
- (void)clearCookies;

@end
