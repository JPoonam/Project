//
//  GoogleTranslate.m
//  Rospil
//
//  Created by Alex Babaev on 5/9/11.
//  Copyright 2011 DevPocket. All rights reserved.
//

#import "GoogleTranslate.h"
#import "INResponseParser.h"

@implementation GoogleTranslate

+ (GoogleTranslate*)serviceWithKey:(NSString*)aServiceKey appName:(NSString*)aAppName appURL:(NSString*)aAppURL {
    return [[[GoogleTranslate alloc] initWithServiceKey:aServiceKey appName:aAppName appURL:aAppURL] autorelease];
}

- (id)initWithServiceKey:(NSString*)aServiceKey appName:(NSString*)aAppName appURL:(NSString*)aAppURL {
    self = [super init];
    if (self) {
        _googleAPIKey = [aServiceKey copy];

        _rester = [[INRester alloc] init];
        _rester.userAgent = [NSString stringWithFormat:@"%@ iOS Application (support@devpocket.ru), v1.1", aAppName];
        _rester.referer = aAppURL;
    }

    return self;
}

- (NSString*)translate:(NSString*)aText from:(NSString*)aLanguageFrom to:(NSString*)aLanguageTo {
    NSString *result = [_rester processRequestForURL:@"https://ajax.googleapis.com/ajax/services/language/translate"
            parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                    @"1.0", @"v",
                    [NSString stringWithFormat:@"%@|%@", aLanguageFrom, aLanguageTo], @"langpair",
                    aText, @"q",
                    _googleAPIKey, @"key",
                    nil]
            method:INResterRequestTypePOST];

    INResponseParser *parser = [INResponseParser jsonParserForString:result];
    NSString *translated = [[parser valueForPath:@"responseData.translatedText"] stringValue];

    translated = [translated stringByReplacingOccurrencesOfString:@"\\u0026" withString:@"&"];
    translated = [translated stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];

    return translated;
}

- (void)dealloc {
    [_rester release];
    [_googleAPIKey release];
    [super dealloc];
}

@end
