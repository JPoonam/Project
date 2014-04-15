//
//  JSONParser.m
//  Maryland_Governor
//
//  Created by mac mini on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONParser.h"
#import "JSON.h"
#import "BHGlobals.h"


@implementation JSONParser
@synthesize hostStr,delegate;

-(id)init
{
    if ((self=[super init]))
    {
            
    }
    return self ;
}


-(void)sendEmail:(NSString *)emailId

{
    
  
    
     NSString *serverOutput = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:SERVERSTATUS] encoding:NSASCIIStringEncoding error:nil];
      
    //if ([serverOutput :@"true"] || [serverOutput isEqualToString:@"TRUE"])
    if ([serverOutput rangeOfString:@"true"].location!=NSNotFound)
    {
        NSString *post =[NSString stringWithFormat:@"recipientEmail=%@&recipientName=%@",emailId, emailId];
        
        hostStr = [SENDMAILURL stringByAppendingString:post];
        
        
        NSString *jsonOutput = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:hostStr] encoding:NSASCIIStringEncoding error:nil];
        
        
        SBJSON *parser=[[SBJSON alloc]init];
        
        NSDictionary *myDic=(NSDictionary *)[parser objectWithString:jsonOutput error:nil];
        
        
        BOOL *successFlag=(NSString *)[myDic objectForKey:@"success"];
        NSString *mesString;
        NSLog(@"%@",successFlag);
        if(successFlag)
        {
            [delegate messageSent:@"Email successfully sent."];
            [parser release]; 
            
            /*  mesString=(NSString *)[myDic objectForKey:@"data"];
             [delegate messageSent:mesString];
             [parser release]; 
             */
            
        }
        else
        {
            [delegate messageSent:@"Email can’t be sent. Please try again later!"];
            [parser release]; 
            /*
             NSMutableArray *messageObjectList=(NSMutableArray *)[myDic bjectForKey:@"messages"];;
             
             
             for (int i=0; i<messageObjectList.count; i++) 
             {
             NSDictionary *messageDict=[messageObjectList objectAtIndex:i];
             NSString *tempIdValue=(NSString *)[messageDict objectForKey:@"id"];
             mesString=(NSString *)[messageDict objectForKey:@"message"];
             [delegate messageSent:mesString ];
             [parser release];
             
             } */
            
            
            
            
            
        }
   
    }
    else 
    {
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Server Error" message:@"Get coupon service is not available. Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
        
        [delegate messageSent:@"Get coupon service is not available. Please try again later!" ];
        
    }
    //[parser release];
    
    
       
   
     

    
    
    } 

@end


