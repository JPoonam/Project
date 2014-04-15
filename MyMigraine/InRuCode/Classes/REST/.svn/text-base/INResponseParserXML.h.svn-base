//
//  Created by alex on 4/8/11.
//


#import <Foundation/Foundation.h>
#import "INResterValue.h"


@interface INResponseParserXML : NSObject<INResterParserPositioner> {
    NSString *_source;

    NSInteger _currentTagStartPosition; // начало тэга, ищется при джампах
    NSInteger _currentTagEndPosition;
    NSInteger _currentTagAttributesEndPosition; // если прочитаны атрибуты, то обозначает окончание тэга/начало внутренностей тэга.

    NSRange _currentTagNameRange;
    NSRange _currentTextRange;
    NSInteger _currentTagLevel;
    NSMutableDictionary *_currentElementAttributes;

    BOOL _attributesWereRead;
    BOOL _textWasRead;
}

- (id)initWithString:(NSString*)aString;

- (INResterValue*)attributeWithName:(NSString*)aName;

- (BOOL)jumpToNextElementWithName:(NSString*)aName;

- (INResterValue *)valueForTag:(NSString*)aTagName;

- (BOOL)skipTagWithName:(NSString *)aTagName;

- (NSInteger)getCurrentElementStartPosition;
- (void)setCurrentPosition:(NSInteger)aPosition;

@end
