//
//  AppDefaults.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/24/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDefaults : NSObject

+ (BOOL)didLoadAtLeastOnce;
+ (BOOL)shouldReloadSchedule;
+ (NSDate *)lastLoadedDate;
+ (void)didLoadSchedule;

@end
