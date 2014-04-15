//
//  Created by alex on 5/8/11.
//


#import <Foundation/Foundation.h>
#import "INResterValue.h"
#import "INResponseParserJSON.h"
#import "INResponseParserXML.h"


@class INResponseParserJSON;
@class INResponseParserXML;

typedef enum {
    INResponseTypeXML,
    INResponseTypeJSON
} INResponseType;


@interface INResponseParser : NSObject {
    INResponseType _type;
    NSString *_string;

    BOOL _parsed;

    NSMutableDictionary *_pathCache;
    NSMutableDictionary *_valueCache;

    NSObject <INResterParserPositioner> *_parser;
}

    - (id)initWithType:(INResponseType)aType andString:(NSString *)aString;

    + (INResponseParser *)jsonParserForString:(NSString *)aString;
    + (INResponseParser *)xmlParserForString:(NSString *)aString;

    - (INResterValue *)valueForPath:(NSString *)aKey;
    - (NSEnumerator *)valuesForPath:(NSString *)aKey;

@end
