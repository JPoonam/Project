//!
//! @file INPersistentObject.m
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

#import "INPersistentObject.h"

#import <objc/runtime.h>

//==================================================================================================================================
//==================================================================================================================================

@implementation INPersistentObject

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
	_storage = nil;
	___id = -1;
	_dynamicValues = [[NSMutableDictionary alloc] init];
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
	[_dynamicValues release];
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

@end
