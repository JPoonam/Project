//
//  Created by alex on 5/8/11.
//


#import "INAssert.h"


#define LOG_LEVEL_DEBUG 3
#define LOG_LEVEL_INFO  2
#define LOG_LEVEL_ERROR 1

#ifdef DEBUG
#define LOG_LEVEL LOG_LEVEL_DEBUG
#else
#define LOG_LEVEL LOG_LEVEL_ERROR
#endif


@implementation INAssert

    + (void)logDebug:(id)aMessage, ... {
#if LOG_LEVEL >= LOG_LEVEL_DEBUG
        va_list args;
        va_start(args, aMessage);

        NSString *string = [[NSString alloc] initWithFormat:aMessage arguments:args];
        NSLog(@"%@", string);
        [string release];
        
        va_end(args);
#endif
    }

    + (void)log:(NSString *)aMessage {
#if LOG_LEVEL >= LOG_LEVEL_INFO
        NSLog(@"%@", aMessage);
#endif
    }

    + (void)logError:(NSString *)aMessage {
#if LOG_LEVEL >= LOG_LEVEL_ERROR
        NSLog(@"%@", aMessage);
#endif
    }

    + (void)failWithMessage:(NSString *)aMessage, ... {
        va_list args;
        va_start(args, aMessage);

        id string = [[NSString alloc] initWithFormat:aMessage arguments:args];
        NSAssert(NO, @"%@", string);
        [string release];
        
        va_end(args);
    }

    + (void)assert:(BOOL)aCondition withMessageIfFail:(NSString *)aMessage {
#if LOG_LEVEL >= LOG_LEVEL_ERROR
        if (!aCondition) {
            NSAssert(NO, @"%@", aMessage);
        }
#endif
    }

    + (void)checkError:(NSError *)aError {
        if (aError != nil) {
#if LOG_LEVEL >= LOG_LEVEL_DEBUG
            [self failWithMessage:[NSString stringWithFormat:@"NSError: %@", [aError localizedDescription]]];
#endif
#if LOG_LEVEL >= LOG_LEVEL_INFO
            NSLog(@"(!) NSError: %@", [aError localizedDescription]);
#endif
        }
    }

@end
