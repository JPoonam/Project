//!
//! @file INNetCenter.h
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

#import "INCommonTypes.h"
#import "INObject.h"
#import "INNetXML.h"

typedef enum { 
    INNetQueryIdle,
    INNetQueryRunning,
    INNetQueryCompleted,
    INNetQueryFatalFail,
    INNetQueryRecoverableFail  
} INNetQueryState; 

@class INNetQuery, INNetCenter, INNetResourcePool;

//==================================================================================================================================
//==================================================================================================================================

@protocol INNetQueryContent<NSObject>

@required

- (id<INManagedNetResource>)createNetworkResourceForQuery:(INNetQuery *)query URLString:(NSString **)URLString;
- (void)query:(INNetQuery *)query didFinishWithResource:(id<INManagedNetResource>)resource error:(NSError *)error;
    
@optional

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INNetQuery : INObject<INNetXMLContainerDelegate, INNetResourceDelegate /* not implemented yet , INNetXMLResourceDelegate */> {
@package
    INNetQueryState _state;
    NSDate * _lastExecuted;
    BOOL     _markedForDeletion, _scheduledToUpdateNow, _suspended, _repeatable;
    NSTimeInterval _timeInterval, _recoverableTimeInterval;
    id<INNetQueryContent> _content;
    id<INManagedNetResource> _networkResource; 
    NSInteger _tag, _priority;
    INNetCenter * _netCenter;
    NSDictionary * _userInfo;
}

@property(nonatomic,readonly) INNetQueryState state;
@property(nonatomic,readonly) BOOL markedForDeletion;
@property(nonatomic,readonly) id<INNetQueryContent> content;
@property(nonatomic) NSTimeInterval timeInterval;
@property(nonatomic) NSTimeInterval recoverableTimeInterval;
@property(nonatomic) BOOL repeatable;
@property(nonatomic) NSInteger priority; // highest has most priority. default is 0
@property(nonatomic,readonly)  BOOL suspended;
@property(nonatomic,retain) NSDictionary * userInfo;
@property(nonatomic) NSInteger tag;

- (void)suspend;
- (void)resumeWithImmediateUpdate:(BOOL)updateNow;
- (void)scheduleToUpdateNow;
- (void)remove;
- (void)cancelNetworkOperation;

@end


//==================================================================================================================================
//==================================================================================================================================

@protocol INNetResourcePoolHandler<NSObject>

- (id<INManagedNetResource>)netResourcePool:(INNetResourcePool *)pool createNetworkResourceForTag:(id)tag URLString:(NSString **)URLString;
- (id)netResourcePool:(INNetResourcePool *)pool createResultFromResource:(id<INManagedNetResource>)resource tag:(id)tag error:(NSError **)error;

@end


//==================================================================================================================================
//==================================================================================================================================

@interface INNetCenter : INObject<NSFastEnumeration> {
    NSTimer * _updateTimer;
    int _state;
    NSMutableArray * _queries;
    NSInteger _maxConnectionCount, _currentConnectionCount;
    BOOL _listValid;
    id<INNetResourcePoolHandler> _resourcePoolHandler;
    NSMutableArray * _resourcePools;
}

- (void)start;
- (void)stop;

- (INNetQuery *)addQueryWithContent:(id<INNetQueryContent>)content;
- (INNetQuery *)addQueryWithContent:(id<INNetQueryContent>)content repeatInterval:(NSTimeInterval)interval;
- (void)removeQueryWithContent:(id<INNetQueryContent>)content;
- (void)removeQueryWithContent:(id<INNetQueryContent>)content tag:(NSInteger)tag;

- (INNetQuery *)queryWithContent:(id<INNetQueryContent>)content tag:(NSInteger)tag;
- (INNetQuery *)queryWithContent:(id<INNetQueryContent>)content;
- (INNetQuery *)queryWithTag:(NSInteger)tag;

- (void)scheduleToUpdateAllNow;

@property(nonatomic) NSInteger maxConnectionCount; // 0 is for unlimited (DEFAULT)
@property(nonatomic,readonly) NSInteger currentConnectionCount;

// -------------------------------------------------------------------------------

@property(nonatomic,assign) id<INNetResourcePoolHandler> resourcePoolHandler;

- (INNetResourcePool *)addResourcePoolWithPriority:(NSInteger)priority 
                                    updateInterval:(NSTimeInterval)updateInterval 
                               recoverableInterval:(NSTimeInterval)recoverableInterval 
                                 keepAliveInterval:(NSTimeInterval)keepAliveInterval;
- (void)removeResourcePool:(INNetResourcePool *)pool;

@end

//==================================================================================================================================
//==================================================================================================================================

@protocol INNetResourcePoolSubscriber<NSObject>

- (void)netResourcePool:(INNetResourcePool *)pool didUpdateResourceWithTag:(id)tag resource:(id)resource;

@optional

- (void)netResourcePool:(INNetResourcePool *)pool didFailUpdateResourceWithTag:(id)tag error:(NSError *)error;

@end

// =================================================================================================================================
// =================================================================================================================================

@interface INNetResourcePool : INObject { 
    INNetCenter * _netCenter;
    NSMutableDictionary * _resources;
    NSInteger _priority;
    NSTimeInterval _updateInterval,_recoverableInterval, _keepAliveInterval;
    NSInteger _queryTag;
}

- (id)resourceForTag:(id)tag; 
- (void)subscribe:(id<INNetResourcePoolSubscriber>)subscriber toResourceWithTag:(id)tag;
- (void)unsubscribe:(id<INNetResourcePoolSubscriber>)subscriber fromResourceWithTag:(id)tag;
- (void)unsubscribeAll;

@end

