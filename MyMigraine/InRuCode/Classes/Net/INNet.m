//!
//! @file INNet.m
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

#import "INNet.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <netinet/in.h>

BOOL INNetWeAreConnectedToNetwork(){
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags){
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection)? YES :NO;
}

//==================================================================================================================================
//==================================================================================================================================

@implementation INNetworkIndicator

static int _networkActivityStartCount = 0;

+ (void)start { 
    _networkActivityStartCount++;    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (void)stop {
    if (_networkActivityStartCount > 0){ 
        _networkActivityStartCount-- ;
    }
    if (_networkActivityStartCount == 0){ 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end

