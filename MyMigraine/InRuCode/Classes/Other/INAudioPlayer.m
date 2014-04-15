//!
//! @file INAudioPlayer.m
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

#import "INAudioPlayer.h"

// #define AUDIO_DEBUG 1

#define INAudioPlayerBuffersCount 3

enum {
    kDownloadIsInProgressError = 'y988', // от балды
    kEofAtEndPrimeFillingError = 'y989',
    kDownloadFailed            = 'y990'
};

//----------------------------------------------------------------------------------------------------------------------------------

static NSError * _CheckOSStatus(OSStatus status, NSString * message) { 
    NSError * error = nil;
    if (status) { 
        message = [NSString stringWithFormat:@"%@: error code 0x%x ('%@')", message, status, INFourByteNumberToString(status)];
        NSDictionary * dict = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:dict];
    }
    return error;
}



//==================================================================================================================================
//==================================================================================================================================

@interface NSError (INRU_AUDIO)
 
- (BOOL)inru_audio_isInProgressError;

@end

//==================================================================================================================================

@implementation NSError (INRU_AUDIO)

- (BOOL)inru_audio_isInProgressError { 
    return [self.domain isEqualToString:NSOSStatusErrorDomain] && (self.code == kDownloadIsInProgressError);
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INAudioFile ()

@property(nonatomic,readonly) AudioFileID audioFileID;
@property(nonatomic,assign) id<INAudioFileDelegate> delegate;
@property(nonatomic,readonly) BOOL fileOpened;
@property(nonatomic,readonly) NSError * lastError;
@property(nonatomic,readonly) AudioStreamBasicDescription streamBasicDescription;
@property(nonatomic,readonly) UInt32 maxPacketSize;
@property(nonatomic,readonly) BOOL isVBR;

@property(nonatomic,readonly) UInt64 lastRequestedFileSize;
@property(nonatomic,readonly) NSTimeInterval duration;

- (void *)getMagicCookie:(UInt32 *)cookieLength;
- (AudioChannelLayout *)getChannelLayout:(UInt32 *)layoutLength;

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INAudioFile

@synthesize delegate = _delegate;
@synthesize lastError = _lastError;
@synthesize streamBasicDescription = _streamBasicDescription;
@synthesize maxPacketSize = _maxPacketSize;
@synthesize audioFileID = _audioFileID;
@synthesize remoteFile = _remoteFile;
@synthesize lastRequestedFileSize = _lastRequestedFileSize;
@synthesize duration = _duration;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithRemoteFile:(INRemoteFile *)remoteFile {
    self = [super init];
    if (self != nil){
        _remoteFile = [remoteFile retain];
        [_remoteFile addDelegate:self];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc { 
    [self close];
    [_remoteFile removeDelegate:self];
    [_remoteFile release];
    [_lastError release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setLastError:(NSError *)error { 
#ifdef AUDIO_DEBUG
    if (error) { 
        NSLog(@"AudioFile: Fatal error %@", error);
    }
#endif 
    [_lastError release];
    _lastError = [error retain];
    [_delegate audioFile:self didFailWithError:error];
}

//----------------------------------------------------------------------------------------------------------------------------------

static OSStatus _ReadFunc(INAudioFile * file, SInt64 inPosition, UInt32 requestCount, void * buffer, UInt32 * actualCount) {

    if (file->_closing) { 
        *actualCount = 0;
        return noErr;
    }
    
    UInt64 offset = inPosition + requestCount;
    if (offset > file->_lastRequestedFileSize) {
        SInt64 remoteFileSize = file.remoteFile.remoteFileSize;
        if (remoteFileSize > offset && file->_streamBasicDescription.mFramesPerPacket && file->_maxPacketSize) {
            SInt64 bytesForBuffer = file->_maxPacketSize * file->_streamBasicDescription.mSampleRate / file->_streamBasicDescription.mFramesPerPacket * 10; // 10 seconds is enought
            offset += bytesForBuffer;
            if (offset > remoteFileSize) { 
               offset = remoteFileSize;
            }
        }
        file->_lastRequestedFileSize = offset;
    }

    UInt32 aCount = requestCount;
    int status = [file->_remoteFile requestBytes:buffer offset:inPosition length:&aCount]; 

    OSStatus  result = kAudioFileNotOpenError; 
    switch (status) { 
        case INRemoteFileRequestCompleted:
            result = noErr;
            break;
            
        case INRemoteFileRequestIsInProgress:
            result = kDownloadIsInProgressError;    
            break;
            
        case INRemoteFileRequestFatalError:
            result = kDownloadFailed; // todo: handle;
            break;
    }
    *actualCount = aCount; 

#ifdef AUDIO_DEBUG 
    // NSLog(@"AudioFile: Reading %d bytes at pos %lld (status %d (%@) returned)",requestCount, inPosition, result, INFourByteNumberToString(result));
#endif 

    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

static SInt64 _GetSizeFunc(INAudioFile * file) {

    if (file->_closing) { 
        return 0;
    }
    
    SInt64 fileSize = 0;
#ifdef AUDIO_DEBUG 
    //int status = 
#endif
    [file->_remoteFile requestRemoteFileSize:&fileSize];

#ifdef AUDIO_DEBUG 
    // NSLog(@"AudioFile: GetSize returned % lld with status %d", fileSize, status);
#endif 

    return fileSize;
}

//----------------------------------------------------------------------------------------------------------------------------------

static OSStatus _WriteFunc(INAudioFile * file, SInt64 inPosition, UInt32 requestCount, const void * buffer, UInt32 * actualCount) {

#ifdef AUDIO_DEBUG 
    NSLog(@"AudioFile: Writing");
#endif 
    return kAudioFilePermissionsError;
}

//----------------------------------------------------------------------------------------------------------------------------------

static OSStatus _SetSizeFunc(INAudioFile * file, SInt64	inSize) {

#ifdef AUDIO_DEBUG  
    NSLog(@"AudioFile: SetSize");
#endif 
    return kAudioFilePermissionsError;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)fileOpened { 
    return _audioFileID != nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isVBR { 
    return _streamBasicDescription.mBytesPerPacket == 0 || _streamBasicDescription.mFramesPerPacket == 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSTimeInterval)sampleToTime:(double)sample { 
    NSTimeInterval result = 0;
    if (_streamBasicDescription.mSampleRate) { 
        result = sample/_streamBasicDescription.mSampleRate;
        if (result < 0) { 
            result = 0;
        }
        if (result > _duration) { 
            result = _duration;
        }
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INAudioFileOperationResult)open {
    if (self.fileOpened) {
        return INAudioFileOperationCompleted;
    }  
    
    _lastRequestedFileSize = 0;

    NSError * result = nil;
    OSStatus status;
    bzero(&_streamBasicDescription,sizeof(_streamBasicDescription));
    
    // open file 
    status = AudioFileOpenWithCallbacks(self,
                                       (AudioFile_ReadProc)_ReadFunc,
                                       (AudioFile_WriteProc)_WriteFunc,
                                       (AudioFile_GetSizeProc)_GetSizeFunc,
                                       (AudioFile_SetSizeProc)_SetSizeFunc,
                                       0,&_audioFileID);
    if (status) {
        result = _CheckOSStatus(status,@"Cannot open audio file");
    }
    
    // get data format
    if (!result) {
        UInt32 size = sizeof(_streamBasicDescription);
        status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyDataFormat, &size, &_streamBasicDescription);
        if (status) { 
            result = _CheckOSStatus(status, @"Could not get audio file's data format");
        }
    }

    // buffer info
    if (!result) { 
	    UInt32 size = sizeof(_maxPacketSize);
	    status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyPacketSizeUpperBound, &size, &_maxPacketSize);
        if (status) { 
            result = _CheckOSStatus(status, @"Could not get max packet size");
        }
    }
    
    // duration 
    if (!result) {
	    UInt32 size = sizeof(_duration);
	    status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyEstimatedDuration, &size, &_duration);
        if (status) { 
            result = _CheckOSStatus(status, @"Could not get audio file duration");
        }
    }
    
    // packet count
    // это делать бесполезно. количество пакетов рассчитывается исходя из фактических данных (меняется в зависимости от скачанности файла.
    // будем работать через 		Float64 numPacketsForTime = inDesc->mSampleRate / inDesc->mFramesPerPacket * inSeconds;
    // if (!result) {
	//    UInt32 size = sizeof(_packetCount);
	//    status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyAudioDataPacketCount, &size, &_packetCount);
    //    if (status) { 
    //        result = _CheckOSStatus(status, @"Could not get audio file packet count");
    //    }
    // }    
    

    // for any errors - close file
    if (result) { 
        [self close];
    }
    
    if ([result inru_audio_isInProgressError]) { 
        return INAudioFileOperationIsInProgress;
    }
    if (result) { 
        [self setLastError:result];
        return INAudioFileOperationFailed;
    }
    return INAudioFileOperationCompleted;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)close {
    if (_audioFileID) {  
        _closing = YES;
        AudioFileClose (_audioFileID);
        _closing = NO;
        _audioFileID = nil;
    }
    if (_cookie) { 
        free(_cookie);
        _cookie = nil;
    }
    if (_channelLayout) { 
        free(_channelLayout);
        _channelLayout = nil;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void *)getMagicCookie:(UInt32 *)cookieLength {
    NSParameterAssert(cookieLength);
    if (!_cookie) { 
	    OSStatus status = AudioFileGetPropertyInfo (_audioFileID, kAudioFilePropertyMagicCookieData, &_cookieSize, NULL);
	    if (!status && _cookieSize) {
		    _cookie = malloc(_cookieSize);		
		    status =  AudioFileGetProperty(_audioFileID, kAudioFilePropertyMagicCookieData, &_cookieSize, _cookie);
            if (status) { 
                free(_cookie);
                _cookie = nil;
            }
        }
    }
    *cookieLength = _cookieSize;
    return _cookie;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (AudioChannelLayout *)getChannelLayout:(UInt32 *)layoutLength {
    NSParameterAssert(layoutLength);
    
    if (!_channelLayout) { 
        OSStatus status = AudioFileGetPropertyInfo(_audioFileID, kAudioFilePropertyChannelLayout, &_channelLayoutSize, NULL);
        if (!status && _channelLayoutSize > 0) {
            _channelLayout = (AudioChannelLayout *)malloc(_channelLayoutSize);
            status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyChannelLayout, &_channelLayoutSize, _channelLayout);
            if (status) { 
                free(_channelLayout);
                _channelLayout = nil;
            }
        }
    }
    *layoutLength = _channelLayoutSize;
    return _channelLayout;
}

//----------------------------------------------------------------------------------------------------------------------------------


- (void)remoteFile:(INRemoteFile *)file didDownloadToSize:(SInt64)size { 
    if (size >= _lastRequestedFileSize) { 
        // NSLog(@"AudioFile: RemoteFile did Download to REQUIRED size: %lld (%lld required)", size, _lastRequestedFileSize);
        [_delegate audioFile:self didDownloadToSize:size];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)remoteFile:(INRemoteFile *)file didFailToDownloadWithError:(NSError *)error {
    // NSLog(@"AudioFile: RemoteFile report download fail");
    // [self setLastError:error];
    [_delegate audioFile:self remoteFileDidFailDownloadWithError:error];
    // закомментировано - файл сбойнул для загрузки но все еще может быть доступен, по крайней мере его часть
}

@end

//==================================================================================================================================
//==================================================================================================================================

#define kBufferDurationSeconds .5

@interface INAudioPlayer()

- (void)setState:(INAudioPlayerState)newState;
- (void)stopInternal;
- (void)releaseFile;

@end

//==================================================================================================================================

@implementation INAudioPlayer

@synthesize delegate = _delegate;
@synthesize state = _state;
@synthesize lastError = _lastError;
@synthesize currentPlaybackPosition = _currentPlaybackPosition;

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        _buffers = malloc(sizeof(AudioQueueBufferRef) *  INAudioPlayerBuffersCount);
        _timeTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2
                                                       target:self
                                                     selector:@selector(timeTimerTriggered:)
                                                     userInfo:nil
                                                      repeats:YES] retain];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)stateAsString {
    NSString * stateMessage = nil;
    
    switch (_state) {
        case INAudioPlayerIdle:  
                stateMessage = @"IDLE";
                break; 
        case INAudioPlayerFileStopping:  
                stateMessage = @"STOPPING...";
                break; 
        case INAudioPlayerFileStopped:  
                stateMessage = @"STOPPED";
                break; 
        case INAudioPlayerFileStoppedAtEndOfFile:
                stateMessage = @"STOPPED AT THE END OF FILE";
                break; 
                
        case INAudioPlayerFileFatalError:  
                stateMessage = @"ERROR";
                break; 
        case INAudioPlayerFileWaitingForData:
                stateMessage = [NSString stringWithFormat:@"WAITING FOR A DATA TO PLAY/OPEN THE FILE... %@", [_file.remoteFile.URL relativeString]];
                break;

        case INAudioPlayerFileStartPlaying:
                stateMessage = @"START PLAYING...";
                break; 
                
        case INAudioPlayerFilePlaying:
                stateMessage = @"PLAYING";
                break; 
        
        /*
        case :  
                stateMessage = @"";
                break; 
        */
        default:
            stateMessage = [NSString stringWithFormat:@"(Unknown state %d",_state];
    }
    return stateMessage;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc { 
    [_timeTimer invalidate];
    [_timeTimer release];
    [self stopInternal];
    [self releaseFile];
     free(_buffers);
    [_lastError release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setLastError:(NSError *)error {
#ifdef AUDIO_DEBUG
    if (error) { 
        NSLog(@"AudioPlayer: Fatal error %@", error);
    }
#endif
    [_lastError release];
    _lastError = [error retain];
    [self setState:INAudioPlayerFileFatalError];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSError *)checkOSStatus:(OSStatus)status message:(NSString *)message {
    NSError * error = _CheckOSStatus(status, message);
    if (error) { 
        [self setLastError:error];
    }
    return error;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setState:(INAudioPlayerState)newState {

    if (newState != _state) { 
        _state = newState;
#ifdef AUDIO_DEBUG 
        NSLog(@"AudioPlayer: STATE %@",self.stateAsString);
#endif
        [_delegate player:self didChangeState:newState];
    } 
}    

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setPlaybackTimeInternal:(NSTimeInterval)newValue { 
    if (newValue != _currentPlaybackPosition) { 
        _currentPlaybackPosition = newValue;
        [_delegate player:self didChangePlaybackPosition:_currentPlaybackPosition];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)timeTimerTriggered:(NSTimer*)theTimer {
    if (_state == INAudioPlayerFilePlaying) { 
        Boolean outTimelineDiscontinuity;
        AudioTimeStamp outTimeStamp;
        // bzero(&outTimeStamp,sizeof(outTimeStamp));
        if (!AudioQueueGetCurrentTime(_queue,nil,&outTimeStamp,&outTimelineDiscontinuity)) {
            NSTimeInterval time = [_file sampleToTime:outTimeStamp.mSampleTime] + _queueStartTimePosition;
            [self setPlaybackTimeInternal:time];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSTimeInterval)fullPlaybackTime { 
    return _file.duration;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)doSelfStop {
    _flagSelfStop = YES; 
    AudioQueueStop(_queue, false);
}

//----------------------------------------------------------------------------------------------------------------------------------


static void _BufferCallback(INAudioPlayer * player, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) {

    BOOL   isFileCompletelyDownloaded = player->_file.remoteFile.fullyAvailable;
	UInt32 numBytes;
	UInt32 nPackets = player->_numPacketsToRead;
	OSStatus result = AudioFileReadPackets(player->_file.audioFileID, false, &numBytes, inCompleteAQBuffer->mPacketDescriptions, 
                                           player->_currentPacket, &nPackets, inCompleteAQBuffer->mAudioData);
    player->_bufferCallbackResult = result;

    //NSLog(@"********* _BufferCallback File_Dnld:%d CurPacket:%d status:%d got %d of %d", isFileCompletelyDownloaded, player->_currentPacket,result,
    //      nPackets,player->_numPacketsToRead);
                   
    if (! result && nPackets == player->_numPacketsToRead) {
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;		
		inCompleteAQBuffer->mPacketDescriptionCount = nPackets;		
		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
		player->_currentPacket += nPackets;
        return;
	}

    
    if (player->_primeTheQueueMode) {
        if (!result && isFileCompletelyDownloaded) { 
            player->_bufferCallbackResult = kEofAtEndPrimeFillingError;
        } else 
        if (!result) { 
            player->_bufferCallbackResult = kDownloadIsInProgressError;
        }
    } else {
        if (!result && isFileCompletelyDownloaded) { 
            [player doSelfStop];
        } else 
        if (result == kDownloadIsInProgressError || (result == 0 && !isFileCompletelyDownloaded)) { 
            [player setState:INAudioPlayerFileWaitingForData];
            AudioQueueStop(inAQ, false);
        } else {
            [player checkOSStatus:result message:@"Could not read packets from audio file"];	
            AudioQueueStop(inAQ, true);
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

static void _CalculateBytesForTime(AudioStreamBasicDescription * inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, 
                                   UInt32 *outBufferSize, UInt32 *outNumPackets) {
	// we only use time here as a guideline
	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
	
	if (inDesc->mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc->mSampleRate / inDesc->mFramesPerPacket * inSeconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	// we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}

//----------------------------------------------------------------------------------------------------------------------------------

static void _IsRunningListener(INAudioPlayer * player, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    // NSLog(@"-------------------- _IsRunningListener ---------------");
	UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &isRunning, &size);
    if (!result && !isRunning && player->_flagSelfStop) { 
        [player setState:INAudioPlayerFileStoppedAtEndOfFile];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)disposeQueue { 
    if (_queue) {
        AudioQueueStop(_queue, true);
        AudioQueueDispose(_queue, true);
        _queue = NULL;
    }
}

- (void)releaseFile { 
    _file.delegate = nil;
   [_file autorelease];
    _file = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stopInternal {
    [self disposeQueue];
    [_file close];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)delayedPlay { 
    [self play:_file atPosition:_currentPlaybackPosition];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stopDelayedPlay { 
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedPlay) object:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stop {
    [self stopDelayedPlay];
     
    if (_queue || _file) {
        [self setState:INAudioPlayerFileStopping];
        //#warning 
        //NSLog(@"stop1");
        [self stopInternal];
        //NSLog(@"stop2");
        [self setState:INAudioPlayerFileStopped];
	}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)audioFile:(INAudioFile *)file didDownloadToSize:(SInt64)size { 
    // NSLog(@"Player: did updated to size %d -------------------------- size", size);
    switch (_state) { 
        case INAudioPlayerFileWaitingForData:
            [self performSelector:@selector(delayedPlay) withObject:nil afterDelay:1.0];  
            break;
            
        default:
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)audioFile:(INAudioFile *)file didFailWithError:(NSError *)error {
    [self setLastError:error];
    [self stopInternal];
}

//----------------------------------------------------------------------------------------------------------------------------------
 
- (void)audioFile:(INAudioFile *)file remoteFileDidFailDownloadWithError:(NSError *)error { 
     // надо обрывать бесконечное ожидание
     if (_state == INAudioPlayerFileWaitingForData) { 
        [self setLastError:error];
        [self stopInternal];    
    }
}

//----------------------------------------------------------------------------------------------------------------------------------


- (void)play:(INAudioFile *)file atPosition:(NSTimeInterval)position { 
    [self stopDelayedPlay];
    NSParameterAssert(file);
    // NSParameterAssert(!file.fileOpened);
    NSParameterAssert(position >= 0);
    
    // NSLog(@"START play from state %d",_state);
    
    [self setState:INAudioPlayerFileStartPlaying];
    
    // stop playback if not yet
    [self stopInternal];
    // assert(_state == INAudioPlayerFileStopped || _state == INAudioPlayerIdle || _state == INAudioPlayerFileStoppedAtEndOfFile);
    
    // saving file reference and set playback position
    // assert(_file == nil);
    if (_file != file) { 
        [self releaseFile];
        _file = [file retain];
        _file.delegate = self;
    }
    
    [self setPlaybackTimeInternal:position];
    
    // opening the file
    switch ([_file open]) { 
        case INAudioFileOperationCompleted:
            // [self setState:INAudioPlayerFileOpened];
            // NSLog(@"AudioPlayer: File Opened");
            break;
            
        case INAudioFileOperationIsInProgress:
            [self setState:INAudioPlayerFileWaitingForData];
            [self stopInternal];
            return;
    
        case INAudioFileOperationFailed:
            [self setLastError:_file.lastError];
            [self stopInternal];
            return;
    }
    
    // file is opened, working with queue
    NSAssert(_file.fileOpened, @"e4b5dd47_ae9c_4db6_a065_d4162ab72cd6");
    NSAssert(_queue == nil, @"153287b0_b59b_4971_ab96_2dd46efda527");
  
    OSStatus status;
    UInt32 size;
	UInt32 bufferByteSize;		
    
    
    //NSURL * url = [NSURL fileURLWithPath:filePath];
    //status = AudioFileOpenURL((CFURLRef)url, kAudioFileReadPermission, 0, &_audioFile);
    //if (status) { 
    //    return [self checkOSStatus:status message:@"Could not open audiofile"];
    //}
    // UInt32 size = sizeof(_dataFormat);
	//status = AudioFileGetProperty(_audioFile, kAudioFilePropertyDataFormat, &size, &_dataFormat);
    //if (status) { 
    //    return [self checkOSStatus:status message:@"Could not get file's data format"];
    //}
    AudioStreamBasicDescription sbd = _file.streamBasicDescription;
    
    status = AudioQueueNewOutput(&sbd, (void *)_BufferCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
    if (status && status != kDownloadIsInProgressError) { 
        [self checkOSStatus:status message:@"Could not get create audio queue"];
    }

	// we need to calculate how many packets we read at a time, and how big a buffer we need
	// we base this on the size of the packets in the file and an approximate duration for each buffer
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
	//size = sizeof(maxPacketSize);
	//status = AudioFileGetProperty(_audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
    //if (status) { 
    //    return [self checkOSStatus:status message:@"Could not get file's max packet size"];
    //}

	// adjust buffer size to represent about a half second of audio based on this format
    if (!status) { 
  	    _CalculateBytesForTime(&sbd, _file.maxPacketSize, kBufferDurationSeconds, &bufferByteSize, &_numPacketsToRead);
	}
    
	// (2) If the file has a cookie, we should get it and set it on the AQ
    if (!status ) {
        void * cookie = [_file getMagicCookie:&size];
        if (cookie) {
            status = AudioQueueSetProperty(_queue, kAudioQueueProperty_MagicCookie, cookie, size);
            if (status) { 
                [self checkOSStatus:status message:@"Could not pass magic cookie"];
            }    
        }
    }
    
	// channel layout?
    if (!status) { 
        void * channelLayout = [_file getChannelLayout:&size]; 
        if (channelLayout) { 
            status = AudioQueueSetProperty(_queue, kAudioQueueProperty_ChannelLayout, channelLayout, size);
            if (status  && status != kDownloadIsInProgressError) { 
                [self checkOSStatus:status message:@"Could not pass channel layout"];
            }
        }
    }
	
    if (!status) { 
	    status = AudioQueueAddPropertyListener(_queue, kAudioQueueProperty_IsRunning,(void *)_IsRunningListener, self);
        if (status && status != kDownloadIsInProgressError) { 
            [self checkOSStatus:status message:@"Could not set 'is running' listener"];
        }
    }
    
    // allocate buffers
    if (!status) { 
        BOOL isFormatVBR = _file.isVBR;
        for (int i = 0; i < INAudioPlayerBuffersCount; ++i) {
            status = AudioQueueAllocateBufferWithPacketDescriptions(_queue, bufferByteSize, (isFormatVBR ? _numPacketsToRead : 0), &_buffers[i]);
            if (status  && status != kDownloadIsInProgressError) { 
                [self checkOSStatus:status message:@"AudioQueueAllocateBuffer failed"];
                break;
            }
        }
    }

	// set the volume of the queue
	if (!status) { 
        status = AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, 1.0);
        if (status && status != kDownloadIsInProgressError) { 
             [self checkOSStatus:status message:@"Could not set queue volume"];
        }
    }

    // calculate and assign the start packet
    if (!status) { 
        UInt64 startPacket = sbd.mSampleRate / sbd.mFramesPerPacket * position;
        _currentPacket = startPacket;
    }
  
	// prime the queue with some data before starting
    if (! status ) { 
	    for (int i = 0; i < INAudioPlayerBuffersCount; ++i) {
		    _primeTheQueueMode = YES;    
            _BufferCallback(self, _queue, _buffers[i]);
            status = _bufferCallbackResult;
            if (status) {
                if (status != kDownloadIsInProgressError && status != kEofAtEndPrimeFillingError) {  
                    [self checkOSStatus:status message:@"Could not set queue prime buffers"];
                }
                break;
            }
        }
    }
        
    // Start the queue
    if (!status) {
        _primeTheQueueMode = NO;
        _queueStartTimePosition = position;
        _flagSelfStop = NO;
         
        //  AudioQueuePrime(_queue,INAudioPlayerBuffersCount,0);
        // if (!status) {
            status = AudioQueueStart(_queue, NULL);
        //}
        if (status && status != kDownloadIsInProgressError) { 
             [self checkOSStatus:status message:@"Could not start queue"];
        }
    }
     
    // anylize results 
    if (!status) {
        [self setState:INAudioPlayerFilePlaying];
        
    } else {
        [self stopInternal];
        switch(status) {
            case kDownloadIsInProgressError:
               [self setState:INAudioPlayerFileWaitingForData];
               break;
               
            case kEofAtEndPrimeFillingError:
               [self setState:INAudioPlayerFileStoppedAtEndOfFile];
               break;
            
            default:
                assert(_state == INAudioPlayerFileFatalError); 
        }
    }
    
    // NSLog(@"END play from state %d",_state);
}

@end
