//! @file INNetResource.h
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

#import <Foundation/Foundation.h>

//==================================================================================================================================
//==================================================================================================================================

@class INNetResource;

/**
 @brief A delegate protocol for \c INNetResource class
    
*/

@protocol INNetResourceDelegate<NSObject>
@optional

//! @brief The network resource has started the loading
-(void)netResource:(INNetResource *)resource didStartLoadWithURL:(NSURL *)anURL;

//! @brief The network resource has completed the loading 
-(void)netResource:(INNetResource *)resource didFinishWithData:(NSData *)data;

//! @brief The network resource got chunk of data (ther can be several chunks during one transfer). Return YES if you want to handle chunk data yourself and do not want the chunk must be appended to the _connectionData collector
-(BOOL)netResource:(INNetResource *)resource didReceiveDataChunk:(NSData *)data;

//! @brief Loading was canceled with the [INNetResource stop] method
-(void)netResourceDidCancel:(INNetResource *)resource;

//! @brief Tells a delegate about network error for recource.
//! Note that NSURLErrorUserCancelledAuthentication error means an authorization failure generally
-(void)netResource:(INNetResource *)resource didFailLoadWithError:(NSError *)anError;

//! @brief Received HTTP url response 
-(void)netResource:(INNetResource *)resource didReceiveHTTPResponse:(NSHTTPURLResponse *)httpResponse;

//! @brief Конец обработки контента (в случае, если назначен contentHandler). 
//         Обратить внимание, что этот метод перекликается с INNetResourceContentHandlerDelegate. Это сделано не от хорошей жизни а по историческим причинам.
//         Если self.delegate == self.contentHandler, то метод вызывается только один раз! В противном случае он вызвается как для делегата, так и для contentHandler (этот вызов будет первым) 
- (void)netResource:(INNetResource *)resource didHandleContentWithResult:(NSError *)error;

@end

//==================================================================================================================================
//==================================================================================================================================

@protocol INManagedNetResource<NSObject>
    
- (void)releaseGracefully;
- (void)loadFromURLString:(NSString *)URLString;

@end

//==================================================================================================================================
//==================================================================================================================================

@protocol INNetResourceInterceptor<NSObject>
@optional

//! @brief The network resource has started the loading
- (NSError *)netInterceptorForResource:(INNetResource *)resource handleStartLoadWithURL:(NSURL *)anURL 
                               request:(NSMutableURLRequest *)request;
 
- (NSHTTPURLResponse *)netInterceptorForResource:(INNetResource *)resource handleHTTPResponse:(NSHTTPURLResponse *)response;
 
//! @brief here you can modify received data (return nil if you don't) or set optional error on bad data content 
- (NSData *)netInterceptorForResource:(INNetResource *)resource  handleData:(NSData *)data setError:(NSError **)error;

- (NSURLRequest *)netInterceptorForResource:(INNetResource *)resource handleRedirect:(NSURLRequest *)redirect
                          redirectResponse:(NSURLResponse *)redirectResponse;

@end


@protocol INNetResourceContentHandlerDelegate
@required

- (void)netResource:(INNetResource *)resource willHandleContent:(NSData *)data;
- (NSError *)netResource:(INNetResource *)resource handleContent:(NSData *)data; // called in thread!
- (void)netResource:(INNetResource *)resource didHandleContentWithResult:(NSError *)error;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A class for accessing different network-based file resources. A NSURLConnection wrapper      
*/

@interface INNetResource : NSObject<INManagedNetResource> {
@private
    NSURLConnection * _connection;
    NSMutableData   * _connectionData;
    BOOL _isFileURL, _flagBusy, _stopping;
	id<INNetResourceDelegate> _delegate;
    NSString * _user, * _password;
    NSURL * _URL;
    NSURLResponse * _lastResponse1;
    BOOL _checkForHTTPStatusCodes;
    id<INNetResourceInterceptor> _interceptor;
    NSData * _receivedData;
    NSMutableURLRequest * _originalURLRequest;
	NSDictionary * _userInfo;
    
    // tags
    NSInteger _tag;
    id _tagObject; 
    
    // content handling 
    id<INNetResourceContentHandlerDelegate> _contentHandler;
    BOOL _contentHandlingIsInProgress;
    NSCondition * _contentHandlingConditionLock;
    
    // cache
    NSTimeInterval _cacheTTL, _cacheTTL2;
    NSString * _cacheFileName;
    BOOL _loadedFromCache;
    NSInteger _loadStage;
    NSString * _cacheSubDirectory;
    
    // network error (полезно, когда cacheTTL2 > 0 и загрузка случилась при ошибке сети из кеша)  
    NSError * _lastError;
          
    // debug. currently works only for thread content handling!  
    NSUInteger _slowNetworkEmulationDelay;
}

+ (id)resource;

//! @brief Begins downloding from the url \c anURL 
- (void)loadFromURL:(NSURL *)anURL;

//! @brief Begins downloding from the url \c anURLString given in the NSString form. Calls [self loadFromURL] 
- (void)loadFromURLString:(NSString *)anURLString;

- (void)loadFromEscapedURLString:(NSString *)anURLString;

//! @brief Cancels all pending downloads and content handlings
- (void)stop;

//! @brief Returns YES if the receiver has been received \c stop call and trying to abort donloading or parsing. Use it at flag to complete all delegate-implemented processing
@property(readonly) BOOL isStopping;

//! @brief Cancels all pending downloads, assign nil to the delegate, calls [self release].
//         Calling just \c release will not stop immediately any pending downloads 
- (void)releaseGracefully; 

//! @brief A delegate 
@property(nonatomic,assign)id<INNetResourceDelegate> delegate;

//! @brief Returns YES for any downloads in progress 
@property(nonatomic,readonly) BOOL busy;

//! @brief A username (login)for accessing the resource 
@property(retain,nonatomic) NSString * user;

//! @brief A password for accessing the resource 
@property(retain,nonatomic) NSString * password;
    
//! @brief URL of the network resource
@property(nonatomic,readonly) NSURL * URL;

//! @brief Just put in the public section for overrriding by INNetXMLResource class. To make a compiler happy!
- (void)resourceDidFinishNetworkLoadingWithData:(NSData *)data;

//! @brief The last response received from the network server. Most usually it is a NSHTTPURLResponse
@property(nonatomic,readonly) NSURLResponse * lastResponse;

//! @brief The data received from the remote side. Valid only inside netResource:didFinishWithData:delegate call.
@property(nonatomic,readonly) NSData * receivedData;

//! @brief Checks if last HTTP (if any) response is a 2XX, or report an error. Default is YES
@property BOOL checkForHTTPStatusCodes;


@property NSInteger tag;

//! @brief Similar to tag, but allows "attach" data to the class. Can be used with interceptor to create POST requests, for instance
@property(nonatomic,retain) id tagObject;

@property(assign,nonatomic) id<INNetResourceInterceptor> interceptor;

@property(assign) id<INNetResourceContentHandlerDelegate> contentHandler; 

@property(readonly) BOOL contentHandlingIsInProgress;

//! @brief For debug purposes - emulates slow network delay (in seconds)
@property(nonatomic) NSUInteger slowNetworkEmulationDelay;

/* 

    Для того, чтобы заработало кеширование нужно указать cacheFileName (сюда можно смело указывать URL) и либо cacheTTL или cacheTTL2 (можно и то и другое)
    
    При работе ресурс смотрит, есть ли уже кешированный файл.
    Если файл есть и он свежее cachTTL секунд, то используется он
    В противном случае идет скачка из инета. Если скачка оборвалась и при этом у нас есть кстарый кеш с старше cacheTTL но моложе cacheTTL2 то используется он

    Таким образом, если указывается и cacheTTL и cacheTTL2, то должно быть cacheTTL < cachTTL2
    
    Опционально можно указать папку cacheSubDirectory, в которой хранится кеш (иначе он хранится в руте стандартного фолдера кеша приложения )
*/

//! @brief Time-To-Live interval (seconds) for unconditional cached data usage (cacheFileName must be set!)
@property(nonatomic) NSTimeInterval cacheTTL;

//! @brief Time-To-Live interval (seconds) for cached data usage when the resource is not available or broken. cacheTTL2 > cachTTL, cacheFileName must be set.
@property(nonatomic) NSTimeInterval cacheTTL2;

@property(nonatomic,readonly) NSError * lastError;

@property(nonatomic,readonly) BOOL loadedFromCache;
@property(retain) NSString * cacheFileName;
@property(retain) NSString * cacheSubDirectory; // подкаталог rootCacheDirectory

@property (nonatomic, retain) NSDictionary *userInfo;

- (void)clearCache;
+ (NSString *)rootCacheDirectory;
+ (void)clearCacheFileWithName:(NSString *)fileName subDirectory:(NSString *)subDirectory;
+ (BOOL)isCacheFileWithNameExists:(NSString *)fileName subDirectory:(NSString *)subDirectory;

@end


