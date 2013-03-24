//
//  Feedback.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Feedback.h"

//#define TESTING

#ifndef TESTING
#define FEEDBACK_URL_STRING @"http://www.seladeveloperpractice.com/api/feedback"
#else
#define FEEDBACK_URL_STRING @"http://localhost:8080/api/feedback"
#endif

#define INSTALLATION_ID_KEY @"installationId"
#define SESSION_NUM_KEY @"sessionNum"
#define SESSION_TITLE_KEY @"sessionTitle"
#define CONTENT_RATING_KEY @"contentRating"
#define SPEAKER_RATING_KEY @"speakerRating"
#define FREETEXT_KEY @"freeText"

@interface Feedback () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *installationUUIDString;
@property (nonatomic) float contentRating;
@property (nonatomic) float speakerRating;
@property (nonatomic, strong) NSString *freeText;
@property (nonatomic, strong) Session *session;
@property (nonatomic, strong) feedback_completion_handler_t completionHandler;

@end

@implementation Feedback

+ (Feedback *)feedbackWithSession:(Session *)session
                    contentRating:(float)contentRating
                    speakerRating:(float)speakerRating
                      andFreeText:(NSString *)freeText
{
    Feedback *feedback = [[Feedback alloc] init];
    feedback.contentRating = contentRating;
    feedback.speakerRating = speakerRating;
    feedback.freeText = freeText;
    feedback.session = session;
    feedback.installationUUIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return feedback;
}

- (NSData *)bodyData {
    NSDictionary *body = @{
                           INSTALLATION_ID_KEY: self.installationUUIDString,
                           SESSION_NUM_KEY : @(self.session.number),
                           SESSION_TITLE_KEY : self.session.title,
                           CONTENT_RATING_KEY : @(self.contentRating),
                           SPEAKER_RATING_KEY : @(self.speakerRating),
                           FREETEXT_KEY : self.freeText
                           };
    return [NSJSONSerialization dataWithJSONObject:body options:0 error:NULL];
    //Error handled by caller, who expects a possible nil return value.
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.completionHandler(NO, [error description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            self.completionHandler(NO, [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
        } else {
            self.completionHandler(YES, nil);
        }
    } else {
        NSLog(@"Unrecognized URL response class: %@", [response class]);
    }
}

- (void)submitWithCompletionHandler:(feedback_completion_handler_t)completionHandler {
    self.completionHandler = completionHandler;
    
    NSData *body = [self bodyData];
    if (!body) {
        completionHandler(NO, @"Error serializing feedback object to NSData.");
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FEEDBACK_URL_STRING]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

@end
