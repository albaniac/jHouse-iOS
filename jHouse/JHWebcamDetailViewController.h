//
//  JHWebcamDetailViewController.h
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_END_MARKER_BYTES { 0xFF, 0xD9 }

@interface JHWebcamDetailViewController : UIViewController <NSURLConnectionDataDelegate>

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) IBOutlet UIImageView *webcamImageView;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPanUp;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPanDown;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPanLeft;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPanRight;

@property (strong, nonatomic) IBOutlet UIButton *buttonPanUp;
@property (strong, nonatomic) IBOutlet UIButton *buttonPanDown;
@property (strong, nonatomic) IBOutlet UIButton *buttonPanLeft;
@property (strong, nonatomic) IBOutlet UIButton *buttonPanRight;


@property (weak, nonatomic) NSURL *videoUrl;

@property (strong, nonatomic) NSURL *panUpUrl;
@property (strong, nonatomic) NSURL *panDownUrl;
@property (strong, nonatomic) NSURL *panLeftUrl;
@property (strong, nonatomic) NSURL *panRightUrl;
@property (strong, nonatomic) NSURL *panStopUrl;

@property (nonatomic) BOOL ptzEnabled;

- (void)loadVideo;

@end
