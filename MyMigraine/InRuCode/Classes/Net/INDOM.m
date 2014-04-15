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

#import "INDOM.h"

//==================================================================================================================================
//==================================================================================================================================

@implementation INDOMElement 

@synthesize data = _data;
@synthesize parent = _parent;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_data release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setParent:(INDOMElement *)parent { 
    _parent = parent;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addData:(NSString *)data { 
    if (!_data) { 
        _data = [data retain]; // в большинстве ситуций у нас только одна строка в элементе. Даже не будем копировать (работает для NSXMLParser как минимум, для JSON надо проверять)
    } else {
        // строка длинная - выгоднее ее сделать NSMutableString 
        if (!_dataIsMutableString) {
            NSMutableString * newDataString = [[NSMutableString alloc] initWithCapacity:_data.length + data.length + 100];
            [newDataString appendString:_data];
            [newDataString appendString:data];
            [_data release];
            _data = newDataString;
            _dataIsMutableString = YES;
        } else {
            [(NSMutableString *)_data appendString:data];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setData:(NSString *)data { 
    if (_data != data) { 
        [_data release];
        _data = [data retain];
        _dataIsMutableString = [data isKindOfClass:NSMutableString.class];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dumpAtLevel:(NSInteger)level {
    NSMutableString * padding = [NSMutableString string];
    for (int i =0; i < level; i++) { 
        [padding appendString:@"  "];
    }
    
    NSMutableArray * attrs = [NSMutableArray array];
    for (id key in self.attributes.allKeys) { 
        [attrs addObject:[NSString stringWithFormat:@"%@='%@'",key,[self.attributes objectForKey:key]]];
    }

    NSString * str1 = [NSString stringWithFormat:@"%@<%@%@%@", padding, self.name, (attrs.count ? @" " : @""), 
                      [attrs componentsJoinedByString:@", "]];
    
    // simple element
    if (self.items.count == 0) {
        if (_data.length == 0) { 
            NSLog(@"%@/>",str1);
        } else { 
            NSLog(@"%@>%@</%@>",str1,_data,self.name);
        }
    } else { 
        NSString * str = [NSString stringWithFormat:@"%@<%@%@%@>", padding, self.name, (attrs.count ? @" " : @""), 
                      [attrs componentsJoinedByString:@", "]];
        NSLog(@"%@",str);
        for (INDOMElement * element in self) { 
            [element dumpAtLevel:level + 1];
        }
        if ([_data inru_trim].length) { 
            NSLog(@"  %@%@",padding,_data);
        }
        str = [NSString stringWithFormat:@"%@</%@>", padding, self.name];
        NSLog(@"%@",str);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dump { 
    [self dumpAtLevel:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)prettyFormatedItemsAtLevel_JSON:(NSInteger)level { 
    // сляпано на скорую руку, просто для просмотра. если нужен полноценный документ, то надо
    // добавить вывод номера, булевых значений, nil и экранирование строк

    NSString * PADDING = @"    ";
    NSMutableString * padding = [NSMutableString string];
    for (int i =0; i < level; i++) { 
        [padding appendString:PADDING];
    }
    NSMutableArray * elementStrings = [NSMutableArray array];
    for (INDOMElement * element in self) {
        BOOL lastElement = (element == self.items.lastObject);
        NSMutableString * string = [NSMutableString stringWithString:padding];
        if (element.name.length) { 
            [string appendFormat:@"\"%@\" : ", element.name];
        }
        if ([element hasItems]) {
            NSString * encloser1 = @"{";
            NSString * encloser2 = @"}";
            if ([[[element itemAtIndex:0] name] length] == 0) { 
                encloser1 = @"[";
                encloser2 = @"]";
            }
            [string appendFormat:@"%@\n", encloser1];
            [string appendFormat:@"%@%@%@", [element prettyFormatedItemsAtLevel_JSON:level+1], 
                                            padding,encloser2];
            if (!lastElement) { 
                [string appendFormat:@",", padding];
            }
        } else { 
            [string appendFormat:@"\"%@\"", element.data];
            if (!lastElement) { 
                [string appendFormat:@","];
            }
        }
        [string appendFormat:@"\n"];
        [elementStrings addObject:string];
    }
    return [elementStrings componentsJoinedByString:@""];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDOMElement *)elementAtPathComponents:(NSArray *)pathes startIndex:(NSInteger)startIndex {
    NSUInteger pathCount = pathes.count; 
    if (startIndex >= pathCount) { 
        return nil;    
    }
    if (![NSString inru_string:self.name isEqualTo:[pathes objectAtIndex:startIndex]]) { 
        return nil;
    }
    
    if (startIndex == pathCount - 1) { 
        return self;
    }
    for (INDOMElement * e in self.items) { 
        INDOMElement * result = [e elementAtPathComponents:pathes startIndex:startIndex + 1];
        if (result) { 
           return result;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)pathToRoot { 
    NSString * name = self.name.length ? self.name : @"";
    if (_parent) { 
        int count = 0, index = 0;
        for (INDOMElement * e in _parent) {
            if ([e hasName:self.name]) {
                if (e == self) { 
                    index = count;
                }
                count++;
            }
        }
        if (count > 1) { 
            name = [NSString stringWithFormat:@"%@[%d]",name, index];
        }
    }
    return _parent ? [NSString stringWithFormat:@"%@/%@", [_parent pathToRoot], name] : name;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDOMElement *)itemWithName:(NSString *)name {
    for (INDOMElement * e in self) { 
        if ([e hasName:name]) { 
            return e;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

/*
- (INDOMElement *)elementAtPath:(NSString *)path { 
    NSMutableCharacterSet * cs = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [cs addCharactersInString:@"/"];
    path = [path stringByTrimmingCharactersInSet:cs];
    NSArray * subPathes = [path componentsSeparatedByString:@"/"];
    return [self elementAtPathComponents:subPathes startIndex:0];  
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDictionary *)attributes { 
    return self.properties;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)trimmedData { 
    return [_data inru_trim];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)integerValue { 
    return [[_data inru_trim] integerValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (float)floatValue { 
    return [[_data inru_trim] floatValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (double)doubleValue { 
    return [[_data inru_trim] doubleValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)boolValue { 
    return [[_data inru_trim] boolValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)attributeWithName:(NSString *)name { 
    return [self propertyForKey:name];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INDOMElement *)itemAtPath:(NSString *)path {
    NSArray * pathes = [path componentsSeparatedByString:@"/"];    
    for (INDOMElement * e in self.items) { 
        INDOMElement * result = [e elementAtPathComponents:pathes startIndex:0];
        if (result) { 
            return result;
        }
    }
    return nil;
}      

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INDOMDocument

@synthesize rootElement = _rootElement;
@synthesize parserError = _parserError;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithData:(NSData *)data ofType:(INDOMSourceType)sourceType {
    self = [super init];
    if (self != nil) {
        _sourceType = sourceType;
        switch (_sourceType) { 
           case INDOMSourceXML:
               { 
                   NSXMLParser * xmlParser = [[NSXMLParser alloc] initWithData:data];
                   xmlParser.delegate = (id)self;
                   if (![xmlParser parse]) {
                       _parserError = [xmlParser.parserError retain];
                   }
                   [xmlParser release];
               }
               break;
				
			case INDOMSourceJSON: {
				id parserClass = NSClassFromString(@"INJSONParser");
				NSAssert(parserClass, @"ip_32f94e23_e4a8_4b5f_af61_950c95614aec include INJSONParse.m in your project!");
		
				NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
				INJSONParser *jsonParser = [[parserClass alloc] initWithString:jsonString];
				jsonParser.delegate = self;
				if (![jsonParser parse]) {
					_parserError = [jsonParser.parseError retain];
				}
				[jsonParser release];
				break;
			}


			default:
               NSAssert(0,@"5e1f5f9a_59d9_4933_9d22_5a5761c6549c");
        }
                          
    }
    return self;
}

/*----------------------------------------------------------------------------------------------------------------------------------*/


- (id)initWithString:(NSString *)string ofType:(INDOMSourceType)sourceType {
    self = [super init];
    if (self != nil) {
        _sourceType = sourceType;
        switch (_sourceType) { 
			case INDOMSourceXML:
			{ 
				NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
				NSXMLParser * xmlParser = [[NSXMLParser alloc] initWithData:data];
				xmlParser.delegate = (id)self;
				if (![xmlParser parse]) {
					_parserError = [xmlParser.parserError retain];
				}
				[xmlParser release];
			}
				break;
				
			case INDOMSourceJSON: {
				id parserClass = NSClassFromString(@"INJSONParser");
				NSAssert(parserClass,@"ip_fc5e82d8_a9cc_4d92_a197_2fafef618732");
				
				INJSONParser *jsonParser = [[parserClass alloc] initWithString:string];
				jsonParser.delegate = self;
				if (![jsonParser parse]) {
					_parserError = [jsonParser.parseError retain];
				}
				[jsonParser release];
				break;
			}
				
				
			default:
				NSAssert(0,@"ip_c4f536f9_c3fa_46e0_b63c_8cefd43cbbe8");
        }
		
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_rootElement release];
    [_parserError release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
            qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict { 
                
    INDOMElement * element = [INDOMElement newWithName:elementName];
    if (!_rootElement) { 
        _rootElement = [element retain];
    } else {
        [element setParent:_currentElement];
        [_currentElement addItem:element]; 
    }
    _currentElement = element;
    if (attributeDict.count) { 
        [element addProperties:attributeDict];    
    }
    [element release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
    qualifiedName:(NSString *)qName { 
    if (_currentElement) {
        _currentElement = _currentElement.parent;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
    [_currentElement addData:string];
}

//----------------------------------------------------------------------------------------------------------------------------------


#pragma mark -
#pragma mark NSJSONParserDelegate methods

- (void) injsonParser:(INJSONParser *)parser didStartElement:(NSString *)elementName ofType:(INJSONElementValueType)elementType {
    if (!elementName) { 
        elementName = @"";
    }

    INDOMElement * element = [INDOMElement newWithName:elementName];
    if (!_rootElement) { 
        _rootElement = [element retain];
    } else {
        [element setParent:_currentElement];
        [_currentElement addItem:element]; 
    }
    _currentElement = element;
    [element release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) injsonParser:(INJSONParser *)parser didEndElement:(NSString *)elementName ofType:(INJSONElementValueType)elementType {
    //if (!elementName) { 
    //    elementName = @"";
    //}

    if (_currentElement) {
        _currentElement = _currentElement.parent;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) injsonParser:(INJSONParser *)parser foundCharacters:(NSString *)string {
    [_currentElement addData:string];
}



#pragma mark - Working with path
#pragma mark 

- (INDOMElement *)elementAtPath:(NSString *)path { 
    NSArray * subPathes = [path componentsSeparatedByString:@"/"];    
    return [_rootElement elementAtPathComponents:subPathes startIndex:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Debug stuff

- (void)dump {
    NSLog(@"Dumping %@...", self);
    [_rootElement dumpAtLevel:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)dumpXMLString:(NSString *)xml { 
    INDOMDocument * document = [[INDOMDocument alloc] initWithData:[xml dataUsingEncoding:NSUTF8StringEncoding] ofType:INDOMSourceXML];
    [document dump];
    [document release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)formatDocument_JSON { 
    return [NSString stringWithFormat:@"{\n%@}\n",[_rootElement prettyFormatedItemsAtLevel_JSON:1]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)formatDocument { 
    switch (_sourceType) {
        case INDOMSourceJSON:
           return [self formatDocument_JSON];
           break;

        default:
            NSAssert(0, @"not implemented yet mk_01b7fa51_da26_403c_af00_9db330f2e840");
            break;
    }
    return nil;
}


/*
__attribute__((constructor)) 
void Test() { 
    [NSAutoreleasePool new];

    NSString * xml = @""    
    "<SOAP-ENV:Envelope " 
    "xmlns:ns2=\"http://xml.apache.org/xml-soap\"  "
    "xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"  "
    "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"  "
    "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"  "
    "xmlns:ns1=\"urn:PoezdkaService\"  "
    "xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"  "
    "SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" "
    "> "
    "<SOAP-ENV:Body> "
    "<ns1:searchResponse xmlns:ns2=\"http://xml.apache.org/xml-soap\" xmlns:ns1=\"urn:PoezdkaService\"> "
    "<searchReturn xsi:type=\"ns2:Map\"> "
    "<item> "
    "<key xsi:type=\"xsd:string\">errors</key> "
    "<value SOAP-ENC:arrayType=\"xsd:string[1]\" xsi:type=\"SOAP-ENC:Array\"> "
    "<item xsi:type=\"xsd:string\">Неправильный пароль или имя пользователя</item> "
    "</value> "
    "</item> "
    "<item> "
    "<key xsi:type=\"xsd:string\">XML</key> "
    "<value xsi:type=\"xsd:string\"></value> "
    "</item>  "
    "</searchReturn>  "
    "</ns1:searchResponse>  "
    "</SOAP-ENV:Body> "
    "</SOAP-ENV:Envelope>";
    
    // NSData * data = [NSData dataWithContentsOfFile:@"/Users/murad/Desktop/Poezdka.RU/dobook.request.xml"];
    NSData * data = [xml dataUsingEncoding:NSUTF8StringEncoding];
    INDOMDocument * dom = [[INDOMDocument alloc] initWithData:data ofType:INDOMSourceXML];   
    if (dom.parserError) { 
        NSLog(@"parse failed %@",dom.parserError);
    } else {
        [dom dump];
        
        [[[dom elementAtPath:@"SOAP-ENV:Envelope/SOAP-ENV:Body"] itemAtPath:@"ns1:searchResponse/searchReturn"] dump]; // itemAtPath
        
        // [[dom elementAtPath:@"SOAP-ENV:Envelope/SOAP-ENV:Body/ns1:searchResponse/searchReturn"] dumpAtLevel:0];
    }
    exit(1);
}
*/

@end

