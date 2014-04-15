//
//  Created by alex on 5/7/11.
//


#import <Foundation/Foundation.h>

@class INResterValue;

typedef enum {
    IndexSearchingTypeSpace = 0,
    IndexSearchingTypeNotALetter = 1
} IndexSearchingType;

NSInteger indexOfSymbolInStringStartingAt(unichar aStopSymbol,  NSString * aString,  NSInteger aStartIndex);

@protocol INResterParserPositioner

- (NSInteger)getCurrentElementStartPosition;
- (void)setCurrentPosition:(NSInteger)aPosition;

- (NSString*)elementName;
- (INResterValue *)elementValue;
- (NSInteger)elementLevel;

- (NSDictionary*)attributes;

- (BOOL)gotoNextElement;
- (BOOL)gotoElementWithName:(NSString*)aName;

@end

@interface INResterValue : NSObject {
    BOOL _isQuotedString;

    BOOL _isCalculatedNull;
    BOOL _isNull;

    BOOL _isCalculatedTrueFalse;
    BOOL _isTrue;

    NSString *_string;
}

+ (INResterValue*)value:(NSString*)aString;

- (id)initWithString:(NSString *)aString;

- (BOOL)isEqualToString:(NSString*)aString;

- (NSString*)stringValue;
- (NSInteger)intValue;
- (CGFloat)floatValue;
- (NSInteger)isNull;
- (NSInteger)isTrue;
- (NSInteger)isFalse;

@end
