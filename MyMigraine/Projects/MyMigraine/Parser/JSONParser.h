//
//  JSONParser.h
//  Maryland_Governor
//
//  Created by mac mini on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EmailMessageDelegate
@required

-(void)messageSent:(NSString *)message;
-(void)messageFailed:(NSString *)message error:(NSError *)error;

@end
@interface JSONParser : NSObject
{
    NSString *hostStr;
    id <EmailMessageDelegate> delegate;
}
@property (nonatomic, retain)   NSString *hostStr;
@property(nonatomic, assign) id <EmailMessageDelegate> delegate;
-(void)sendEmail:(NSString *)emailId;



@end
