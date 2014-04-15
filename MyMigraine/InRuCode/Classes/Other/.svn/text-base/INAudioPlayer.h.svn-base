//!
//! @file INAudioPlayer.h
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
#import <AudioToolbox/AudioToolbox.h>
#import "INCommonTypes.h"
#import "INRemoteFile.h"

@class INAudioFile, INAudioPlayer;

typedef enum {
    INAudioFileOperationCompleted,
    INAudioFileOperationIsInProgress,
    INAudioFileOperationFailed
} INAudioFileOperationResult;

//==================================================================================================================================
//==================================================================================================================================

@protocol INAudioFileDelegate <NSObject> 

- (void)audioFile:(INAudioFile *)file didDownloadToSize:(SInt64)size;
- (void)audioFile:(INAudioFile *)file didFailWithError:(NSError *)error;
- (void)audioFile:(INAudioFile *)file remoteFileDidFailDownloadWithError:(NSError *)error;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INAudioFile : NSObject<INRemoteFileDelegate> {
@package
    id<INAudioFileDelegate> _delegate; 
    AudioFileID _audioFileID;
    AudioStreamBasicDescription _streamBasicDescription;
    INRemoteFile * _remoteFile;
    NSError * _lastError;
    UInt32 _maxPacketSize;
    void * _cookie;
    UInt32 _cookieSize;
    AudioChannelLayout * _channelLayout;
    UInt32 _channelLayoutSize;
    UInt64 _lastRequestedFileSize;
    UInt64 _packetCount;
    NSTimeInterval _duration;
    BOOL _closing;
}

- (id)initWithRemoteFile:(INRemoteFile *)remoteFile;
- (INAudioFileOperationResult)open;
- (void)close;

@property(nonatomic,readonly) INRemoteFile * remoteFile;

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum {
    INAudioPlayerIdle,

    INAudioPlayerFileStartPlaying,   
    INAudioPlayerFileWaitingForData, 
    INAudioPlayerFilePlaying,        
    
    INAudioPlayerFileStopping, 
    INAudioPlayerFileStopped,  
    INAudioPlayerFileFatalError,
    INAudioPlayerFileStoppedAtEndOfFile
} INAudioPlayerState;

//==================================================================================================================================
//==================================================================================================================================

@protocol INAudioPlayerDelegate<NSObject> 

- (void)player:(INAudioPlayer *)player didChangeState:(INAudioPlayerState)newState;
- (void)player:(INAudioPlayer *)player didChangePlaybackPosition:(NSTimeInterval)newPosition;
 
@end

//==================================================================================================================================
//==================================================================================================================================

@interface INAudioPlayer : NSObject<INAudioFileDelegate> {
@package
    AudioQueueRef _queue;
    INAudioFile * _file;
    UInt32 _numPacketsToRead,_currentPacket;
    AudioQueueBufferRef * _buffers;
    INAudioPlayerState _state;
    id<INAudioPlayerDelegate> _delegate;
    NSError * _lastError;
    NSTimer * _timeTimer;
    BOOL _primeTheQueueMode, _flagSelfStop;
    OSStatus _bufferCallbackResult;
    NSTimeInterval _currentPlaybackPosition, _queueStartTimePosition;
}

@property(nonatomic,assign)   id<INAudioPlayerDelegate> delegate;
@property(nonatomic,readonly) INAudioPlayerState state;
@property(nonatomic,readonly) NSString * stateAsString; // for debug purposes
@property(nonatomic,readonly) NSError * lastError; 

@property(nonatomic,readonly) NSTimeInterval currentPlaybackPosition;
@property(nonatomic,readonly) NSTimeInterval fullPlaybackTime;

- (void)play:(INAudioFile *)file atPosition:(NSTimeInterval)position;
- (void)stop;

@end
