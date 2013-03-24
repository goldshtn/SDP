//
//  Session.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/21/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Speaker;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) NSString * day;
@property (nonatomic) int16_t dayIndex;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int16_t level;
@property (nonatomic) int16_t number;
@property (nonatomic, retain) NSString * prerequisites;
@property (nonatomic, retain) NSString * slot;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * track;
@property (nonatomic, retain) Speaker *speaker;

@end
