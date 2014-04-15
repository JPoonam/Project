//!
//! @file INCoreData.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! @copyright Copyright © 2011 InRu
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

#import "INCoreData.h"
#import "INCommonTypes.h"
#import <objc/runtime.h>


@implementation NSManagedObject (INRU_CoreData)

+ (INRelationshipInfo)inru_infoForRelationshipWithName:(NSString *)name { 
    return (INRelationshipInfo) {
        .removeObjectSelector = NSSelectorFromString([NSString stringWithFormat:@"remove%@Object:", [name inru_capitalizeFirstLetter]]), 
        .addObjectSelector = NSSelectorFromString([NSString stringWithFormat:@"add%@Object:", [name inru_capitalizeFirstLetter]]),
        .fetchSelector = NSSelectorFromString(name)
    };
}

//----------------------------------------------------------------------------------------------------------------------------------


//todo: реализовать хранение в objects, так, чтобы не допускать циклические ссылки
- (NSString *)inru_dumpDescriptionAtLevel:(NSInteger)level objects:(NSMutableDictionary *)objects{
    
    NSString * (^Padding)() = ^() { 
        return [@"" stringByPaddingToLength:level * 4 withString:@" " startingAtIndex:0];  
    };
    NSString * (^Padding1)() = ^() { 
        return [@"" stringByPaddingToLength:(level + 1) * 4 withString:@" " startingAtIndex:0];  
    };
    
    NSMutableString * result = [NSMutableString stringWithFormat:@"%@%@ '%@'",Padding(),self.class,self.entity.name];
    
    // get list of dynamic props  
    NSMutableArray * props = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t * properties = class_copyPropertyList(self.class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        NSArray * attributes = [[NSString stringWithUTF8String:property_getAttributes(property)] componentsSeparatedByString:@","];
        BOOL isDynamic = [attributes containsObject:@"D"];
        if (isDynamic) { 
            [props addObject:propertyName];
        }        
    }
    free(properties);
    [props sortUsingSelector:@selector(compare:)];

    NSDictionary * chValues = [self changedValues];
    
    if (!props.count) {
        [result appendFormat:@"{}\n"];    
    } else { 
        [result appendFormat:@"{\n"];
        int i = 0;
        for (NSString * propName in props) {
            id propValue = [self valueForKey:propName];
            NSString * modifiedFlag = [chValues objectForKey:propName] ? @"(*)" : @"";
            
            [result appendFormat:@"%@%@%@ = ", Padding1(), modifiedFlag, propName];
            
            // SET (relationships)
            if ([propValue isKindOfClass:NSSet.class]) { 
                NSSet * set = propValue;
                if (set.count) {
                     [result appendString:@"{\n"];
                     for (id obj in set) { 
                         if ([obj isKindOfClass:NSManagedObject.class]) { 
                             [result appendString:[obj inru_dumpDescriptionAtLevel:level+2 objects:objects]]; 
                         } else { 
                             [result appendFormat:@"%@%@\n",Padding1(),obj];
                         }
                     }
                     [result appendFormat:@"%@}", Padding1()];
                } else { 
                    [result appendFormat:@"{}"];
                }
            } else { 
                [result appendFormat:@"'%@'", propValue];
            }
            
            if (i++ != props.count - 1) { 
                [result appendString:@",\n"];
            } else { 
                [result appendString:@"\n"];
            }
        }
        [result appendFormat:@"%@}\n", Padding()];    
    }
    return result;   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inru_dump { 
    NSMutableDictionary * objects = [NSMutableDictionary dictionary];
    NSLog(@"%@",[self inru_dumpDescriptionAtLevel:0 objects:objects]);
}

@end


//==================================================================================================================================
//==================================================================================================================================

static const NSString * INCoreDataErrorDomain = @"INCoreDataErrorDomain";

@implementation NSError (INRU_CoreData)

- (NSString *)inru_localizedDescriptionForCoreData {
    NSString * result = self.localizedDescription;  
    if ([self.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        if (self.userInfo) {
            NSMutableArray * a = [NSMutableArray array];
            NSArray * errors = [self.userInfo objectForKey:NSDetailedErrorsKey];
            if (errors.count) {
                for (NSError * error in errors) { 
                    [a addObject:error.inru_localizedDescriptionForCoreData]; 
                }
                result = [NSString stringWithFormat:@"%@\n{%@}", result, [a componentsJoinedByString:@"}, {"]];
            } else {
                for (NSString * key in self.userInfo) {
                    if (![key isEqualToString:NSLocalizedDescriptionKey]) {      
                        [a addObject:[NSString stringWithFormat:@"%@ = %@", key, [self.userInfo objectForKey:key]]];      
                    }
                }
                if (a.count) { 
                    result = [NSString stringWithFormat:@"%@\n{%@}", result, [a componentsJoinedByString:@"; "]];
                }
            }
        }
    }
    return result;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface _INManagedObjectContext : NSManagedObjectContext {
    __unsafe_unretained INCoreDatabase * _database;
}

@property(nonatomic,assign) INCoreDatabase * database;

@end

//----------------------------------------------------------------------------------------------------------------------------------

@implementation _INManagedObjectContext

@synthesize database = _database;

@end

//----------------------------------------------------------------------------------------------------------------------------------

@implementation NSManagedObjectContext (INRU_CoreData)

// Solution got from here 
// http://cocoawithlove.com/2008/08/safely-fetching-nsmanagedobject-by-uri.html
//
// Problem description: But there's a catch: these methods do not actually fetch the object from the persistent store. 
// If the object doesn't exist, these methods will still succeed, giving you an NSManagedObjectID or NSManagedObject referencing a non-existent entry in the 
// persistent store (which will throw an  NSObjectInaccessibleException if you try to fault it). The reality is that, despite their 
// appearance, these methods are for constructing object ID's, they don't search the persistent store.
 
- (NSManagedObject *)inru_objectWithURL:(NSURL *)uri {

    NSManagedObjectID * objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:uri];
    if (!objectID) {
        return nil;
    }
    
    NSManagedObject *objectForID = [self objectWithID:objectID];
    if (![objectForID isFault]) {
        return objectForID;
    }
    
    NSFetchRequest *request = [NSFetchRequest new];
    #if !__has_feature(objc_arc)
        [request autorelease];
    #endif 
    [request setEntity:[objectID entity]];
    
    // Equivalent to predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression: [NSExpression expressionForEvaluatedObject]
                                                                rightExpression: [NSExpression expressionForConstantValue:objectForID]
                                                                       modifier:  NSDirectPredicateModifier
                                                                           type: NSEqualToPredicateOperatorType
                                                                        options: 0];
    [request setPredicate:predicate];
    NSArray *results = [self executeFetchRequest:request error:nil];
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    }    
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSManagedObject *)inru_objectWithURL:(NSURL *)uri ofClass:(Class)objectClass {
    NSManagedObject * result = [self inru_objectWithURL:uri];
    if (result && [result isKindOfClass:objectClass]) { 
        return result;
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INCoreDatabase *)inru_database {
    if ([self isKindOfClass:_INManagedObjectContext.class]) {
        return [(_INManagedObjectContext *)self database];
    }
    return nil;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation NSFetchedResultsController(INRU_CoreData)

- (BOOL)inru_performFetch {
    NSError *error = nil;
    if (![self performFetch:&error]) {
        INCoreDatabase * database = [self.managedObjectContext inru_database];
        if (database) {
            [database.delegate incoreDatabase:database didFailWithError:error];
        }
        return NO;
    }
    return YES;
}

@end

//==================================================================================================================================
//==================================================================================================================================


@interface INCoreDatabase()

@property (nonatomic,strong) NSURL * modelURL;
@property (nonatomic,strong) NSURL * databaseURL;

@end

//==================================================================================================================================

@implementation INCoreDatabase

NSURL * PrivateDocumentsFolderURL() {
    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    applicationDocumentsDirectory = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Private Documents"];
    return applicationDocumentsDirectory;
}

//----------------------------------------------------------------------------------------------------------------------------------

@synthesize databaseURL = _databaseURL;
@synthesize modelURL = _modelURL;
@synthesize delegate = _delegate;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithModelFilename:(NSString *)modelName databaseFilename:(NSString *)databaseFileName delegate:(id<INCoreDatabaseDelegate>)delegate {
    NSParameterAssert(modelName.length);
    NSParameterAssert(databaseFileName.length);
    self = [super init];
    if (self) {
        self.modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:nil];
        self.databaseURL = [PrivateDocumentsFolderURL() URLByAppendingPathComponent:databaseFileName];
        self.delegate = delegate;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    NSAssert(0, @"should not be called mk_f023c723_e33c_4880_9d66_960026cac8eb");
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

#if !__has_feature(objc_arc)

- (void) dealloc {
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_databaseURL release];
    [_modelURL release];
    [super dealloc];
}

#endif

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drop {
    NSAssert(!_opened, @"mk_009acbc9_805f_479f_aaf2_401efd228ee5");
    if (!_opened && _databaseURL) {
        [[NSFileManager defaultManager] removeItemAtURL:_databaseURL error:nil];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)openWithResult:(NSError **)error canRecreateDatabase:(BOOL *)canRecreateDatabase {
    if (_opened) {
        return YES;
    }
    
    NSAssert(!_managedObjectContext,@"mk_ca44c11f_6a79_493b_ac70_c5bf758b5a98");
    NSAssert(!_managedObjectModel,@"mk_ca44c11f_6a79_493b_ac70_c5bf758b5a99");
    NSAssert(!_persistentStoreCoordinator,@"mk_ca44c11f_6a79_493b_ac70_c5bf758b5a9A");

    // load model
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    if (!_managedObjectModel) {
        if (error) {
            *error = [NSError inru_errorWithDomain:NSCocoaErrorDomain
                                              code:NSCoreDataError
                              localizedDescription:@"Unable to load database model"];
        }
        if (canRecreateDatabase) {
            * canRecreateDatabase = NO;
        }
        return NO;
    }
    
    // check database URL,
    NSURL * dbURL = _databaseURL;
    BOOL dbExists = NO;
    if (dbURL.isFileURL) {
        NSString * dbPath = dbURL.path;
        dbExists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
        if (!dbExists) {
            NSString * directory = [dbPath stringByDeletingLastPathComponent];
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    // 
    // NSURL * storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Fitness.sqlite"];
    
    // load persistent storage
    NSError * error1 = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_databaseURL
                                     options:options error:&error1]) {
                                     
        if (error) {
            *error = error1;
        }
        if (canRecreateDatabase) {
            * canRecreateDatabase = YES;
        }
        #if !__has_feature(objc_arc)
            [_persistentStoreCoordinator release];
            [_managedObjectModel release];
        #endif
        _persistentStoreCoordinator = nil;
        _managedObjectModel = nil;
        
        return NO;
    }

    // create context
    _managedObjectContext = [_INManagedObjectContext new];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    if (error) {
        *error = nil;
    }
    if (canRecreateDatabase) {
        * canRecreateDatabase = YES;
    }
    
    _opened = YES;
    
    if (!dbExists) {
        if ([_delegate respondsToSelector:@selector(incoreDatabaseCreated:)]) {
            [_delegate incoreDatabaseCreated:self];
        }
    }
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)save {
    NSAssert(_opened, @"mk_b492316b_e601_4a50_89e5_74b601ba5776");

    if (!_opened) {
         NSLog(@"[INCoreDatabase save]: database is not loaded yet");
         return YES;
    }
    
    NSError * error = nil;
    if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
        NSLog(@"[INCoreDatabase save]: failed with error %@", error);
        [_delegate incoreDatabase:self didFailWithError:error];
        return NO;
    }
    
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSManagedObject *)insertNewObjectForEntityWithName:(NSString *)entityName {
    NSParameterAssert(entityName.length);
    NSAssert(_opened, @"mk_b492316b_e601_4a50_89e5_74b601ba5777");
    if (!_opened) {
        NSLog(@"[INCoreDatabase insertNewObjectForEntityWithName]: database is not loaded yet");
        return nil;
    }
    
    NSEntityDescription * entity = [[_managedObjectModel entitiesByName] objectForKey:entityName];
    if (!entity) {
        NSError * error = [NSError inru_errorWithDomain:NSCocoaErrorDomain
                                                   code:NSCoreDataError
                                               localizedDescription:@"Cannot find entity with name %@",entityName];
        [_delegate incoreDatabase:self didFailWithError:error];
        return nil;
    }

    NSManagedObject *newObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
    #if !__has_feature(objc_arc)
        [newObject autorelease];
    #endif
     
    return newObject;
}

//----------------------------------------------------------------------------------------------------------------------------------
    
- (NSFetchedResultsController *)fetchedResultsControllerForRequest:(NSFetchRequest *)request{

    NSFetchedResultsController * aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_managedObjectContext
                                              sectionNameKeyPath:nil /* sectionNameKey*/ cacheName:nil];
    #if !__has_feature(objc_arc)
        [aFetchedResultsController autorelease];
    #endif
    [aFetchedResultsController inru_performFetch];
    return aFetchedResultsController;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSManagedObject *)objectWithURL:(NSURL *)uri ofClass:(Class)objectClass {
    return [_managedObjectContext inru_objectWithURL:uri ofClass:objectClass];
}
 
@end

//==================================================================================================================================
//==================================================================================================================================

/* 

// User info keys for errors created by Core Data:
COREDATA_EXTERN NSString * const NSDetailedErrorsKey NS_AVAILABLE(10_4,3_0);           // if multiple validation errors occur in one operation, they are collected in an array and added with this key to the "top-level error" of the operation
COREDATA_EXTERN NSString * const NSValidationObjectErrorKey NS_AVAILABLE(10_4,3_0);    // object that failed to validate for a validation error
COREDATA_EXTERN NSString * const NSValidationKeyErrorKey NS_AVAILABLE(10_4,3_0);       // key that failed to validate for a validation error
COREDATA_EXTERN NSString * const NSValidationPredicateErrorKey NS_AVAILABLE(10_4,3_0); // for predicate-based validation, the predicate for the condition that failed to validate
COREDATA_EXTERN NSString * const NSValidationValueErrorKey NS_AVAILABLE(10_4,3_0);     // if non-nil, the value for the key that failed to validate for a validation error
COREDATA_EXTERN NSString * const NSAffectedStoresErrorKey NS_AVAILABLE(10_4,3_0);      // stores prompting an error
COREDATA_EXTERN NSString * const NSAffectedObjectsErrorKey NS_AVAILABLE(10_4,3_0);     // objects prompting an error
COREDATA_EXTERN NSString * const NSPersistentStoreSaveConflictsErrorKey NS_AVAILABLE(10_7, 5_0);     // key in NSError's userInfo specifying the NSArray of NSMergeConflict
COREDATA_EXTERN NSString * const NSSQLiteErrorDomain NS_AVAILABLE(10_5,3_0);           // Predefined domain for SQLite errors, value of "code" will correspond to preexisting values in SQLite.

enum {
    NSManagedObjectValidationError                   = 1550,   // generic validation error       
    NSValidationMultipleErrorsError                  = 1560,   // generic message for error containing multiple validation errors
    NSValidationMissingMandatoryPropertyError        = 1570,   // non-optional property with a nil value
    NSValidationRelationshipLacksMinimumCountError   = 1580,   // to-many relationship with too few destination objects
    NSValidationRelationshipExceedsMaximumCountError = 1590,   // bounded, to-many relationship with too many destination objects
    NSValidationRelationshipDeniedDeleteError        = 1600,   // some relationship with NSDeleteRuleDeny is non-empty
    NSValidationNumberTooLargeError                  = 1610,   // some numerical value is too large
    NSValidationNumberTooSmallError                  = 1620,   // some numerical value is too small
    NSValidationDateTooLateError                     = 1630,   // some date value is too late
    NSValidationDateTooSoonError                     = 1640,   // some date value is too soon
    NSValidationInvalidDateError                     = 1650,   // some date value fails to match date pattern
    NSValidationStringTooLongError                   = 1660,   // some string value is too long
    NSValidationStringTooShortError                  = 1670,   // some string value is too short
    NSValidationStringPatternMatchingError           = 1680,   // some string value fails to match some pattern
    
    NSManagedObjectContextLockingError               = 132000, // can't acquire a lock in a managed object context
    NSPersistentStoreCoordinatorLockingError         = 132010, // can't acquire a lock in a persistent store coordinator
    
    NSManagedObjectReferentialIntegrityError         = 133000, // attempt to fire a fault pointing to an object that does not exist (we can see the store, we can't see the object)
    NSManagedObjectExternalRelationshipError         = 133010, // an object being saved has a relationship containing an object from another store
    NSManagedObjectMergeError                        = 133020, // merge policy failed - unable to complete merging
    
    NSPersistentStoreInvalidTypeError                = 134000, // unknown persistent store type/format/version
    NSPersistentStoreTypeMismatchError               = 134010, // returned by persistent store coordinator if a store is accessed that does not match the specified type
    NSPersistentStoreIncompatibleSchemaError         = 134020, // store returned an error for save operation (database level errors ie missing table, no permissions)
    NSPersistentStoreSaveError                       = 134030, // unclassified save error - something we depend on returned an error
    NSPersistentStoreIncompleteSaveError             = 134040, // one or more of the stores returned an error during save (stores/objects that failed will be in userInfo)
	NSPersistentStoreSaveConflictsError				 = 134050, // an unresolved merge conflict was encountered during a save.  userInfo has NSPersistentStoreSaveConflictsErrorKey
    
    NSCoreDataError                                  = 134060, // general Core Data error
    NSPersistentStoreOperationError                  = 134070, // the persistent store operation failed 
    NSPersistentStoreOpenError                       = 134080, // an error occured while attempting to open the persistent store
    NSPersistentStoreTimeoutError                    = 134090, // failed to connect to the persistent store within the specified timeout (see NSPersistentStoreTimeoutOption)
	NSPersistentStoreUnsupportedRequestTypeError	 = 134091, // an NSPersistentStore subclass was passed an NSPersistentStoreRequest that it did not understand
    
    NSPersistentStoreIncompatibleVersionHashError    = 134100, // entity version hashes incompatible with data model
    NSMigrationError                                 = 134110, // general migration error
    NSMigrationCancelledError                        = 134120, // migration failed due to manual cancellation
    NSMigrationMissingSourceModelError               = 134130, // migration failed due to missing source data model
    NSMigrationMissingMappingModelError              = 134140, // migration failed due to missing mapping model
    NSMigrationManagerSourceStoreError               = 134150, // migration failed due to a problem with the source data store
    NSMigrationManagerDestinationStoreError          = 134160, // migration failed due to a problem with the destination data store
    NSEntityMigrationPolicyError                     = 134170, // migration failed during processing of the entity migration policy 
    
    NSSQLiteError                                    = 134180,  // general SQLite error 
    
    NSInferredMappingModelError                      = 134190, // inferred mapping model creation error
    NSExternalRecordImportError                      = 134200 // general error encountered while importing external records
    
};

*/
