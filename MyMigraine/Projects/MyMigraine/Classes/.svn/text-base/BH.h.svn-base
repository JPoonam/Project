
#import <Foundation/Foundation.h>
#import "BHGlobals.h"
#import "BHClasses.h"
#import "INErrorAlertCenter.h"

typedef enum {
    // Items 
    BHFetchStyleCategoryItem,
    BHFetchStyleItemByName,
    BHFetchStyleCheckList,
    
    // events
    BHFetchStyleHistory,
    BHFetchStyleScreenReport,
    BHFetchStylePDFReport,
    BHFetchStyleCharts
} BHFetchStyle;


//==================================================================================================================================

@interface BH : NSObject<UIAlertViewDelegate> {
    INErrorAlertCenter * _errorAlertCenter;
    
    NSManagedObjectContext * _managedObjectContext_notUseDirectly;
    NSManagedObjectModel   * _managedObjectModel_notUseDirectly;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator_notUseDirectly;
    
    NSString * _prefillEntityName;
    NSInteger _prefillOrder;
    
    BHMigrainEvent * _migrainEvent;
    NSInteger _logFilterMask;
    BHStartDate _sharedStartDate;
    
    BOOL _firstStartAfterUpdateOrInstall;
}

// preferences
- (void)loadPreferences;
- (void)savePreferences;

@property(nonatomic) BOOL askMenstruations;
@property(nonatomic) BOOL termsAccepted;
@property(nonatomic) BOOL hasRecords;
@property(nonatomic) NSInteger logFilterItemMask1;
@property(nonatomic) BHStartDate sharedStartDate;

// called from app delegate. Put all startup/cleanup code here
- (void)onAppStart;
- (void)onAppTerminateOrGoingBackground:(BOOL)isTerminated;
- (void)onAppActivating;
- (void)onAppDeactivating;
- (void)onAppGoingForeground;
 
// error processing
- (void)clearErrorForSender:(id)sender;
- (void)showError:(NSError *)error titleKey:(NSString *)titleKey explanationKey:(NSString *)explKey forceShow:(BOOL)forceShow sender:(id)sender;
- (void)showError:(NSError *)error title:(NSString *)title explanation:(NSString *)explanation forceShow:(BOOL)forceShow sender:(id)sender;

// database stuff
- (BOOL)saveContext;
- (void)loadDatabase;
- (NSFetchedResultsController *)fetchedResultsControllerForCategoryWithEntityName:(NSString *)entityName style:(BHFetchStyle)style params:(id)params;
- (NSEntityDescription *)entityWithName:(NSString *)name;
- (NSFetchedResultsController *)fetchedResultsControllerForEventWithStyle:(BHFetchStyle)style sinceDate:(NSDate *)startDate;
- (BOOL)prepareAndSaveEvent:(BHMigrainEvent *)event;

- (BHMigrainEvent *)currentMigrainEvent:(BOOL)createIfNotYet;
@property (nonatomic,readonly) BHMigrainEvent * currentMigrainEvent;
- (void)releaseCurrentEvent;

- (void)showHelpTopic:(NSInteger)topic;
- (BOOL)hasHelpText:(NSInteger)recordTag;

@end

extern BH * g_BH;

//==================================================================================================================================
//==================================================================================================================================

@interface NSFetchedResultsController(BH) 

- (BOOL)bh_performFetch;

@end
