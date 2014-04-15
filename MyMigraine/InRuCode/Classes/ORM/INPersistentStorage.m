//!
//! @file INPersistentStorage.m
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

#import "INPersistentStorage.h"

#define MAX_STRING_LENGTH_IN_BYTES 128
#define DEBUG_INIT 0

// static BOOL WE_MUST_UPDATE_DATA_TO_ALIGNED = NO;

static NSMutableSet *ALREADY_INSTRUMENTED_CLASSES;

//==================================================================================================================================
//==================================================================================================================================

NSString *getFileInDocumentsPath(NSString *aFileName) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:aFileName];
}

//----------------------------------------------------------------------------------------------------------------------------------

NSString* extractPropertyNameFromSetter(const char *aSetterName) {
    NSString *result = [NSString stringWithCString:aSetterName encoding:NSUTF8StringEncoding];
    
    return [NSString stringWithFormat:@"%@%@",
            [[result substringWithRange:NSMakeRange(3, 1)] lowercaseString], 
            [result substringWithRange:NSMakeRange(4, [result length] - 5)]];
}

//==================================================================================================================================
//==================================================================================================================================

@interface INSelectorWithName : NSObject {
    SEL _selector;
    NSString *_propertyName;
}

- (id)initWithSelector:(SEL)aSelector;

@property (readonly) SEL selector;
@property (readonly) NSString *propertyName;

@end

//==================================================================================================================================

@implementation INSelectorWithName

@synthesize selector = _selector;

- (NSString *)propertyName {
    if (_propertyName == nil) {
        _propertyName = [NSStringFromSelector(_selector) copy];
        if ([_propertyName hasPrefix:@"set"] && [_propertyName hasSuffix:@":"]) {
            _propertyName = [extractPropertyNameFromSetter(sel_getName(_selector)) copy];
        }
    }
    
    return _propertyName;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithSelector:(SEL)aSelector {
    if (self == [super init]) {
        _selector = aSelector;
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isEqualToSelector:(SEL)aSelector {
    return sel_isEqual(aSelector, _selector);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_propertyName release];
    [super dealloc];
}

@end

//==================================================================================================================================

NSString* getPropertyNameBySelector(SEL aSelector) {
    static NSMutableArray *cachedSelectors;
    if (cachedSelectors == nil) {
        cachedSelectors = [[NSMutableArray alloc] init];
    }
    
    for (INSelectorWithName *selectorWithName in cachedSelectors) {
        if ([selectorWithName isEqualToSelector:aSelector]) {
            return selectorWithName.propertyName;
        }
    }
    
    INSelectorWithName *newSelectorWithName = [[[INSelectorWithName alloc] initWithSelector:aSelector] autorelease];
    [cachedSelectors addObject:newSelectorWithName];
    
    return newSelectorWithName.propertyName;
}

//==================================================================================================================================
//==================================================================================================================================

// Types, that are supported by INPersistentStorage.
typedef enum {
    INPersistentPropertyTypeInt = 0,
    INPersistentPropertyTypeDouble = 1,
    INPersistentPropertyTypeString = 2,
    INPersistentPropertyTypeDate = 3,
    INPersistentPropertyTypeBool = 4
} INPersistentPropertyType;

//==================================================================================================================================
//==================================================================================================================================

// Inner struct for holding properties.
@interface INPersistentProperty : NSObject {
    NSString *_name;
    INPersistentPropertyType _type;
}

@property (readonly) NSString *name;
@property (readonly) INPersistentPropertyType type;

+ (id)propertyWithName:(NSString*)aName andType:(INPersistentPropertyType)aType;
- (id)initWithName:(NSString*)aName andType:(INPersistentPropertyType)aType;

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INPersistentProperty

@synthesize name = _name;
@synthesize type = _type;

+ (id)propertyWithName:(NSString*)aName andType:(INPersistentPropertyType)aType {
    return [[[INPersistentProperty alloc] initWithName:aName andType:aType] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithName:(NSString*)aName andType:(INPersistentPropertyType)aType {
    if (self = [super init]) {
        _name = [aName copy];
        _type = aType;
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString*)description {
    return [NSString stringWithFormat:@"%@; type: %d", _name, _type];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_name release];
    [super dealloc];
}

@end // @implementation INPersistentProperty

//==================================================================================================================================
//==================================================================================================================================

@interface INPersistentObject (Private)

@property (assign) int64_t ___id;
@property (readonly) INPersistentStorage *storage;
@property (readonly) NSMutableDictionary *dynamicValues;

- (void)setStorage:(INPersistentStorage*)aStorage;

@end

//==================================================================================================================================

@implementation INPersistentObject (Private)

- (int64_t)___id {
    return ___id;
}

- (void)set___id:(int64_t)aId {
    ___id = aId;
}

- (INPersistentStorage*)storage {
    return _storage;
}

- (NSMutableDictionary*)dynamicValues {
    return _dynamicValues;
}

- (void)setStorage:(INPersistentStorage*)aStorage {
    _storage = aStorage;
}

@end // @implementation INPersistentObject (Private)

//==================================================================================================================================
//==================================================================================================================================

int getDynamicPropertyInt(id self, SEL _cmd);
double getDynamicPropertyDouble(id self, SEL _cmd);
BOOL getDynamicPropertyBool(id self, SEL _cmd);
id getDynamicPropertyId(id self, SEL _cmd);
NSDate* getDynamicPropertyDate(id self, SEL _cmd);

void setDynamicPropertyInt(id self, SEL _cmd, int aValue);
void setDynamicPropertyDouble(id self, SEL _cmd, double aValue);
void setDynamicPropertyBool(id self, SEL _cmd, BOOL aValue);
void setDynamicPropertyId(id self, SEL _cmd, id aValue);

void setFilePropertyInt(id self, SEL _cmd, int aValue);
void setFilePropertyDouble(id self, SEL _cmd, double aValue);
void setFilePropertyBool(id self, SEL _cmd, BOOL aValue);
void setFilePropertyId(id self, SEL _cmd, id aValue);

//==================================================================================================================================
//==================================================================================================================================

@interface INPersistentStorage (Private)

- (Class)objectClass;

- (void)extractClassPropertiesData;

- (void)initAndUpdateDDLInDb;
- (void)loadFileData;

- (BOOL)isPropertyDynamic:(objc_property_t)aProperty;
- (INPersistentPropertyType)getPropertyType:(objc_property_t)aProperty;
- (NSUInteger)getPropertySizeFromAttributes:(objc_property_t)aProperty;
- (INPersistentProperty*)getPropertyNamed:(NSString*)aPropertyName;
- (id)getSQLParameterForProperty:(INPersistentProperty*)aProperty andValue:(id)aValue;

- (id)getDynamicValueForObject:(INPersistentObject*)aObject andProperty:(NSString*)aPropertyName;
- (void)setDynamicValue:(id)aValue forObject:(INPersistentObject*)aObject andProperty:(NSString*)aPropertyName;

- (void)incrementObjectsCounter;

- (id)fillObject:(id)anObject withDataForId:(NSInteger)aId;
- (id)fillObject:(id)anObject withDataPointer:(void*)objectStructPointer;

- (void)fillObject:(INPersistentObject*)anObject property:(INPersistentProperty*)property;
- (void)fillObject:(INPersistentObject*)anObject property:(INPersistentProperty*)property objectPointer:(void*)objectStructPointer;
- (INPersistentProperty*)filePropertyForName:(NSString*)aPropertyName;

- (void)setObject:(INPersistentObject*)anObject atIndex:(NSUInteger)aIndex;
- (void)saveDynamicPropertiesForObject:(INPersistentObject*)anObject;

@end // @interface INPersistentStorage (Private)

//==================================================================================================================================

@implementation INPersistentStorage (Private)

- (Class)objectClass {
    return _objectClass;
}

- (void)extractClassPropertiesData {
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(_objectClass, &propertiesCount);
    
    NSMutableDictionary *propertySizes = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        const char* propertyName = property_getName(property);
        BOOL propertyIsDynamic = [self isPropertyDynamic:property];
        
        if (propertyIsDynamic) {
            [_dynamicProperties addObject:[INPersistentProperty propertyWithName:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding] 
                                                                         andType:[self getPropertyType:property]]];
        } else {
            if (!strcasestr(property_getAttributes(property), "__transient_")) {
                NSUInteger propertySize = [self getPropertySizeFromAttributes:property];
                [_fileProperties addObject:[INPersistentProperty propertyWithName:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding] 
                                                                          andType:[self getPropertyType:property]]];
                
                [propertySizes setObject:[NSNumber numberWithUnsignedInt:propertySize] forKey:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    NSArray *sortedKeys = [[propertySizes allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    int currentStructureSize = 0;
    for (NSString *key in sortedKeys) {
        [_objectStructureLookupTable setObject:[NSNumber numberWithInt:currentStructureSize] forKey:key];
        currentStructureSize += [[propertySizes objectForKey:key] intValue];
    }
    
    _objectFilePartSize = currentStructureSize;
    
    [propertySizes release];
    
    free(properties);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)initAndUpdateDDLInDb {
    _db = [[INdb alloc] initWithDBFileName:[NSString stringWithFormat:@"_in_ps_%@", _storageName]];
    
#if DEBUG_INIT == 1
    NSLog(@"DB opened (%@ / %@)", _objectClass, _storageName);
#endif
    
    id check = [_db getSimpleResult:@"SELECT name FROM sqlite_master WHERE name='object_data'" andParameters:nil];
    if (check == nil && [_dynamicProperties count] != 0) {
        NSMutableString *tableStructure = [[NSMutableString alloc] init];
        
        for (INPersistentProperty *property in _dynamicProperties) {
            if ([tableStructure length] != 0) {
                [tableStructure appendString:@", "];
            }
            
            if (property.type == INPersistentPropertyTypeInt) {
                [tableStructure appendFormat:@"%@ INTEGER", property.name];
            } else if (property.type == INPersistentPropertyTypeDouble) {
                [tableStructure appendFormat:@"%@ DOUBLE", property.name];
            } else if (property.type == INPersistentPropertyTypeBool) {
                [tableStructure appendFormat:@"%@ INTEGER", property.name];
            } else if (property.type == INPersistentPropertyTypeString) {
                [tableStructure appendFormat:@"%@ TEXT", property.name];
            } else if (property.type == INPersistentPropertyTypeDate) {
                [tableStructure appendFormat:@"%@ INTEGER", property.name];
            }
        }
        
        NSString *createTableSQL = [[NSString alloc] initWithFormat:@"CREATE TABLE object_data (id INTEGER PRIMARY KEY ASC AUTOINCREMENT, %@)", tableStructure];
        [_db executeSQL:createTableSQL withParameters:nil];
        [createTableSQL release];
        
        [tableStructure release];
    } else {
        //@todo: проверить, что структура не поменялась
    }
    
#if DEBUG_INIT == 1
    NSLog(@"DDL prepared (%@ / %@)", _objectClass, _storageName);
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadFileData {
    //@todo: тут проверить, что структура не поменялась (по _objectStructureLookupTable)
    
#if DEBUG_INIT == 1
    NSLog(@"Loading started");
#endif
    
    NSArray *fileArray = [[NSArray alloc] initWithContentsOfFile:getFileInDocumentsPath([NSString stringWithFormat:@"_in_ps_data_%@", _storageName])];
    
    if (fileArray != nil) {
        _objectFilePartSize = [[fileArray objectAtIndex:0] intValue];
        
        [_objectStructureLookupTable release];
        _objectStructureLookupTable = [[NSMutableDictionary alloc] initWithDictionary:[fileArray objectAtIndex:1]];
        
        NSData *data = [fileArray objectAtIndex:2];
        if (data != nil) {
            _fileObjectsData = malloc([data length]);
            memcpy(_fileObjectsData, [data bytes], [data length]);
        }
        
        NSData *lookup = [fileArray objectAtIndex:3];
        if (lookup != nil) {
            _ids = malloc([lookup length]);
            memcpy(_ids, [lookup bytes], [lookup length]);
        }
        
        _objectsCount = [data length]/_objectFilePartSize;
        _objectsReservedCount = _objectsCount;
        
        if ([fileArray count] > 4) {
            [_delegate restoreAdditionalDataFromPath:(NSData*)[fileArray objectAtIndex:4]];
        }
    }
    
    [fileArray release];
    
#if DEBUG_INIT == 1
    NSLog(@"Loaded %d objects", _objectsCount);
#endif
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isPropertyDynamic:(objc_property_t)aProperty {
    const char* attributes = property_getAttributes(aProperty);
    return (strstr(attributes, ",D,") != NULL || 
            (attributes[strlen(attributes) - 1] == 'D' && attributes[strlen(attributes) - 2] == ','));
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INPersistentPropertyType)getPropertyType:(objc_property_t)aProperty {
    const char* attributes = property_getAttributes(aProperty);
    
    INPersistentPropertyType result = INPersistentPropertyTypeInt;
    
    if (attributes[1] == '@') {
        if (strstr(attributes, "T@\"NSString\"") != NULL) {
            result = INPersistentPropertyTypeString;
        } else if (strstr(attributes, "T@\"NSDate\"") != NULL) {
            result = INPersistentPropertyTypeDate;
        } else {
            @throw [NSException exceptionWithName:@"Unknown type happened" 
                                           reason:[NSString stringWithFormat:@"Couldn't determine size of type %s", attributes]
                                         userInfo:nil];
        }
    } else if (attributes[1] == 'i' || attributes[1] == 'I') {
        result = INPersistentPropertyTypeInt;
    } else if (attributes[1] == 's' || attributes[1] == 'S') {
        result = INPersistentPropertyTypeInt;
    } else if (attributes[1] == 'c' || attributes[1] == 'C') {
        result = INPersistentPropertyTypeBool;
    } else if (attributes[1] == 'f' || attributes[1] == 'F') {
        result = INPersistentPropertyTypeDouble;
    } else if (attributes[1] == 'd' || attributes[1] == 'D') {
        result = INPersistentPropertyTypeDouble;
    } else {
        @throw [NSException exceptionWithName:@"Unknown type happened" 
                                       reason:[NSString stringWithFormat:@"Couldn't determine persistent type for type %s", attributes]
                                     userInfo:nil];
    }
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)getPropertySizeFromAttributes:(objc_property_t)aProperty {
    const char* attributes = property_getAttributes(aProperty);
    
    NSUInteger result = 0;
    NSInteger align = 0;
    
    if (attributes[1] == '@') {
        if (strstr(attributes, "T@\"NSString\"") != NULL) {
            result = MAX_STRING_LENGTH_IN_BYTES;
        } else if (strstr(attributes, "T@\"NSDate\"") != NULL) {
            result = sizeof (NSTimeInterval);
        } else {
            @throw [NSException exceptionWithName:@"Unknown type happened" 
                                           reason:[NSString stringWithFormat:@"Couldn't determine size of type %s", attributes]
                                         userInfo:nil];
        }
    } else if (attributes[1] == 'i' || attributes[1] == 'I') {
        result = sizeof(int);
        align = __alignof__(int);
    } else if (attributes[1] == 's' || attributes[1] == 'S') {
        result = sizeof(short);
        align = __alignof__(short);
    } else if (attributes[1] == 'c' || attributes[1] == 'C') {
        result = sizeof(char);
        align = __alignof__(char);
    } else if (attributes[1] == 'l' || attributes[1] == 'L') {
        result = sizeof(long);
        align = __alignof__(long);
    } else if (attributes[1] == 'q' || attributes[1] == 'Q') {
        result = sizeof(long long);
        align = __alignof__(long long);
    } else if (attributes[1] == 'f' || attributes[1] == 'F') {
        result = sizeof(float);
        align = __alignof__(float);
    } else if (attributes[1] == 'd' || attributes[1] == 'D') {
        result = sizeof(double);
        align = __alignof__(double);
    } else {
        @throw [NSException exceptionWithName:@"Unknown type happened" 
                                       reason:[NSString stringWithFormat:@"Couldn't determine size of type %s", attributes]
                                     userInfo:nil];
    }
    
    //TODO: do the align
//    align data by 4. 
    
//    if (result % 4 != 0) {
//        result += result % 4;
//        WE_MUST_UPDATE_DATA_TO_ALIGNED = YES;
//    }
//    
//    NSLog(@"%c: %d/%d", attributes[1], result, align);
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INPersistentProperty*)getPropertyNamed:(NSString*)aPropertyName {
    for (INPersistentProperty* property in _dynamicProperties) {
        if ([property.name isEqualToString:aPropertyName]) {
            return property;
        }
    }
    
    for (INPersistentProperty* property in _fileProperties) {
        if ([property.name isEqualToString:aPropertyName]) {
            return property;
        }
    }
    
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)getSQLParameterForProperty:(INPersistentProperty*)aProperty andValue:(id)aValue {
    INSQLParameter *parameter;
    
    if (aProperty.type == INPersistentPropertyTypeInt) {
        parameter = [INSQLParameter intParameter:[(NSNumber*)aValue intValue]];
    } else if (aProperty.type == INPersistentPropertyTypeDouble) {
        parameter = [INSQLParameter doubleParameter:[(NSNumber*)aValue doubleValue]];
    } else if (aProperty.type == INPersistentPropertyTypeBool) {
        parameter = [INSQLParameter boolParameter:[(NSNumber*)aValue boolValue]];
    } else if (aProperty.type == INPersistentPropertyTypeString) {
        parameter = [INSQLParameter stringParameter:(NSString*)aValue];
    } else if (aProperty.type == INPersistentPropertyTypeDate) {
        parameter = [INSQLParameter dateParameter:(NSDate*)aValue];
    } else {
        @throw [NSException exceptionWithName:@"Unknown SQL type" reason:[NSString stringWithFormat:@"Unknown: %d", aProperty.type] userInfo:nil];
    }
    
    return parameter;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)getDynamicValueForObject:(INPersistentObject*)aObject andProperty:(NSString*)aPropertyName {
    id result = [aObject.dynamicValues valueForKey:aPropertyName];
    
    //TODO тут нужно правильно кэшировать значение, а не лезть каждый раз в базу, если значение nil
    if (aObject.___id != -1 && result == nil) {
        if (_db == nil) {
            [self initAndUpdateDDLInDb];
        }
        
        result = [_db getSimpleResult:[NSString stringWithFormat:@"SELECT %@ FROM object_data WHERE id=?", aPropertyName] 
                        andParameters:[NSArray arrayWithObject:[INSQLParameter intParameter:aObject.___id]]];
    }
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setDynamicValue:(id)aValue forObject:(INPersistentObject*)aObject andProperty:(NSString*)aPropertyName {
    [aObject.dynamicValues setValue:aValue forKey:aPropertyName];
    
    if (aObject.___id != -1) {
        INPersistentProperty *property = [self getPropertyNamed:aPropertyName];
        
        NSArray *parameters = [[NSArray alloc] initWithObjects:
                               [self getSQLParameterForProperty:property andValue:aValue], 
                               [INSQLParameter intParameter:aObject.___id], 
                               nil];
        
        if (_db == nil) {
            [self initAndUpdateDDLInDb];
        }
        
        [_db executeSQL:[NSString stringWithFormat:@"UPDATE object_data SET %@=? WHERE id=?", property.name] withParameters:parameters];
        
        [parameters release];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)incrementObjectsCounter {
    if (_objectsReservedCount == _objectsCount) {
        //        NSLog(@"File data size increasing (%@) to %d", _storageName, _objectsReservedCount);
        
        if (_objectsReservedCount == 0) {
            _objectsReservedCount = 100;
        } else {
            _objectsReservedCount *= 1.5;
        }
        
        void *newObjectsData = malloc(_objectFilePartSize*_objectsReservedCount);
        
        if (_fileObjectsData != NULL) {
            memcpy(newObjectsData, _fileObjectsData, _objectsCount*_objectFilePartSize);
            free(_fileObjectsData);
        }
        
        int64_t *newIds = malloc(sizeof(int64_t)*_objectsReservedCount);
        
        if (_ids != NULL) {
            memcpy(newIds, _ids, _objectsCount*sizeof(int64_t));
            free(_ids); 
        }
        
        _ids = newIds;
        _fileObjectsData = newObjectsData;
        
        //        NSLog(@"File data size increased succesfully (%@) to %d", _storageName, _objectsReservedCount);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)fillObject:(id)anObject withDataForId:(NSInteger)aId {
    ((INPersistentObject*)anObject).___id = aId;
    
    NSInteger bias = 0;
    
    NSNumber *biasCache = [_objectsLookupCache objectForKey:[NSNumber numberWithInt:aId]];
    if (biasCache == nil) {
        for (int i = 0; i < _objectsCount; i++) {
            if (_ids[i] == aId) {
                bias = i*_objectFilePartSize;
                [_objectsLookupCache setObject:[NSNumber numberWithInt:bias] forKey:[NSNumber numberWithInt:aId]];
            }
        }
    } else {
        bias = [biasCache intValue];
    }
    
    void *objectStructPointer = _fileObjectsData + bias;
    
    return [self fillObject:anObject withDataPointer:objectStructPointer];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)fillObject:(id)anObject withDataPointer:(void*)objectStructPointer {
    INPersistentStorage *savedStorage = ((INPersistentObject*) anObject).storage;
    ((INPersistentObject*) anObject).storage = nil;
    
    for (INPersistentProperty *property in _fileProperties) {
        int valueBias = [[_objectStructureLookupTable objectForKey:property.name] intValue];
        
        if (property.type == INPersistentPropertyTypeInt) {
            int value = 0;
            memcpy(&value, objectStructPointer + valueBias, sizeof(int));
            void (*setter)(id, SEL, int);
            SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                                       [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                                       [property.name substringFromIndex:1]]);
            setter = (void (*)(id, SEL, int))[anObject methodForSelector:setterSelector];
            setter(anObject, setterSelector, value);
        } else if (property.type == INPersistentPropertyTypeDouble) {
            double value = 0;
            memcpy(&value, objectStructPointer + valueBias, sizeof(double));
            void (*setter)(id, SEL, double);
            SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                                       [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                                       [property.name substringFromIndex:1]]);
            setter = (void (*)(id, SEL, double))[anObject methodForSelector:setterSelector];
            setter(anObject, setterSelector, value);
        } else if (property.type == INPersistentPropertyTypeBool) {
            BOOL value = 0;
            memcpy(&value, objectStructPointer + valueBias, sizeof(BOOL));
            void (*setter)(id, SEL, BOOL);
            SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                                       [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                                       [property.name substringFromIndex:1]]);
            setter = (void (*)(id, SEL, BOOL))[anObject methodForSelector:setterSelector];
            setter(anObject, setterSelector, value);
        } else if (property.type == INPersistentPropertyTypeString) {
            const char* value = (char*)(objectStructPointer + valueBias);
            void (*setter)(id, SEL, id);
            SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                                       [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                                       [property.name substringFromIndex:1]]);
            setter = (void (*)(id, SEL, id))[anObject methodForSelector:setterSelector];
            setter(anObject, setterSelector, [NSString stringWithCString:value encoding:NSUTF8StringEncoding]);
        } else if (property.type == INPersistentPropertyTypeDate) {
            double value = 0;
            memcpy(&value, objectStructPointer + valueBias, sizeof(double));
            void (*setter)(id, SEL, id);
            SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", 
                                                       [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                                       [property.name substringFromIndex:1]]);
            setter = (void (*)(id, SEL, id))[anObject methodForSelector:setterSelector];
            setter(anObject, setterSelector, [NSDate dateWithTimeIntervalSince1970:value]);
        } 
    }
    
    ((INPersistentObject*) anObject).storage = savedStorage;
    
    return anObject;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)fillObject:(INPersistentObject*)anObject property:(INPersistentProperty*)property {
    int objectIndex = -1;
    for (int i = 0; i < _objectsCount; i++) {
        if (anObject.___id == _ids[i]) {
            objectIndex = i;
            break;
        }
    }
    
    if (objectIndex == -1) {
        @throw [NSException exceptionWithName:@"Error during fill object property" reason:@"Object id was not found in _ids" userInfo:nil];
    }
    
    int bias = objectIndex*_objectFilePartSize;
    uint8_t *objectStructPointer = (uint8_t*)_fileObjectsData + bias;
    
    [self fillObject:anObject property:property objectPointer:objectStructPointer];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)fillObject:(INPersistentObject*)anObject property:(INPersistentProperty*)property objectPointer:(void*)objectStructPointer {
    int valueBias = [[_objectStructureLookupTable objectForKey:property.name] intValue];
    
    if (property.type == INPersistentPropertyTypeInt) {
        int (*getter)(id, SEL);
        SEL getterSelector = NSSelectorFromString(property.name);
        getter = (int (*)(id, SEL))[anObject methodForSelector:getterSelector];
        int value = getter(anObject, getterSelector);
        
        memcpy(objectStructPointer + valueBias, &value, sizeof(int));
        //        *((int*) (objectStructPointer + valueBias)) = value;
    } else if (property.type == INPersistentPropertyTypeDouble) {
        double (*getter)(id, SEL);
        SEL getterSelector = NSSelectorFromString(property.name);
        getter = (double (*)(id, SEL))[anObject methodForSelector:getterSelector];
        double value = getter(anObject, getterSelector);
        
        memcpy(objectStructPointer + valueBias, &value, sizeof(double));
        //        double *doublePointer = (double*) (objectStructPointer + valueBias);
        //        *doublePointer = value;
    } else if (property.type == INPersistentPropertyTypeBool) {
        BOOL (*getter)(id, SEL);
        SEL getterSelector = NSSelectorFromString(property.name);
        getter = (BOOL (*)(id, SEL))[anObject methodForSelector:getterSelector];
        BOOL value = getter(anObject, getterSelector);
        
        memcpy(objectStructPointer + valueBias, &value, sizeof(BOOL));
        //        *((BOOL*) (objectStructPointer + valueBias)) = value;
    } else if (property.type == INPersistentPropertyTypeString) {
        NSString *value = [anObject performSelector:NSSelectorFromString(property.name)];
        if (value == nil) {
            static char zeeeeroChar = 0;
            memcpy(objectStructPointer + valueBias, &zeeeeroChar, sizeof(char));
            //            *((char*) (objectStructPointer + valueBias)) = 0;
        } else {
            BOOL result = NO;
            unsigned int maxCount = MAX_STRING_LENGTH_IN_BYTES;
            if (maxCount > [value length]) {
                maxCount = [value length];
            }
            
            while (!result) {
                result = [[value substringToIndex:maxCount] getCString:(char*)(objectStructPointer + valueBias) 
                                                             maxLength:MAX_STRING_LENGTH_IN_BYTES 
                                                              encoding:NSUTF8StringEncoding];
                maxCount--;
            }
        }
    } else if (property.type == INPersistentPropertyTypeDate) {
        NSDate *value = [anObject performSelector:NSSelectorFromString(property.name)];
        if (value == nil) {
            static double zeeeeroDouble = 0;
            memcpy(objectStructPointer + valueBias, &zeeeeroDouble, sizeof(double));
            //            *((double*) (objectStructPointer + valueBias)) = 0;
        } else {
            double timeValue = [value timeIntervalSince1970];
            memcpy(objectStructPointer + valueBias, &timeValue, sizeof(double));
            //            *((double*) (objectStructPointer + valueBias)) = [value timeIntervalSince1970];
        }
    } 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INPersistentProperty*)filePropertyForName:(NSString*)aPropertyName {
    for (INPersistentProperty *property in _fileProperties) {
        if ([property.name isEqualToString:aPropertyName]) {
            return property;
        }
    }
    
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setObject:(INPersistentObject*)anObject atIndex:(NSUInteger)aIndex {
    int bias = aIndex*_objectFilePartSize;
    void *objectStructPointer = _fileObjectsData + bias;
    
    for (INPersistentProperty *property in _fileProperties) {
        [self fillObject:anObject property:property objectPointer:objectStructPointer];
    }
    
    _ids[aIndex] = ((INPersistentObject*) anObject).___id;
    
    _needSave = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)saveDynamicPropertiesForObject:(INPersistentObject*)anObject {
    NSMutableString *parametersString = [[NSMutableString alloc] init];
    NSMutableString *valuesString = [[NSMutableString alloc] init];
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    
    for (INPersistentProperty *property in _dynamicProperties) {
        id value = [self getDynamicValueForObject:anObject andProperty:property.name];
        
        [parametersString appendFormat:@", %@", property.name];
        [valuesString appendString:@", ?"];
        [parameters addObject:[self getSQLParameterForProperty:property andValue:value]];
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"INSERT INTO object_data (id%@) VALUES (NULL%@)", parametersString, valuesString];
    
    if (_db == nil) {
        [self initAndUpdateDDLInDb];
    }
    
    [_db executeSQL:sql withParameters:parameters];
    [sql release];
    
    int64_t objectId = [_db lastInsertedId];
    anObject.___id = objectId;
    
    [parameters release];
    [valuesString release];
    [parametersString release];
}

//----------------------------------------------------------------------------------------------------------------------------------

@end // @implementation INPersistentStorage (Private)

//==================================================================================================================================
//==================================================================================================================================

@implementation INPersistentStorage

@synthesize delegate = _delegate;

- (id)initWithClass:(Class)aObjectClass {
    return [self initWithClass:aObjectClass 
                   storageName:[NSString stringWithCString:class_getName(aObjectClass) encoding:NSUTF8StringEncoding]
                      delegate:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithClass:(Class)aObjectClass storageName:(NSString*)aStorageName delegate:(id<INPersistentStorageDelegate>)aDelegate {
    if (self = [super init]) {
#if DEBUG_INIT == 1
        NSLog(@"Initialization…");
#endif
        
        _objectClass = [aObjectClass retain];
        _storageName = [aStorageName copy];
        
        _delegate = (id)[(NSObject*)aDelegate retain];
        
        _dynamicProperties = [[NSMutableArray alloc] init];
        _fileProperties = [[NSMutableArray alloc] init];
        
        _objectsLookupCache = [[NSMutableDictionary alloc] init];
        _objectStructureLookupTable = [[NSMutableDictionary alloc] init];
        
        _fileObjectsData = NULL;
        _ids = NULL;
        
#if DEBUG_INIT == 1
        NSLog(@"Extracting class data (%@ / %@)…", _objectClass, _storageName);
#endif
        
        [self extractClassPropertiesData];
        
#if DEBUG_INIT == 1
        NSLog(@"Preparing finished (%@ / %@)", _objectClass, _storageName);
#endif
        
        [self loadFileData];
#if DEBUG_INIT == 1
        NSLog(@"Data loaded (%@ / %@)", _objectClass, _storageName);
#endif
        
        if (ALREADY_INSTRUMENTED_CLASSES == nil) {
            ALREADY_INSTRUMENTED_CLASSES = [[NSMutableSet alloc] init];
        }
        
        if (![ALREADY_INSTRUMENTED_CLASSES containsObject:_objectClass]) {
            // update class methods with dynamic ones
            for (INPersistentProperty *property in _dynamicProperties) {
                IMP getImp;
                IMP setImp;
                
                if (property.type == INPersistentPropertyTypeInt) {
                    getImp = (IMP)getDynamicPropertyInt;
                    setImp = (IMP)setDynamicPropertyInt;
                } else if (property.type == INPersistentPropertyTypeDouble) {
                    getImp = (IMP)getDynamicPropertyDouble;
                    setImp = (IMP)setDynamicPropertyDouble;
                } else if (property.type == INPersistentPropertyTypeBool) {
                    getImp = (IMP)getDynamicPropertyBool;
                    setImp = (IMP)setDynamicPropertyBool;
                } else if (property.type == INPersistentPropertyTypeDate) {
                    getImp = (IMP)getDynamicPropertyDate;
                    setImp = (IMP)setDynamicPropertyId;
                } else {
                    getImp = (IMP)getDynamicPropertyId;
                    setImp = (IMP)setDynamicPropertyId;
                }
                
                NSString *getterName = [[NSString alloc] initWithFormat:@"%@", property.name];
                NSString *setterName = [[NSString alloc] initWithFormat:@"set%@%@:", 
                                        [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                        [property.name substringFromIndex:1]];
                
                class_addMethod(_objectClass, 
                                NSSelectorFromString(getterName), 
                                getImp, 
                                "@@:");
                
                class_addMethod(_objectClass, 
                                NSSelectorFromString(setterName), 
                                setImp, 
                                "v@:@");
                
                [getterName release];
                [setterName release];
            }
            
#if DEBUG_INIT == 1
            NSLog(@"Dynamic properties done (%@ / %@)", _objectClass, _storageName);
#endif
            
            // update file-properties so that they invoke updating data on disk
            for (INPersistentProperty *property in _fileProperties) {
                IMP setImp;
                char *typeString;
                
                if (property.type == INPersistentPropertyTypeInt) {
                    setImp = (IMP)setFilePropertyInt;
                    typeString = "v@:i";
                } else if (property.type == INPersistentPropertyTypeDouble) {
                    setImp = (IMP)setFilePropertyDouble;
                    typeString = "v@:d";
                } else if (property.type == INPersistentPropertyTypeBool) {
                    setImp = (IMP)setFilePropertyBool;
                    typeString = "v@:B";
                } else {
                    setImp = (IMP)setFilePropertyId;
                    typeString = "v@:@";
                }
                
                NSString *setterName = [[NSString alloc] initWithFormat:@"set%@%@:", 
                                        [[property.name substringWithRange:NSMakeRange(0, 1)] uppercaseString], 
                                        [property.name substringFromIndex:1]];
                SEL originalSelector = NSSelectorFromString(setterName);
                
                Method oldMethod = class_getInstanceMethod(_objectClass, originalSelector);
                
                NSString *setterNameNew = [[NSString alloc] initWithFormat:@"____%@", setterName];
                SEL newSelector = NSSelectorFromString(setterNameNew);
                
                class_addMethod(_objectClass, newSelector, setImp, typeString);
                
                Method newMethod = class_getInstanceMethod(_objectClass, newSelector);
                
                if (oldMethod == nil || newMethod == nil) {
                    [setterNameNew release];
                    [setterName release];
                    
                    @throw [NSException exceptionWithName:@"Error during instrumenting" 
                                                   reason:[NSString stringWithFormat:@"Error during instrumenting class %s (method: %@)", class_getName(_objectClass), setterName] 
                                                 userInfo:nil];
                }
                
                method_exchangeImplementations(oldMethod, newMethod);
                
                [setterNameNew release];
                [setterName release];
            }
            
#if DEBUG_INIT == 1
            NSLog(@"Static properties done (%@ / %@)", _objectClass, _storageName);
#endif
            
            [ALREADY_INSTRUMENTED_CLASSES addObject:_objectClass];
        }
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)saveFileData {
    if (_bulkUpdateInProcess) {
        _needSave = YES;
        return;
    }
    
    if (_objectsCount != 0) {
        NSData *dataBasic = [[NSData alloc] initWithBytesNoCopy:_fileObjectsData length:_objectsCount*_objectFilePartSize freeWhenDone:NO];
        NSData *dataLookup = [[NSData alloc] initWithBytesNoCopy:_ids length:_objectsCount*sizeof(int64_t) freeWhenDone:NO];
        NSData *additionalData = [_delegate storeAdditionalData];
        
        NSArray *arrayToSave;
        
        if (additionalData != nil) {
            arrayToSave = [[NSArray alloc] initWithObjects:
                           [NSNumber numberWithInt:_objectFilePartSize],
                           _objectStructureLookupTable,
                           dataBasic,
                           dataLookup,
                           additionalData,
                           nil];
        } else {
            arrayToSave = [[NSArray alloc] initWithObjects:
                           [NSNumber numberWithInt:_objectFilePartSize],
                           _objectStructureLookupTable,
                           dataBasic,
                           dataLookup,
                           nil];
        }
        
        
        [arrayToSave writeToFile:getFileInDocumentsPath([NSString stringWithFormat:@"_in_ps_data_%@", _storageName]) atomically:YES];
        
        [arrayToSave release];
        [dataLookup release];
        [dataBasic release];
    }
    
    _needSave = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)count {
    return _objectsCount;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)newObject {
    return [[self objectFromPool] retain];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)objectById:(NSInteger)aId {
    if (_fileObjectsData == NULL) {
        return nil;
    }
    
    INPersistentObject *result = nil;
    result = [self objectFromPool];
    result.___id = aId;
    [self fillObject:result withDataForId:aId];
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)objectFromPool {
    if (_lastGotObject != nil) {
        if ([_lastGotObject retainCount] == 1) {
            return _lastGotObject;
        }
    }
    
    //TODO: тут нужон какой-то пул, наверное…
    INPersistentObject *result = [[[_objectClass alloc] init] autorelease];
    result.storage = self;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)objectAtIndex:(NSUInteger)index {
    if (_fileObjectsData == NULL) {
        return nil;
    }
    
    INPersistentObject *result = nil;
    
    if (_objectByIdCache != nil) {
        result = [_objectByIdCache objectForKey:[NSNumber numberWithInt:index]];
    }
    
    if (result == nil) {
        result = [self objectFromPool];
        result.___id = _ids[index];
        [self fillObject:result withDataPointer:(_fileObjectsData + index*_objectFilePartSize)];
        
        if (_objectByIdCache != nil) {
            [_objectByIdCache setObject:result forKey:[NSNumber numberWithInt:index]];
        }
    }
    
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addObject:(id)anObject {
    INPersistentObject *object = (INPersistentObject*)anObject;
    
    if (object.storage == self || object.___id != -1) {
        @throw [NSException exceptionWithName:@"Can't add object twice" 
                                       reason:@"Object is already persisted. Can't persist object twice or simultaneously in to several persistent storages" 
                                     userInfo:nil];
    }
    
    [object setStorage:self];
    
    [self incrementObjectsCounter];
    
    _objectsCount++;
    
    [self saveDynamicPropertiesForObject:object];
    [self setObject:object atIndex:_objectsCount - 1];
    
    [_delegate objectAdded:anObject atIndex:_objectsCount - 1];
    
    [self saveFileData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (index == _objectsCount) {
        [self addObject:anObject];
    } else if ((int)index < 0 || index > _objectsCount) {
        @throw [NSException exceptionWithName:@"Index out of range" 
                                       reason:[NSString stringWithFormat:@"Index (%d) is out of range (%d - %d)", index, 0, _objectsCount] 
                                     userInfo:nil];
    } else {
        INPersistentObject *object = (INPersistentObject*)anObject;
        
        if (object.storage == self || object.___id != -1) {
            @throw [NSException exceptionWithName:@"Can't add object twice" 
                                           reason:@"Object is already persisted. Can't persist object twice or simultaneously in to several persistent storages" 
                                         userInfo:nil];
        }
        
        [object setStorage:self];
        
        [self incrementObjectsCounter];
        [self saveDynamicPropertiesForObject:object];
        
        memmove((int64_t*)_ids + index + 1, (int64_t*)_ids + index, sizeof(int64_t)*(_objectsCount - index));
        memmove(_fileObjectsData + (_objectFilePartSize*(index + 1)), _fileObjectsData + (_objectFilePartSize*index), _objectFilePartSize*(_objectsCount - index));
        
        _objectsCount++;
        
        [self setObject:object atIndex:index];
        
        [_delegate objectAdded:anObject atIndex:index];
        
        [self saveFileData];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (/* index < 0 || */ index >= _objectsCount) {
        @throw [NSException exceptionWithName:@"Index out of range" 
                                       reason:[NSString stringWithFormat:@"Index (%d) is out of range (%d - %d)", index, 0, _objectsCount] 
                                     userInfo:nil];
    }
    
    for (int i = index + 1; i < _objectsCount; i++) {
        _ids[i - 1] = _ids[i];
    }
    
    memmove(_fileObjectsData + (_objectFilePartSize*index), _fileObjectsData + (_objectFilePartSize*(index + 1)), _objectFilePartSize*(_objectsCount - index - 1));
    
    _objectsCount--;
    
    [_delegate objectRemovedAtIndex:index];
    
    [self saveFileData];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)beginBulkUpdate {
    _bulkUpdateInProcess = YES;
    
    if (_db == nil) {
        [self initAndUpdateDDLInDb];
    }
    
    [_db beginTransaction];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)endBulkUpdate {
    _bulkUpdateInProcess = NO;
    [self saveFileData];
    
    if (_db == nil) {
        [self initAndUpdateDDLInDb];
    }
    
    [_db commitTransaction];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)beginBulkIndexSearch {
    [_objectByIdCache release];
    
    _objectByIdCache = [[NSMutableDictionary alloc] init];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)endBulkIndexSearch {
    [_objectByIdCache release];
    _objectByIdCache = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeObject:(id)anObject {
    @throw [NSException exceptionWithName:@"Not implemented yet" reason:@"Not implemented" userInfo:nil];
    //TODO:
    _needSave = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)removeAllObjects {
    while (_objectsCount > 0) {
        [self removeObjectAtIndex:0];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)containsObject:(id)anObject {
    return [self indexOfObject:anObject] != NSNotFound;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)indexOfObject:(id)anObject {
    for (int i = 0; i < _objectsCount; i++) {
        if (_ids[i] == ((INPersistentObject*)anObject).___id) {
            return i;
        }
    }
    
    return NSNotFound;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    if (_needSave) {
        [self saveFileData];
    }
    
    if (_fileObjectsData != NULL) {
        free(_fileObjectsData);
    }
    
    if (_ids != NULL) {
        free(_ids);
    }
    
    [_db release];
    [_objectClass release];
    [_storageName release];
    
    [_dynamicProperties release];
    [_fileProperties release];
    
    [_objectsLookupCache release];
    [_objectStructureLookupTable release];
    
    [_objectByIdCache release];
    
    [(NSObject*)_delegate release];
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    if (state->state >= _objectsCount) {
        return 0;
    }
    
    if ((int)state->state < 0) {
        state->state = 0;
    }
    
    stackbuf[0] = [self objectAtIndex:state->state];
    
    state->itemsPtr = stackbuf;
    state->state++;
    state->mutationsPtr = (unsigned long *) self;
    
    return 1;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)cleanMemoryForBackground {
//    NSLog(@"Cleaning…");
    
    if (_needSave) {
        [self saveFileData];
    }
    
    if (_fileObjectsData != NULL) {
        free(_fileObjectsData);
        _fileObjectsData = NULL;
    }
    
    [_db release];
    _db = nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)restoreDataFromBackground {
//    NSLog(@"Restoring…");

    NSArray *fileArray = [[NSArray alloc] initWithContentsOfFile:getFileInDocumentsPath([NSString stringWithFormat:@"_in_ps_data_%@", _storageName])];
    
    if (fileArray != nil) {
        NSData *data = [fileArray objectAtIndex:2];
        if (data != nil) {
            _fileObjectsData = malloc([data length]);
            memcpy(_fileObjectsData, [data bytes], [data length]);
        }
    }
    
    [fileArray release];

    _db = [[INdb alloc] initWithDBFileName:[NSString stringWithFormat:@"_in_ps_%@", _storageName]];
}

//----------------------------------------------------------------------------------------------------------------------------------

@end

//==================================================================================================================================
#pragma mark Helper Functions
//==================================================================================================================================

int getDynamicPropertyInt(id self, SEL _cmd) {
    INPersistentObject *object = (INPersistentObject*) self;
    
    NSNumber *value;
    if (object.storage == nil) {
        value = [object.dynamicValues valueForKey:getPropertyNameBySelector(_cmd)];
    } else {
        value = [object.storage getDynamicValueForObject:self andProperty:getPropertyNameBySelector(_cmd)];
    }
    
    return [value intValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

double getDynamicPropertyDouble(id self, SEL _cmd) {
    INPersistentObject *object = (INPersistentObject*) self;
    
    NSNumber *value;
    if (object.storage == nil) {
        value = [object.dynamicValues valueForKey:getPropertyNameBySelector(_cmd)];
    } else {
        value = [object.storage getDynamicValueForObject:self andProperty:getPropertyNameBySelector(_cmd)];
    }
    
    return [value doubleValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

BOOL getDynamicPropertyBool(id self, SEL _cmd) {
    INPersistentObject *object = (INPersistentObject*) self;
    
    NSNumber *value;
    if (object.storage == nil) {
        value = [object.dynamicValues valueForKey:getPropertyNameBySelector(_cmd)];
    } else {
        value = [object.storage getDynamicValueForObject:self andProperty:getPropertyNameBySelector(_cmd)];
    }
    
    return [value boolValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

id getDynamicPropertyId(id self, SEL _cmd) {
    INPersistentObject *object = (INPersistentObject*) self;
    
    id value;
    if (object.storage == nil) {
        value = [object.dynamicValues valueForKey:getPropertyNameBySelector(_cmd)];
    } else {
        value = [object.storage getDynamicValueForObject:self andProperty:getPropertyNameBySelector(_cmd)];
    }
    
    return value;
}

//----------------------------------------------------------------------------------------------------------------------------------

NSDate* getDynamicPropertyDate(id self, SEL _cmd) {
    INPersistentObject *object = (INPersistentObject*) self;
    
    NSNumber *value;
    if (object.storage == nil) {
        value = [object.dynamicValues valueForKey:getPropertyNameBySelector(_cmd)];
    } else {
        value = [object.storage getDynamicValueForObject:self andProperty:getPropertyNameBySelector(_cmd)];
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
}

//==================================================================================================================================

void setInCacheOrCallStorage(INPersistentObject* anObject, id aValue, NSString *aPropertyName) {
    if (anObject.storage == nil) {
        [anObject.dynamicValues setValue:aValue forKey:aPropertyName];
    } else {
        [anObject.storage setDynamicValue:aValue forObject:anObject andProperty:aPropertyName];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

void setDynamicPropertyInt(id self, SEL _cmd, int aValue) {
    INPersistentObject *object = (INPersistentObject*) self;
    setInCacheOrCallStorage(object, [NSNumber numberWithInt:aValue], getPropertyNameBySelector(_cmd));
}

//----------------------------------------------------------------------------------------------------------------------------------

void setDynamicPropertyDouble(id self, SEL _cmd, double aValue) {
    INPersistentObject *object = (INPersistentObject*) self;
    setInCacheOrCallStorage(object, [NSNumber numberWithDouble:aValue], getPropertyNameBySelector(_cmd));
}

//----------------------------------------------------------------------------------------------------------------------------------

void setDynamicPropertyBool(id self, SEL _cmd, BOOL aValue) {
    INPersistentObject *object = (INPersistentObject*) self;
    setInCacheOrCallStorage(object, [NSNumber numberWithBool:aValue], getPropertyNameBySelector(_cmd));
}

//----------------------------------------------------------------------------------------------------------------------------------

void setDynamicPropertyId(id self, SEL _cmd, id aValue) {
    INPersistentObject *object = (INPersistentObject*) self;
    setInCacheOrCallStorage(object, aValue, getPropertyNameBySelector(_cmd));
}

//==================================================================================================================================

void invokePreviousSelector(id self, SEL _cmd, void *anArgument) {
    NSString *selectorName = [NSString stringWithFormat:@"____%s", sel_getName(_cmd)];
    
    SEL selector = NSSelectorFromString(selectorName);
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    [invocation setArgument:anArgument atIndex:2];
    
    [invocation invoke];
    
    INPersistentStorage *storage = ((INPersistentObject*) self).storage;
    if (storage != nil) {
        [storage fillObject:self property:[storage filePropertyForName:getPropertyNameBySelector(_cmd)]];
        
        [storage.delegate objectWasChanged:self];
        [storage saveFileData];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

void setFilePropertyInt(id self, SEL _cmd, int aValue) {
    invokePreviousSelector(self, _cmd, &aValue);
}

//----------------------------------------------------------------------------------------------------------------------------------

void setFilePropertyDouble(id self, SEL _cmd, double aValue) {
    invokePreviousSelector(self, _cmd, &aValue);
}

//----------------------------------------------------------------------------------------------------------------------------------

void setFilePropertyBool(id self, SEL _cmd, BOOL aValue) {
    invokePreviousSelector(self, _cmd, &aValue);
}

//----------------------------------------------------------------------------------------------------------------------------------

void setFilePropertyId(id self, SEL _cmd, id aValue) {
    invokePreviousSelector(self, _cmd, &aValue);
}

//----------------------------------------------------------------------------------------------------------------------------------
