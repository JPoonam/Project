//!
//! @file INSOAP.h
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

#import "INCommonTypes.h"
#import "INObject.h"

@interface INSimpleSOAPObject : INObject {

}

@property(nonatomic,readonly) NSString * XML;

@end

//==================================================================================================================================
//==================================================================================================================================

typedef enum { 
    INSimpleSOAPParamUnknown,
    INSimpleSOAPParamString,
    INSimpleSOAPParamNumber,
    INSimpleSOAPParamMap
} INSimpleSOAPParamType;

//==================================================================================================================================
//==================================================================================================================================

@interface INSimpleSOAPParam : INSimpleSOAPObject { 
    NSString * _paramTypeString;
    id _value;
    INSimpleSOAPParamType _type;
}

@property(nonatomic,copy) NSString * paramTypeString;
@property(nonatomic,readonly) INSimpleSOAPParamType paramType;

+ (id)mapWithName:(NSString *)name value:(NSDictionary *)dictionary;
+ (id)paramWithName:(NSString *)name value:(id)value;
+ (id)stringWithName:(NSString *)name value:(id)value;
+ (id)numberWithName:(NSString *)name value:(NSNumber *)value;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INSimpleSOAPRequestMethod : INSimpleSOAPObject {
    NSString * _nameSpace;
    NSString * _nameSpacePrefix;
    NSMutableArray * _params; 
}

@property(nonatomic,copy) NSString * nameSpace;
@property(nonatomic,copy) NSString * nameSpacePrefix;

- (void)addParam:(INSimpleSOAPParam *)param;
- (void)addParams:(NSArray *)params;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INSimpleSOAPRequest : INSimpleSOAPObject {
    INSimpleSOAPObject * _rootObject;
}

@property(nonatomic,readonly) INSimpleSOAPRequestMethod * method;
+ (id)methodRequestWithName:(NSString *)methodName nameSpace:(NSString *)nameSpace;

@end
