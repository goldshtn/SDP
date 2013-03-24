//
//  Session+DescriptionForSharing.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Session.h"

@interface Session (DescriptionForSharing)

- (NSString *)descriptionForSharing;
- (NSString *)shortDescriptionForSharing;

@end
