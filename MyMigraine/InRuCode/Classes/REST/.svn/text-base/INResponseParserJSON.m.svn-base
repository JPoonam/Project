//
//  Created by alex on 5/6/11.
//


#import "INResponseParserJSON.h"

@implementation INResponseParserJSON

- (id)initWithString:(NSString *)aString {
    self = [super init];
    if (self) {
        _source = [aString copy];
        _currentPosition = 0;
        _currentElementLevel = 0;
    }

    return self;
}

- (unichar)currentChar {
    if (_currentPosition >= [_source length]) {
        return 0;
    }

    return [_source characterAtIndex:(NSUInteger)_currentPosition];
}

- (BOOL)isWhitespace {
    if (_currentPosition >= [_source length]) {
        return YES;
    }

    static NSCharacterSet *whitespaces = nil;
    if (whitespaces == nil) {
        whitespaces = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
    }

    return [whitespaces characterIsMember:[self currentChar]];
}

- (BOOL)isComma {
    if (_currentPosition >= [_source length]) {
        return NO;
    }

    static unichar chComma = 0;

    if (chComma == 0) {
        chComma = [@"," characterAtIndex:0];
    }

    unichar ch = [self currentChar];
    return ch == chComma;
}

- (void)skipSpaces {
    NSInteger length = [_source length];
    while (_currentPosition < length && [self isWhitespace]) {
        _currentPosition++;
    }
}

- (void)moveToSymbol:(unichar)aStopSymbol {
    _currentPosition = indexOfSymbolInStringStartingAt(aStopSymbol, _source, _currentPosition);
}

- (NSString *)readSomething {
    static unichar quote = 0;
    static unichar apostroph = 0;
    static unichar openBrace = 0;
    static unichar closeBrace = 0;
    static unichar openBracket = 0;
    static unichar closeBracket = 0;

    if (quote == 0) {
        quote = [@"\"" characterAtIndex:0];
        apostroph = [@"'" characterAtIndex:0];
        openBrace = [@"{" characterAtIndex:0];
        closeBrace = [@"}" characterAtIndex:0];
        openBracket = [@"[" characterAtIndex:0];
        closeBracket = [@"]" characterAtIndex:0];
    }

    [self skipSpaces];

    BOOL isQuotedString = NO;
    BOOL isQuoteDouble = NO;

    if ([self currentChar] == '"') {
        isQuotedString = YES;
        isQuoteDouble = YES;
        _currentPosition++;
    } else if ([self currentChar] == '\'') {
        isQuotedString = YES;
        isQuoteDouble = NO;
        _currentPosition++;
    }

    NSMutableString *result = [NSMutableString string];

    while (true) {
        if (_currentPosition >= [_source length]) {
            break;
        }

        if (!isQuotedString && ([self isWhitespace] || [self isComma])) {
            break;
        }

        unichar ch = [self currentChar];

        if (isQuotedString && isQuoteDouble && ch == quote) {
            _currentPosition++;
            break;
        } else if (isQuotedString && !isQuoteDouble && ch == apostroph) {
            _currentPosition++;
            break;
        }

        if (!isQuotedString && (ch == openBrace || ch == closeBrace || ch == openBracket || ch == closeBracket)) {
            break;
        }

        [result appendFormat:@"%C", ch];
        _currentPosition++;
    }

    return [NSString stringWithString:result];
}

- (BOOL)jumpToNextElementWithName:(NSString *)aName {
    static unichar colon = 0;
    static unichar comma = 0;
    static unichar openBrace = 0;
    static unichar closeBrace = 0;
    static unichar openBracket = 0;
    static unichar closeBracket = 0;

    if (colon == 0) {
        colon = [@":" characterAtIndex:0];
        comma = [@"," characterAtIndex:0];
        openBrace = [@"{" characterAtIndex:0];
        closeBrace = [@"}" characterAtIndex:0];
        openBracket = [@"[" characterAtIndex:0];
        closeBracket = [@"]" characterAtIndex:0];
    }

    [self skipSpaces];

    NSUInteger length = [_source length];
    unichar ch = [self currentChar];
    while (_currentPosition < length) {
        if (ch == openBrace) {
            _currentElementLevel++;
        } else if (ch == closeBrace) {
            _currentElementLevel--;
        } else if (ch == comma || ch == openBracket || ch == closeBracket) {
            // simply run
        } else {
            break;
        }

        _currentPosition++;

        if (_currentPosition >= length) {
            break;
        }

        [self skipSpaces];

        ch = [self currentChar];
    }


    NSInteger savedPosition = _currentPosition;
    BOOL found = NO;
    BOOL anyElement = [aName isEqualToString:@"*"];

    while (_currentPosition < length) {
        [_currentElementName autorelease];
        _currentElementName = [[self readSomething] copy];

        if (anyElement || [_currentElementName compare:aName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [self moveToSymbol:colon];
            _currentPosition++;
            found = YES;
            break;
        }

        [self moveToSymbol:colon];
        _currentPosition++;

        [self skipSpaces];

        if (_currentPosition >= length) {
            break;
        }

        ch = [self currentChar];
        if (ch == openBrace) {
            _currentElementLevel++;
            _currentPosition++;
        } else if (ch == closeBrace) {
            _currentElementLevel--;
            _currentPosition++;
        } else {
            [self moveToSymbol:comma];
            _currentPosition++;
        }

        [self skipSpaces];
    }

    if (!found) {
        _currentPosition = savedPosition;
    }

    return found;
}

- (INResterValue*)getValueForName:(NSString*)aName {
    NSInteger currentPosition = _currentPosition;

    BOOL ok = [self jumpToNextElementWithName:aName];
    if (!ok) {
        return nil;
    }

    INResterValue *result = [INResterValue value:[self readSomething]];

    _currentPosition = currentPosition;

    return result;
}

- (NSString*)elementName {
    return _currentElementName;
}

// нужно вызывать сразу после jumpToNextElementWithName или jumpToNextElement
- (INResterValue*)elementValue {
    return [INResterValue value:[self readSomething]];
}

- (NSDictionary*)attributes {
    return nil;
}

- (NSInteger)elementLevel {
    return _currentElementLevel;
}

- (NSInteger)getCurrentElementStartPosition {
    return _currentPosition;
}

- (void)setCurrentPosition:(NSInteger)aPosition {
    _currentPosition = aPosition;
}

- (BOOL)gotoNextElement {
    return [self jumpToNextElementWithName:@"*"];
}

- (BOOL)gotoElementWithName:(NSString*)aName {
    return [self jumpToNextElementWithName:aName];
}

- (void)dealloc {
    [_source release];

    [super dealloc];
}

@end
