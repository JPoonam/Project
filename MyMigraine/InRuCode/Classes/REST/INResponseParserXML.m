//
//  Created by alex on 4/8/11.
//


#import "INResponseParserXML.h"
#import "INResterValue.h"

@interface INResponseParserXML (Private)

    - (void)readAttributes;
    - (void)readText;

@end

@implementation INResponseParserXML

    - (id)initWithString:(NSString*)aString {
        self = [super init];
        if (self) {
            _source = [aString copy];

            _currentTagStartPosition = -1;
            _currentTagEndPosition = -1;

            _currentElementAttributes = [[NSMutableDictionary alloc] init];
        }

        return self;
    }

    - (void)readAttributes {
        if (_attributesWereRead) {
            return;
        }

        static unichar chEquals = 0;
        static unichar chQuote = 0;
        static unichar chApos = 0;
        static unichar chGT = 0;
        static unichar chSlash = 0;

        if (chEquals == 0) {
            chEquals = [@"=" characterAtIndex:0];
            chQuote = [@"\"" characterAtIndex:0];
            chApos = [@"'" characterAtIndex:0];
            chGT = [@">" characterAtIndex:0];
            chSlash = [@"/" characterAtIndex:0];
        }

        NSCharacterSet *spaceChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];

        _attributesWereRead = YES;

        [_currentElementAttributes removeAllObjects];

        NSUInteger index = _currentTagNameRange.location + _currentTagNameRange.length;
        NSUInteger attributeNameStartIndex = 0;
        NSUInteger attributeNameEndIndex = 0;
        NSUInteger attributeValueStartIndex = 0;
        NSUInteger attributeValueEndIndex = 0;
        BOOL readingAttributeName = NO;
        BOOL readingAttributeValue = NO;
        BOOL readingQuoteIsApos = NO;

        NSUInteger length = [_source length];
        while (index < length) {
            unichar ch = [_source characterAtIndex:index];

            BOOL chIsQuote = ch == chQuote || ch == chApos;

            if (readingAttributeName) {
                if (attributeNameEndIndex == 0 && ([spaceChars characterIsMember:ch] || ch == chEquals)) {
                    attributeNameEndIndex = index;
                }

                if (chIsQuote) {
                    readingQuoteIsApos = ch == chApos;

                    readingAttributeName = NO;
                    readingAttributeValue = YES;

                    attributeValueStartIndex = 0;
                    attributeValueEndIndex = 0;
                }
            } else if (readingAttributeValue) {
                if (attributeValueStartIndex == 0) {
                    attributeValueStartIndex = index;
                } else {
                    if ((ch == chQuote && !readingQuoteIsApos) || (ch == chApos && readingQuoteIsApos)) {
                        attributeValueEndIndex = index;

                        NSString *key = [_source substringWithRange:NSMakeRange(attributeNameStartIndex, attributeNameEndIndex - attributeNameStartIndex)];
                        NSString *value = [_source substringWithRange:NSMakeRange(attributeValueStartIndex, attributeValueEndIndex - attributeValueStartIndex)];
                        [_currentElementAttributes setObject:value forKey:key];

                        readingAttributeValue = NO;
                    }
                }
            } else {
                if (ch == chGT) {
                    _currentTagAttributesEndPosition = index;
                    if ([_source characterAtIndex:index - 1] == chSlash) {
                        _currentTagEndPosition = index;
                        _textWasRead = YES;
                        _currentTextRange = NSMakeRange(0, 0);
                    }

                    break;
                } else if (ch == chEquals || chIsQuote) {
                    @throw [NSException exceptionWithName:@"INResponseParser exception" reason:@"Attribute has no name." userInfo:nil];
                } else if (![spaceChars characterIsMember:ch] && ch != chSlash) {
                    attributeNameStartIndex = index;
                    attributeNameEndIndex = 0;
                    readingAttributeName = YES;
                }
            }

            index++;
        }
    }

    - (void)readText {
        [self readAttributes];

        if (_textWasRead) {
            return;
        }

        _textWasRead = YES;

        static unichar chBracket = 0;
        static unichar chLt = 0;
        static unichar chGt = 0;

        if (chBracket == 0) {
            chBracket = [@"]" characterAtIndex:0];
            chLt = [@"<" characterAtIndex:0];
            chGt = [@">" characterAtIndex:0];
        }

        BOOL hasCDATA = NO;

        if ([_source length] > _currentTagAttributesEndPosition + 1 + 9) {
            NSString *maybeCDATA = [_source substringWithRange:NSMakeRange((NSUInteger)(_currentTagAttributesEndPosition + 1), 9)];
            hasCDATA = [maybeCDATA isEqualToString:@"<![CDATA["];
        }

        NSUInteger index = (NSUInteger)(_currentTagAttributesEndPosition + 1 + (hasCDATA ? 9 : 0));
        _currentTextRange.location = index;

        NSUInteger length = [_source length];
        while (index < length) {
            unichar ch = [_source characterAtIndex:index];

            if (ch == chLt || (hasCDATA && ch == chBracket && [_source characterAtIndex:index + 1] == chBracket && [_source characterAtIndex:index + 2] == chGt)) {
                _currentTextRange.length = index - _currentTextRange.location;
                break;
            }

            index++;
        }
    }

    - (NSString *)elementName {
        if (_currentTagNameRange.location == NSNotFound) {
            @throw [NSException exceptionWithName:@"INResponseParser exception" reason:@"Tag is not selected. Use jumpToNextElementWithTagName to jump to a tag." userInfo:nil];
        }

        return [[[_source substringWithRange:_currentTagNameRange] copy] autorelease];
    }

    - (INResterValue*)attributeWithName:(NSString*)aName {
        [self readAttributes];
        return [INResterValue value:[_currentElementAttributes objectForKey:aName]];
    }

    - (NSDictionary*)attributes {
        [self readAttributes];
        return _currentElementAttributes;
    }

    - (INResterValue *)elementValue {
        [self readText];
        return [INResterValue value:[_source substringWithRange:_currentTextRange]];
    }

    - (NSInteger)elementLevel {
        return _currentTagLevel;
    }

    // returns NO if tag was not found
    - (BOOL)jumpToNextElementWithName:(NSString*)aName {
        static unichar chLT = 0;
        static unichar chGT = 0;
        static unichar chSlash = 0;
        static unichar chQuestion = 0;

        if (chLT == 0) {
            chLT = [@"<" characterAtIndex:0];
            chGT = [@">" characterAtIndex:0];
            chSlash = [@"/" characterAtIndex:0];
            chQuestion = [@"?" characterAtIndex:0];
        }

        NSUInteger startIndex = 0;

        if (_currentTagStartPosition >= 0) {
            startIndex = (NSUInteger)_currentTagStartPosition + 1;
        }

        if (_currentTagEndPosition >= 0) {
            startIndex = (NSUInteger)_currentTagEndPosition;
        }

        if ([aName isEqualToString:@"*"]) {
            aName = @"";
        }

        NSRange range;
        while (true) {
            range = [_source rangeOfString:[NSString stringWithFormat:@"<%@", aName] options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex, [_source length] - startIndex)];

            if (range.location == NSNotFound) {
                break;
            }

            if ([_source characterAtIndex:(NSUInteger)(range.location + 1)] != chQuestion && [_source characterAtIndex:(NSUInteger)(range.location + 1)] != chSlash) {
                break;
            } else {
                startIndex = range.location + 1;
            }
        }

        if (range.location == NSNotFound) {
            return NO;
        }

        // определим новый уровень вложенности
        NSInteger currentPosition = _currentTagStartPosition + 1;
        while (currentPosition <= range.location) {
            NSInteger ltIndex = indexOfSymbolInStringStartingAt(chLT, _source, currentPosition);
            NSInteger gtIndex = indexOfSymbolInStringStartingAt(chGT, _source, currentPosition);

            if (gtIndex < ltIndex) {
                if ([_source characterAtIndex:(NSUInteger)(gtIndex - 1)] == chSlash) {
                    _currentTagLevel--;
                }

                currentPosition = gtIndex + 1;
            } else {
                if ([_source characterAtIndex:(NSUInteger)(ltIndex + 1)] != chQuestion) {
                    if ([_source characterAtIndex:(NSUInteger)(ltIndex + 1)] == chSlash) {
                        _currentTagLevel--;
                    } else {
                        _currentTagLevel++;
                    }
                }

                currentPosition = ltIndex + 1;
            }
        }

        _currentTagStartPosition = range.location;
        _currentTagEndPosition = -1;
        _currentTagNameRange.location = range.location + 1;
        _currentTagNameRange.length = (NSUInteger)(indexOfSymbolInStringStartingAt(IndexSearchingTypeNotALetter, _source, _currentTagNameRange.location) - _currentTagNameRange.location);

        _attributesWereRead = NO;
        _textWasRead = NO;

        return YES;
    }

    - (BOOL)skipTagWithName:(NSString*)aTagName {
        NSUInteger startIndex = 0;

        if (_currentTagStartPosition >= 0) {
            startIndex = (NSUInteger)_currentTagStartPosition + 1;
        }

        NSRange range = [_source rangeOfString:[NSString stringWithFormat:@"</%@", aTagName] options:NSCaseInsensitiveSearch range:NSMakeRange(startIndex, [_source length] - startIndex)];
        if (range.location == NSNotFound) {
            return NO;
        }

        range = [_source rangeOfString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(range.location, [_source length] - range.location)];

        _currentTagStartPosition = range.location + 1;
        _currentTagEndPosition = -1;
        _currentTagNameRange.location = 0;
        _currentTagNameRange.length = 0;

        _attributesWereRead = NO;
        _textWasRead = NO;

        return YES;
    }

    - (INResterValue *)valueForTag:(NSString*)aTagName {
        BOOL hasNext = [self jumpToNextElementWithName:aTagName];
        return hasNext ? [self elementValue] : nil;
    }

    - (NSInteger)getCurrentElementStartPosition {
        return _currentTagStartPosition;
    }

    - (void)setCurrentPosition:(NSInteger)aPosition {
        _currentTagStartPosition = aPosition;
    }

    - (BOOL)gotoNextElement {
        return [self jumpToNextElementWithName:@"*"];
    }

    - (BOOL)gotoElementWithName:(NSString*)aName {
        return [self jumpToNextElementWithName:aName];
    }

    - (void)dealloc {
        [_source release];
        [_currentElementAttributes release];
        [super dealloc];
    }

@end
