//
//  Feedback.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

typedef void(^feedback_completion_handler_t)(BOOL success, NSString *error);

@interface Feedback : NSObject

+ (Feedback *)feedbackWithSession:(Session *)session
                    contentRating:(float)contentRating
                    speakerRating:(float)speakerRating
                      andFreeText:(NSString *)freeText;
- (void)submitWithCompletionHandler:(feedback_completion_handler_t)completionHandler;

@end
