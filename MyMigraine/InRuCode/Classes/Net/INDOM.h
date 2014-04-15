//!
//! @file INDOM.h
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2011 InRu
//! 
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//! 
//!     http://www.apache.org/licenses/LICENSE-2.0
//! 
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.
//!
//++

#import <Foundation/Foundation.h>
#import "INCommonTypes.h"
#import "INJSONParser.h"
#import "INObject.h"

typedef enum { 
    INDOMSourceXML,
	INDOMSourceJSON
} INDOMSourceType;

//==================================================================================================================================
//==================================================================================================================================

@interface INDOMElement : INObject2 {
@private 
    INDOMElement * _parent;
    NSString * _data; // тут сделано с подвыпадвертом. это может быть и NSMutableString. см. addData 
    BOOL _dataIsMutableString;
}

@property(nonatomic,readonly) INDOMElement * parent;
@property(nonatomic,readonly) NSDictionary * attributes; // alias to properties
@property(nonatomic,retain)   NSString * data;
@property(nonatomic,readonly) NSString * trimmedData;    // data без пробелов в начале и конце
@property(nonatomic,readonly) NSInteger integerValue;
@property(nonatomic,readonly) float floatValue;
@property(nonatomic,readonly) double doubleValue;
@property(nonatomic,readonly) BOOL boolValue;
@property(nonatomic,readonly) NSString * pathToRoot;

- (void)dump;

- (INDOMElement *)itemWithName:(NSString *)name;
- (INDOMElement *)itemAtPath:(NSString *)path;
- (id)attributeWithName:(NSString *)name;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INDOMDocument : INObject <INJSONParserDelegate> {
@private
    INDOMElement * _rootElement;
    NSError * _parserError;   
    INDOMSourceType _sourceType;
    INDOMElement * _currentElement; // used for parsing // 
}

- (id)initWithData:(NSData *)data ofType:(INDOMSourceType)sourceType;
- (id)initWithString:(NSString *)string ofType:(INDOMSourceType)sourceType;

@property(nonatomic,readonly) INDOMElement * rootElement;  
@property(nonatomic,retain) NSError * parserError;

- (INDOMElement *)elementAtPath:(NSString *)path;
- (void)dump;
+ (void)dumpXMLString:(NSString *)xml;
- (NSString *)formatDocument;

@end
