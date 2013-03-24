//
//  Speaker+LazyFetch.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Speaker+LazyFetch.h"
#import "NetworkIndicatorHelper.h"

@implementation Speaker (LazyFetch)

- (void)loadPhotoWithCompletionHandler:(photo_block_t)completionHandler {
    if (!self.photoData) {
        dispatch_queue_t fetchQ = dispatch_queue_create("Speaker Image Fetch", NULL);
        dispatch_async(fetchQ, ^{
            [NetworkIndicatorHelper addNetworkActivity];
            NSData *photoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photoURL]];
            [NetworkIndicatorHelper removeNetworkActivity];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoData = photoData;
                completionHandler([UIImage imageWithData:photoData]);
            });
        });
    } else {
        completionHandler([UIImage imageWithData:self.photoData]);
    }
}

@end
