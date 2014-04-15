//!
//! @file INObject.h
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

/*
   useful macros:
      INDEBUG_REPORT_DEALLOC - print deallocation to console
*/ 
 
#import <Foundation/Foundation.h>

/**
 @brief Some useful category extensions for NSObject class 
 
 */
//@interface NSObject (INRU)

//! @brief Retains an array of NSObjectr descendants. No bounds checking are performed!
//+ (void)inru_retainArray:(NSObject **)array ofSize:(NSInteger)size;

//! @brief Realeases an array of NSObjectr descendants. No bounds checking are performed!
//+ (void)inru_releaseArray:(NSObject **)array ofSize:(NSInteger)size;

//@end

@class INObject;

//==================================================================================================================================
//==================================================================================================================================

@protocol INObjectDelegate

@optional

- (void)inobjectDidNotify:(INObject *)object;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
   @brief A simple descendant of NSObject with some useful common features, like names, etc  
    
*/

@interface INObject : NSObject {
@private
    NSString * _name; // todo: если где будет ругаться - использовать self.name вместо _name
    NSInteger _objectState;
    BOOL _subscriptionNotificationsEnabled;
    NSError * _lastObjectError;
    NSMutableArray * _subscribers123;
}

//! @brief The name of object. default is nil
@property(nonatomic,copy) NSString * name;

- (BOOL)hasName:(NSString *)name;

//! @brief Almost the same as [self new] call, but allows to set an object name
+ (id)newWithName:(NSString *)name;

//! @brief Sorting-by-name selector
- (NSComparisonResult)nameCaseInsensitiveCompare:(INObject *)otherNamedObject;

@property(nonatomic,retain) NSError * lastObjectError;
@property(nonatomic) NSInteger objectState;
- (void)setObjectStateWithoutNotification:(NSInteger)newObjectState;

@property(nonatomic) BOOL subscriptionNotificationsEnabled;
@property(nonatomic,readonly) NSArray * subscribers;
- (void)notifySubscribers;
- (void)subscribe:(id)subscriber;
- (void)unsubscribe:(id)subscriber;

@end

//==================================================================================================================================
//==================================================================================================================================

/* 
    Объект поддерживает копирование. NSCopying дает shallow copying, NSMutableCopying делает deep copy (объкты в _items и _properties копируются,
    если они, конечно, поддерживают NSMutableCopying или NSCopying протокол, если нет - то просто передаются по значению 
       При этом объекты в _properties не копируются

*/
@interface INObject2 : INObject<NSFastEnumeration, NSCopying, NSMutableCopying> {
@private
    NSMutableArray * _items;
    NSMutableDictionary * _properties;
}

// _properties создаются при первом обращении к self.properties. Чтобы не создавать лишних структур _всегда_ там, где это требуется лишь _иногда_ – добавлены эти методы 
- (void)addProperties:(NSDictionary *)properties;
- (void)setProperty:(id)property forKey:(id)key;
- (id)propertyForKey:(id)key;
- (void)removeAllProperties;

@property(nonatomic,readonly) NSDictionary * properties;

// _items создаются при первом обращении к self.items. Чтобы не создавать лишних структур _всегда_ там, где это требуется лишь _иногда_ – добавлены эти методы 
- (void)addItem:(id)item;
- (void)insertItem:(id)item atIndex:(NSUInteger)index;
- (void)addUniqueItem:(id)item;
- (void)addItemsFromArray:(NSArray *)array;
- (id)itemAtIndex:(NSUInteger)index;
- (void)removeAllItems;
- (void)removeItemAtIndex:(NSUInteger)index;
- (BOOL)hasItems;
- (void)sortItemsUsingSelector:(SEL)selector;
- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item;
- (BOOL)containsItem:(id)item;

@property(nonatomic,readonly) NSArray * items;  

// 
- (NSMutableDictionary *)serialize;
+ (id)deserialize:(NSDictionary *)dictionary;

@end

