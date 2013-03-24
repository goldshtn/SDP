//
//  GAITrackerContainer.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/21/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"

@interface GAITrackerContainer : NSObject

+ (void)setupGoogleAnalytics;
+ (id<GAITracker>)sharedTracker;

@end
