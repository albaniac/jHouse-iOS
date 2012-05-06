//
//  JHDevicesListViewController.h
//  jHouse
//
//  Created by Greg on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHCellBinarySwitch.h"
#import "JHCellMultilevelSwitch.h"

@interface JHDevicesListViewController : UITableViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, JHCellBinarySwitchDelegate, JHCellMultilevelSwitchDelegate>

@property (strong, nonatomic) IBOutlet UITableView *devicesTableView;

- (IBAction)refreshTable:(UIBarButtonItem *)sender;

@end
