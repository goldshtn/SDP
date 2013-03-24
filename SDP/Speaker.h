//
//  Speaker.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/21/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface Speaker : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * blog;
@property (nonatomic, retain) NSString * mvpProfile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSSet *sessions;
@end

@interface Speaker (CoreDataGeneratedAccessors)

- (void)addSessionsObject:(Session *)value;
- (void)removeSessionsObject:(Session *)value;
- (void)addSessions:(NSSet *)values;
- (void)removeSessions:(NSSet *)values;

@end
