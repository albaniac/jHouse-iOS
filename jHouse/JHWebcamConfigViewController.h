//
//  JHWebcamConfigViewController.h
//  jHouse
//
//  Created by Greg on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JHWebcamDetailViewController;

@interface JHWebcamConfigViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *videoQuality;
@property (weak, nonatomic) JHWebcamDetailViewController *parentDetailViewController;

- (IBAction)videoQuality:(UISegmentedControl *)sender forEvent:(UIEvent *)event;

@end
