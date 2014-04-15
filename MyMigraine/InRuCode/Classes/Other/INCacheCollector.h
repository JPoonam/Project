//!
//! @file INCacheCollector.h
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

// Поведение по умолчанию - обход дерева кеша, начиная с пути path, удаление всех просроченных файлов, вложенные папки не удаляются

enum { 
    INCacheCollectOperationDeleteNestedFolders = 1 << 0,
    INCacheCollectOperationDeleteRootFolder    = 1 << 1,
} INCacheCollectOperationOptions;


@interface INCacheCollectOperation : NSOperation {
    NSInteger _overallSize, _restSize;
    NSMutableArray * _targets;
}

- (void)addPath:(NSString *)path options:(NSUInteger)options expirationInterval:(NSTimeInterval)interval; // никакие опции еще не определены

@end

/*

NSOperationQueue * _queue = [NSOperationQueue new];
INCacheCollectOperation * cco = [INCacheCollectOperation new];
cco.queuePriority = NSOperationQueuePriorityVeryLow;
[_queue addOperation:cco];
[cco release];

- (void)dealloc {
    [_queue cancelAllOperations];
    [_queue release];
}

*/
