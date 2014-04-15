//!
//! @file INCacheCollector.m
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

#import "INCacheCollector.h"


@implementation INCacheCollectOperation

- (id) init {
    self = [super init];
    if (self != nil) {
        _targets = [NSMutableArray new];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) dealloc {
    [_targets release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

#define OPTIONS           @"options"
#define EXP_INTERVAL      @"expInterval"
#define PATH              @"path"


- (void)addPath:(NSString *)path options:(NSUInteger)options  expirationInterval:(NSTimeInterval)interval { 
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
         path ? path : @"", PATH,
         [NSNumber numberWithInt:options], OPTIONS,
         [NSNumber numberWithDouble:interval], EXP_INTERVAL,
         nil];
    [_targets addObject:dict];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)handlePath:(NSString *)path thresholdDate:(NSDate *)thresholdDate options:(NSUInteger)options level:(NSUInteger)level {
    NSError * err;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * names = [fm contentsOfDirectoryAtPath:path error:&err];
	for (NSString * name in names) {
		if ([self isCancelled]) {
			break;
		}
        NSString * currentPath = [path stringByAppendingPathComponent: name];
		NSDictionary * attributes = [fm attributesOfItemAtPath:currentPath error:&err];
		NSString * fileType = [attributes objectForKey:NSFileType];
		if ([fileType isEqualToString:NSFileTypeRegular] == YES) {
            NSDate * modDate = [attributes objectForKey:NSFileModificationDate];
            NSInteger size = [[attributes objectForKey:NSFileSize] intValue];
            _overallSize += size;
            if ([modDate compare: thresholdDate] == NSOrderedAscending) { 
                [fm removeItemAtPath:currentPath error:&err];
                // NSLog(@"remove file %@",currentPath);
            } else {
                _restSize += size;
            }
		} else 
        if ([fileType isEqualToString:NSFileTypeDirectory] == YES) {
            [self handlePath:currentPath thresholdDate:thresholdDate options:options level:level+1];
        }
	}
    
    BOOL shouldDeleteNonEmptyFolder = NO;
    if (level == 0) { 
        if (options & INCacheCollectOperationDeleteRootFolder) { 
            shouldDeleteNonEmptyFolder = YES;
        }
    } else { 
        if (options & INCacheCollectOperationDeleteNestedFolders) { 
            shouldDeleteNonEmptyFolder = YES;
        }
    }
    if (shouldDeleteNonEmptyFolder) { 
        if ([fm contentsOfDirectoryAtPath:path error:&err].count == 0) {
            [fm removeItemAtPath:path error:&err];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)main {	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // Starting from the Cache folder
    NSString * cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    for (NSDictionary * dict in _targets) {
        if ([self isCancelled]) {
            break;
        }
        NSString * p = [dict objectForKey:PATH];
        NSString * rootFolder;
        if ([p hasPrefix:cacheFolder]) { 
            rootFolder = p;
        } else { 
            rootFolder = [cacheFolder stringByAppendingPathComponent:p];
        }
        NSTimeInterval ti = [[dict objectForKey:EXP_INTERVAL] doubleValue];
        NSUInteger options = [[dict objectForKey:OPTIONS] intValue]; 
        NSDate * thresholdDate = [NSDate dateWithTimeIntervalSinceNow: -ti]; 
        [self handlePath:rootFolder thresholdDate:thresholdDate options:options level:0];
    }
    
    [pool release];
}

//----------------------------------------------------------------------------------------------------------------------------------
@end

