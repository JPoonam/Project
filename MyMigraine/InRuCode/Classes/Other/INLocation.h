//!
//! @file INLocation.h
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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CLLocationManager (INRU) 

+ (BOOL)inru_locationServicesEnabled;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface CLLocation (INRU) 

- (CLLocationDistance)inru_distanceFromLocation:(const CLLocation *)location;

@end

//==================================================================================================================================
//==================================================================================================================================

NS_INLINE CLLocationCoordinate2D INLocationCoordinate2DMake(CLLocationDegrees latitude, CLLocationDegrees longitude) { 
    CLLocationCoordinate2D result = { latitude , longitude };
    return result;  
}

//==================================================================================================================================
//==================================================================================================================================

@interface INMapArea : NSObject {
    CLLocationDegrees _minLat,_maxLat,_minLon,_maxLon;
    NSInteger _pointsAdded;
}

- (void)addCoordinateWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (void)addCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)reset;

@property (nonatomic,readonly) CLLocationCoordinate2D center;
- (CLLocationDistance)distanceToCenterFromCoordinate:(CLLocationCoordinate2D)coordinate;
- (MKCoordinateRegion)regionWithSpanRatio:(CGFloat)ratio minSpanDistance:(CLLocationDistance)spanDistance;

@end
