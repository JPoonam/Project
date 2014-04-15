//
//  Created by alex on 5/8/11.
//


#import "INResponseParser.h"
#import "INAssert.h"


@interface NSMutableDictionary (INResterCategory)
    - (void)addObjectCreateArrayIfNessecary:(id)aObject forKey:(id)aKey;
@end


@implementation NSMutableDictionary (INResterCategory)
    - (void)addObjectCreateArrayIfNessecary:(id)aObject forKey:(id)aKey {
        id value = [self valueForKey:aKey];
        if (value != nil) {
            if (![value isKindOfClass:[NSMutableArray class]]) {
                NSMutableArray *value1 = [NSMutableArray arrayWithObject:value];
                value = value1;

                [self setValue:value forKey:aKey];
            }

            [value addObject:aObject];

            // just for debug
//            aObject = value;
        } else {
            [self setValue:aObject forKey:aKey];
        }

//        NSLog(@"%@ -> \"%@\"", aKey, aObject);
    }
@end


@interface INResponseParser (Private)
    - (void)parse;
@end


@implementation INResponseParser

    + (INResponseParser *)jsonParserForString:(NSString *)aString {
        return [[[self alloc] initWithType:INResponseTypeJSON andString:aString] autorelease];
    }

    + (INResponseParser *)xmlParserForString:(NSString *)aString {
        return [[[self alloc] initWithType:INResponseTypeXML andString:aString] autorelease];
    }

    - (id)initWithType:(INResponseType)aType andString:(NSString *)aString {
        self = [super init];
        if (self) {
            _type = aType;

            _pathCache = [[NSMutableDictionary alloc] init];
            _valueCache = [[NSMutableDictionary alloc] init];

            _parsed = NO;

            switch (_type) {
                case INResponseTypeJSON:
                {
                    _parser = [[INResponseParserJSON alloc] initWithString:aString];
                    break;
                }
                case INResponseTypeXML:
                {
                    _parser = [[INResponseParserXML alloc] initWithString:aString];
                    break;
                }
                default:
                {
                    [INAssert failWithMessage:@"90B0022D-6DE4-41B0-984C-2A3D85B05ACA"];
                    break;
                }
            }

            [self parse];
        }

        return self;
    }

    - (void)parse {
        if (_parsed) {
            return;
        }

        NSMutableArray *path = [NSMutableArray array];
        NSInteger lastLevel = 0;

        while (true) {
            BOOL weHaveNextElement = [_parser gotoNextElement];
            if (!weHaveNextElement) {
                break;
            }

            NSString *name = [_parser elementName];
            INResterValue *value = [_parser elementValue];

            NSInteger nextLevel = [_parser elementLevel];
            if (nextLevel <= lastLevel && (nextLevel != 0 || lastLevel != 0)) {
                for (int i = 0; i <= lastLevel - nextLevel; i++) {
                    [path removeLastObject];
                }
            }

            lastLevel = nextLevel;

            [path addObject:name];

            NSString *key = [path componentsJoinedByString:@"."];
            [_valueCache addObjectCreateArrayIfNessecary:value forKey:key];

            NSDictionary *attributes = [_parser attributes];
            if (attributes != nil) {
                for (NSString *attributeName in [attributes allKeys]) {
                    NSString *keyA = [NSString stringWithFormat:@"%@#%@", key, attributeName];
                    [_valueCache addObjectCreateArrayIfNessecary:[attributes valueForKey:attributeName] forKey:keyA];
                }
            }

//        NSLog(@"%@ -> %@ (level: %d)", key, value, lastLevel);
        }

        _parsed = YES;
    }

    - (void)gotoValueForPath:(NSString *)aPath {
        NSArray *pathComponents = [aPath componentsSeparatedByString:@"."];
        for (NSString *pathComponent in pathComponents) {
            [_parser gotoElementWithName:pathComponent];
        }

    }

    - (INResterValue *)valueForPath:(NSString *)aKey {
        id value = [_valueCache valueForKey:aKey];
        if (value != nil && [value isKindOfClass:[NSArray class]]) {
            value = [value objectAtIndex:0];
        }

        return value;
    }

    - (NSEnumerator *)valuesForPath:(NSString *)aKey {
        id value = [_valueCache valueForKey:aKey];
        if (value != nil && [value isKindOfClass:[NSArray class]]) {
            return [(NSArray *) value objectEnumerator];
        } else if (value != nil) {
            return [[NSArray arrayWithObject:value] objectEnumerator];
        }

        return nil;
    }
    
    - (void)objectForPath:(NSString*)aPath {
        
    }

    - (void)dealloc {
        [_pathCache release];
        [_valueCache release];
        [_parser release];
        [super dealloc];
    }

@end
