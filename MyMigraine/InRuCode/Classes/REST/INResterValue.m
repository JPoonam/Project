//
//  Created by alex on 5/7/11.
//


#import "INResterValue.h"

// aStopSymbol is 0 -> find next space
NSInteger indexOfSymbolInStringStartingAt(unichar aStopSymbol,  NSString * aString,  NSInteger aStartIndex) {
    static unichar chQuote = 0;
    static unichar chDoubleQuote = 0;
    static unichar chBackSlash = 0;
    static NSMutableCharacterSet *letters = nil;
    

    if (chQuote == 0) {
        chQuote = [@"'" characterAtIndex:0];
        chDoubleQuote = [@"\"" characterAtIndex:0];
        chBackSlash = [@"\\" characterAtIndex:0];

        letters = [[NSMutableCharacterSet alphanumericCharacterSet] retain];
        [letters addCharactersInString:@"_-"];
    }

    BOOL inQuote = NO;
    BOOL inDoubleQuote = NO;

    unichar prevCharacter = 0;

    NSInteger currentPosition = aStartIndex;

    NSUInteger length = [aString length];
    while (currentPosition < length) {
        unichar ch = [aString characterAtIndex:(NSUInteger)currentPosition];

        if (ch == chQuote) {
            if (!inQuote && !inDoubleQuote && prevCharacter != chBackSlash) {
                inQuote = YES;
            } else if (inQuote && prevCharacter != chBackSlash) {
                inQuote = NO;
            }
        } else if (ch == chDoubleQuote) {
            if (!inQuote && !inDoubleQuote && prevCharacter != chBackSlash) {
                inDoubleQuote = YES;
            } else if (inDoubleQuote && prevCharacter != chBackSlash) {
                inDoubleQuote = NO;
            }
        }

        if (!inQuote && !inDoubleQuote && (
                ch == aStopSymbol ||
                (aStopSymbol == IndexSearchingTypeSpace && [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch]) ||
                (aStopSymbol == IndexSearchingTypeNotALetter && ![letters characterIsMember:ch])
            )) {
            break;
        }

        prevCharacter = ch;
        currentPosition++;
    }

    return currentPosition;
}

@implementation INResterValue

+ (INResterValue*)value:(NSString*)aString {
    return [[[self alloc] initWithString:aString] autorelease];
}

- (id)initWithString:(NSString *)aString {
    static NSCharacterSet *setDoubleQuotes = nil;
    static NSCharacterSet *setSingleQuotes = nil;

    if (setDoubleQuotes == nil) {
        setDoubleQuotes = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        setSingleQuotes = [NSCharacterSet characterSetWithCharactersInString:@"'"];
    }

    self = [super init];
    if (self) {
        _string = aString;

        if ([_string hasPrefix:@"\""] && [_string hasSuffix:@"\""]) {
            _isQuotedString = YES;
            _string = [_string stringByTrimmingCharactersInSet:setDoubleQuotes];
        } else if ([_string hasPrefix:@"'"] && [_string hasSuffix:@"'"]) {
            _isQuotedString = YES;
            _string = [_string stringByTrimmingCharactersInSet:setSingleQuotes];
        }
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (null: %@; true: %@)", _string, [self isNull] ? @"YES" : @"NO", [self isTrue] ? @"YES" : @"NO"];
}

- (BOOL)isEqualToString:(NSString*)aString {
    return [_string isEqualToString:aString];
}

- (NSString*)stringValue {
    if ([self isNull]) {
        return nil;
    }

    return _string;
}

- (NSString*)stringTrimmedValue {
    if ([self isNull]) {
        return nil;
    }

    return [_string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSInteger)intValue {
    if ([self isNull]) {
        return 0;
    }

    @try {
        return [_string integerValue];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
    }

    return 0;
}

- (CGFloat)floatValue {
    if ([self isNull]) {
        return 0;
    }

    @try {
        return [_string floatValue];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
    }

    return 0;
}

- (NSInteger)isNull {
    if (_isQuotedString) {
        return NO;
    } else {
        if (!_isCalculatedNull) {
            _isNull = ([_string compare:@"null" options:NSCaseInsensitiveSearch] == NSOrderedSame);
            _isCalculatedNull = YES;
        }

        return _isNull;
    }
}

- (NSInteger)isTrue {
    if (_isQuotedString) {
        return NO;
    } else {
        if (!_isCalculatedTrueFalse) {
            _isTrue = ([_string compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame);

            if (!_isTrue) {
                _isTrue = ([_string compare:@"1" options:NSCaseInsensitiveSearch] == NSOrderedSame);
            }

            if (!_isTrue) {
                _isTrue = ([_string compare:@"yes" options:NSCaseInsensitiveSearch] == NSOrderedSame);
            }

            _isCalculatedTrueFalse = YES;
        }

        return _isTrue;
    }
}

- (NSInteger)isFalse {
    return ![self isTrue];
}

@end
