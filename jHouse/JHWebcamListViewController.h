//
//  JHWebcamListViewController.h
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHServerConfig.h"

@interface JHWebcamListViewController : UITableViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, JHServerConfigDelegate>

@property (strong, nonatomic) IBOutlet UITableView *webcamTableView;

- (IBAction)refreshTable:(UIBarButtonItem *)sender;

@end
