//!
//! @file INRSSChannel.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2010
//! 
//! Copyright 2010 InRu
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
     
#import "INRSSChannel.h"
#import "INCommonTypes.h"

enum {
    TAG_TITLE,
    TAG_LINK,
    TAG_DESCRIPTION,
    TAG_PUBDATE
};

#define PLAIN_TEXT_KEY @"plainText_29324f6b_a8f7_49c7_a437_c0dd1350cfb4"
#define PLAIN_TITLE_KEY @"plainTitle_293479823479032"

#define TEXT_KEY       @"description"
#define TITLE_KEY       @"title"


@implementation INRSSItem

INXML_GET_SET_PROP(self.properties, link, setLink, NSString *, @"link");
INXML_GET_SET_PROP(self.properties, publicationDateString, setPublicationDateString, NSString *, @"pubDate");

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)title { 
    return [self propertyForKey:TITLE_KEY];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) setTitle:(NSString *)value { 
    [self.properties setObject:value forKey:TITLE_KEY];
    [self.properties removeObjectForKey:PLAIN_TITLE_KEY];
}

//----------------------------------------------------------------------------------------------------------------------------------
    
- (NSString *)plainTitle { 
    NSString * obj = [self propertyForKey: PLAIN_TITLE_KEY];
    if (!obj) { 
        obj = [[self.title inru_htmlToPlain] inru_trim];
        [self setProperty: obj forKey: PLAIN_TITLE_KEY];
    }

    if (!obj) { 
        obj = [[self.text inru_htmlToPlain] inru_trim];
        [self setProperty: obj forKey: PLAIN_TITLE_KEY];
    }
    
    return obj;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)text { 
    return [self propertyForKey: TEXT_KEY];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) setText:(NSString *)value { 
    [self.properties setObject: value forKey: TEXT_KEY];
    [self.properties removeObjectForKey: PLAIN_TEXT_KEY];
}

//----------------------------------------------------------------------------------------------------------------------------------
    
- (NSString *)plainText { 
    NSString * obj = [self propertyForKey: PLAIN_TEXT_KEY];
    if (!obj) { 
        obj = [[self.text inru_htmlToPlain] inru_trim];
        [self setProperty: obj forKey: PLAIN_TEXT_KEY];
    }
    return obj;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSDate *)publicationDate { 
    return [NSDate inru_dateFromRfc822String:self.publicationDateString];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id) uniqueKeyName { 
    return @"link";
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id) modificationKeyName {
    return @"pubDate";
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INRSSChannel

INXML_GET_SET_PROP(self.properties, title, setTitle, NSString *, @"title");

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        self.xmlResource.nameMap = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithInt: TAG_TITLE],       @"title",
                [NSNumber numberWithInt: TAG_LINK],        @"link",
                [NSNumber numberWithInt: TAG_DESCRIPTION], @"description",
                [NSNumber numberWithInt: TAG_PUBDATE],     @"pubDate",
                nil
            ] autorelease];
        self.nodesTagName = @"channel";
        self.nodeTagName = @"item";
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) processChildOfNodesWithTag:(int)tag startCollectData:(BOOL *)startCollectData { 
    switch (tag) {
        case TAG_TITLE:
        case TAG_LINK:
        case TAG_DESCRIPTION:
            *startCollectData = YES;
            break;
    }    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) processChildOfNode:(INNetXMLContainerNode *)node withTag:(int)tag startCollectData:(BOOL *)startCollectData { 
    switch (tag) {
        case TAG_TITLE:
        case TAG_LINK:
        case TAG_DESCRIPTION:
        case TAG_PUBDATE:
            *startCollectData = YES;
            break;
    }    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) finalizeChildOfNodesWithTag:(int) tag collectedData:(NSString *)collectedData { 
    switch (tag) {
        case TAG_TITLE:
        case TAG_LINK:
        case TAG_DESCRIPTION:
            [self.properties setObject:collectedData forKey: self.currentlyParsedElement];
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) finalizeChildOfNode:(INNetXMLContainerNode *)node withTag:(int)tag collectedData:(NSString *)collectedData { 
    switch (tag) {
        case TAG_TITLE:
        case TAG_LINK:
        case TAG_DESCRIPTION:
        case TAG_PUBDATE:
            [node setProperty:collectedData forKey:self.currentlyParsedElement];
            break;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (Class) nodeClass { 
    return [INRSSItem class];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL) checkNodeBeforeAdding:(INNetXMLContainerNode *)node { 
    return [((INRSSItem *)node).link length] != 0;
}
    
//----------------------------------------------------------------------------------------------------------------------------------

NSInteger CompareRSSItems(INRSSItem * item1, INRSSItem * item2, void *context) {
    NSDate * d1 = item1.publicationDate;
    NSDate * d2 = item2.publicationDate;
    NSInteger result;
    
    result = [d1 compare: d2]; 
    return -1 * result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void) sortVisibleNodes:(NSMutableArray *)nodes { 
    [nodes sortUsingFunction: CompareRSSItems context: nil];  
}
    
@end
