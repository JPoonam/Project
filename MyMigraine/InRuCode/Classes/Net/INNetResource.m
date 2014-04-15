//!
//! @file INNetResource.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! @copyright Copyright © 2010-2011 InRu
//! 
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//! 
//!     http://www.apache.org/licenses/LICENSE-2.0
//! 
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.
//!
//++

#import <unistd.h>
#import "INNetResource.h"
#import "INCommonTypes.h"
#import "INNet.h"

/* 
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
*/


enum {
    LOAD_STAGE_REGULAR,
    LOAD_STAGE_FROM_CACHE,
    LOAD_STAGE_FROM_CACHE2,
    LOAD_STAGE_REGULAR_NOT_TRY_CACHE

};


//==================================================================================================================================
//==================================================================================================================================

@interface INNetResource()

@property(nonatomic,retain) NSMutableData * connectionData;
@property(nonatomic,retain) NSURLConnection * connection;
@property(nonatomic,retain) NSURLResponse * lastResponse1;

- (void)notifyDelegateOfError:(NSError *)error;
- (void)restartLoadingWithStage:(id)object;
- (void)handleContentInThread:(NSData *)data;

@end

//==================================================================================================================================

@implementation INNetResource

@synthesize delegate = _delegate;
@synthesize connectionData = _connectionData;
@synthesize connection = _connection;
@synthesize user = _user;
@synthesize password = _password;
@synthesize URL = _URL;
@synthesize lastResponse1 = _lastResponse1;
@synthesize checkForHTTPStatusCodes = _checkForHTTPStatusCodes;
@synthesize tag = _tag;
@synthesize tagObject = _tagObject;
@synthesize interceptor = _interceptor;
@synthesize receivedData = _receivedData;
@synthesize contentHandler = _contentHandler;
@synthesize contentHandlingIsInProgress = _contentHandlingIsInProgress;
@synthesize isStopping = _stopping;
@synthesize slowNetworkEmulationDelay = _slowNetworkEmulationDelay;
@synthesize cacheTTL = _cacheTTL;
@synthesize cacheTTL2 = _cacheTTL2;
@synthesize cacheFileName = _cacheFileName;
@synthesize loadedFromCache = _loadedFromCache;
@synthesize lastError = _lastError;
@synthesize cacheSubDirectory = _cacheSubDirectory;
@synthesize userInfo = _userInfo;

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)resource { 
    return [[self new] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSURLResponse *)lastResponse { 
    return _lastResponse1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)busy {
    return _flagBusy || _contentHandlingIsInProgress;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
        _checkForHTTPStatusCodes = YES;
        _contentHandlingConditionLock = [NSCondition new];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)cleanConnectionData {
    self.connectionData = nil;
    self.connection = nil;
    self.lastResponse1 = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)releaseGracefully { 
    _delegate = nil;
    [self stop];
    [self release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    _delegate = nil;
    [_originalURLRequest release];
    [_tagObject release];
    [self cleanConnectionData];
    self.user = nil;
    self.password = nil;
    [_URL release];
    [_contentHandlingConditionLock release];
    [_cacheFileName release];
    [_lastError release];
    [_cacheSubDirectory release];
	[_userInfo release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadFromEscapedURLString:(NSString *)anURLString {
    [self loadFromURLString:[anURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadFromURLString:(NSString *)anURLString {
    if (anURLString.length == 0){
        _isFileURL = NO;
        if ([_delegate respondsToSelector:@selector(netResource:didFailLoadWithError:)]){
            NSError * err = [INError errorWithCode:INErrorCodeBadParameter description:@"INNetResource: Empty URL"]; 
            [_delegate netResource:self didFailLoadWithError:err];
        }
        return;
    }
	NSURL * url = [NSURL URLWithString:anURLString];
	[self loadFromURL:url];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)rootCacheDirectory { 
    NSString * cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return cacheFolder;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)cacheDirectoryWithSubDirectory:(NSString *)subDirectory { 
    NSString * result = self.rootCacheDirectory;
    if (subDirectory.length) { 
        result = [result stringByAppendingPathComponent:subDirectory];
    } 
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)localCachePathForFile:(NSString *)fileName subDirectory:(NSString *)subDirectory { 
    NSString * normalizedCacheFile = [fileName inru_normalizeFileName];
    NSString * cacheDirectory = [self.class cacheDirectoryWithSubDirectory:subDirectory];
    return [cacheDirectory stringByAppendingPathComponent:normalizedCacheFile];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)localCachePath { 
    return [self.class localCachePathForFile:_cacheFileName subDirectory:_cacheSubDirectory]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)clearCache {
    // #warning убрать
    // NSLog(@"Cache is cleared"); 
    if (_cacheFileName.length) { 
        [[NSFileManager defaultManager] removeItemAtPath:self.localCachePath error:nil];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------
 
+ (void)clearCacheFileWithName:(NSString *)fileName subDirectory:(NSString *)subDirectory{
    if (fileName.length) {
        NSString * path = [self.class localCachePathForFile:fileName subDirectory:subDirectory]; 
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (BOOL)isCacheFileWithNameExists:(NSString *)fileName subDirectory:(NSString *)subDirectory{
    if (fileName.length) {
        NSString * path = [self.class localCachePathForFile:fileName subDirectory:subDirectory]; 
        return [[NSFileManager defaultManager] fileExistsAtPath:path];
    }
    return NO;
}
    
//----------------------------------------------------------------------------------------------------------------------------------
/*
- (BOOL)cacheDoesNotExistOrOlder:(NSTimeInterval)ttl {
    if (ttl > 0 && _cacheFileName.length) { 
        NSString * path = self.localCachePath;
        NSFileManager * fm = [NSFileManager defaultManager];
        NSDate * modDate = nil;
        if ([fm fileExistsAtPath:path]) { 
            modDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] fileModificationDate];
        }
        if (modDate && ([modDate timeIntervalSinceNow] > -(ttl))) { 
            return NO;
        }
    }
    return YES;
}
*/

- (BOOL)cacheDoesNotExistOrOlder:(NSTimeInterval)ttl {
    if (ttl > 0 && _cacheFileName.length) { 
        NSString * path = self.localCachePath;
        NSFileManager * fm = [NSFileManager defaultManager];
        NSDate * modDate = nil;
        if ([fm fileExistsAtPath:path]) { 
            modDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] fileModificationDate];
        }
        if (modDate) { 
            NSTimeInterval ti = [modDate timeIntervalSinceNow];
            if (ti <= 0 /* может быть косяк, если юзер перевел дату на год вперед и сделал кеш, этот кеш висит год - соответственно проверяем это */ 
                && ti > -(ttl)) { 
                return NO;
            }
        }
    }
    return YES;
}
    
//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadFromURL:(NSURL *)anURL {	
    if (self.busy){
        return;
    }
    _flagBusy = YES;
    
    [_lastError release];
    _lastError = nil;
    
    // remember the url, prepare request 
    [_URL release];
    _URL = [anURL copy]; 
    _isFileURL = !anURL || [anURL isFileURL];
    NSMutableURLRequest * URLRequest = [NSMutableURLRequest requestWithURL:anURL];

    // ask helper
    if (_interceptor){ 
        if ([_interceptor respondsToSelector:@selector(netInterceptorForResource:handleStartLoadWithURL:request:)]){
            NSError * error = [_interceptor netInterceptorForResource:self handleStartLoadWithURL:anURL request:URLRequest];
            if (error){ 
                [self notifyDelegateOfError:error];
                [self cleanConnectionData];   
                return;
            }
        }
    }

    [_originalURLRequest release];
    _originalURLRequest = [URLRequest mutableCopy];
    
    // notify the delegate
    if (_delegate) { 
        if ([_delegate respondsToSelector:@selector(netResource:didStartLoadWithURL:)]){
            [_delegate netResource:self didStartLoadWithURL:anURL];
        }
    }
    
    // check for cache, reroute request if needed
    _loadedFromCache = NO;
    _loadStage = LOAD_STAGE_REGULAR;
    
    if (_cacheFileName.length && (_cacheTTL > 0)) { 
        if ([self cacheDoesNotExistOrOlder:_cacheTTL]) { 
            // load from network
            // NSLog(@"%@ ++ updating cache %@ (%.f seconds old)", anURL.absoluteString, self.localCachePath, -[modDate timeIntervalSinceNow]); 
        } else {
             NSString * path = self.localCachePath;
            [URLRequest setURL:[NSURL fileURLWithPath:path]]; // // load from cache 
            _isFileURL = YES;
            _loadedFromCache = YES;
            _loadStage = LOAD_STAGE_FROM_CACHE;
            // NSLog(@"%@ -- loading from cache %@ (%.f seconds old)", anURL.absoluteString, self.localCachePath, -[modDate timeIntervalSinceNow]); 
        }
    }

    // start connection   
    _connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
    if (!_isFileURL){
        [INNetworkIndicator start];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stop { 
    _stopping  = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartLoadingWithStage:) object:nil];
    if (_flagBusy){
        _flagBusy = NO;
        [_connection cancel];
        if (!_isFileURL){
            [INNetworkIndicator stop];
        }
        if ([_delegate respondsToSelector:@selector(netResourceDidCancel:)]){
            [_delegate netResourceDidCancel:self];
        }
        [self cleanConnectionData];  
    }
    [_contentHandlingConditionLock lock];
    while (_contentHandlingIsInProgress){ 
        if (![_contentHandlingConditionLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]]){ // just in case - exiting even in locking 
            break;    
        }
    }
    [_contentHandlingConditionLock unlock];
    _stopping = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)resourceDidFinishNetworkLoadingWithData:(NSData *)data {
    _receivedData = data;    
    if ([_delegate respondsToSelector:@selector(netResource:didFinishWithData:)]){
        [_delegate netResource:self didFinishWithData:data];
    }
    _receivedData = nil;

    if (_stopping ){ 
        return;    
    }
    
    // save cache
    if (!_loadedFromCache && _cacheFileName.length && ((_cacheTTL > 0) || (_cacheTTL2 > 0))) {
        NSFileManager * fm = [NSFileManager defaultManager];
        [fm createDirectoryAtPath:[self.class cacheDirectoryWithSubDirectory:_cacheSubDirectory] withIntermediateDirectories:YES attributes:nil error:nil]; 
        [data writeToFile:self.localCachePath atomically:YES];
    }
    
    if (_contentHandler) { 
        [_contentHandler netResource:self willHandleContent:data]; 
        _contentHandlingIsInProgress = YES;

        // Spawn a thread to fetch the data so that the UI is not 
        // blocked while the application parses the XML data.
        // IMPORTANT! - Don't access UIKit objects on secondary threads.
        
        [NSThread detachNewThreadSelector:@selector(handleContentInThread:)
                                 toTarget:self 
                               withObject:data];
        // data will be retained by the thread until parseXMLDataInThread:
        // has finished executing, so we no longer need a reference 
        // to it in the main thread.
    }
}

//--------------------------------------------------------------------------------`--------------------------------------------------

- (void)returnResultsToMainThread:(NSError *)error { 
    NSAssert(self.contentHandler, @"7b8d6ee5_cee5_4adc_9604_2a65a201ef63");
    [self.contentHandler netResource:self didHandleContentWithResult:error];
    if (_delegate && (id)_delegate != (id)self.contentHandler) {
        if ([_delegate respondsToSelector:@selector(netResource:didHandleContentWithResult:)]) {
            [_delegate netResource:self didHandleContentWithResult:error];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleContentInThread:(NSData *)data {
    if (INAlertedAssertionHandlerForInternalINLibThreadsEnabled()) {
        INInstallAlertedAssertionHandlerForCurrentThread();
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSParameterAssert(self.contentHandler);
    {
        if (_slowNetworkEmulationDelay){ 
            sleep(_slowNetworkEmulationDelay);
        }
        
        NSError * error = [self.contentHandler netResource:self handleContent:data];
        [self performSelectorOnMainThread:@selector(returnResultsToMainThread:)
                               withObject:error 
                            waitUntilDone:NO];
    }
    [pool release];
    [_contentHandlingConditionLock lock];
    _contentHandlingIsInProgress = NO;
    [_contentHandlingConditionLock signal];
    [_contentHandlingConditionLock unlock];    
}

//----------------------------------------------------------------------------------------------------------------------------------
/******************************* NSURLConnection delegate methods **********************************/
//----------------------------------------------------------------------------------------------------------------------------------

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request 
            redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse && _interceptor) {
        if ([_interceptor respondsToSelector:@selector(netInterceptorForResource:handleRedirect:redirectResponse:)]){   
            NSURLRequest * newRequest = [_interceptor netInterceptorForResource:self handleRedirect:request redirectResponse:redirectResponse];
            if (newRequest) { 
                request = newRequest;
            }
        }
        /*    
    NSLog(@"-------  %@ %@ (%d bytes) redirect %d %@", 
          [request HTTPMethod],
          request, 
          [[request HTTPBody] length], 
          [redirectResponse statusCode],
          [redirectResponse allHeaderFields]);
        */
    }
    return request;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.connectionData = [NSMutableData data];
    self.lastResponse1 = [[response copy] autorelease];
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    
        if (_interceptor){ 
            if ([_interceptor respondsToSelector:@selector(netInterceptorForResource:handleHTTPResponse:)]){
                NSHTTPURLResponse * httpResponseModified = [_interceptor netInterceptorForResource:self handleHTTPResponse:httpResponse];
                if (httpResponseModified){ 
                    httpResponse = httpResponseModified;
                }
            }
        }
        if ([_delegate respondsToSelector:@selector(netResource:didReceiveHTTPResponse:)]){
            [_delegate netResource:self didReceiveHTTPResponse:httpResponse];
        }
    }    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // NSLog(@"----------------------------------- ++ %d", data.length);
    if ([_delegate respondsToSelector:@selector(netResource:didReceiveDataChunk:)]){
        if ([_delegate netResource:self didReceiveDataChunk:data]) { 
            return;
        }
    }
    
    [_connectionData appendData:data];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notifyDelegateOfError:(NSError *)error {
    _flagBusy = NO;
    if ([_delegate respondsToSelector:@selector(netResource:didFailLoadWithError:)]){
        [_delegate netResource:self didFailLoadWithError:error];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)restartLoadingWithStage:(id)object { 
    NSAssert(_flagBusy, @"e371b0ba_67b8_4a40_a6ce_135f03765aef");

    // cleanup connection
    [self cleanConnectionData];
    
    NSMutableURLRequest * r = [[_originalURLRequest mutableCopy] autorelease];
    switch (_loadStage) { 
        case LOAD_STAGE_REGULAR_NOT_TRY_CACHE:
               // no changes, will use original network request
               _loadedFromCache = NO;
               _loadStage = LOAD_STAGE_REGULAR;
               break;
               
        case LOAD_STAGE_FROM_CACHE2:
               // если у нас есть кэш, то попытаемся загрузить с него
               if (_cacheTTL2 > 0 && _cacheFileName.length && ![self cacheDoesNotExistOrOlder:_cacheTTL2]) { 
                   NSString * path = self.localCachePath;
                   [r setURL:[NSURL fileURLWithPath:path]];
                   _loadedFromCache = YES;
                   _loadStage = LOAD_STAGE_FROM_CACHE2;  
               }
               break;
               
        default:
            NSAssert(0, @"9b9e2866_ffd6_4a87_ba35_9f9eba42655e");        
    }
    _connection = [[NSURLConnection alloc] initWithRequest:r delegate:self];
    _isFileURL = [r.URL isFileURL];
    if (!_isFileURL){
        [INNetworkIndicator start];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)startAdditionalRequest:(NSInteger)newStage {
    // #warning убрать
    // NSLog(@"---- new stage %d", newStage); 
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(restartLoadingWithStage:) object:nil];
    _loadStage = newStage;
    [self performSelector:@selector(restartLoadingWithStage:) withObject:nil afterDelay:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (!_isFileURL){
        [INNetworkIndicator stop];
        
        // handling iPod 3.1.3 bug  - it returns POSIX error 22 on nonconnected wifi 
        if (![error inru_networkErrorNoInternet]){ 
            if (!INNetWeAreConnectedToNetwork()){ 
                error = [NSError errorWithDomain:NSURLErrorDomain 
                                            code:NSURLErrorNotConnectedToInternet
                                        userInfo:error.userInfo];
            }
        }
    }
    
    switch (_loadStage) {
        // если у нас сбойнул кеш - допустим, файл битый или еще как - мы его чистим и запускаем повторное сетевое обращение 
        case LOAD_STAGE_FROM_CACHE:
            [self clearCache];
            [self startAdditionalRequest:LOAD_STAGE_REGULAR_NOT_TRY_CACHE];
            return;
                        
        case LOAD_STAGE_REGULAR:
           _lastError = [error retain];
           
           // если у нас есть кэш, то попытаемся загрузить с него
           if (_cacheTTL2 > 0 && _cacheFileName.length && ! [self cacheDoesNotExistOrOlder:_cacheTTL2]) { 
               [self startAdditionalRequest:LOAD_STAGE_FROM_CACHE2];  
               return;
           }
           break;
    }
    // #warning убрать
    // NSLog(@"CLEAR CACHE %@ for %@error",_cacheFileName, error);

    _flagBusy = NO;
    
    [self notifyDelegateOfError:error];
    [self cleanConnectionData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _flagBusy = NO;
    
    if (!_isFileURL){
        [INNetworkIndicator stop];
    }
    
    INError * error = nil;
    if (_checkForHTTPStatusCodes){
        if ([_lastResponse1 isKindOfClass:[NSHTTPURLResponse class]]){ 
            NSHTTPURLResponse * r = (NSHTTPURLResponse *)_lastResponse1;
            if (r.statusCode / 100 != 2) { 
                // NSString * errMessage = [NSString stringWithFormat:@"HTTP server responsed: %d - '%@'",
                //                            r.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:r.statusCode]];
                error = [INError errorWithDomain:INNetErrorDomain 
                                            code:INErrorCodeBadHTTPStatusCode 
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       // errMessage, NSLocalizedDescriptionKey,
                                                       r, INNetErrorHTTPResponseKey,
                                                       nil]];
            }
        }
    }
    
    NSData * data = _connectionData;
    if (!error){ 
        
        // let helper to intercept (and possible modify)data
        if (_interceptor){ 
            if ([_interceptor respondsToSelector:@selector(netInterceptorForResource:handleData:setError:)]){
                NSData * dataModified = [_interceptor netInterceptorForResource:self handleData:data setError:&error];
                if (dataModified){ 
                    data = dataModified;
                }
            }
        }
    }        
    
    if (error){ 
        [self notifyDelegateOfError:error];
    } else {
        [self resourceDidFinishNetworkLoadingWithData:data];
    }
    
    [self cleanConnectionData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)connection:(NSURLConnection *)connection 
        canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

    int previousFailureCount = challenge.previousFailureCount;
    NSURLCredential * proposedCredential = challenge.proposedCredential;
    
    if (previousFailureCount == 0 && proposedCredential == nil && _user && _password) {  
            NSURLCredential * credential = [NSURLCredential credentialWithUser:_user 
                                                                      password:_password  
                                                                   persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    } else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}
  
@end

