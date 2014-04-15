//!
//! @file INRemoteFile.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2010-2011 InRu
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
#import "INCommonTypes.h"
#import "INNetResource.h"

@class INRemoteFile;

typedef enum { 
    INRemoteFileRequestCompleted,
    INRemoteFileRequestIsInProgress,
    INRemoteFileRequestFatalError
} INRemoteFileRequestResult;

//==================================================================================================================================
//==================================================================================================================================

@protocol INRemoteFileDelegate<NSObject> 

- (void)remoteFile:(INRemoteFile *)file didDownloadToSize:(SInt64)size;
- (void)remoteFile:(INRemoteFile *)file didFailToDownloadWithError:(NSError *)error;

@optional

- (void)remoteFileDidStartDownloading:(INRemoteFile *)file;
- (void)remoteFileDidFinishDownloading:(INRemoteFile *)file;
- (void)remoteFileDidCancelDownloading:(INRemoteFile *)file;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INRemoteFile : NSObject<INNetResourceDelegate,INNetResourceInterceptor> { 
    NSMutableArray * _delegates;
    NSError * _lastError;
    FILE * _localFile;
    SInt64  _remoteFileSize,_localFileSize;
    NSURL * _URL;
    INNetResource * _netResource;
    NSMutableArray * _chunks;
    BOOL _remoteFileChanged;
    NSInteger _serverHTTPStatusErrorCode;
    NSInteger _tag;
    NSString * _cacheFileName;
    
    void * _buffer;
    SInt64 _bufferSize;
    SInt64 _bufferFilled;
    SInt64 _bufferOffset;
}

@property(nonatomic) NSInteger tag;
@property(nonatomic,retain) NSURL * URL;
@property(nonatomic,retain) NSString * cacheFileName; // assign it before URL!

@property(nonatomic,readonly) SInt64 localFileSize;
@property(nonatomic,readonly) SInt64 remoteFileSize; // return as-is. negative values for 'unknown'

@property(nonatomic,readonly) BOOL fullyAvailable;

@property(nonatomic,readonly) NSError * lastError;

- (INRemoteFileRequestResult)requestBytes:(void *)buffer offset:(SInt64)offset length:(UInt32 *)length;
- (INRemoteFileRequestResult)requestRemoteFileSize:(SInt64*)fileSize; // initiate downloading if size is not known

- (void)download;
- (void)stopDownload;
@property(nonatomic,readonly) BOOL isDownloading;

- (void)addDelegate:(id<INRemoteFileDelegate>) delegate;
- (void)removeDelegate:(id<INRemoteFileDelegate>) delegate;

@end
