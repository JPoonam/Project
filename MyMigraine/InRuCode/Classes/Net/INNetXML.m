//!
//! @file INNetXML.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! @copyright Copyright © 2010-2011 InRu
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

#import "INNetXML.h"
#import "INCommonTypes.h"

//==================================================================================================================================
//==================================================================================================================================

@interface INNetXMLResource()

//! @brief Current parse state (one of INXML_PARSESTATE_*). Just helper for descendants
@property int parseState;

//! @brief Temporary string buffer. Just helper for descendants
@property(nonatomic,readonly) NSMutableString * tempStringForParsing;

@end

//==================================================================================================================================


@implementation INNetXMLResource 

@synthesize nameMap = _nameMap;
@synthesize xmlDelegate = _xmlDelegate;
@synthesize parseState = _parseState;
@synthesize tempStringForParsing = _tempStringForParsing;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
        _tempStringForParsing = [NSMutableString new];  
        _nameMap = [NSMutableDictionary new];  
        self.contentHandler = self;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    _xmlDelegate = nil;
    [_tempStringForParsing release];
    _tempStringForParsing = nil;
    [_nameMap release]; 
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addName:(NSString *)name tag:(int)tag {
    [_nameMap setObject:[NSNumber numberWithInt:tag] forKey:name];  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)addNameIfNotYet:(NSString *)name tag:(int)tag {
    NSNumber * prevValue = [_nameMap objectForKey:name];
    if (!prevValue) {  
        [_nameMap setObject:[NSNumber numberWithInt:tag] forKey:name];
        return tag;
    } 
    return [prevValue intValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (int)tagWithName:(NSString *)name { 
    NSNumber * number = [_nameMap objectForKey:name];
    return number ? [number intValue] : INXML_NONE;    
}

//----------------------------------------------------------------------------------------------------------------------------------

enum {
    PARSER_ABORT, PARSER_DROP, PARSER_CREATE 
};

//----------------------------------------------------------------------------------------------------------------------------------

- (void)controlParser:(int)operation withData:(NSData *)data {
    @synchronized(self){    
        switch (operation){
            case PARSER_ABORT:
                _parser.delegate = nil;
                [_parser abortParsing];
                break;
                
            case PARSER_DROP:
                _parser.delegate = nil;
                [_parser release];
                _parser = nil;
                break;
                
            case PARSER_CREATE:
                _parser = [[NSXMLParser alloc] initWithData:data];
                _parser.delegate = _xmlDelegate;
                break;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stop { 
    [self controlParser:PARSER_ABORT withData:nil];
    [super stop];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)netResource:(INNetResource *)resource willHandleContent:(NSData *)data { 
    // init our helpers
    _parseState = 0;
    [_tempStringForParsing inru_clear];
    
    // if ([self.delegate respondsToSelector:@selector(xmlResource:willParseData:)]){
    //    [(id)self.delegate xmlResource:self willParseData:data];
    // }
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)netResource:(INNetResource *)resource didHandleContentWithResult:(NSError *)error {
    if (error) {     
        if ([self.delegate respondsToSelector:@selector(xmlResource:didFailToParseWithError:)]){
            [(id)self.delegate xmlResource:self didFailToParseWithError:error];
        }
        [self clearCache];
    } else {
        if ([self.delegate respondsToSelector:@selector(xmlResourceDidFinishParse:)]){
            [(id)self.delegate xmlResourceDidFinishParse:self];
        }        
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSError *)netResource:(INNetResource *)resource handleContent:(NSData *)data { 
    // save for debugging  
    // [data writeToFile:@"/Users/murad/Desktop/1.xml" atomically:YES]; 
    
    NSError * error = nil;
    NSAssert(!_parser, @"c6e96420_a39b_45be_ad0e_e1d8300c4e73");

    [self controlParser:PARSER_CREATE withData:data];
    if (self.isStopping) {
        goto cleanupAndExit;
    }
    // [_xmlParser setShouldProcessNamespaces:NO];
    // [_xmlParser setShouldReportNamespacePrefixes:NO];
    // [_xmlParser setShouldResolveExternalEntities:NO];

    BOOL success = NO;

    // First trying to parse it as-is
    // NSUInteger t1 = INTickCount();
    success = [_parser parse];
    // NSLog(@"parse1 %d %@",INTickCount() - t1,resource.URL.absoluteString);
    
    // parsing failed. Possible error - unsupported encoding. Let's try to fix that
    if (!success){
        if ( _parser.parserError.domain == NSXMLParserErrorDomain && 
             _parser.parserError.code == NSXMLParserUnknownEncodingError){
            
             // trying to find appripriate encoding in the 
             // string like <?xml version="1.0" encoding="windows-1251"?>
             NSInteger len = MIN(data.length, 100); 
             char buf[101];
             [data getBytes:buf length:len];
             buf[len] = 0;
             for (int i = 0; i < len; i++){ 
                 buf[i] = tolower(buf[i]);
             }
             
             char * enc1 = strstr(buf, "encoding");
             if (enc1){
                 NSRange encodingStringPosition;
                 encodingStringPosition.location = enc1 - buf;
                 enc1 += strlen("encoding"); 
                 while (*enc1 == ' ')enc1++;
                 if (*enc1 == '='){
                     enc1++;
                     while (*enc1 == ' ')enc1++;
                     if (*enc1 == '"' || *enc1 == '\''){
                         enc1++;
                         if (*enc1){ 
                             char * enc2 = enc1 + 1;
                             while (1){ 
                                 switch (*enc2){
                                     case 0:
                                     case '\'':
                                     case '"':break;
                                 default:
                                    enc2++;
                                    continue;
                                 }
                                 break;
                             }
                             *enc2 = 0;
                             encodingStringPosition.length = enc2 - buf - encodingStringPosition.location + 1; 
                             NSStringEncoding encoding = [[NSString stringWithCString:enc1 encoding:NSASCIIStringEncoding] 
                                                                       inru_stringToEncoding];
                             if (encoding){ 
                                 NSString * s  = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
                                 if (s){ 
                                     NSString * s2 = [s stringByReplacingCharactersInRange:encodingStringPosition withString:@""];
                                     NSData * data2 = [s2 dataUsingEncoding:NSUTF8StringEncoding];
                                     if (data2){
                                         [self controlParser:PARSER_DROP withData:nil];
                                         if (self.isStopping){
                                             goto cleanupAndExit;   
                                         }
                                         [self controlParser:PARSER_CREATE withData:data2];
                                         // NSUInteger t1 = INTickCount();
                                         success = [_parser parse];
                                         // NSLog(@"parse2 %d %@",INTickCount() - t1,resource.URL.absoluteString);
                                     }
                                 }
                             }
                         }
                     }
                 }
             }
        }
    }
    
    // debug. Simulates slow processing
    // sleep(10);
        
    // handle results
    if (!self.isStopping) { 
        if (!success) {
            error = _parser.parserError;
            [[error retain] autorelease]; 
        }    
    }

cleanupAndExit:
    [self controlParser:PARSER_DROP withData:nil];
    return error;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INNetXMLContainerNode 

@synthesize properties = _properties;
@synthesize attributes = _attributes;
@synthesize nodeData = _nodeData;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
        _properties = [NSMutableDictionary new];    
        _flags.allInOne = 0;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_properties release];
    [_attributes release];
    [_nodeData release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setProperty:(id)aProperty forKey:(id)aKey {
    if (aKey){ 
        if (aProperty){ 
            [_properties setObject:aProperty forKey:aKey];
        } else {
            [_properties removeObjectForKey:aKey];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)propertyForKey:(id)aKey { 
    return [_properties objectForKey:aKey];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)uniqueKeyName { 
    return nil;
}

+ (id)modificationKeyName {
    return nil;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INNetXMLContainer ()

-(void)validateVisibility;

@property(nonatomic,retain) NSMutableArray * fetchedItems;

@end

//==================================================================================================================================

@implementation INNetXMLContainer 

@synthesize delegate = _delegate;
@synthesize resourceURL  = _resourceURL;
@synthesize user     = _user;
@synthesize password = _password;
@synthesize fetchedItems = _fetchedItems;
@synthesize lastSuccessfulUpdateDate = _lastSuccessfulUpdate;
@synthesize properties = _commonProperties;
@synthesize nodes = _nodes;
@synthesize currentlyParsedElement = _currentlyParsedElement;
@synthesize currentlyParsedElementAttributes = _currentlyParsedElementAttributes;
@synthesize currentlyParsedElementLevel = _currentlyParsedLevel;
@synthesize xmlResource = _xmlNetResource;
@synthesize nodesTagName = _nodesTagName;
@synthesize nodeTagName = _nodeTagName;
@synthesize currentlyParsedNode = _currentNode;
@synthesize shouldClearPreviousResult = _shouldClearPreviousResult;

//----------------------------------------------------------------------------------------------------------------------------------

- (NSArray *)visibleNodes { 
    [self validateVisibility];
    return _visibleNodes;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil){
        _xmlNetResource = [INNetXMLResource new];
        _xmlNetResource.delegate = self;
        _xmlNetResource.xmlDelegate = self;
        _nodes = [[NSMutableArray array] retain];
        _visibleNodes = [[NSMutableArray array] retain];
        _commonProperties = [NSMutableDictionary new];
        _fetchedItems = [NSMutableArray new];
        _lastSuccessfulUpdate = [[NSDate distantPast] retain];
        _shouldClearPreviousResult = YES;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithNodesTagName:(NSString *)nodesTagName nodeTagName:(NSString *)nodeTagName { 
    self = [self init];
    if (self != nil){
        self.nodesTagName = nodesTagName;
        self.nodeTagName = nodeTagName;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_xmlNetResource releaseGracefully];
    [_nodes release];
    self.user = nil;
    self.password = nil;
    self.resourceURL = nil;
    [_visibleNodes release];
    [_commonProperties release];
    self.currentlyParsedNode = nil;
    self.fetchedItems = nil;
    self.nodesTagName = nil;
    self.nodeTagName = nil;
    [_lastSuccessfulUpdate release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSUInteger)slowNetworkEmulationDelay {
    return _xmlNetResource.slowNetworkEmulationDelay; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSlowNetworkEmulationDelay:(NSUInteger)value { 
    _xmlNetResource.slowNetworkEmulationDelay = value;
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResource:(INNetResource *)resource didStartLoadWithURL:(NSURL *)anURL {
    [_delegate netxmlContainerDidStartUpdate:self];
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)netResource:(INNetResource *)resource didFailLoadWithError:(NSError *)anError {
    [_delegate netxmlContainer:self updateDidFailWithError:anError];
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)xmlResource:(INNetXMLResource *)resource didFailToParseWithError:(NSError *)anError {
    [_delegate netxmlContainer:self updateDidFailWithError:anError];
}


- (void)netResourceDidCancel:(INNetResource *)resource {
    [_delegate netxmlContainerDidCancel:self];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isUpdating { 
    return _xmlNetResource.busy;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)loadFromURLString:(NSString *)URLString {
    self.resourceURL = URLString;
    [self update];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)update {
    if (self.isUpdating){
        return;
    }
    if (_shouldClearPreviousResult){ 
        [self clearLoadedNodes];    
    }
    _xmlNetResource.user = _user;
    _xmlNetResource.password = _password;
    [_xmlNetResource loadFromURLString:_resourceURL];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)stop { 
    [_xmlNetResource stop];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)isNodeVisible:(INNetXMLContainerNode *)node {
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)sortVisibleNodes:(NSMutableArray *)nodes { 
   // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)invalidateVisibleNodes { 
    _visibleFilterValid = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)validateVisibility {
    if (!_visibleFilterValid){ 
        [_visibleNodes removeAllObjects];
        for (INNetXMLContainerNode * node in _nodes){ 
            if ([self isNodeVisible:node]){ 
                [_visibleNodes addObject:node];  
            }  
        }
        [self sortVisibleNodes:_visibleNodes];  
        _visibleFilterValid = YES;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

/* 
- (NSString *)containerNodesName {
    NSAssert(false, @"override this! c48a027c_a5a3_4df9_bf87_057c8ebc9ee9");
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)containerNodeName {
    NSAssert(false, @"override this! c48a027c_a5a3_4df9_bf87_057c8ebc9eeA");
    return nil;
}
*/

//----------------------------------------------------------------------------------------------------------------------------------

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _useINNetXMLContainerNode = [[self nodeClass] isMemberOfClass:INNetXMLContainerNode.class]; 

    _xmlNetResource.parseState = INXML_PARSESTATE_START;
    NSAssert(_nodesTagName.length, @"The 'nodesTagName' property is not set");
    NSAssert(_nodeTagName.length, @"The 'nodeTagName' property is not set");
    _nodesTag = [_xmlNetResource addNameIfNotYet:_nodesTagName tag:INXML_CONTAINER_NODES];
    _nodeTag  = [_xmlNetResource addNameIfNotYet:_nodeTagName tag:INXML_CONTAINER_NODE];
    [_fetchedItems removeAllObjects];
    [_commonProperties removeAllObjects];
    _currentlyParsedElement = nil;
    self.currentlyParsedNode = nil;
    _currentlyParsedLevel = 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)processChildOfNodesWithTag:(int)tag startCollectData:(BOOL *)startCollectData { 
   // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)processChildOfNode:(INNetXMLContainerNode *)node withTag:(int)tag startCollectData:(BOOL *)startCollectData { 
    // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)processNode:(INNetXMLContainerNode *)node withAttributes:(NSDictionary *)attributes { 
    // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)processNodesAttributes:(NSDictionary *)attributes { 
    // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)finalizeChildOfNodesWithTag:(int)tag collectedData:(NSString *)collectedData { 
    // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)finalizeChildOfNode:(INNetXMLContainerNode *)node withTag:(int)tag collectedData:(NSString *)collectedData { 
    // nothing in the base class
}

//----------------------------------------------------------------------------------------------------------------------------------

- (Class)nodeClass { 
    return [INNetXMLContainerNode class];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)checkNodeBeforeAdding:(INNetXMLContainerNode *)node { 
    return YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName  
     attributes:(NSDictionary *)attributeDict {
    
    BOOL startCollectData = NO;
    _currentlyParsedElement = elementName;
    _currentlyParsedElementAttributes = attributeDict;
    _currentlyParsedLevel++;
    
    int tag = [_xmlNetResource tagWithName:elementName];
    switch (_xmlNetResource.parseState){ 
        case INXML_PARSESTATE_START:
            if (tag == _nodesTag){
                _xmlNetResource.parseState = INXML_PARSESTATE_NODES;
                [self processNodesAttributes:attributeDict];
            }
            break;
            
        case INXML_PARSESTATE_NODES:
            if (tag == _nodeTag){
                _xmlNetResource.parseState = INXML_PARSESTATE_NODE;
                INNetXMLContainerNode * newNode;
                if (_useINNetXMLContainerNode) {
                    newNode = [INNetXMLContainerNode new];
                } else { 
                    newNode = [[self nodeClass] new];
                }
                newNode.attributes = attributeDict;
                self.currentlyParsedNode = newNode;
                [newNode release];
                [self processNode:newNode withAttributes:attributeDict]; 
            } else {
                [self processChildOfNodesWithTag:tag startCollectData:&startCollectData];
                if (startCollectData){ 
                    [_xmlNetResource.tempStringForParsing inru_clear]; 
                    _xmlNetResource.parseState = INXML_PARSESTATE_NODES_CD;
                }
            }
            break;
            
        case INXML_PARSESTATE_NODE:
            [self processChildOfNode:self.currentlyParsedNode withTag:tag startCollectData:&startCollectData];
            if (startCollectData){
                [_xmlNetResource.tempStringForParsing inru_clear]; 
                _xmlNetResource.parseState = INXML_PARSESTATE_NODE_CD;
            }
            break;
    }     
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    switch (_xmlNetResource.parseState){
        case INXML_PARSESTATE_NODE_CD:
        case INXML_PARSESTATE_NODES_CD:
            [_xmlNetResource.tempStringForParsing appendString:string];
            break;
        
        case INXML_PARSESTATE_NODE:
            if (! self.currentlyParsedNode.nodeData){ 
                self.currentlyParsedNode.nodeData = [NSMutableString stringWithString:string];
            } else {
                [self.currentlyParsedNode.nodeData appendString:string];
            }
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName {
    
    _currentlyParsedElement = elementName;
    int tag = [_xmlNetResource tagWithName:elementName];
    
    switch (_xmlNetResource.parseState){ 
        case INXML_PARSESTATE_NODES:
            if (tag == _nodesTag){
                _xmlNetResource.parseState = INXML_PARSESTATE_START;
            }
            break;
            
        case INXML_PARSESTATE_NODES_CD:
            [self finalizeChildOfNodesWithTag:tag collectedData:
                  [[_xmlNetResource.tempStringForParsing copy] autorelease]];
            _xmlNetResource.parseState = INXML_PARSESTATE_NODES;
            break;
            
        case INXML_PARSESTATE_NODE_CD:
            [self finalizeChildOfNode:_currentNode withTag:tag collectedData:
                [[_xmlNetResource.tempStringForParsing copy] autorelease]];
            _xmlNetResource.parseState = INXML_PARSESTATE_NODE;
            break;
            
        case INXML_PARSESTATE_NODE:
            if (tag == _nodeTag){
                if ([self checkNodeBeforeAdding:self.currentlyParsedNode]){
                    [_fetchedItems addObject:self.currentlyParsedNode];
                }
                self.currentlyParsedNode = nil;
                _xmlNetResource.parseState = INXML_PARSESTATE_NODES;
            } else {
                [self finalizeChildOfNode:_currentNode withTag:tag collectedData:nil];   
            }
    }   
    
    _currentlyParsedLevel--;
}

//----------------------------------------------------------------------------------------------------------------------------------

-(void)xmlResourceDidFinishParse:(INNetXMLResource *)resource {
    // we have array _fetchedItems of downloaded items. now we try to 
    // synchronize it with the existing items. Update existing items,
    // append new ones
    BOOL hasChanges = NO;
    id uniqueNodeKeyName = [[self nodeClass] uniqueKeyName];
    id modificationKeyName = [[self nodeClass] modificationKeyName];
    
    
    // for speedness - will just add all items to the initially empty list (no duplicates checking)
    if (_nodes.count == 0){ 
        uniqueNodeKeyName = nil;    
    }
    
    for (INNetXMLContainerNode * fetchedItem in _fetchedItems){ 
        INNetXMLContainerNode * existingItem = nil;
        if (uniqueNodeKeyName){ 
            existingItem = [self findNodeByProperty:uniqueNodeKeyName value:[fetchedItem propertyForKey:uniqueNodeKeyName]];
        }
        
        // add new item
        if (existingItem == nil){ 
            [_nodes addObject:fetchedItem];
            fetchedItem->_flags.f.contentModified = YES;
            fetchedItem->_flags.f.unreadStatusModified = YES;
            hasChanges = YES;
        } else 
        // update modified item
        if (modificationKeyName){ 
            if (! [NSString inru_string:[existingItem propertyForKey:modificationKeyName] isEqualTo:
                                         [fetchedItem propertyForKey:modificationKeyName]]){ 
                for (id propKey in fetchedItem.properties.allKeys){
                    [existingItem setProperty:[fetchedItem propertyForKey:propKey] forKey:propKey];             
                }
                existingItem->_flags.f.contentModified = YES;
                existingItem->_flags.f.unreadStatusModified = YES;
                existingItem->_flags.f.read = NO;
                hasChanges = YES;
            }
        }
    }
    
    // remove unchanged items
    [_fetchedItems removeAllObjects];
    
    if (hasChanges){ 
        _visibleFilterValid = NO;
    }
    [_lastSuccessfulUpdate release];
    _lastSuccessfulUpdate = [[NSDate date] retain];
    [_delegate netxmlContainerDidFinishUpdate:self withChanges:hasChanges];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INNetXMLContainerNode *)findNodeByProperty:(id)property value:(id)value { 
    for (INNetXMLContainerNode * item in _nodes){ 
        if ([[item.properties objectForKey:property] isEqual:value]){
            return item;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)clearLoadedNodes { 
    [_nodes removeAllObjects];
    _visibleFilterValid = NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)releaseGracefully { 
    // _delegate = nil;
    // [_xmlNetResource releaseGracefully];
    [self release];
}

@end

