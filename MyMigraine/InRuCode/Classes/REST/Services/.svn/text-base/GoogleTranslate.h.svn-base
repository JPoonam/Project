//
//  GoogleTranslate.h
//  Rospil
//
//  Created by Alex Babaev on 5/9/11.
//  Copyright 2011 DevPocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INRester.h"

@class INRester;

@interface GoogleTranslate : NSObject {
    NSString *_googleAPIKey;

    INRester *_rester;
}

+ (GoogleTranslate*)serviceWithKey:(NSString*)aServiceKey appName:(NSString*)aAppName appURL:(NSString*)aAppURL;
- (id)initWithServiceKey:(NSString*)aServiceKey appName:(NSString*)aAppName appURL:(NSString*)aAppURL;

- (NSString*)translate:(NSString*)aText from:(NSString*)aLanguageFrom to:(NSString*)aLanguageTo;

@end
