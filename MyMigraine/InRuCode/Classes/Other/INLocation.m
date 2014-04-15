//!
//! @file INLocation.m
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

#import "INLocation.h"
#import "INCommonTypes.h"

@implementation CLLocationManager (INRU) 

+ (BOOL)inru_locationServicesEnabled {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000	
    if (INSystemVersionEqualsOrGreater(4, 0, 0)) {
        return [self locationServicesEnabled]; 
    }
#endif
    CLLocationManager * mngr = [CLLocationManager new]; 
    BOOL result = [(id)mngr locationServicesEnabled];
    [mngr release];
    return result;
}

@end


//==================================================================================================================================
//==================================================================================================================================

@implementation CLLocation (INRU) 

/* теоретически более быстрая функция. Не тестировалась. Попробовать если нужна будет скорость */ 
/*
- (float)distanceFromPoint:(CLLocationCoordinate2D)fromCoordinate toPoint:(CLLocationCoordinate2D)toCoordinate {  
    float dLat1InRad = fromCoordinate.latitude * (M_PI / 180.0);  
    float dLong1InRad = fromCoordinate.longitude * (M_PI / 180.0);  
    float dLat2InRad = toCoordinate.latitude * (M_PI / 180.0);  
    float dLong2InRad = toCoordinate.longitude * (M_PI / 180.0);  
    float dLongitude = dLong2InRad - dLong1InRad;  
    float dLatitude = dLat2InRad - dLat1InRad;  
    float a = pow(sin(dLatitude / 2.0), 2.0) + cos(dLat1InRad) * cos(dLat2InRad) * pow(sin(dLongitude / 2.0), 2.0);  
    float c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a));  
    float radius = 6371;  
    return radius * c;
}
*/

- (CLLocationDistance)inru_distanceFromLocation:(const CLLocation *)location {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200	
    if (INSystemVersionEqualsOrGreater(3, 2, 0)) {
        return [self distanceFromLocation:location]; 
    }
#endif
    return [(id)self getDistanceFrom:location];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INMapArea

//----------------------------------------------------------------------------------------------------------------------------------

- (void)reset { 
    _pointsAdded = 0;
    _minLat = 1000;
    _maxLat = -1000;
    _minLon = 1000;
    _maxLon = -1000;   
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id) init {
    self = [super init];
    if (self != nil) {
        [self reset];    
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

//- (void) dealloc {
//    [_currentLocation release];
//    [super dealloc];
//}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addCoordinate:(CLLocationCoordinate2D)coordinate { 
    [self addCoordinateWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)addCoordinateWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude { 
    if (latitude > _maxLat) { 
        _maxLat = latitude;
    }
    if (latitude < _minLat) { 
        _minLat = latitude;
    }
    if (longitude > _maxLon) { 
        _maxLon = longitude;
    }
    if (longitude < _minLon) { 
        _minLon = longitude;
    }
    _pointsAdded++;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CLLocationCoordinate2D)center { 
    CLLocationDegrees latitudeDelta = (_maxLat - _minLat) / 2; 
    CLLocationDegrees longitudeDelta = (_maxLon - _minLon) / 2; 
    CLLocationCoordinate2D centerCoordinate = INLocationCoordinate2DMake(_minLat + latitudeDelta,_minLon + longitudeDelta);
    return centerCoordinate; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CLLocationDistance)distanceToCenterFromCoordinate:(CLLocationCoordinate2D)coordinate {
    CLLocation * location1 = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocationCoordinate2D center = self.center;
    CLLocation * location2 = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    CLLocationDistance result = [location1 inru_distanceFromLocation:location2];
    [location1 release];
    [location2 release];
    return result; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (MKCoordinateRegion)regionWithSpanRatio:(CGFloat)ratio minSpanDistance:(CLLocationDistance)spanDistance { 
    CLLocationCoordinate2D center = self.center;
    //if (_pointsAdded <= 1) { 
    //    return MKCoordinateRegionMakeWithDistance(center, spanDistance, spanDistance);   
    //} else {
    CLLocationCoordinate2D c = { _minLat, _minLon }; 
    CGFloat distance = [self distanceToCenterFromCoordinate:c] * 2; // diametr
    if (distance <= spanDistance) { 
        return MKCoordinateRegionMakeWithDistance(center, spanDistance, spanDistance);    
    } else {
        CLLocationDegrees latitudeDelta = fabs((_maxLat - _minLat) / 2); 
        CLLocationDegrees longitudeDelta = fabs((_maxLon - _minLon) / 2);
        MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta * ratio,longitudeDelta * ratio);
        return MKCoordinateRegionMake(center,span);
    }
}

@end

