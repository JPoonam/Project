//!
//! @file INNetXML.h
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

#import <Foundation/Foundation.h>
#import "INNetResource.h"

/**
 @brief A convenient method to define named properties for INNetXMLContainerNode descendants  
    
*/
#define INXML_GET_SET_PROP(DICTIONARY, GETMETHOD, SETMETHOD, TYPE, KEY )\
- (TYPE)GETMETHOD {\
        return [DICTIONARY objectForKey:KEY]; \
    }\
- (void)SETMETHOD:(TYPE)value { \
        [DICTIONARY setObject:value forKey:KEY]; \
    }\

enum {
    INXML_NONE                  = -1000,
    INXML_CONTAINER_NODES       = -1001,
    INXML_CONTAINER_NODE        = -1002,
    INXML_PARSESTATE_START      =     0,
    INXML_PARSESTATE_NODES      = -2001,
    INXML_PARSESTATE_NODE       = -2002,
    INXML_PARSESTATE_NODES_CD   = -2003,
    INXML_PARSESTATE_NODE_CD    = -2004,
};

//==================================================================================================================================
//==================================================================================================================================

@class INNetXMLResource, INNetXMLContainer;

/**
 @brief Delegate protocol for INNetXMLResource  
    
*/
@protocol INNetXMLResourceDelegate<INNetResourceDelegate>
@optional

//! @brief Notifies a delegate about beginning of XML data parsing
// - (void)xmlResource:(INNetXMLResource *)resource willParseData:(NSData *)data;

//! @brief Notifies a delegate about XML data parsing fatal error 
- (void)xmlResource:(INNetXMLResource *)resource didFailToParseWithError:(NSError *)anError;

//! @brief Notifies a delegate about XML data parsing finish
- (void)xmlResourceDidFinishParse:(INNetXMLResource *)resource;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A class for very common situation - receiving and processing of a remotely-located XML document 
    
*/

@interface INNetXMLResource : INNetResource<INNetResourceContentHandlerDelegate> {
@private
    id            _xmlDelegate;
    NSXMLParser * _parser;
        
    // Common helper parses variables. use it on certain XML parsing  in descendants
    int                    _parseState;   // resets to INXML_PARSESTATE_START at parse beginning
    NSMutableString      * _tempStringForParsing; // resets to @"" at parse beginning
    NSMutableDictionary  * _nameMap;
}

//! @brief A dictionary of (@"tagName" -> [NSNumber tagID] to fast tag and other string literals searching. 
//         On parsing we work with numbers, not with string tag names - it fast and convenient
@property(nonatomic,retain) NSMutableDictionary * nameMap;

//! @brief Add new name->ID map to map (see \c nameMap)
- (void)addName:(NSString *)name tag:(int)tag;


- (NSInteger)addNameIfNotYet:(NSString *)name tag:(int)tag;

//! @brief Finds tag ID by it's name in the \c nameMap
- (int)tagWithName:(NSString *)name;

//! @brief A delegate
@property(nonatomic,assign)id xmlDelegate;
  
@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A delegate for \c INNetXMLContainer usage. Provides callbacks for fetching and displaying items  
 
*/
@protocol INNetXMLContainerDelegate

//! @brief A container starts updating it's net resource
- (void)netxmlContainerDidStartUpdate:(INNetXMLContainer *)container;

//! @brief Updation did fail with some error description
- (void)netxmlContainer:(INNetXMLContainer *)container updateDidFailWithError:(NSError *)error;

//! @brief Notifies the delegate about successful containet updating. \c changed is YES for any data changed/updated
- (void)netxmlContainerDidFinishUpdate:(INNetXMLContainer *)container withChanges:(BOOL)changed;

//! @brief The processing was canceled with \c stop operation
- (void)netxmlContainerDidCancel:(INNetXMLContainer *)container;

@end

//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A single fetched node in INNetXMLContainer. See INNetXMLContainer for more information
    
*/

@interface INNetXMLContainerNode : NSObject {
@private    
    NSMutableDictionary * _properties;
    NSDictionary * _attributes;
    NSMutableString * _nodeData;
@package   
    union { 
        unsigned allInOne;
        struct { 
            unsigned read :1;
            unsigned storedLocally :1;
            unsigned contentModified :1;
            unsigned unreadStatusModified :1;
        } f;
    } _flags;
}    

//! @brief All properties and settings are stored here
@property(nonatomic,readonly) NSMutableDictionary * properties;

//! @brief 
@property(nonatomic,retain) NSDictionary * attributes;

//! @brief 
@property(nonatomic,retain) NSMutableString * nodeData;

//! @brief Set a property for node 
- (void)setProperty:(id)aProperty forKey:(id)aKey;

//! @brief Get a property for node
- (id)propertyForKey:(id)aKey;

//! @brief Unique key name, used when trying to find duplicated nodes in comparing new and old downloaded nodes
+ (id)uniqueKeyName;

//! @brief Modification key name. Used to find modified nodes (e.g. pubDate in RSS)
+ (id)modificationKeyName;

@end


//==================================================================================================================================
//==================================================================================================================================

/**
 @brief A helper for processing very often used (xml)(nodes)(node/)...(/nodes)- structured XML document 
 
    Most XML documents are in the following format:
    (xml)
      ...  
      (nodes)
          (node)
             ...
          (/node)
          ...
      (/nodes)
 
    INNetXMLContainer is a parser for such documents. See INRSSChannel implementation as a sample
*/

@interface INNetXMLContainer : NSObject<INNetXMLResourceDelegate, INManagedNetResource> {
@private    
    id<INNetXMLContainerDelegate> _delegate;
    INNetXMLResource * _xmlNetResource; 
    NSString * _resourceURL, * _user, * _password;
    NSMutableArray * _nodes;
    NSMutableArray * _visibleNodes;
    BOOL _visibleFilterValid;
    NSMutableDictionary * _commonProperties;
    NSDate * _lastSuccessfulUpdate;
    NSString  * _currentlyParsedElement;
    NSDictionary * _currentlyParsedElementAttributes;
    NSInteger _currentlyParsedLevel;
    NSString * _nodesTagName; 
    NSString * _nodeTagName;
    BOOL _shouldClearPreviousResult;
    BOOL _useINNetXMLContainerNode;
    
    // temporary stuff for parsing 
    NSMutableArray * _fetchedItems;
    INNetXMLContainerNode * _currentNode;

    NSInteger _nodesTag, _nodeTag;  // INXML_CONTAINER_NODES or INXML_CONTAINER_NODE usually, but can be
                                    // changed if such names are in tag map already
    
}
//! @brief 
- (id)initWithNodesTagName:(NSString *)nodesTagName nodeTagName:(NSString *)nodeTagName;

//! @brief A delegate
@property(nonatomic,assign)id <INNetXMLContainerDelegate> delegate;  

//! @brief URL of remote XML resource
@property(nonatomic,retain) NSString  * resourceURL;

//! @brief Username for accessing data from resourceURL resource.
@property(nonatomic,retain) NSString  * user;

//! @brief Password for accessing data from resourceURL resource.
@property(nonatomic,retain) NSString  * password;

//! @brief The storage for all common properties (empty in the base class)
@property(nonatomic,retain) NSMutableDictionary * properties;

//! @brief All nodes are here. An array of \c INNetXMLContainerNodes (or its descendants)
@property(nonatomic,readonly) NSMutableArray * nodes;

//! @brief A filtered list of nodes to display (items are taken from self.nodes array)
@property(nonatomic,readonly) NSArray * visibleNodes;

//! @brief Returns YES when channel updates it's contents 
@property(nonatomic,readonly) BOOL isUpdating;

//! @brief Updates the container (fetch new nodes from the url). Do nothing if updating is already in progress 
- (void)update;

//! @brief Stops the updating
- (void)stop;

//! @brief Clears all loaded nodes. 
//  Do it before updating if you do not provide [INNetXMLContainerNode uniqueKeyName] with the correct value and shouldClearPreviosResult = NO
- (void)clearLoadedNodes;

//! @brief Calls \c clearLoadedNodes on new document loading/updating. default is YES 
@property BOOL shouldClearPreviousResult;

//! @brief Invalidate visible node state. Visible nodes will be validated on the first subsequent accessing
- (void)invalidateVisibleNodes;

//! @brief The timestamp of last successful update. Returns [NSDate distantPast] if not updates were performed yet
@property(nonatomic,readonly) NSDate * lastSuccessfulUpdateDate;

//! @brief Current parsed element. A parse helper for descendants
@property(nonatomic,readonly) NSString  * currentlyParsedElement;

//! @brief Current parsed element attributes. A parse helper for descendants
@property(nonatomic,readonly) NSDictionary * currentlyParsedElementAttributes;

//! @brief Current parsed element level (0 for root level). A parse helper for descendants
@property(nonatomic,readonly) NSInteger currentlyParsedElementLevel;

//! @brief Current parsed node. A parse helper for descendants
@property(nonatomic,retain) INNetXMLContainerNode * currentlyParsedNode;

//! @brief XML resource (document). A parse helper for descendants
@property(nonatomic,readonly) INNetXMLResource * xmlResource;

//! @brief Finds a node with the property for key \c property that equals the \c value
- (INNetXMLContainerNode *)findNodeByProperty:(id)property value:(id)value;

//! @brief "nodes" XML tag name. A mandatory field. Set it up in the before any XML parsing
@property(nonatomic,retain) NSString * nodesTagName;

//! @brief A single "node" XML tag name. A mandatory field. Set it up in the before any XML parsing
@property(nonatomic,retain) NSString * nodeTagName;

//! @brief For debug purposes - emulates slow network delay (in seconds)
@property NSUInteger slowNetworkEmulationDelay;


// for overriding only, do not call methods below
- (void)processNodesAttributes:(NSDictionary *)attributes;

- (void)processChildOfNodesWithTag:(int)tag startCollectData:(BOOL *)startCollectData;
- (void)finalizeChildOfNodesWithTag:(int)tag collectedData:(NSString *)collectedData;

- (void)processNode:(INNetXMLContainerNode *)node withAttributes:(NSDictionary *)attributes;

- (void)processChildOfNode:(INNetXMLContainerNode *)node withTag:(int)tag startCollectData:(BOOL *)startCollectData;
- (void)finalizeChildOfNode:(INNetXMLContainerNode *)node withTag:(int)tag collectedData:(NSString *)collectedData;

- (Class)nodeClass;

- (BOOL)checkNodeBeforeAdding:(INNetXMLContainerNode *)node;
- (void)sortVisibleNodes:(NSMutableArray *)nodes;

@end

