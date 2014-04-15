//!
//! @file INKeyChain.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//!
//! Based partly on code by Jonathan Wight, Jon Crosby, Mike Malone and Buzz Andersen.
//! Copyright © 2011 InRu
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

#import "INKeyChain.h"
#import <Security/Security.h>
#import "INCommonTypes.h"

static NSString * INKeyChainErrorDomain = @"INKeyChainErrorDomain";
#define NOT_FOUND_CODE -23498

@implementation INKeyChain
	
static NSError * _Error(int code) { 
    return [NSError errorWithDomain:INKeyChainErrorDomain code:code userInfo:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------
        
+ (NSString *)passwordForUsername:(NSString *)username service:(NSString *)serviceName error:(NSError **)error {
    
    if (!username || !serviceName) {
        if (error) { 
		    *error = [INError errorWithCode:INErrorCodeBadParameter];
		}
        return nil;
	}
    
    if (error) { 
	    *error = nil;
    }
		
	// Set up a query dictionary with the base query attributes: item type (generic), username, and service	
	NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, kSecAttrService, nil] autorelease];
	NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, username, serviceName, nil] autorelease];
	
	NSMutableDictionary *query = [[[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
	
	// First do a query for attributes, in case we already have a Keychain item with no password data set.
	// One likely way such an incorrect item could have come about is due to the previous (incorrect)
	// version of this code (which set the password as a generic attribute instead of password data).
	NSDictionary *attributeResult = NULL;
	NSMutableDictionary *attributeQuery = [query mutableCopy];
	[attributeQuery setObject: (id) kCFBooleanTrue forKey:(id) kSecReturnAttributes];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef) attributeQuery, (CFTypeRef *) &attributeResult);
	
	[attributeResult release];
	[attributeQuery release];
	
	if (status != noErr) {
		// No existing item found--simply return nil for the password
		if (status != errSecItemNotFound) {
			if (error) { 
                *error = _Error(status);
            }
		}
		return nil;
	}
	
	// We have an existing item, now query for the password data associated with it.
	
	NSData *resultData = nil;
	NSMutableDictionary *passwordQuery = [query mutableCopy];
	[passwordQuery setObject: (id) kCFBooleanTrue forKey: (id) kSecReturnData];

	status = SecItemCopyMatching((CFDictionaryRef) passwordQuery, (CFTypeRef *) &resultData);
	
	[resultData autorelease];
	[passwordQuery release];
	
	if (status != noErr) {
		if (error) { 
            if (status == errSecItemNotFound) {
                // We found attributes for the item previously, but no password now, so return a special error.
                // Users of this API will probably want to detect this error and prompt the user to
                // re-enter their credentials.  When you attempt to store the re-entered credentials
                // using storeUsername:andPassword:forServiceName:updateExisting:error
                // the old, incorrect entry will be deleted and a new one with a properly encrypted
                // password will be added.
                *error = _Error(NOT_FOUND_CODE);			
            } else {
                // Something else went wrong. Simply return the normal Keychain API error code.
                *error = _Error(status);
            }
        }
		
		return nil;
	}

	NSString *password = nil;
	if (resultData) {
		password = [[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding];
	} else {
		// There is an existing item, but we weren't able to get password data for it for some reason,
		// Possibly as a result of an item being incorrectly entered by the previous code.
		// Set the NOT_FOUND_CODE error so the code above us can prompt the user again.
		*error = _Error(NOT_FOUND_CODE);		
	}
			
	return [password autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (BOOL)savePassword:(NSString *)password forUsername:(NSString *)username service:(NSString *)service error:(NSError **)error {		
	if (!username || !password || !service) {
		if (error) { 
            *error = [INError errorWithCode:INErrorCodeBadParameter];
		}
        return NO;
	}
	
	// See if we already have a password entered for these credentials.
	NSString *existingPassword = [self passwordForUsername: username service: service error: error];

	if ([*error code] == NOT_FOUND_CODE) {
		// There is an existing entry without a password properly stored (possibly as a result of the previous incorrect version of this code.
		// Delete the existing item before moving on entering a correct one.
		*error = nil;
		[self deletePasswordForUsername: username service: service error: error];
		if ([*error code] != noErr) {
			return NO;
		}
	} else 
    if ([*error code] != noErr) {
		return NO;
	}
	
	*error = nil;
	
	OSStatus status = noErr;
		
	if (existingPassword) {
		// We have an existing, properly entered item with a password.
		// Update the existing item.
		
		if (![existingPassword isEqualToString:password] /* && * updateExisting */) {
			//Only update if we're allowed to update existing.  If not, simply do nothing.
			
			NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, 
							  kSecAttrService, 
							  kSecAttrLabel, 
							  kSecAttrAccount, 
							  nil] autorelease];
			
			NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, 
								 service,
								 service,
								 username,
								 nil] autorelease];
			
			NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];			
			
			status = SecItemUpdate((CFDictionaryRef) query, (CFDictionaryRef) [NSDictionary dictionaryWithObject: 
                      [password dataUsingEncoding: NSUTF8StringEncoding] forKey: (NSString *) kSecValueData]);
		}
	} else {
		// No existing entry (or an existing, improperly entered, and therefore now
		// deleted, entry).  Create a new entry.
		
		NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, 
						  kSecAttrService, 
						  kSecAttrLabel, 
						  kSecAttrAccount, 
						  kSecValueData, 
						  nil] autorelease];
		
		NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, 
							 service,
							 service,
							 username,
							 [password dataUsingEncoding: NSUTF8StringEncoding],
							 nil] autorelease];
		
		NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];			

		status = SecItemAdd((CFDictionaryRef) query, NULL);
	}
	
	if (status != noErr) {
		// Something went wrong with adding the new item. Return the Keychain error code.
		if (error) { 
            *error = _Error(status);
        }
        return NO;
	}
    
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (BOOL)deletePasswordForUsername:(NSString *)username service:(NSString *)serviceName error:(NSError **)error {
	if (!username || !serviceName) {
		if (error) {
            *error = [INError errorWithCode:INErrorCodeBadParameter];
		}
        return NO;
	}
	
    if (error) { 
	    *error = nil;
    }
		
	NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil] autorelease];
	NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, username, serviceName, kCFBooleanTrue, nil] autorelease];
	
	NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
	
	OSStatus status = SecItemDelete((CFDictionaryRef) query);
	
	if (status != noErr) {
		if (error) { 
            *error = _Error(status);
        }
        return NO;
	}
    
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (NSString *)passwordForUsername:(NSString *)username service:(NSString *)service { 
   NSError * error; 
   return [self passwordForUsername:username service:service error:&error];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)savePassword:(NSString *)password forUsername:(NSString *)username service:(NSString *)service { 
   NSError * error; 
   [self savePassword:password forUsername:username service:service error:&error];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)deletePasswordForUsername:(NSString *)username service:(NSString *)service { 
   NSError * error; 
   [self deletePasswordForUsername:username service:service error:&error];
}

@end

