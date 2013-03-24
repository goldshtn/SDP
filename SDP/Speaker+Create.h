//
//  Speaker+Create.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Speaker.h"

@interface Speaker (Create)

+ (Speaker *)speakerWithJSONObject:(NSDictionary *)jsonObject
            inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
