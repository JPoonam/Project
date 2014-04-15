//
//  Created by alex on 5/6/11.
//


#import <Foundation/Foundation.h>
#import "INResterValue.h"


@interface INResponseParserJSON : NSObject<INResterParserPositioner> {
    NSString *_source;
    NSInteger _currentPosition;
    NSString *_currentElementName;
    NSInteger _currentElementLevel;
}

- (id)initWithString:(NSString*)aString;
- (INResterValue *)getValueForName:(NSString *)aName;

- (NSInteger)getCurrentElementStartPosition;
- (void)setCurrentPosition:(NSInteger)aPosition;

@end
