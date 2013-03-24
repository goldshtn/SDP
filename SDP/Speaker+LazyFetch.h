//
//  Speaker+LazyFetch.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Speaker.h"

@interface Speaker (LazyFetch)

typedef void(^photo_block_t)(UIImage *photo);

- (void)loadPhotoWithCompletionHandler:(photo_block_t)completionHandler;

@end
