//
//  INJSONParser.m
//  InruCode
//
//  Created by Igor Pokrovsky on 5/18/11.
//  Copyright 2011 InRu. All rights reserved.
//

#import "INJSONParser.h"


//==================================================================================================================================
// @interface INJSONParser
//==================================================================================================================================

@interface INJSONParser ()

- (NSError*) parserErrorWithCode:(INJSONParserErrorCode)code description:(NSString*)description;

- (BOOL) parseValueOfElementWithName:(CFStringRef)name;
- (BOOL) parseElementValuePair;

@end


//==================================================================================================================================
// @class INJSONParser
//==================================================================================================================================

@implementation INJSONParser
@synthesize delegate = _delegate;
@synthesize parseError = _parseError;

- (id) initWithString:(NSString*)jsonString {
	if ((self = [super init])) {
		_bufferLength = CFStringGetLength((CFStringRef)jsonString);
		CFStringInitInlineBuffer((CFStringRef)jsonString, &_charactersBuffer, CFRangeMake(0, _bufferLength));
		
		_tmp = CFStringCreateMutable(NULL, 512);
	}
	
	return self;
}


- (void) dealloc {
	CFRelease(_tmp);
	[_parseError release];
	[super dealloc];
}

/*----------------------------------------------------------------------------------------------------------------------------------*/


char char2hex(UniChar ch) {
	return ('0' <= ch && ch <= '9') ? (ch - '0') :
	( ('A' <= ch && ch <= 'F') ? (ch - 'A') + 10 : ( ('a' <= ch && ch <= 'f') ? (ch - 'a') + 10 : -1));
}


/*
 * Collect all characters up to the given one
 * Tell delegate of an error if searching character not found
 */
- (CFStringRef) getStringUpToCharacter:(UniChar)character {
	BOOL	characterFound =  NO;
	BOOL	escapedSymbol = NO;
	
	/* clear temporal storage */
	CFStringDelete(_tmp, CFRangeMake(0, CFStringGetLength(_tmp)));
	
	while (++_currentIndex < _bufferLength) {
		UniChar ch = CFStringGetCharacterFromInlineBuffer(&_charactersBuffer, _currentIndex);
		
		/* next symbol is escaped */
		if (ch == '\\' && !escapedSymbol) {
			escapedSymbol = !escapedSymbol;
		}
		else {
			if (!escapedSymbol && ch == character) {
				characterFound = YES;
				break;
			}
			
			if (escapedSymbol) {
				if (ch == '\\') {
					CFStringAppendFormat(_tmp, NULL, CFSTR("\\"));
				}
				else if (ch == 'b') {
					CFStringAppendFormat(_tmp, NULL, CFSTR("\b"));
				}
				else if (ch == 'f') {
					CFStringAppendFormat(_tmp, NULL, CFSTR("\f"));
				}
				else if (ch == 'n') {
					CFStringAppendFormat(_tmp, NULL, CFSTR("\n"));	
				}
				else if (ch == 'r') {
					CFStringAppendFormat(_tmp, NULL, CFSTR("\r"));
				}
				else  if (ch == 't') {
					CFStringAppendFormat(_tmp, NULL, CFSTR("\t"));
				}
				else if (ch == 'u') {
					/* get next 4 symbols */
					if ((_currentIndex+4) < _bufferLength) {
						
						UniChar code = 0;
						short chi[4];
						
						for (int i=0; i<4; i++) {
							ch = CFStringGetCharacterFromInlineBuffer(&_charactersBuffer, ++_currentIndex);

							chi[i] = char2hex(ch);
							
							if (chi[i] < 0) {
								[self parserErrorWithCode:INJSONParserGenericError 
											  description:[NSString stringWithFormat:@"Invalid symbol after \\u: %C!", ch]];
								return nil;
							}
						}
						
						code = (chi[0]<<12) | (chi[1]<<8) | (chi[2]<<4) | chi[3];
						
						CFStringAppendFormat(_tmp, NULL, CFSTR("%C"), code);
					}
					else {
						[self parserErrorWithCode:INJSONParserGenericError 
									  description:@"\\u expects 4 symbols after!"];
					}
				}
				else {
					CFStringAppendCharacters(_tmp, &ch, 1);
				}
			}
			else {
				CFStringAppendCharacters(_tmp, &ch, 1);
			}
			
			escapedSymbol = NO;
		}
		
	}
	
	/* return error */
	if (!characterFound) {
		[self parserErrorWithCode:INJSONParserGenericError 
					  description:[NSString stringWithFormat:@"Closing '%C' not found", character]];
	}
	
	return _tmp;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*
 * Skip everything until requested character not found
 */
- (BOOL) skipUpToCharacter:(UniChar)character {
	while (++_currentIndex < _bufferLength) {
		UniChar ch = CFStringGetCharacterFromInlineBuffer(&_charactersBuffer, _currentIndex);
		
		if (ch == character) {
			return YES;
		}
	}
	
	return NO;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*
 * Parse element name
 * Returns NULL if none found
 */

// mk: переименовал метод для того, что-бы анализатор не ругался на излишне ритейненый объект
- (CFStringRef)copyElementName {
	CFStringRef elementName = NULL;
	
	while (++_currentIndex < _bufferLength) {
		UniChar ch = CFStringGetCharacterFromInlineBuffer(&_charactersBuffer, _currentIndex);
		
		if (ch == '"') {
			elementName = CFStringCreateCopy(NULL, [self getStringUpToCharacter:'"']);
			break;
		}
		else if (ch == '}') {	/* end of hash object */
			break;
		}
	}
	
	return elementName; 
}


/*----------------------------------------------------------------------------------------------------------------------------------*/

/*
 * Parse element value
 * Returns FALSE if not found or end of array block
 */
- (BOOL) parseValueOfElementWithName:(CFStringRef)name {
	BOOL ret = TRUE;
	BOOL escapedSymbol = NO;
	BOOL foundCharacters = NO;
	NSString *elementName = nil;
	
	if (name) {
		elementName = [NSString stringWithString:(NSString*)name];
	}
	
	CFMutableStringRef unparsedValue = CFStringCreateMutable(NULL, 128);
	
	while (++_currentIndex < _bufferLength) {
		UniChar ch = CFStringGetCharacterFromInlineBuffer(&_charactersBuffer, _currentIndex);
		
		/* next symbol is escaped */
		if (ch == '\\') {
			escapedSymbol = !escapedSymbol;
		}
		else {
			if (!escapedSymbol) {
								
				/* end of object */
				if (ch == '}' || ch == ']') {
					foundCharacters = YES;
					ret = FALSE;
					break;
				}
				/* end of value */
				else if (ch == ',') {
					foundCharacters = YES;
					break;
				}
				/* start of hash object */
				else if (ch == '{') {
					[_delegate injsonParser:self didStartElement:elementName ofType:INJSONElementValueHash];
					
					while ([self parseElementValuePair]) {
						if (_parsingAborted) {
							break;
						}
					}
					
					[_delegate injsonParser:self didEndElement:elementName ofType:INJSONElementValueHash];
					
					break;
				}
				/* start of array */
				else if (ch == '[') {
					[_delegate injsonParser:self didStartElement:elementName ofType:INJSONElementValueArray];
					
					while ([self parseValueOfElementWithName:nil]) {
						if (_parsingAborted) {
							break;
						}	
					}
					
					[_delegate injsonParser:self didEndElement:elementName ofType:INJSONElementValueArray];
					
					break;
				}
				/* start of string */
				else if (ch == '"') {
					[_delegate injsonParser:self didStartElement:elementName ofType:INJSONElementValueString];
					
					CFStringRef elementValue = [self getStringUpToCharacter:'"'];
					if (elementValue) {
						[_delegate injsonParser:self foundCharacters:[NSString stringWithString:(NSString*)elementValue]];
					}
					
					[_delegate injsonParser:self didEndElement:elementName ofType:INJSONElementValueString];
					
					break;
				}
			}			
			escapedSymbol = NO;
		}
		CFStringAppendCharacters(unparsedValue, &ch, 1);
	}
	
	/*
	 * We come here if we found a simple value other then of string type
	 */
	if (foundCharacters) {
		/* get rid of whitespaces from both ends */
		CFStringTrimWhitespace(unparsedValue);
	
		if (CFStringGetLength(unparsedValue) > 0) {
            /* Tell delegate o this element */
            [_delegate injsonParser:self didStartElement:elementName ofType:INJSONElementValueUnknown];
			
            [_delegate injsonParser:self foundCharacters:[NSString stringWithString:(NSString*)unparsedValue]];
            
            [_delegate injsonParser:self didEndElement:elementName ofType:INJSONElementValueUnknown];
		}
	}
	
	
	CFRelease(unparsedValue);
	return ret;
}

									   
/*----------------------------------------------------------------------------------------------------------------------------------*/
							
/*
 * Parse a pair element/value
 * Returns FALSE if any of them not found
 */
- (BOOL) parseElementValuePair {	
	
	CFStringRef elementName = [self copyElementName];
	if (elementName) {
		if ([self skipUpToCharacter:':']) {
			if (![self parseValueOfElementWithName:elementName]) {
				CFRelease(elementName);
				return FALSE;
			}
		}
		else {
			[self parserErrorWithCode:INJSONParserGenericError description:@"':' not found"];
			
			CFRelease(elementName);
            return FALSE;
		}
		
		CFRelease(elementName);
		return TRUE;
	}
	
	return FALSE;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/

/*
 * Parse root object and its children recursively
 */
- (BOOL) parseRootElement {
	
	do  {
		UniChar ch = CFStringGetCharacterFromInlineBuffer(&_charactersBuffer, _currentIndex);

		if (ch == '{') {
			[_delegate injsonParser:self didStartElement:nil ofType:INJSONElementValueHash];
			
			while ([self parseElementValuePair]) {
				if (_parsingAborted) {
					break;
				}
			}
			
			[_delegate injsonParser:self didEndElement:nil ofType:INJSONElementValueHash];
			
			return TRUE;
		}
		else if (ch == '[') {
			[_delegate injsonParser:self didStartElement:nil ofType:INJSONElementValueArray];
			
			while ([self parseValueOfElementWithName:nil]) {
				if (_parsingAborted) {
					break;
				}	
			}
			
			[_delegate injsonParser:self didEndElement:nil ofType:INJSONElementValueArray];
			
			return TRUE;
		}
	} while (++_currentIndex < _bufferLength);
	
	[self parserErrorWithCode:INJSONParserGenericError description:@"Root element not found!"];
	return FALSE;
}


/*----------------------------------------------------------------------------------------------------------------------------------*/

/*
 * Parse input string
 */
- (BOOL) parse {
	if (!_parsingAborted) {	
		/* Start document */
		if ([_delegate respondsToSelector:@selector(injsonParserDidStartDocument:)]) {
			[_delegate injsonParserDidStartDocument:self];
		}
		
		[self parseRootElement];
		
		if (!_parseError) {
			/* End document */
			if ([_delegate respondsToSelector:@selector(injsonParserDidEndDocument:)]) {
				[_delegate injsonParserDidEndDocument:self];
			}
		}
	}
	
	return (_parseError ? FALSE : TRUE);
}


/*----------------------------------------------------------------------------------------------------------------------------------*/

/*
 * Abort parsing  
 */

- (void) abortParsing {
    _parsingAborted = YES;
	[self parserErrorWithCode:INJSONParseDelegateAbortedParseError description:@"Parsing abnormally aborted."];
}


/*----------------------------------------------------------------------------------------------------------------------------------*/
/* Parsing error */

- (NSError*) parserErrorWithCode:(INJSONParserErrorCode)code description:(NSString*)description {	
	NSString *errDescription = [NSString stringWithFormat:@"%@: %@", NSStringFromClass([INJSONParser class]), description];
	NSError *err = [NSError errorWithDomain:@"INJSONParserErrorDomain" 
                                       code:code 
                                   userInfo:[NSDictionary dictionaryWithObject:errDescription forKey:NSLocalizedDescriptionKey]];
	
	if (_parseError) {
		[_parseError release];
	}

	_parseError = [err retain];
	
	if ([_delegate respondsToSelector:@selector(injsonParser:parseErrorOccurred:)]) {
		[_delegate injsonParser:self parseErrorOccurred:err];
	}
	
	/* every error is fatal */
	_parsingAborted = YES;
	
	return err;
}

@end

//==================================================================================================================================
//==================================================================================================================================

#if 0

@interface INJSONParserTest: NSObject <INJSONParserDelegate>  { 

}

@end

@implementation INJSONParserTest

- (void)run { 

	NSString *json = 
    @"{"
	@"  \"firstName\": \"Иван\", "
	@"  \"lastName\": \"Иванов\", "
	@"  \"address\": { "
	@"     \"streetAddress\": \"Московское ш., 101, кв.101\", "
	@"     \"city\": \"Ленинград\", "
	@"     \"postalCode\": 101101 "
	@"   }, "
	@"   \"phoneNumbers\": [ 1, 2, "
	@"     \"812 123-1234\", "
	@"     \"916 123-4567\" "
	@"   ],"
    @"   \"This quote:\\\" is in a key\" : \"value backslash:'\\\\' slash:\\/ unichar+1234:\\u00651234 unichar:'\\uabcd' slash-f:'\\f' slash-b:'\\b' quote:'\\\"' newLine:'\\n' CR:'\\r' TAB:'\\t' \"" 
	@"}";
	
    
	INJSONParser *parser = [[INJSONParser alloc] initWithString:json];
	parser.delegate = self;
	[parser parse];
    [parser release];
}


/*----------------------------------------------------------------------------------------------------------------------------------*/
/* INJSONParser */
/*----------------------------------------------------------------------------------------------------------------------------------*/

- (void)injsonParser:(INJSONParser *)parser didStartElement:(NSString *)elementName ofType:(INJSONElementValueType)elementType {
	if (!elementName) {
		elementName = @"null";
	}
		
	NSLog(@"<%@ %d>", elementName, elementType);
}

- (void)injsonParser:(INJSONParser *)parser didEndElement:(NSString *)elementName ofType:(INJSONElementValueType)elementType {
	if (!elementName) {
		elementName = @"null";
	}

	NSLog(@"</%@ %d>", elementName, elementType);
}


- (void)injsonParser:(INJSONParser *)parser foundCharacters:(NSString *)string {
	NSLog(@"%@", string);
}

- (void) injsonParser:(INJSONParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"%@", [parseError description]);
}

@end

__attribute__((constructor)) void TEST() { 
   NSAutoreleasePool * pool = [NSAutoreleasePool new]; 
   INJSONParserTest * test = [INJSONParserTest new];
   [test run];
   [test release];
   [pool release];
   exit(1);
}

#endif
