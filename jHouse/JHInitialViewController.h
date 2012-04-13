//
//  JHInitialViewController.h
//  jHouse
//
//  Created by Greg on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHServerConfig.h"

@interface JHInitialViewController : UIViewController <JHServerConfigDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
