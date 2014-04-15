//!
//! @file INNetCenter.m
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

#import "INNetCenter.h"

#define START_POOL_TAG -1000000

@interface INNetCenter ()

- (void)invalidateQueryList;
- (void)timeSignificallyChanged:(NSNotification *)notification;
- (void)appAbout2Terminate:(NSNotification *)notification;
- (void)appAbout2ChangeActiveStatus:(NSNotification *)notification;
- (void)updateTimerTriggered:(NSTimer*)theTimer;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface _INNetResourcePoolResourceInfo : NSObject<INNetQueryContent> {
@package 
    INNetResourcePool * _pool;
    NSMutableArray * _subscribers;
    id _resource;
    NSError * _lastError;
    id _tag;  
}

@property(nonatomic,retain) id resource;
@property(nonatomic,retain) NSError * lastError;

@end

//==================================================================================================================================
//==================================================================================================================================

// define in project 
// #define IN_NET_CENTER_DEBUG 

@implementation INNetQuery

@synthesize state = _state;
@synthesize markedForDeletion = _markedForDeletion;
@synthesize content = _content;
@synthesize timeInterval = _timeInterval;
@synthesize suspended = _suspended;
@synthesize repeatable = _repeatable;
@synthesize recoverableTimeInterval = _recoverableTimeInterval;
@synthesize tag = _tag;
@synthesize userInfo = _userInfo;
@synthesize priority = _priority;

//----------------------------------------------------------------------------------------------------------------------------------

- (NSComparisonResult)compareByPriorityDesc:(INNetQuery *)otherParty { 
    return INCompareInt(otherParty->_priority,_priority);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setPriority:(NSInteger)value {
    if (value != _priority) { 
        _priority = value; 
        [_netCenter invalidateQueryList];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setTimeInterval:(NSTimeInterval)value { 
     NSAssert(value > 0, @"0fc7da3a_7b3d_4ac3_b67a_b7c7b7371ba9");
    _timeInterval = value;
    _recoverableTimeInterval = value; // mk: поведение не менять!!! если приспичит - устанавливать интервал независимо и ПОСЛЕ основного интервала
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithContent:(id<INNetQueryContent>)content center:(INNetCenter *)center{ 
    self = [super init];
    if (self != nil){
        _content = content;
        _netCenter = center;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)description {
    if ([_content isKindOfClass:_INNetResourcePoolResourceInfo.class]) { 
        _INNetResourcePoolResourceInfo * info = (id)_content;
        return [NSString stringWithFormat:@"%@:%X Pool:%@ Tag:%@ (%d subscribers)", [self class], (unsigned int) self, [info->_pool description],
                                          info->_tag, info->_subscribers.count];    
    }
    return [NSString stringWithFormat:@"%@:%X Priority:%d Tag:%d (%@)", [self class], (unsigned int) self, _priority, _tag, _content ? _content.description :@""];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)releaseNetworkResource { 
    if (_networkResource){ 
       [_networkResource releaseGracefully];
        _networkResource = nil;
    }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)remove { 
    #ifdef IN_NET_CENTER_DEBUG
        NSLog(@"%@:MARKED FOR DELETION", self);
        if (!self.name.length){ 
            self.name = self.description;
        }
    #endif 
    _content = nil;
    _markedForDeletion = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [self releaseNetworkResource];
    [_lastExecuted release];
    [_userInfo release];
    
    #ifdef IN_NET_CENTER_DEBUG
        NSLog(@"%@ (%@):RELEASED", self, self.name);
    #endif 
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)scheduleToUpdateNow {
    // NSAssert(_queryType == INNetQueryRepeatable, @"ad2f3795_dd42_4c34_9b19_4b5c5ffa5610"); 
    _scheduledToUpdateNow = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)suspend { 
    #ifdef IN_NET_CENTER_DEBUG
        if (!_suspended){
            NSLog(@"%@:SUSPENDED", self);
        }
    #endif 
    _suspended = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)resumeWithImmediateUpdate:(BOOL)updateNow { 
    #ifdef IN_NET_CENTER_DEBUG
        if (_suspended){
            NSLog(@"%@:RESUMED", self);
        }
    #endif 
    
    _suspended = NO;
    if (updateNow){ 
        [self scheduleToUpdateNow];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)startQuery {
    NSAssert(_state != INNetQueryRunning, @"8b014a41_9d05_4adb_a2d2_a17becea46b8");
    
    _scheduledToUpdateNow = NO;
    
    // recreate network resources
    [self releaseNetworkResource];
    NSString * urlString = nil;
    _networkResource = [[_content createNetworkResourceForQuery:self URLString:&urlString] retain];
    if (!_networkResource && _suspended){ 
        return;
    }
    if (_markedForDeletion){ 
        return;
    }

    if ([_networkResource isKindOfClass:[INNetXMLContainer class]]){ 
        ((INNetXMLContainer *)_networkResource).delegate = self; 
    } else 
    if ([_networkResource isKindOfClass:[INNetResource class]]){ 
        ((INNetResource *)_networkResource).delegate = self; 
    //} else
    //if ([_networkResource isKindOfClass:[INNetXMLResource class]]){ 
        // NSAssert(0, @"not implemented 1e760429_d513_48fe_81d5_e039f945d831");
    //    ((INNetXMLResource *)_networkResource).delegate = self; 
    } else {
        NSAssert(_networkResource,@"Network resource object is not assigned");
        NSAssert(0, @"01f624db_c151_40ec_9a92_7a3ddb966615 Unsupported network resource for query content object created");
    }
    
    #ifdef IN_NET_CENTER_DEBUG
        NSLog(@"%@:START UPDATE with URL %@", self, urlString);
    #endif 
    _state = INNetQueryRunning;
    [_networkResource loadFromURLString:urlString];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)poll {
    BOOL startNow = NO;
    
    if (_suspended){ 
        return;
    }

    switch (_state){ 
        case INNetQueryIdle:
             startNow = YES;
             break;
             
        case INNetQueryCompleted:
        case INNetQueryRecoverableFail:
            {
               if (_repeatable){
                   if (_scheduledToUpdateNow){ 
                       startNow = YES;
                   } else { 
                       NSTimeInterval interval = (_state == INNetQueryRecoverableFail)? _recoverableTimeInterval :_timeInterval;
                       NSAssert(interval > 0, @"f59b2d79_7abe_471b_992e_4663809881a1");
                       NSDate * dt = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:_lastExecuted] autorelease];  
                       // if ([[_lastExecuted addTimeInterval:interval] compare:[NSDate date]] != NSOrderedDescending){ // deprecated since 4.0 call
                       if ([dt compare:[NSDate date]] != NSOrderedDescending){ 
                           startNow = YES;      
                       }
                   }
               } else 
               ;
               //if (_queryType == INNetQueryOneTime){
               //    NSAssert(_markedForDeletion, @"0810e680_fd11_455f_9553_4c67fef08f92");
               //}
            }
            break;
        default:
            break;
    }
    if (startNow){ 
        [self startQuery];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handleCompletedWithError:(NSError *)error {
    #ifdef IN_NET_CENTER_DEBUG
        NSLog(@"%@:%@ UPDATE %@", self, (error ? @"!!! FAILED !!! " : @"FINISHED"), (error ? error.description : @""));
    #endif 
    if (error){ 
        _state = INNetQueryRecoverableFail; // todo:extend to INNetQueryFatalFail situations
    } else {
        _state = INNetQueryCompleted;
    }
    [_lastExecuted release];
    _lastExecuted = [[NSDate date] retain];
    [_content query:self didFinishWithResource:_networkResource error:error];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)cancelNetworkOperation { 
    if (_networkResource){ 
        [_networkResource retain];
        [_networkResource releaseGracefully];
        NSError * err = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
        [self handleCompletedWithError:err];
        [_networkResource release];
        _networkResource = nil; 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark INNetXMLContainerDelegate

- (void)netxmlContainerDidStartUpdate:(INNetXMLContainer *)container { 
    // nothing yet
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)netxmlContainerDidCancel:(INNetXMLContainer *)container { 
    // nothing yet
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)netxmlContainer:(INNetXMLContainer *)container updateDidFailWithError:(NSError *)error {
    [self handleCompletedWithError:error];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)netxmlContainerDidFinishUpdate:(INNetXMLContainer *)container withChanges:(BOOL)changed { 
    [self handleCompletedWithError:nil];
}

#pragma mark -
#pragma mark INNetResourceDelegate

-(void)netResource:(INNetResource *)resource didFinishWithData:(NSData *)data {
    // if (![resource isKindOfClass:INNetXMLResource.class]) { // у XML окончанием работы будет парсинг
    if (!resource.contentHandler) { 
        [self handleCompletedWithError:nil];    
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResource:(INNetResource *)resource didFailLoadWithError:(NSError *)anError { 
    [self handleCompletedWithError:anError];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)netResource:(INNetResource *)resource didHandleContentWithResult:(NSError *)error { 
    // NSLog(@"--- didHandleContentWithResult %@",resource);
    [self handleCompletedWithError:error];
}

/*
#pragma mark -
#pragma mark INNetXMLResourceDelegate

- (void)xmlResource:(INNetXMLResource *)resource didFailToParseWithError:(NSError *)anError { 
    [self handleCompletedWithError:anError];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)xmlResourceDidFinishParse:(INNetXMLResource *)resource { 
    NSLog(@"--- xmlResourceDidFinishParse %@",resource);
    [self handleCompletedWithError:nil];    
}
*/

@end


//==================================================================================================================================
//==================================================================================================================================

@interface INNetResourcePool()

- (id)initWithNetCenter:(INNetCenter *)center priority:(NSInteger)priority updateInterval:(NSTimeInterval)updateInterval 
                recoverableInterval:(NSTimeInterval)recoverableInterval keepAliveInterval:(NSTimeInterval)keepAliveInterval;

@property(nonatomic,readonly) INNetCenter * netCenter;
@property(nonatomic) NSInteger queryTag;

@end


//==================================================================================================================================
//==================================================================================================================================

enum { 
   STATE_STOPPED, STATE_RUNNING, STATE_PAUSED_ON_DEACTIVATION
};

@implementation INNetCenter 

@synthesize maxConnectionCount = _maxConnectionCount;
@synthesize currentConnectionCount = _currentConnectionCount;
@synthesize resourcePoolHandler = _resourcePoolHandler;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
        self.name = @"INNetCenter";
        _state = STATE_STOPPED;    
        NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(appAbout2ChangeActiveStatus:)
                       name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:self selector:@selector(appAbout2ChangeActiveStatus:)
                       name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(timeSignificallyChanged:)
                       name:UIApplicationSignificantTimeChangeNotification object:nil];
        [center addObserver:self selector:@selector(appAbout2Terminate:)
                       name:UIApplicationWillTerminateNotification object:nil];
        //[center addObserver:self selector:@selector(appAbout2ChangeActiveStatus:)
        //               name:UIApplicationDidEnterBackgroundNotification object:nil];
        _queries = [NSMutableArray new];
        _resourcePools = [NSMutableArray new];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
    [_resourcePools release];
    [_queries release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)start {
    if (_state != STATE_RUNNING){ 
        #ifdef IN_NET_CENTER_DEBUG
            NSLog(@"%@ STARTED", self.name);
        #endif 
        if (!_updateTimer){
            _updateTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2
                                                             target:self
                                                           selector:@selector(updateTimerTriggered:)
                                                           userInfo:nil
                                                            repeats:YES] retain];
        }
        _state = STATE_RUNNING;
    }    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stop { 
    if (_state != STATE_STOPPED){ 
        if (_updateTimer){ 
            [_updateTimer invalidate];
            [_updateTimer release];
            _updateTimer = nil;
        }
        _state = STATE_STOPPED;
        #ifdef IN_NET_CENTER_DEBUG
            NSLog(@"%@ HAS BEEN STOPPED", self.name);
        #endif 
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)scheduleToUpdateAllNow { 
    for (INNetQuery * query in _queries){ 
        if (query.repeatable){ 
            [query scheduleToUpdateNow];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)timeSignificallyChanged:(NSNotification *)notification {
    [self scheduleToUpdateAllNow]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)appAbout2Terminate:(NSNotification *)notification { 
    [self stop];
}

//----------------------------------------------------------------------------------------------------------------------------------


- (void)appAbout2ChangeActiveStatus:(NSNotification *)notification { 
    BOOL willActive = [notification.name isEqualToString:UIApplicationDidBecomeActiveNotification];
    if (willActive){ 
        if (_state == STATE_PAUSED_ON_DEACTIVATION){ 
            [self start];
        }
    } else { 
        if (_state == STATE_RUNNING){
            [self stop];
            _state = STATE_PAUSED_ON_DEACTIVATION;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateTimerTriggered:(NSTimer*)theTimer {
    if (_state != STATE_RUNNING){ 
         return;
    }
  
    // sort by priorities
    if (!_listValid) { 
        _listValid = YES;
#ifdef IN_NET_CENTER_DEBUG
        NSLog(@"%@ Validating list...",self.name);
#endif
        [_queries sortUsingSelector:@selector(compareByPriorityDesc:)];   
    }
  
    BOOL limitConnections = _maxConnectionCount > 0;
    _currentConnectionCount = 0; 
     
    for (int i = _queries.count-1; i >= 0; i--){ 
        INNetQuery * query = [_queries objectAtIndex:i];
        if (query.markedForDeletion){
            [_queries removeObjectAtIndex:i];                
            continue;
        }
        [query poll];
        if (query.state == INNetQueryRunning) { 
            _currentConnectionCount++;
            if (limitConnections && _currentConnectionCount >= _maxConnectionCount) { 
                break;
            }
        }
    }
#ifdef IN_NET_CENTER_DEBUG
    if (_currentConnectionCount) { 
        NSLog(@"%@ Active connections: %d",self.name,_currentConnectionCount);
    }
#endif
}

- (void)invalidateQueryList { 
    _listValid = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INNetQuery *)addQueryWithContent:(id<INNetQueryContent>)content {
    INNetQuery * query = [[INNetQuery alloc] initWithContent:content center:self];
    [_queries addObject:query];
    _listValid = NO;
    [query release];
    return query; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INNetQuery *)addQueryWithContent:(id<INNetQueryContent>)content repeatInterval:(NSTimeInterval)interval {
    INNetQuery * result = [self addQueryWithContent:content];
    result.timeInterval = interval;
    result.repeatable = YES;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INNetQuery *)queryWithContent:(id<INNetQueryContent>)content {
    for (INNetQuery * query in _queries){ 
        if (query.content == content){ 
            return query;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INNetQuery *)queryWithContent:(id<INNetQueryContent>)content tag:(NSInteger)tag {
    for (INNetQuery * query in _queries){ 
        if (query.content == content && query.tag == tag){ 
            return query;
        }
    }
    return nil;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (INNetQuery *)queryWithTag:(NSInteger)tag { 
    for (INNetQuery * query in _queries){ 
        if (query.tag == tag){ 
            return query;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeQueryWithContent:(id<INNetQueryContent>)content tag:(NSInteger)tag { 
    for (INNetQuery * query in _queries){ 
        if (query.tag == tag && query.content == content){ 
            [query remove];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeQueryWithContent:(id<INNetQueryContent>)content {
    for (INNetQuery * query in _queries){ 
        if (query.content == content){ 
            [query remove];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [_queries countByEnumeratingWithState:state objects:stackbuf count:len];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INNetResourcePool *)addResourcePoolWithPriority:(NSInteger)priority updateInterval:(NSTimeInterval)updateInterval 
                               recoverableInterval:(NSTimeInterval)recoverableInterval keepAliveInterval:(NSTimeInterval)keepAliveInterval { 
                               
    INNetResourcePool * pool = [[INNetResourcePool alloc] initWithNetCenter:self priority:priority updateInterval:updateInterval 
                                recoverableInterval:recoverableInterval keepAliveInterval:keepAliveInterval];                       
    [_resourcePools addObject:pool];
    pool.queryTag = START_POOL_TAG - _resourcePools.count;
    [pool release];
    return pool;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeResourcePool:(INNetResourcePool *)pool { 
    [_resourcePools removeObject:pool];
}


@end


//==================================================================================================================================
//==================================================================================================================================

@implementation _INNetResourcePoolResourceInfo

@synthesize resource = _resource;
@synthesize lastError = _lastError;

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        _subscribers = [NSMutableArray new];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [_subscribers release];
    [_resource release];
    [_lastError release];
    [_tag release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notifySubscriber:(id<INNetResourcePoolSubscriber>)subscriber {
    // только если есть хоть какой-то результат
    
    if (_resource) {
        [subscriber netResourcePool:_pool didUpdateResourceWithTag:_tag resource:_resource]; 
    } else
    if (_lastError) { 
        if ([subscriber respondsToSelector:@selector(netResourcePool:didFailUpdateResourceWithTag:error:)]) { 
            [subscriber netResourcePool:_pool didFailUpdateResourceWithTag:_tag error:_lastError];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id<INManagedNetResource>)createNetworkResourceForQuery:(INNetQuery *)query URLString:(NSString **)URLString { 
    NSAssert(_pool.netCenter.resourcePoolHandler, @"5af889a9_ee30_484a_ab09_66f059157142 pool handler is not assigned!");
    NSString * URLString1 = nil;
    id<INManagedNetResource> resource = [_pool.netCenter.resourcePoolHandler netResourcePool:_pool createNetworkResourceForTag:_tag 
                                         URLString:&URLString1];
    NSAssert(resource, @"9a74c639_9ade_4f48_99d1_d086a518ecb0");
    NSAssert(URLString1.length, @"1e74f3f7_3738_41f1_89bd_311269ea733e");
    *URLString = URLString1;
    self.lastError = nil;
    return resource;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)query:(INNetQuery *)query didFinishWithResource:(id<INManagedNetResource>)resource error:(NSError *)error {
    if (error) { 
        self.lastError = error;
    } else {
        NSAssert(_pool.netCenter.resourcePoolHandler, @"5af889a9_ee30_484a_ab09_66f059157142 pool handler is not assigned!");
        NSError * err = nil;
        id result = [_pool.netCenter.resourcePoolHandler netResourcePool:_pool createResultFromResource:resource tag:_tag error:&err];
        NSAssert(result || err, @"0ae41629_cd96_4291_8eea_903c8c8a9f6e");
        self.resource = result;
        self.lastError = err;
    }
    for (id subscriber in _subscribers) { 
        [self notifySubscriber:subscriber];
    }
}
    
@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INNetResourcePool

@synthesize netCenter = _netCenter;
@synthesize queryTag = _queryTag;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNetCenter:(INNetCenter *)center priority:(NSInteger)priority updateInterval:(NSTimeInterval)updateInterval 
            recoverableInterval:(NSTimeInterval)recoverableInterval keepAliveInterval:(NSTimeInterval)keepAliveInterval {
    self = [super init];
    if (self != nil) {
        _netCenter = [center retain];
        _priority = priority;
        _keepAliveInterval = keepAliveInterval;
        _recoverableInterval = recoverableInterval;
        _updateInterval = updateInterval;
        _resources = [NSMutableDictionary new];        
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [self unsubscribeAll];
    [_resources release];
    [_netCenter release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)description { 
    return [NSString stringWithFormat:@"%@<%d>",(self.name ? self.name : @""), START_POOL_TAG - _queryTag];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)resourceForTag:(id)tag { 
    _INNetResourcePoolResourceInfo * info = [_resources objectForKey:tag];
    return info.resource;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)subscribe:(id<INNetResourcePoolSubscriber>)subscriber toResourceWithTag:(id)tag { 
    NSParameterAssert(subscriber);    
    NSParameterAssert(tag);
    
    // get or create resource info
    _INNetResourcePoolResourceInfo * info = [_resources objectForKey:tag];
    if (!info) { 
        info = [_INNetResourcePoolResourceInfo new];
        info->_pool = self;
        info->_tag = [tag retain];
        [_resources setObject:info forKey:tag];
        [info release];
        // q.userInfo = [NSDictionary dictionaryWithObject:tag forKey:@"info"];
    }

    // даже если info уже существует, все равно, запрос может быть удален? так что явно проверяем
    INNetQuery * q = [_netCenter queryWithContent:info];
    if (! q || q.markedForDeletion ) { 
        q = [_netCenter addQueryWithContent:info repeatInterval:_updateInterval];
        q.priority = _priority;
        q.tag = _queryTag;
        q.recoverableTimeInterval = _recoverableInterval;
    }
    
    // add subscriber to the list and notify of results immediately if possible )result is ready or error happened)
    if (![info->_subscribers containsObject:subscriber]) { 
        [info->_subscribers addObject:subscriber];
        [info notifySubscriber:subscriber];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)unsubscribe:(id<INNetResourcePoolSubscriber>)subscriber fromResourceWithTag:(id)tag {
    NSParameterAssert(tag);
    _INNetResourcePoolResourceInfo * info = [_resources objectForKey:tag];
    if (info) { 
        if (subscriber) { 
            [info->_subscribers removeObject:subscriber];
        } else {
            [info->_subscribers removeAllObjects];
        }
        
        // если подписчиков больше не осталось - грохаем запрос. но не сам контент, это сделает netcenter
        if (info->_subscribers.count == 0) {
            [_netCenter removeQueryWithContent:info];
        }    
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)unsubscribeAll { 
    for (id tag in _resources) { 
        [self unsubscribe:nil fromResourceWithTag:tag];        
    }
}

@end

