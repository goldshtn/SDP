//
//  ErrorReporting.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "ErrorReporting.h"
#import "GAITrackerContainer.h"

@implementation ErrorReporting

//For recoverable errors, we suggest that the user try the operation again. For non-recoverable
//errors, we suggest that the user restart the application.
+ (void)reportError:(NSError *)error withErrorMessage:(NSString *)errorMessage recoverable:(BOOL)recoverable {
    //This method might be called from a thread that isn't the main thread, so make sure to dispatch
    //back to the main thread because we want to show UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"We apologize, but an error occurred.\n%@\nError message: %@.", recoverable ? @"We suggest that you try again soon." : @"We suggest that you shut down the application and run it again.", errorMessage];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
    });

    [[GAITrackerContainer sharedTracker] sendEventWithCategory:@"Error"
                                                    withAction:errorMessage
                                                     withLabel:[error description]
                                                     withValue:@0];
    NSLog(@"Error reporting invoked with message = %@, NSError = %@, recoverable = %@",
          errorMessage, [error description], (recoverable ? @"YES" : @"NO"));
}

@end
