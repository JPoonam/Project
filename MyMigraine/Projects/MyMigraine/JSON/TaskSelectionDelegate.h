//
//  Mon.h
//  Maryland_Governor
//
//  Created by mac mini on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>

@class Task;
@class Issue;

@protocol TaskSelectionDelegate
- (void)taskSelectionChanged:(Task *)curSelection;
- (void)issueSelectionChanged:(Issue *)curSelection;
@end