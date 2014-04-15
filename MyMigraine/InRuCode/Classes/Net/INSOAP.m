//
//  INSOAP.m
//  Poezdka.RU
//
//  Created by Murad Kakabayev (murad.kakabayev@gmail.com) on 3/16/11.
//  Copyright 2011 InRu. All rights reserved.
//

#import "INSOAP.h"

//==================================================================================================================================
//==================================================================================================================================

@interface NSDictionary (INRU_SimpleSOAP) 

- (NSString *)inru_simpleSoap_serilizeAsAttributes;

@end

//==================================================================================================================================

@implementation NSDictionary (INRU_SimpleSOAP) 

- (NSString *)inru_simpleSoap_serilizeAsAttributes { 
    NSMutableString * string = [NSMutableString string];
    for (id key in self) {
        [string appendFormat:@" %@=\"%@\"",key,[self objectForKey:key]];    
    }
    return string; 
}

@end

//==================================================================================================================================
//==================================================================================================================================

// NSString * _SerializeValue(id value) { 
//    return [value description];
// }

static NSString * _NameWithNSPrefix(NSString * name, NSString * prefix) { 
    if (prefix.length) { 
        return [NSString stringWithFormat:@"%@:%@",prefix,name];
    }
    return name;
}

//==================================================================================================================================
//==================================================================================================================================

@implementation INSimpleSOAPObject

- (NSString *)XML {
    NSAssert(0,@"3889a476_1ed3_45b0_b240_468910082a59 not implemented");
    return nil;
}

@end

//==================================================================================================================================
//==================================================================================================================================


@implementation INSimpleSOAPParam

@synthesize paramTypeString = _paramTypeString;
@synthesize paramType = _paramType;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_paramTypeString release];
    [_value release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)stringWithName:(NSString *)name value:(id)value {
    INSimpleSOAPParam * param = [[INSimpleSOAPParam newWithName:name] autorelease];
    param->_type = INSimpleSOAPParamString;
    param->_value = [[value description] retain];
    param->_paramTypeString = @"xsd:string";
    return param;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)numberWithName:(NSString *)name value:(NSNumber *)value {
    NSParameterAssert([value isKindOfClass:NSNumber.class]);
    INSimpleSOAPParam * param = [[INSimpleSOAPParam newWithName:name] autorelease];
    param->_type = INSimpleSOAPParamNumber;
    param->_value = [value retain];
    const char * enc = [value objCType];
    switch (enc[0]) {
        case 'i': 
            param->_paramTypeString = @"xsd:int";
            break;
            
        default:
            NSAssert1(0,@"numberWithName: not handled for type '%c'", enc);
    }
    // The valid return values are “c”, “C”, “s”, “S”, “i”, “I”, “l”, “L”, “q”, “Q”, “f”, and “d”.
    
    return param;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)mapWithName:(NSString *)name value:(NSDictionary *)dictionary {
    NSParameterAssert([dictionary isKindOfClass:NSDictionary.class]);
    INSimpleSOAPParam * param = [[INSimpleSOAPParam newWithName:name] autorelease];
    param->_type = INSimpleSOAPParamMap;
    param->_paramTypeString = @"ns2:Map";
    param->_value = [dictionary retain];
    return param;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)paramWithName:(NSString *)name value:(id)value {
    if ([value isKindOfClass:INSimpleSOAPParam.class]) { 
        INSimpleSOAPParam * src = value;
        INSimpleSOAPParam * param = [[INSimpleSOAPParam newWithName:name] autorelease];
        param->_type = src->_type;
        param.paramTypeString = src->_paramTypeString;
        param->_value = [src->_value retain];
        return param;
    }

    if ([value isKindOfClass:NSString.class]) {
        return [self stringWithName:name value:value];
    }

    if ([value isKindOfClass:NSNumber.class]) {
        return [self numberWithName:name value:value];
    }

    NSAssert1(0,@"Cannot create [INSimpleSOAPParam object] from '%@'", value);  
    return nil;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)valueAsXML {
    if (!_value) { 
         return @"";
    }
    if ([_value respondsToSelector:@selector(XML)]) { 
        return [_value XML];
    }
    if ([_value isKindOfClass:[NSArray class]]) { 
        NSMutableString * result = [NSMutableString string];
        for (id obj in _value) { 
            [result appendString:[obj XML]];
        }
        return result;
    }
    if ([_value isKindOfClass:[NSDictionary class]]) { 
        NSMutableString * result = [NSMutableString string];
        for (id key in _value) {
            id v1 = [INSimpleSOAPParam paramWithName:@"key" value:key];
            id v2 = [INSimpleSOAPParam paramWithName:@"value" value:[_value objectForKey:key]];
            [result appendFormat:@"<item>%@%@</item>",[v1 XML],[v2 XML]];
        }
        return result;
    }
   
    return [_value description];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)XML {
    NSAssert(self.name.length,@"Param name is not set");
    NSAssert(_paramTypeString.length,@"Param type is not set");
    
    NSMutableDictionary * attributes  = [NSMutableDictionary dictionary];
    [attributes setObject:_paramTypeString forKey:@"xsi:type"];
    
    return [NSString stringWithFormat:
              @"<%@%@>%@</%@>",
              self.name,
              [attributes inru_simpleSoap_serilizeAsAttributes],
              self.valueAsXML,
              self.name];
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INSimpleSOAPRequestMethod

@synthesize nameSpace = _nameSpace;
@synthesize nameSpacePrefix = _nameSpacePrefix;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {
        _params = [NSMutableArray new];
        _nameSpacePrefix = @"m1";
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_nameSpace release];
    [_params release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)XML {
    NSAssert(self.name.length,@"Method name is not set");
    NSAssert(_nameSpace.length,@"Namespace is not set");
    
    NSMutableDictionary * attributes  = [NSMutableDictionary dictionary];
    NSMutableArray * paramStrings = [NSMutableArray array];
    for (INSimpleSOAPParam * p in _params) { 
        [paramStrings addObject:p.XML];
    }
    
    if (_nameSpace.length) { 
        [attributes setObject:_nameSpace forKey:[@"xmlns:" stringByAppendingString:_nameSpacePrefix]]; 
    }
    
    return [NSString stringWithFormat:
              @"<%@%@>\n"
              @"%@\n"
              @"</%@>",
              _NameWithNSPrefix(self.name,_nameSpacePrefix),
              [attributes inru_simpleSoap_serilizeAsAttributes],
              [paramStrings componentsJoinedByString:@"\n"],
              _NameWithNSPrefix(self.name,_nameSpacePrefix)];
}

/* 
//----------------------------------------------------------------------------------------------------------------------------------

- (void)addParamWithName:(NSString *)name type:(NSString *)paramType value:(id)value { 
    INSimpleSOAPRequestParam * param = [INSimpleSOAPRequestParam newWithName:name];
    param.paramType = paramType;
    param.value = value;
    [_params addObject:param];
    [param release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addStringParamWithName:(NSString *)name value:(id)value { 
    [self addParamWithName:name type:@"xsd:string" value:value];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addArrayParamWithName:(NSString *)name value:(NSArray *)value { 
    [self addParamWithName:name type:@"soapenc:Array" value:value];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addMapParamWithName:(NSString *)name value:(NSDictionary *)value { 
    [self addParamWithName:name type:@"ns2:Map" value:value];
}
*/

- (void)addParam:(INSimpleSOAPParam *)param { 
    [_params addObject:param];
}

- (void)addParams:(NSArray *)params { 
    [_params addObjectsFromArray:params];
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INSimpleSOAPRequest

// @synthesize rootObject = _rootObject;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {
        // _nameSpaces = [NSMutableDictionary new];
        //[_nameSpaces setObject:@"http://schemas.xmlsoap.org/soap/envelope/" forKey:(_nsSOAPENV = @"SOAP-ENV")];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_rootObject release];
    // [_nameSpaces release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)XML { 
    NSString * template =  
        @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        @"<SOAP-ENV:Envelope\n"
        @"    xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
        @"    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
        @"    xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\"\n"
        @"    xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
        @"    xmlns:ns2=\"http://xml.apache.org/xml-soap\"\n"
        @"    SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">\n"
        @"    <SOAP-ENV:Body>\n"
        @"%@\n"
        @"    </SOAP-ENV:Body>\n"
        @"</SOAP-ENV:Envelope>\n";
    return [NSString stringWithFormat:template,[_rootObject XML]];   
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)methodRequestWithName:(NSString *)methodName nameSpace:(NSString *)nameSpace { 
    INSimpleSOAPRequest * result = [[INSimpleSOAPRequest new] autorelease];
    INSimpleSOAPRequestMethod * method = [INSimpleSOAPRequestMethod newWithName:methodName];
    method.nameSpace = nameSpace;
    result->_rootObject = method;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INSimpleSOAPRequestMethod *)method { 
    NSAssert([_rootObject isKindOfClass:INSimpleSOAPRequestMethod.class],@"2bc1ffab_5d2b_4c61_a704_e0f7a97f0469");
    return (INSimpleSOAPRequestMethod *)_rootObject;
}

//----------------------------------------------------------------------------------------------------------------------------------

@end

/*
// __attribute__((constructor)) 
static void Test() { 
   [NSAutoreleasePool new];
   
    INSimpleSOAPRequest * rq = [INSimpleSOAPRequest methodRequestWithName:@"search" nameSpace:@"urn:PoezdkaService"];    

    NSDictionary * psgr = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:1], @"adult",
                                  [NSNumber numberWithInt:0], @"youth", 
                                  [NSNumber numberWithInt:0], @"child", 
                                  [NSNumber numberWithInt:0], @"infantseat", 
                                  [NSNumber numberWithInt:0], @"infantnoseat", 
                                  nil
                              ]
                          ];

    NSDictionary * from = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Москва (Россия)", [NSNumber numberWithInt:1],
                                  nil
                              ]
                          ];

    NSDictionary * to = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Анталья (Турция)", [NSNumber numberWithInt:1],
                                  nil
                              ]
                          ];

    NSDictionary * date = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"24-03-2011", [NSNumber numberWithInt:1],
                                  @"31-03-2011", [NSNumber numberWithInt:2],
                                  nil
                              ]
                          ];

    NSDictionary * twt = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"depart", [NSNumber numberWithInt:1],
                                  @"depart", [NSNumber numberWithInt:2],
                                  nil
                              ]
                          ];

    NSDictionary * stw = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"0000", [NSNumber numberWithInt:1],
                                  @"2359", [NSNumber numberWithInt:2],
                                  nil
                              ]
                          ];

    NSDictionary * etw = [INSimpleSOAPParam mapWithName:nil value:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"0000", [NSNumber numberWithInt:1],
                                  @"2359", [NSNumber numberWithInt:2],
                                  nil
                              ]
                          ];
                          
    [rq.method addParams:[NSArray arrayWithObjects:
               [INSimpleSOAPParam stringWithName:@"username" value:@"tet"],
               [INSimpleSOAPParam stringWithName:@"password" value:nil],
               [INSimpleSOAPParam mapWithName:@"search_params" value:
                      [NSDictionary dictionaryWithObjectsAndKeys:
                          @"2w", @"t",
                          psgr, @"psgr",
                          @"Y", @"prefclass",
                          [NSNumber numberWithInt:5], @"num_conx",
                          [NSNumber numberWithInt:99], @"maxtraveltime",
                          from, @"from",
                          to, @"to",
                          date, @"date",
                          twt, @"timewindowtype",
                          stw, @"start_time_window",
                          etw, @"end_time_window",
                          nil
                      ]],
               nil]];
               
    //[rq.method addStringParamWithName:@"" value:nil];
    //[rq.method addMapParamWithName:@"" value:nil];
    
    NSString * xml = rq.XML;
    [[xml dataUsingEncoding:NSUTF8StringEncoding] writeToFile:@"/Users/murad/Desktop/1.xml" atomically:NO];
    NSLog(@"\n%@",xml);
    exit(1);
}
*/