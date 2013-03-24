//
//  DataAccessCoordinator.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/13/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAccessCoordinator : NSObject

typedef void (^data_access_coordinator_completion_block_t)(DataAccessCoordinator *coordinator);

+ (DataAccessCoordinator *)sharedCoordinatorWithCompletionBlock:(data_access_coordinator_completion_block_t)completionBlock;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@end
