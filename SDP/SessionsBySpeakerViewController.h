//
//  SessionsBySpeakerViewController.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "ListOfSessionsViewController.h"
#import "Speaker.h"

@interface SessionsBySpeakerViewController : ListOfSessionsViewController

@property (nonatomic, strong) Speaker *speaker;

@end
