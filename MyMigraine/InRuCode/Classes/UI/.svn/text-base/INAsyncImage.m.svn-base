//!
//! @file INAsyncImage.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2012 InRu
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

#import "INAsyncImage.h"
#import "INView.h"

@interface INAsyncImage()<INNetQueryContent>

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INAsyncImage

@synthesize image = _image;
@synthesize URLString = _URLString;
@synthesize substitutionImage = _substitutionImage;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithURLString:(NSString *)URLString netCenter:(INNetCenter *)center { 
    // NSParameterAssert(URLString);
    self = [super init];
    if (self) {
        self.subscriptionNotificationsEnabled = YES;
        _netCenter = center;
        _URLString = [URLString retain];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_image release];
    [_URLString release];
    [_netCenter removeQueryWithContent:self];
    [_substitutionImage release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setURLString:(NSString *)value { 
    if (![_URLString isEqualToString:value]) { 
        [_URLString release];
        _URLString  = [value retain];
        self.image = nil;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id<INManagedNetResource>)createNetworkResourceForQuery:(INNetQuery *)query URLString:(NSString **)URLString { 
    *URLString = _URLString;
    INNetResource * resource = [INNetResource resource];
    resource.cacheFileName = *URLString;
    resource.cacheTTL = 24 * 3600;
    return resource;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)finishImageLoadingWithImage:(UIImage *)image error:(NSError *)error { 
    self.image = image;
    if (image) { 
        self.lastObjectError = nil;
        self.objectState = INAsyncImageIdleLoaded;
    } else { 
        self.lastObjectError = error;
        self.objectState = INAsyncImageIdleFailed;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)query:(INNetQuery *)query didFinishWithResource:(INNetResource *)resource error:(NSError *)error { 
    [query remove];
    UIImage * image = error ? nil : [UIImage imageWithData:resource.receivedData];
    if (!image) { 
        error = [INError errorWithCode:INErrorCodeBadData];
    }
    [self finishImageLoadingWithImage:image error:error];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)image { 
    UIImage * result = _image;
    if (!result) {  
        if (self.objectState == INAsyncImageIdleState || self.objectState == INAsyncImageIdleFailed ) {
            self.objectState = INAsyncImageIdleLoading;
            if (!_URLString.length) {
                [self finishImageLoadingWithImage:nil error:[INError errorWithCode:INErrorCodeBadParameter]];
            } else { 
                INNetQuery * q = [_netCenter queryWithContent:self];
                if (!q) { 
                    [_netCenter addQueryWithContent:self repeatInterval:10];
                }
            }
        }
    }
    return result ? result : _substitutionImage;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSubstitutionImage:(UIImage *)substitutionImage { 
    if (substitutionImage != _substitutionImage) { 
        [_substitutionImage release];
        _substitutionImage = [substitutionImage retain];
        if (self.objectState != INAsyncImageIdleLoaded) {
            [self notifySubscribers];    
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)imageLoaded { 
    return _image != nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (INAsyncImageState)imageState { 
    return self.objectState;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INAsyncImageView

@synthesize activityIndicatorVisible = _activityIndicatorVisible;
@synthesize activityIndicatorStyle = _activityIndicatorStyle;

- (void)internalInit {
    _activityIndicatorVisible = YES;
    _activityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_asyncImage unsubscribe:self];
    [_asyncImage release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateState {
    if (_activityIndicatorVisible) { 
        if (_asyncImage.objectState == INAsyncImageIdleLoading) { 
            if (!_activityIndicator) { 
                _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:_activityIndicatorStyle];
                _activityIndicator.autoresizingMask =
                         UIViewAutoresizingFlexibleLeftMargin |
                         UIViewAutoresizingFlexibleTopMargin |
                         UIViewAutoresizingFlexibleRightMargin |
                         UIViewAutoresizingFlexibleBottomMargin; 
                 _activityIndicator.center = self.inru_centerOfContent;
                 _activityIndicator.hidesWhenStopped = YES;
                 [self addSubview:_activityIndicator];
                 [_activityIndicator release];       
            }
            [_activityIndicator startAnimating];
        } else { 
            [_activityIndicator stopAnimating];
        }
     
    } else { 
        [_activityIndicator removeFromSuperview];
        _activityIndicator = nil;
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setActivityIndicatorVisible:(BOOL)activityIndicatorVisible { 
    if (_activityIndicatorVisible != activityIndicatorVisible) { 
        _activityIndicatorVisible = activityIndicatorVisible;
        [self updateState];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)assignImage {
    self.image = [_asyncImage performSelector:_asyncImageGetter];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setAsyncImage:(INAsyncImage *)image {
    [self setAsyncImage:image getter:@selector(image)];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setAsyncImage:(INAsyncImage *)image getter:(SEL)getter { 
    if (image != _asyncImage || _asyncImageGetter != getter) { 
        [_asyncImage unsubscribe:self];
        [_asyncImage release];
        _asyncImage = [image retain];
        [_asyncImage subscribe:self];
        _asyncImageGetter = getter;
        [self assignImage];
        [self updateState];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)inobjectDidNotify:(INObject *)object { 
    [self updateState];
    if (object.objectState == INAsyncImageIdleLoaded) { 
        [self assignImage];
    }
}

@end



