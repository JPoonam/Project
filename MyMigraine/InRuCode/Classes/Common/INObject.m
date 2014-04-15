//!
//! @file INObject.m
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

#import "INObject.h"
#import "INCommonTypes.h"

//==================================================================================================================================
//==================================================================================================================================

// @implementation NSObject (INRU)

/*
+ (void)inru_retainArray:(NSObject **)array ofSize:(NSInteger)size { 
    for (NSInteger i = 0; i < size; i++){
        [array[i] retain];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)inru_releaseArray:(NSObject **)array ofSize:(NSInteger)size { 
    for (NSInteger i = 0; i < size; i++){
        NSObject * obj = array[i];
        [obj release];    
    }
}
*/
// @end

//==================================================================================================================================
//==================================================================================================================================

@implementation INObject

@synthesize name = _name;
@synthesize subscriptionNotificationsEnabled = _subscriptionNotificationsEnabled;
@synthesize objectState = _objectState;
@synthesize lastObjectError = _lastObjectError;
@synthesize subscribers = _subscribers123;

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)hasName:(NSString *)name {
   return [NSString inru_string:self.name isEqualTo:name];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)newWithName:(NSString *)name { 
    INObject * result = [self new];     
    result.name = name;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
	self = [super init];
	if (self){
        // 
	}
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

#if !__has_feature(objc_arc)

- (void)dealloc {
    #if defined(INDEBUG_REPORT_DEALLOC)
        #if INDEBUG_REPORT_DEALLOC != 0 
            NSLog(@"{%@} has been deallocated", self);
        #endif 
    #endif
    [_name release];
    [_lastObjectError release];
    [_subscribers123 release];
	[super dealloc];
}

#endif

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)description { 
    return // [NSString stringWithFormat:@"%@ '%@', Retained:%d", [self class], _name, [self retainCount]];
           [NSString stringWithFormat:@"%@%@", [self class], _name ? [NSString stringWithFormat:@" '%@'",_name] :@""];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSComparisonResult)nameCaseInsensitiveCompare:(INObject *)otherNamedObject {
    return [self.name caseInsensitiveCompare:otherNamedObject.name];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setObjectState:(NSInteger)newState {
    if (_objectState != newState) {  
        _objectState = newState;
        [self notifySubscribers];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setObjectStateWithoutNotification:(NSInteger)newState { 
    _objectState = newState;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)notifySubscribers { 
    if (_subscriptionNotificationsEnabled) { 
        for (id s in _subscribers123) {
            if ([s respondsToSelector:@selector(inobjectDidNotify:)]) { 
                [s inobjectDidNotify:self];
            } else {
                #ifndef NS_BLOCK_ASSERTIONS 
                    NSLog(@"%@: subscriber %@ does not implement inobjectDidNotify: method!",self,s);  
                #endif   
            }
        }
    }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)subscribe:(id)subscriber { 
    NSParameterAssert(subscriber);
    if (!_subscribers123) { 
        _subscribers123 = [NSMutableArray inru_nonRetainingArray];
        #if !__has_feature(objc_arc)
            [_subscribers123 retain];
        #endif
    }
    if (![_subscribers123 containsObject:subscriber]) { 
        [_subscribers123 addObject:subscriber];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)unsubscribe:(id)subscriber { 
    NSParameterAssert(subscriber);
    [_subscribers123 removeObject:subscriber];
}
    
@end


//==================================================================================================================================
//==================================================================================================================================

@implementation INObject2

- (id)copyWithZone:(NSZone *)zone { 
    INObject2 * result = [self.class new];
#if !__has_feature(objc_arc)
    result.name = [[self.name copy] autorelease];
#else 
    result.name = [self.name copy];
#endif
    [result addProperties:_properties];
    if (_items) { 
        [(id)result.items addObjectsFromArray:_items]; 
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)mutableCopyWithZone:(NSZone *)zone { 
    INObject2 * result = [self.class new];
    [result addProperties:_properties];
    
#if !__has_feature(objc_arc)
    result.name = [[self.name mutableCopy] autorelease];
#else 
    result.name = [self.name mutableCopy];
#endif
    // properties
    for (id key in _properties) {
        id obj = [_properties objectForKey:key];
        
        if ([obj conformsToProtocol:@protocol(NSMutableCopying)]) { 
            id item = [obj mutableCopy];
            [result setProperty:item forKey:key];
#if !__has_feature(objc_arc)
            [item release];
#endif
        } else
        if ([obj conformsToProtocol:@protocol(NSCopying)]) { 
            id item = [obj copy];
            [result setProperty:item forKey:key];
#if !__has_feature(objc_arc)
            [item release];
#endif
        } else { 
            [result setProperty:obj forKey:key];
        }
    }
    
    // items
    for (id obj in _items) { 
        if ([obj conformsToProtocol:@protocol(NSMutableCopying)]) { 
            id item = [obj mutableCopy];
            [result addItem:item];
#if !__has_feature(objc_arc)
            [item release];
#endif
        } else
        if ([obj conformsToProtocol:@protocol(NSCopying)]) { 
            id item = [obj copy];
            [result addItem:item];
#if !__has_feature(objc_arc)
            [item release];
#endif
        } else { 
            [result addItem:obj];
        }
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

#if !__has_feature(objc_arc)

- (void)dealloc {
    [_items release];
    [_properties release];
    [super dealloc];
}

#endif

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setProperty:(id)property forKey:(id)key {
    if (!property) {
        [(id)self.properties removeObjectForKey:key];
    } else { 
        [(id)self.properties setObject:property forKey:key];
    }    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addProperties:(NSDictionary *)properties {
    if (properties) {  
        [(id)self.properties addEntriesFromDictionary:properties];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeAllProperties { 
    [_properties removeAllObjects];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)propertyForKey:(id)key { 
    if (_properties) { 
        return [_properties objectForKey:key];
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDictionary *)properties { 
    if (!_properties) { 
        _properties = [NSMutableDictionary new];
    }
    return _properties;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSArray *)items { 
    if (!_items) { 
        _items = [NSMutableArray new];
    }
    return _items;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeAllItems { 
    [_items removeAllObjects];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)sortItemsUsingSelector:(SEL)selector { 
    [_items sortUsingSelector:selector];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item { 
    [_items replaceObjectAtIndex:index withObject:item];
}

//----------------------------------------------------------------------------------------------------------------------------------

#if !__has_feature(objc_arc)

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len { 
    return [_items countByEnumeratingWithState:state objects:stackbuf count:len];
}

#else

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [_items countByEnumeratingWithState:state objects:buffer count:len];
}

#endif

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addItem:(id)item { 
    [(id)self.items addObject:item];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)insertItem:(id)item atIndex:(NSUInteger)index { 
    [(id)self.items insertObject:item atIndex:index];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addUniqueItem:(id)item { 
    if (![self containsItem:item]) { 
        [self addItem:item];        
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)containsItem:(id)item { 
    if (_items) { 
        return [_items indexOfObject:item] != NSNotFound;
    }
    return NO;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addItemsFromArray:(NSArray *)array { 
    [(id)self.items addObjectsFromArray:array];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)itemAtIndex:(NSUInteger)index { 
    return [_items objectAtIndex:index];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeItemAtIndex:(NSUInteger)index { 
    return [_items removeObjectAtIndex:index];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSMutableDictionary *)serialize {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithObject:NSStringFromClass(self.class) forKey:@"__class"];
    if (self.name) { 
        [result setObject:self.name forKey:@"__name"];
    }
    if (_properties) { 
        [result setObject:_properties forKey:@"__properties"];
    }
    if (_items) { 
        NSMutableArray * a = [NSMutableArray array];
        for (id item in _items) { 
            if ([item respondsToSelector:@selector(serialize)]) {
                [a addObject:[item serialize]];
            }
        }
        [result setObject:a forKey:@"__items"];
    }
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)deserialize:(NSDictionary *)dictionary { 
    if ([dictionary isKindOfClass:NSDictionary.class]) { 
         NSString * className = [dictionary objectForKey:@"__class"];
         Class c = NSClassFromString(className);
         if ([self isSubclassOfClass:c]) { 
             INObject2 * result = [self newWithName:[dictionary objectForKey:@"__name"]];
             #if !__has_feature(objc_arc)
                 [result autorelease];
             #endif
             NSDictionary * d = [dictionary objectForKey:@"__properties"];
             if ([d isKindOfClass:NSDictionary.class]) { 
                  [result addProperties:d];
             }
             NSArray * a = [dictionary objectForKey:@"__items"];
             if ([a isKindOfClass:NSArray.class]) { 
                 for (NSDictionary * dict in a) { 
                     if ([dict isKindOfClass:NSDictionary.class]) { 
                         NSString * itemClassName = [dict objectForKey:@"__class"];
                         INObject2 * item = [ NSClassFromString(itemClassName) deserialize:dict];
                         if (item) { 
                             [result addItem:item]; 
                         }    
                     }
                 }
             }
             return result; 
         }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)hasItems { 
    return [_items count] != 0;
}

@end

