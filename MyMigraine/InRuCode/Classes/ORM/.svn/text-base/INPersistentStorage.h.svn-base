//!
//! @file INPersistentStorage.h
//!
//! @author Alexander Babaev (alex.babaev@me.com)
//! @version 1.0
//! @date 2010
//! 
//! Copyright 2010 InRu
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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class INPersistentProperty;
@class INPersistentStorage;

#import "INPersistentObject.h"
#import "INdb.h"

#import "INPersistentStorageDelegate.h"

/**
 @brief Main class for a storage.
 
 Usage: alloc-initWithClass, then you can create objects with newObject, get already stored objects by sending getObjectById: message and
 saving/removing objects using addObject/removeObject messages.
 
 It's very important to create INPersistentStorage with specified class before any actions with this class instances. During INPersistentStorage
 creation getters and setters are being created for element class. So, if you create an element object (one instantiated from INPersistentObejct)
 and try to set dynamic property before INPersistentStorage is created, you'll get an exception about "unrecognised selector".
 
 Bulk operations will be added later.
 */
@interface INPersistentStorage : NSObject<NSFastEnumeration> {
@private	
	// need-to-update-data-on-disk flag
	BOOL _needSave;
	
	// this ivar deferes saving of file data until bulk update is not finished.
	BOOL _bulkUpdateInProcess;
	
	//TODO: добавить версионирование
	
	// total current number of objects
	NSUInteger _objectsCount;
	// because I store objects in c-array, I have to reallocate it from time to time. Here current allocated count is stored.
	NSUInteger _objectsReservedCount;
	// size of the single structure that represents object on a disk (this is an object excluding all dynamic properties)
	NSUInteger _objectFilePartSize;
	
	// c-array for storing objects data
	void *_fileObjectsData;
	// db
	INdb *_db;
	
	// class of the storage element
	Class _objectClass;
	// name of the storage, can be used when we've several storages for one class of objects.
	NSString *_storageName;
	
	// "static" object properties (stored in a file)
	NSMutableArray *_fileProperties;
	// "dynamic" object properties (stored in a db)
	NSMutableArray *_dynamicProperties;
	
	// this array is used primarily for fast enumeration and common speedup
	int64_t *_ids;

	// map of objectId to an object bias in a storage memory (_basicObjectData). Used as cache, primary storage for this data is _indexToId array
	NSMutableDictionary *_objectsLookupCache; // id -> object position in _basicObjectData
	// map of fileProperty name to a bias in an object structure (one of stored in _basicObjectData)
	NSMutableDictionary *_objectStructureLookupTable; // field name -> position of object structure start
	
	id<INPersistentStorageDelegate> _delegate;
	id _lastGotObject;
	
	NSMutableDictionary *_objectByIdCache;
}

@property (retain, nonatomic) id<INPersistentStorageDelegate> delegate;

/**
 @brief calls [self initWithClass:aObjectClass andStorageName:
 */
- (id)initWithClass:(Class)aObjectClass;

/**
 @brief initializes storage with data from aObjectClass and aStorageName. 
 
 (Implementation detail: during this pDBrocedure aObjectClass is being modified with custom getters/setters to allow normal 
 access to object structure.
 */
- (id)initWithClass:(Class)aObjectClass storageName:(NSString*)aStorageName delegate:(id<INPersistentStorageDelegate>)aDelegate;

/**
 @brief returns new object of storage class type
 */
- (id)newObject;

/**
 @brief Returns object with specified id.
 */
- (id)objectById:(NSInteger)aId;

/**
 @brief Adds object to a storage. From this time object is persisted. Any change goes to DB or file.
 */
- (void)addObject:(id)anObject;

//! @brief Mimics count method from NSArray.
- (NSUInteger)count;

- (id)objectFromPool;

//! @brief Mimics objectAtIndex: method from NSArray.
- (id)objectAtIndex:(NSUInteger)index;

//! @brief Mimics insertObject:atIndex: method from NSArray.
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;

//! @brief Mimics removeObjectAtIndex: method from NSArray.
- (void)removeObjectAtIndex:(NSUInteger)index;

/**
 Removes object from storage completely. 
 */
- (void)removeObject:(id)anObject;

- (void)removeAllObjects;
- (BOOL)containsObject:(id)anObject;
- (NSUInteger)indexOfObject:(id)anObject;

/**
 Helper method. You can call it to ensure that all data was saved.
 */
- (void)saveFileData;

/**
 If you add multiple objects to a storage, this method before bulk addition and endBulkUpdate after speed up the process.
 */
- (void)beginBulkUpdate;

/**
 If you add multiple objects to a storage, this method after bulk addition and beginBulkUpdate before speed up the process.
 */
- (void)endBulkUpdate;

- (void)beginBulkIndexSearch;
- (void)endBulkIndexSearch;

- (void)cleanMemoryForBackground;
- (void)restoreDataFromBackground;

@end
