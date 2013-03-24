//
//  Session+Create.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Session.h"

@interface Session (Create)

+ (Session *)sessionWithJSONObject:(NSDictionary *)jsonObject
            inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
