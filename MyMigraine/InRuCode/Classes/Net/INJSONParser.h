//
//  INJSONParser.h
//  InruCode
//
//  Created by Igor Pokrovsky on 5/18/11.
//  Copyright 2011 InRu. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {INJSONElementValueUnknown	= 0,		/* Yet undefined */
			  INJSONElementValueHash	= 1,		/* Hash map */
			  INJSONElementValueArray	= 2,		/* Array */
			  INJSONElementValueString	= 3,		/* Unicode string */
			  INJSONElementValueNumber	= 4,		/* Decimal number */
			  INJSONElementValueBoolean = 5,		/* True / False */
			  INJSONElementValueNull	= 6			/* Null */
} INJSONElementValueType;


typedef enum {INJSONParserGenericError, INJSONParseDelegateAbortedParseError} INJSONParserErrorCode;

/*==================================================================================================================================*/
/* @protocol INJSONParserDelegate */
/*==================================================================================================================================*/

@class INJSONParser;

@protocol INJSONParserDelegate <NSObject>

- (void) injsonParser:(INJSONParser *)parser didStartElement:(NSString *)elementName ofType:(INJSONElementValueType)elementType;
- (void) injsonParser:(INJSONParser *)parser didEndElement:(NSString *)elementName ofType:(INJSONElementValueType)elementType;
- (void) injsonParser:(INJSONParser *)parser foundCharacters:(NSString *)string;

@optional
- (void) injsonParserDidStartDocument:(INJSONParser *)parser;
- (void) injsonParserDidEndDocument:(INJSONParser *)parser;
- (void) injsonParser:(INJSONParser *)parser parseErrorOccurred:(NSError *)parseError;

@end


/*==================================================================================================================================*/
/* @class INJSONParser */
/*==================================================================================================================================*/

@interface INJSONParser : NSObject {
	id <INJSONParserDelegate> _delegate;
	
@private
	/* a buffer filled from input string */
	CFStringInlineBuffer	_charactersBuffer;
	CFIndex					_bufferLength;
	
	/* index of unicode character currently being processed */
	CFIndex					_currentIndex;
	
	/* a temporal storage */
	CFMutableStringRef		_tmp;
	
	/* a flag, shows if parsing should continue */
	BOOL					_parsingAborted;
	
	/* error, if any */
	NSError					*_parseError;
}
@property (nonatomic, assign) id <INJSONParserDelegate> delegate;
@property (nonatomic, readonly) NSError *parseError;

- (id) initWithString:(NSString*)jsonString;
- (BOOL) parse;
- (void) abortParsing;

@end
