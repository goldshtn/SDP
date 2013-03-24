//
//  ListOfSessionsViewController.h
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ListOfSessionsViewController : UITableViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
