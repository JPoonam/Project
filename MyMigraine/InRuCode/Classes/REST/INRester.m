//
//  Created by alex on 4/8/11.
//


#import "INRester.h"
#import "INCommonTypes.h"


//#define DEBUG_RESTER


@interface INResterBackgroundConnection : NSObject {
    NSURLRequest *_request;
    NSObject <INResterCallback> *_callback;
    NSObject *_id;
}

    @property(retain, nonatomic) NSURLRequest *request;
    @property(assign, nonatomic) NSObject <INResterCallback> *callback;
    @property(retain, nonatomic) NSObject *id;

    + (INResterBackgroundConnection *)createWithConnection:(NSURLRequest *)aConnection callback:(NSObject <INResterCallback> *)aCallback id:(NSObject *)aId;

@end


@implementation INResterBackgroundConnection

    @synthesize request = _request;
    @synthesize callback = _callback;
    @synthesize id = _id;

    + (INResterBackgroundConnection *)createWithConnection:(NSURLRequest *)aRequest callback:(NSObject <INResterCallback> *)aCallback id:(NSObject *)aId {
        INResterBackgroundConnection *result = [[INResterBackgroundConnection alloc] init];
        result.request = aRequest;
        result.callback = aCallback;
        result.id = aId;
        return [result autorelease];
    }

    - (void)dealloc {
        [_request release];
        [_id release];

        [super dealloc];
    }

@end


@interface INRester (Private)

    + (NSString *)urlEncode:(id)aValue;

    - (NSString *)parametersForQuery:(NSDictionary *)aParameters;
    - (NSURL *)getURLForURL:(NSString *)aURL parameters:(NSDictionary *)aParameters method:(INResterRequestType)aType;
    - (NSURLRequest *)createRequestForURL:(NSString *)aURL parameters:(NSDictionary *)aParameters method:(INResterRequestType)aType;

    - (NSString *)copyResponseStringForRequest:(NSURLRequest *)aRequest;

@end


@implementation INRester (Private)

    + (NSString *)urlEncode:(id)aValue {
        CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                NULL,
                (CFStringRef) aValue,
                NULL,
                (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
                kCFStringEncodingUTF8);
        return [(NSString *) urlString autorelease];
    }

    - (NSString *)parametersForQuery:(NSDictionary *)aParameters {
        NSMutableString *result = [NSMutableString string];
        for (NSString *parameterName in [aParameters allKeys]) {
            id value = [aParameters objectForKey:parameterName];

            if ([result length] != 0) {
                [result appendString:@"&"];
            }

            [result appendFormat:@"%@=%@", parameterName, [INRester urlEncode:value]];
        }

        return [NSString stringWithString:result];
    }

    - (NSURL *)getURLForURL:(NSString *)aURL parameters:(NSDictionary *)aParameters method:(INResterRequestType)aType {
        NSString *urlString = aURL;
        NSString *parameters = aParameters == nil ? nil : [self parametersForQuery:aParameters];
        NSURL *url = [NSURL URLWithString:urlString];

        if (aType == INResterRequestTypeGET) {
            if (parameters != nil) {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, parameters]];
            }
        }

        return url;
    }

    - (NSURLRequest *)createRequestForURL:(NSString *)aURL parameters:(NSDictionary *)aParameters method:(INResterRequestType)aType {
        NSString *parameters = aParameters == nil ? nil : [self parametersForQuery:aParameters];

        NSData *requestData = nil;

        NSURL *url = [self getURLForURL:aURL parameters:aParameters method:aType];

        if (aType != INResterRequestTypeGET) {
            requestData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
        }

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [request setTimeoutInterval:_timeout];
        [request setHTTPMethod:aType == INResterRequestTypePOST ? @"POST" : @"GET"];

        if (aType == INResterRequestTypePOST) {
            [request setHTTPBody:requestData];
            [request setValue:[NSString stringWithFormat:@"%u", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        }

        if (_userAgent != nil) {
            [request setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
        }

        if (_referer != nil) {
            [request setValue:_referer forHTTPHeaderField:@"Referer"];
        }

        if (_cookies != nil) {
            NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:_cookies];
            [request setAllHTTPHeaderFields:cookieHeaders];
        }

        return request;
    }

    - (NSString *)copyResponseStringForRequest:(NSURLRequest *)aRequest {
        NSHTTPURLResponse *response;
        NSError *error = nil;

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        NSString *resultString = nil;

//        _currentConnection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self];
//        [_currentConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        [_currentConnection start];

        NSData *data = [NSURLConnection sendSynchronousRequest:aRequest returningResponse:&response error:&error];

        if (error == nil) {
            if (_cookies == nil) {
                _cookies = [[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[aRequest mainDocumentURL]] retain];
            }

            resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_ERROR object:[NSNumber numberWithBool:NO]];
        } else {
            resultString = @"";
#ifdef DEBUG_RESTER
            NSLog(@"Error: %@", error);
            NSLog(@"Errored URL: %@", [aRequest mainDocumentURL]);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_ERROR object:[NSNumber numberWithBool:YES]];
        }

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        return resultString;
    }

@end


@implementation INRester (ConnectionDelegate)

//- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request NS_AVAILABLE(10_6, 3_0);
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace NS_AVAILABLE(10_6, 3_0);
//- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection NS_AVAILABLE(10_6, 3_0);
//- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite NS_AVAILABLE(10_6, 3_0);

//ToDo: update for POST-redirects
//- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response

//ToDo: update for authentication
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
//- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

    - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
#ifdef DEBUG_RESTER
        NSLog(@"%@ didReceiveResponse: %@", connection, response);
#endif
    }

    - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    }

    - (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    }

    - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    }

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

@end


@implementation INRester

    @synthesize userAgent = _userAgent;
    @synthesize referer = _referer;

    - (id)init {
        self = [super init];
        if (self) {
            _queue = [[NSOperationQueue alloc] init];
            if (INSystemVersionEqualsOrGreater(4, 0, 0)) {
                [_queue setName:@"INRester URLConnections Queue"];
            }
            [_queue setMaxConcurrentOperationCount:3];
            [_queue setSuspended:NO];

            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            if (INSystemVersionEqualsOrGreater(4, 0, 0)) {
                [center addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
                [center addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            }

            _timeout = 15;
        }

        return self;
    }

    - (void)clearCookies {
        [_cookies release];
        _cookies = nil;
    }

    - (void)applicationWillEnterForeground:(NSNotification *)aNotification {
        [_queue setSuspended:NO];
    }

    - (void)applicationDidEnterBackground:(NSNotification *)aNotification {
        [_queue setSuspended:YES];
    }

    - (void)startRequest:(INResterBackgroundConnection *)aConnection {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_ACTIVITY_STARTED object:nil];

        NSString *result = [self copyResponseStringForRequest:aConnection.request];
        [aConnection.callback dataWasLoaded:result forRequest:aConnection.request id:aConnection.id];
        [result release];

        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_ACTIVITY_ENDED object:nil];

        [pool drain];

        [aConnection release];
    }

    - (void)processRequestInBackgroundForURL:(NSString *)aURL parameters:(NSDictionary *)aParameters method:(INResterRequestType)aType
                              callbackObject:(NSObject <INResterCallback> *)aCallbackObject callbackId:(NSObject *)aObject {
        NSURLRequest *request = [self createRequestForURL:aURL parameters:aParameters method:aType];

#ifdef DEBUG_RESTER
        NSLog(@"%@", request);
#endif

        INResterBackgroundConnection *backgroundConnection = [[INResterBackgroundConnection createWithConnection:request callback:aCallbackObject id:aObject] retain];

        NSOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(startRequest:) object:backgroundConnection];
        [_queue addOperation:operation];
        [operation release];
    }

    - (NSString *)processRequestForURL:(NSString *)aURL parameters:(NSDictionary *)aParameters method:(INResterRequestType)aType {
        NSURLRequest *request = [self createRequestForURL:aURL parameters:aParameters method:aType];
        return [[self copyResponseStringForRequest:request] autorelease];
    }

    - (void)dealloc {
        [_cookies release];
        [_userAgent release];
        [_referer release];

        [_queue cancelAllOperations];
        [_queue release];

        [super dealloc];
    }

@end
