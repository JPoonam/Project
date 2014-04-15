//!
//! @file INRemoteFile.m
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

#import "INRemoteFile.h"
#import <unistd.h>

// #define INREMOTE_DEBUG
#define META_TOTAL_SIZE  @"RemoteFileSize"

//==================================================================================================================================
//==================================================================================================================================

@interface INRemoteFile()

- (void)closeFile;
- (BOOL)openFile;

@end

//==================================================================================================================================

@implementation INRemoteFile

@synthesize tag = _tag;
@synthesize URL = _URL;
@synthesize localFileSize = _localFileSize;
@synthesize lastError = _lastError;
@synthesize remoteFileSize = _remoteFileSize;
@synthesize cacheFileName = _cacheFileName;


//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isDownloading { 
    return _netResource.busy;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
        _delegates = [[NSMutableArray inru_nonRetainingArray] retain];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_netResource releaseGracefully];
    [_lastError release];
    [self closeFile];
    [_URL release];
    [_delegates release];
    [_cacheFileName release];
    free(_buffer);
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setURL:(NSURL *)value { 
    if (value != _URL) { 
       [self closeFile];
       [_URL autorelease];
       _URL = [value retain];
       if (_URL) { 
           [self openFile];
       }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addDelegate:(id<INRemoteFileDelegate>)delegate { 
    if (![_delegates containsObject:delegate]) {
        [_delegates addObject:delegate];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeDelegate:(id<INRemoteFileDelegate>)delegate { 
    [_delegates removeObject:delegate];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)canCache { 
   return _URL != nil; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)download { 
    if (!self.isDownloading) { 
        char buffer[1];
        UInt32 length = sizeof(buffer);
        [self requestBytes:buffer offset:_localFileSize + 1 length:&length];     
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stopDownload { 
    [_netResource stop];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)localCacheFile {
    NSAssert(self.canCache,@"760219879102");
    NSString * cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString * cfile = _cacheFileName.length ? _cacheFileName : _URL.absoluteString; 
    return [cacheFolder stringByAppendingPathComponent:cfile.inru_normalizeFileName];
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)localCacheMetaFile {
    return [self.localCacheFile stringByAppendingString:@".metainfo.dict"];
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)saveMetaFile { 
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithLongLong:_remoteFileSize], META_TOTAL_SIZE, nil];
    [dict writeToFile:self.localCacheMetaFile atomically:NO];

}

- (BOOL)fullyAvailable { 
    return _localFileSize > 0 && _localFileSize == _remoteFileSize;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)closeFile {
    [_netResource stop];
    
    if (_localFile) { 
        fflush(_localFile);
        fclose(_localFile);
        _localFile = NULL;
        if (_remoteFileSize >= 0) {
            [self saveMetaFile];
        }
    }  
    _remoteFileSize = -1;
    _localFileSize = 0;
    // reset buffer
    _bufferFilled = 0;
    _bufferOffset = 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void)clearCache {
//   [self closeFile];
//   if (self.canCache) {   
//       [[NSFileManager defaultManager] removeItemAtPath:self.localCacheFile error:nil];
//       [[NSFileManager defaultManager] removeItemAtPath:self.localCacheMetaFile error:nil];
//   }
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setLastError:(NSError *)error { 
    #ifdef INREMOTE_DEBUG
        if (error) { 
            NSLog(@"Remote: Fatal error %@", error);
        }
    #endif 
    [_lastError release];
    _lastError = [error retain];
    for (id<INRemoteFileDelegate> delegate in _delegates) { 
        [delegate remoteFile:self didFailToDownloadWithError:_lastError];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setPOSIXError:(NSString *)explanation { 
    [self setLastError:[NSError errorWithDomain:NSPOSIXErrorDomain 
                                    code:errno userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                              explanation, NSLocalizedDescriptionKey, nil]]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)openFile {
    NSAssert(self.canCache, @"062ec0f7_7134_49c4_8d02_26b8f9429ffc");
    
    if (!_localFile) {
        NSString * localFilePath = self.localCacheFile;
        
        // debug 
        //#warning убрать 
        //truncate(localFilePath.fileSystemRepresentation, 10000);
        
        // open meta
        NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:self.localCacheMetaFile];
        if (dict) { 
            _remoteFileSize = [[dict objectForKey:META_TOTAL_SIZE] longLongValue];
        } else {
            _remoteFileSize = -1;
        }
        
        _localFile = fopen(localFilePath.fileSystemRepresentation,"a+b");
        if (_localFile) {
            _localFileSize = ftello(_localFile);
        }
        
        #ifdef INREMOTE_DEBUG
            NSLog(@"Remote: LocalCache %@ opened (%lld bytes)",localFilePath,_localFileSize); 
        #endif
         
        if (!_localFile || _localFileSize < 0) { 
            _localFileSize = 0;
            [self setPOSIXError:@"Could not create local cache file"];
            return NO;
        }
        
        if (_localFileSize > 0 && _remoteFileSize >=0 && _localFileSize > _remoteFileSize) {
             _remoteFileSize = _localFileSize;  
        }
    }
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INRemoteFileRequestResult)requestBytes:(void *)buffer offset:(SInt64)offset length:(UInt32 *)length {
    NSParameterAssert(offset >= 0);
    NSParameterAssert(buffer);
    NSParameterAssert(length);
    NSAssert(self.canCache,@"45870235723549043");
        
    SInt64 lengthToRead = *length;
    *length = 0;
        
    #ifdef INREMOTE_DEBUG
        NSLog(@"Remote: Request for %lld bytes at offset %lld", lengthToRead, offset); 
    #endif 

    if (lengthToRead == 0) { 
        return INRemoteFileRequestCompleted;
    }
    
    // open/create cache file , if not yet
    if (![self openFile]) { 
        return INRemoteFileRequestFatalError;
    }
    
    NSAssert(_remoteFileSize < 0 || (_localFileSize <= _remoteFileSize),@"43uiutpwtuproitert");
    
    // limit bytes to read if we have remote file info
    if (_remoteFileSize >= 0) { 
        SInt64 offset2 = offset + lengthToRead;
        if (_remoteFileSize < offset2) { 
            lengthToRead -= offset2 - _remoteFileSize;
            assert(lengthToRead >= 0);
            if (lengthToRead <= 0) { 
                return INRemoteFileRequestCompleted;
            }
        }
    }
    
    // return immediately with cached data when we have data in the cache
    if (offset + lengthToRead <= _localFileSize) {
        
        // если нет буфера - выделяем его
        if (!_buffer) { 
            _bufferSize = 512 * 1024;
            _buffer = malloc(_bufferSize);
            _bufferFilled = _bufferOffset = 0;
        }
        
        // если в буфере ничего нет, то прочитаем сначала в буфер
        if (! ((_bufferOffset <= offset) && (offset + lengthToRead <= _bufferOffset + _bufferFilled))) { 
            if (fseeko(_localFile, offset, SEEK_SET) >=0) {
                _bufferFilled = fread(_buffer, 1, _bufferSize, _localFile);
                _bufferOffset = offset;
            // #ifdef INREMOTE_DEBUG
            //   NSLog(@"Remote: (Buffer preloaded with chunk of %lld bytes at offset %lld (requested %lld bytes)", _bufferFilled, offset, lengthToRead); 
            // #endif 
            }
        }
                                        
        // try to get data from buffer
        if (((_bufferOffset <= offset) && (offset + lengthToRead <= _bufferOffset + _bufferFilled))) { 
            memcpy(buffer, (UInt8 *)_buffer + offset - _bufferOffset,lengthToRead);
            *length = lengthToRead; 

            // #ifdef INREMOTE_DEBUG
            //    NSLog(@"Remote: (B) Request for %lld bytes at offset %lld", lengthToRead, offset); 
            // #endif 
           
            return INRemoteFileRequestCompleted;
        }
    
        // вряд ли эта ситуация будет, но все равно:
        // #ifdef INREMOTE_DEBUG
        //    NSLog(@"Remote: Request for %lld bytes at offset %lld", lengthToRead, offset); 
        // #endif 
        
        BOOL success = fseeko(_localFile, offset, SEEK_SET) >= 0;
        if (success) { 
            success =  fread(buffer, 1, lengthToRead, _localFile) == lengthToRead;
        }
        if (!success) { 
            [self setPOSIXError:@"Could not read from local cache file"];
            return INRemoteFileRequestFatalError;
        }
        #ifdef INREMOTE_DEBUG
            NSLog(@"Remote: Returned from the cache"); 
        #endif 
        *length = lengthToRead; 
        return INRemoteFileRequestCompleted;
    }
    
    
    // start network fetching
    // _lastRequestOffset = offset;
    // _lastRequestLength = length;
    
    if (!_netResource.busy) { 
        if (!_netResource) {
            _netResource = [INNetResource new];
            _netResource.delegate = self;
            _netResource.interceptor = self; 
        }
        #ifdef INREMOTE_DEBUG
            NSLog(@"Remote: Starting downloads..."); 
        #endif
        _remoteFileChanged = NO; 
        _serverHTTPStatusErrorCode = 0;
        [_netResource loadFromURL:_URL];
    }
    return INRemoteFileRequestIsInProgress;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INRemoteFileRequestResult)requestRemoteFileSize:(SInt64*)fileSize {
    NSParameterAssert(fileSize);
    
    if (_remoteFileSize >=0) {
        *fileSize = _remoteFileSize;
        return INRemoteFileRequestCompleted;
    }
    
    // experimantal
    if (_localFileSize > 0) {
        *fileSize = _localFileSize;
        return INRemoteFileRequestCompleted;
    }
    
     *fileSize = 0;
    char buffer[1];
    UInt32 length = sizeof(buffer);
    return [self requestBytes:buffer offset:_localFileSize + 1 length:&length];
}

#pragma mark -
#pragma mark INNetResourceDelegate methods

//----------------------------------------------------------------------------------------------------------------------------------

-(BOOL)netResource:(INNetResource *)resource didReceiveDataChunk:(NSData *)data {
    if (_serverHTTPStatusErrorCode || _remoteFileChanged) {
        return YES;
    }
    #ifdef INREMOTE_DEBUG
        NSLog(@"Remote: Did receive data chunk of size %d", data.length); 
    #endif
    NSAssert(_localFile,@"--34578935435345");
    NSUInteger dataLength = data.length;
    BOOL success = fseeko(_localFile, _localFileSize, SEEK_SET) >= 0;
    if (success) { 
        success = fwrite(data.bytes, 1, dataLength, _localFile) == dataLength;
        // #warning убрать 
        // usleep(100 * 1000); 
    }
    if (!success) { 
        [self setPOSIXError:@"Could not write data to local cache file"];
    } else {
        _localFileSize += dataLength;
        if (_remoteFileSize < _localFileSize) { 
            _remoteFileSize = _localFileSize; 
        } 
        #ifdef INREMOTE_DEBUG
            NSLog(@"Remote: Currently %lld of %lld bytes downloaded", _localFileSize, _remoteFileSize); 
        #endif
        for (id<INRemoteFileDelegate> delegate in _delegates) {
            [delegate remoteFile:self didDownloadToSize:_localFileSize];
        }
    }
    return YES;
}

-(void)netResource:(INNetResource *)resource didStartLoadWithURL:(NSURL *)anURL { 
    for (id<INRemoteFileDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(remoteFileDidStartDownloading:)]) {  
            [delegate remoteFileDidStartDownloading:self];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notifyDownloadCompleted { 
    for (id<INRemoteFileDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(remoteFileDidFinishDownloading:)]) {
            [delegate remoteFileDidFinishDownloading:self];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResourceDidCancel:(INNetResource *)resource { 
    for (id<INRemoteFileDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(remoteFileDidCancelDownloading:)]) {
            [delegate remoteFileDidCancelDownloading:self];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResource:(INNetResource *)resource didFailLoadWithError:(NSError *)anError {
    if (_serverHTTPStatusErrorCode == 416) { 
        _remoteFileSize = _localFileSize;
        [self saveMetaFile];
        [self notifyDownloadCompleted];
    } else {  
        [self setLastError:anError];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResource:(INNetResource *)resource didFinishWithData:(NSData *)data {

    #ifdef INREMOTE_DEBUG
        NSLog(@"Remote: Did finish with downloading: the final data size is %lld", _localFileSize); 
    #endif
    if (_remoteFileSize) { 
        [self saveMetaFile];
    }
    fflush(_localFile);
    
    // if remote file is changed (currently we handle only 1 case: remote file content length (as reported  y server) is
    // smaller than local cache size) then we reset all received data - will dwnload file again from beginning
    if (_remoteFileChanged) { 
        // [self clearCache];
        ftruncate(fileno(_localFile),0);
        _localFileSize = 0;
        for (id<INRemoteFileDelegate> delegate in _delegates) {
            [delegate remoteFile:self didDownloadToSize:_localFileSize]; // surprise for delegate: we just has reset to the 0!!!
        }
    }
    
    [self notifyDownloadCompleted];
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResource:(INNetResource *)resource didReceiveHTTPResponse:(NSHTTPURLResponse *)httpResponse {
    #ifdef INREMOTE_DEBUG
        NSLog(@"Remote: didReceiveHTTPResponse: %d (%@): %@ ", httpResponse.statusCode, 
                                                              [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode],
                                                              [httpResponse allHeaderFields]); 
    #endif
   
    // skip processing for server errors
    NSInteger code = httpResponse.statusCode; 
    if (code / 100 != 2) { 
        _serverHTTPStatusErrorCode = code;
        return;
    }

    NSDictionary * dict = [httpResponse allHeaderFields];

    SInt64 cLength = 0;
    
    // check if server returns good resume ranges "Content-Range" = "bytes 12345-60180479/60180480";
    NSString * contentRange = [dict objectForKey:@"Content-Range"];
    if (contentRange.length) { 
        NSRange r = [contentRange rangeOfString:@"/" options:NSBackwardsSearch];
        if (r.location != NSNotFound) { 
            cLength = [[contentRange substringFromIndex:r.location + 1] longLongValue];
        }
    }
    
    // check if server supports resuming
    BOOL resumingSupported = NO;
    {
        NSString * acceptRanges = [dict objectForKey:@"Accept-Ranges"];
        resumingSupported = [acceptRanges isEqualToString:@"bytes"];
        
        // special nginx handling (no Accept-Ranges but has correct contentRange)
        if (!resumingSupported) {
            //NSString * server = [dict objectForKey:@"Server"];
            //resumingSupported = (server.length) && (NSNotFound != [server rangeOfString:@"nginx" options:NSCaseInsensitiveSearch].location);
            resumingSupported = contentRange.length && cLength > 0 && 
                                (NSNotFound != [contentRange rangeOfString:@"bytes" options:NSCaseInsensitiveSearch].location);
        }
    }            
    if (!resumingSupported) { 
        #ifdef INREMOTE_DEBUG
            NSLog(@"Remote: Warning!!! Resuming is not available, will download from beginning");
        #endif
        ftruncate(fileno(_localFile),0);
        _localFileSize = 0;
        _remoteFileSize = -1;
    }
    
    // get content length (if we download it from beginning
    if (cLength <= 0) { 
        NSString * contentLength = [dict objectForKey:@"Content-Length"];
        if (contentLength.length) { 
            cLength = contentLength.longLongValue;
        }
    }
    
    // update total file size
    if (cLength > 0) {
        if (cLength < _remoteFileSize) { 
            _remoteFileChanged = YES;
        }
        _remoteFileSize = cLength;
        [self saveMetaFile];
    }
}
//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark INNetResourceInterceptor methods

- (NSError *)netInterceptorForResource:(INNetResource *)resource handleStartLoadWithURL:(NSURL *)anURL 
                               request:(NSMutableURLRequest *)request { 
    // докачка                           
    if (_localFileSize) { 
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-",_localFileSize] forHTTPHeaderField:@"Range"];
        // NSLog(@"Remote: sending request: %@", [request allHTTPHeaderFields]);
    }
    return nil;
}

@end
