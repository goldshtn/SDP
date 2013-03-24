//
//  ScheduleFetcher.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleFetcher : NSObject

+ (void)fetchScheduleWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
