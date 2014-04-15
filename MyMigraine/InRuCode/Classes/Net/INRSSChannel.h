//!
//! @file INRSSChannel.h
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

#import <Foundation/Foundation.h>
#import "INNetXML.h"


//==================================================================================================================================
//==================================================================================================================================

/**
 @brief Represents a single RSS feed item  

*/
@interface INRSSItem : INNetXMLContainerNode {

}    
/**
 @brief @brief Feed's item URL. 
 
 Convenient getter/setter for INRSSItem.properties[@"link"]
*/
@property (nonatomic, retain) NSString * link;

/**
 @brief Feed's item publication date in string form (as it was received from rss server). 
 
 Convenient getter/setter for INRSSItem.properties[@"pubDate"] 
*/
@property (nonatomic, retain) NSString * publicationDateString;

/**
 @brief Feed's item publication date in NSDate format. 
 */
@property (readonly) NSDate * publicationDate;

/**
 @brief Feed's item title. 
 
 Convenient getter/setter for INRSSItem.properties[@"title"] 
 */
@property (nonatomic, retain) NSString * title;
@property (readonly) NSString * plainTitle;

/**
 @brief Feed's item description (short text content). 
 
 Convenient getter/setter for INRSSItem.properties[@"description"] 
 */
@property (nonatomic, retain) NSString * text;


//! @brief stripped (no html) version of \c self.text
@property (readonly) NSString * plainText;

@end

/**
 @brief A single RSS channel (subscription). Provides fetching and storing
 of all feed items for the given rss feed link
    
*/
@interface INRSSChannel : INNetXMLContainer {
    
}

//! @brief Feed's title. Convenient getter/setter for INRSSChannel.properties[@"title"] 
@property (nonatomic, retain) NSString * title;

@end

/**
 @brief A delegate for INRSSChannel 
    
*/

@protocol INRSSChannelDelegate<INNetXMLContainerDelegate> 

@end
