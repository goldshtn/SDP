//
//  ErrorReporting.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorReporting : NSObject

+ (void)reportError:(NSError *)error withErrorMessage:(NSString *)errorMessage recoverable:(BOOL)recoverable;

@end
