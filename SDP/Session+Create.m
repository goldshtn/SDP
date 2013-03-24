//
//  Session+Create.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Session+Create.h"
#import "JSONConstants.h"
#import "ErrorReporting.h"

@implementation Session (Create)

+ (Session *)sessionWithJSONObject:(NSDictionary *)jsonObject
            inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Session *session;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.predicate = [NSPredicate predicateWithFormat:@"number = %@", jsonObject[SESSION_NUMBER]];

    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (!matches || error) {
        [ErrorReporting reportError:error
                   withErrorMessage:@"Error fetching session."
                        recoverable:NO];
        return nil;
    }
    if ([matches count] == 1) {
        session = matches[0];
    } else {
        session = [NSEntityDescription insertNewObjectForEntityForName:@"Session"
                                                inManagedObjectContext:managedObjectContext];
    }
    session.number = [jsonObject[SESSION_NUMBER] shortValue];
    session.title = jsonObject[SESSION_TITLE];
    session.abstract = jsonObject[SESSION_ABSTRACT];
    session.level = [jsonObject[SESSION_LEVEL] shortValue];
    session.prerequisites = jsonObject[SESSION_PREREQUISITES];
    session.slot = jsonObject[SESSION_TIME];

    return session;
}

@end
