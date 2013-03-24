//
//  DataAccessCoordinator.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/13/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "DataAccessCoordinator.h"
#import "DiagnosticUIManagedDocument.h"
#import "ErrorReporting.h"

@interface DataAccessCoordinator ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSMutableArray *enqueuedCompletionBlocks;

@end

//This class is not thread-safe, but it is asynchronous, so we can have multiple invocations
//come through on the main thread while the underlying document is not yet initialized.
@implementation DataAccessCoordinator

- (NSMutableArray *)enqueuedCompletionBlocks {
    if (!_enqueuedCompletionBlocks) _enqueuedCompletionBlocks = [NSMutableArray array];
    return _enqueuedCompletionBlocks;
}

+ (DataAccessCoordinator *)sharedCoordinatorWithCompletionBlock:(data_access_coordinator_completion_block_t)completionBlock {
    static DataAccessCoordinator *coordinator = nil;
    if (!coordinator) {
        coordinator = [[DataAccessCoordinator alloc] initWithCompletionBlock:completionBlock];
    } else if (!coordinator.managedObjectContext) {
        //There is already an initialization in flight, so we enqueue the completion block for
        //processing as soon as the managed object context is initialized.
        [coordinator.enqueuedCompletionBlocks addObject:completionBlock];
    } else {
        completionBlock(coordinator);
    }
    return coordinator;
}

- (id)initWithCompletionBlock:(data_access_coordinator_completion_block_t)completionBlock {
    if (self = [super init]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsDir = urls[0];
        NSURL* dbPath = [documentsDir URLByAppendingPathComponent:@"sdp.sqlite"];
        self.document = [[DiagnosticUIManagedDocument alloc] initWithFileURL:dbPath];
        void(^documentOpenOrCreateCompletionBlock)(BOOL) = ^(BOOL success) {
            if (!success) {
                [ErrorReporting reportError:nil
                           withErrorMessage:@"Error opening or creating the database."
                                recoverable:NO];
                completionBlock(nil);
            } else {
                self.managedObjectContext = self.document.managedObjectContext;
                completionBlock(self);
                for (data_access_coordinator_completion_block_t enqueuedBlock in self.enqueuedCompletionBlocks) {
                    enqueuedBlock(self);
                }
            }
        };
        if ([fileManager fileExistsAtPath:[self.document.fileURL path]]) {
            [self.document openWithCompletionHandler:documentOpenOrCreateCompletionBlock];
        } else {
            [self.document saveToURL:self.document.fileURL
                    forSaveOperation:UIDocumentSaveForCreating
                   completionHandler:documentOpenOrCreateCompletionBlock];
        }
    }
    return self;
}

@end
