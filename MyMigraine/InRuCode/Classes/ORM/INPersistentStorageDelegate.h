//
//  INPersistentStorageDelegate.h
//  BashOrX2
//
//  Created by Alexander Babaev on 3/23/10.
//  Copyright 2010 Igrolain. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol INPersistentStorageDelegate

- (NSData*)storeAdditionalData;
- (void)restoreAdditionalDataFromPath:(NSData*)aAdditionalData;

- (void)objectAdded:(id)aObject atIndex:(NSInteger)aIndex;
- (void)objectRemovedAtIndex:(NSInteger)aIndex;

- (void)objectWasChanged:(id)aObject;

@end
