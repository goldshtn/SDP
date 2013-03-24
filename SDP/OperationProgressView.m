//
//  OperationProgressView.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "OperationProgressView.h"

@interface OperationProgressView ()

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *progressLabel;

@end

@implementation OperationProgressView

- (void)layoutSubviews {
    CGRect frame = self.frame;
    CGRect activityIndicatorFrame = CGRectMake(frame.size.width/2 - 15, 20, 30, 30);
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:activityIndicatorFrame];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    CGRect progressLabelFrame = CGRectMake(10, frame.size.height - 40, frame.size.width - 20, 30);
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:progressLabelFrame];
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.text = self.progressInfo;
    [self addSubview:activityIndicator];
    [self addSubview:progressLabel];
    self.activityIndicator = activityIndicator;
    self.progressLabel = progressLabel;
    [self.activityIndicator startAnimating];
}

- (void)setProgressInfo:(NSString *)progressInfo {
    self.progressLabel.text = progressInfo;
}

@end
