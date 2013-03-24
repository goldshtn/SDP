//
//  LocalNotificationManager.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@interface LocalNotificationManager : NSObject

+ (void)addNotificationForSession:(Session *)session;
+ (void)removeNotificationForSession:(Session *)session;

@end
