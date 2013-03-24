//
//  NetworkIndicatorHelper.h
//  SDP
//
//  Created by Sasha Goldshtein on 2/28/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkIndicatorHelper : NSObject

+ (void)addNetworkActivity;
+ (void)removeNetworkActivity;

@end
