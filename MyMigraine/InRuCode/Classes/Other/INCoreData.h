//!
//! @file INCoreData.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class INCoreDatabase;

//==================================================================================================================================
//==================================================================================================================================

typedef struct {
    SEL addObjectSelector;
    SEL removeObjectSelector;
    SEL fetchSelector;
} INRelationshipInfo;

@interface NSManagedObject (INRU_CoreData)

- (void)inru_dump;
+ (INRelationshipInfo)inru_infoForRelationshipWithName:(NSString *)name;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface NSError (INRU_CoreData) 

- (NSString *)inru_localizedDescriptionForCoreData;

@end 

//==================================================================================================================================
//==================================================================================================================================

@interface NSManagedObjectContext (INRU_CoreData) 

- (NSManagedObject *)inru_objectWithURL:(NSURL *)uri;
- (NSManagedObject *)inru_objectWithURL:(NSURL *)uri ofClass:(Class)objectClass;
- (INCoreDatabase *)inru_database;

@end

//==================================================================================================================================
//==================================================================================================================================

@protocol INCoreDatabaseDelegate<NSObject>

@optional
- (void)incoreDatabaseCreated:(INCoreDatabase *)database;

@required
- (void)incoreDatabase:(INCoreDatabase *)database didFailWithError:(NSError *)error;

@end

//----------------------------------------------------------------------------------------------------------------------------------

@interface NSFetchedResultsController(INRU_CoreData)

- (BOOL)inru_performFetch;

@end

//----------------------------------------------------------------------------------------------------------------------------------

@interface INCoreDatabase : NSObject {
    NSManagedObjectContext * _managedObjectContext;
    NSManagedObjectModel   * _managedObjectModel;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    NSURL * _modelURL;
    NSURL * _databaseURL;
    BOOL _opened;
    __unsafe_unretained id<INCoreDatabaseDelegate> _delegate;
}

// самый частый случай - модель берется из ресурсов, база данных создается в PrivateDocuments
- (id)initWithModelFilename:(NSString *)modelName databaseFilename:(NSString *)databaseFileName delegate:(id<INCoreDatabaseDelegate>)delegate;
- (BOOL)openWithResult:(NSError **)error canRecreateDatabase:(BOOL *)canRecreateDatabase;
- (BOOL)save;
- (void)drop;

- (NSManagedObject *)insertNewObjectForEntityWithName:(NSString *)entityName;
- (NSManagedObject *)objectWithURL:(NSURL *)uri ofClass:(Class)objectClass;

@property(nonatomic,assign) id<INCoreDatabaseDelegate> delegate;

@property (nonatomic,readonly,strong) NSURL * modelURL;
@property (nonatomic,readonly,strong) NSURL * databaseURL;

@end
