//
//  Session+FavoriteScheduling.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Session.h"

@interface Session (FavoriteScheduling)

- (void)toggleFavorite;
- (NSDate *)startTime;

@end
