//
//  SpeakerCollectionViewCell.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Speaker+LazyFetch.h"

@interface SpeakerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) Speaker *speaker;

@end
