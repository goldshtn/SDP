//
//  SpeakerDetailsViewController.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Speaker+LazyFetch.h"

@interface SpeakerDetailsViewController : UIViewController

@property (nonatomic, strong) Speaker *speaker;

@end
