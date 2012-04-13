//
//  JHWebcamConfigViewController.m
//  jHouse
//
//  Created by Greg on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHWebcamConfigViewController.h"
#import "JHWebcamDetailViewController.h"
#import "JHConstants.h"

@interface JHWebcamConfigViewController ()

@end

@implementation JHWebcamConfigViewController

@synthesize videoQuality = _videoQuality;
@synthesize parentDetailViewController = _parentDetailViewController;

#pragma mark - View delegates

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setVideoQuality:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self viewWillAppear:animated];  //TODO - enabling this causes the app to lock up! why????
    
    [self.videoQuality setSelectedSegmentIndex:[[NSUserDefaults standardUserDefaults] integerForKey:JHWebcamVideoQuality]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - TapGestureRecognizer actions

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    if (self.parentDetailViewController != nil)
        [self.parentDetailViewController loadVideo];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - TapGestureRecognizer delegates

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch 
{
    if ([touch.view isEqual:self.view]) {
        // We touched our view and not a control, handle the touch
        return YES;         
    }
    // Ignore the touch
    return NO;
}

#pragma mark - Actions

- (IBAction)videoQuality:(UISegmentedControl *)sender forEvent:(UIEvent *)event 
{
    NSInteger selectedSegment = sender.selectedSegmentIndex;
        
    if (selectedSegment == UISegmentedControlNoSegment)
        selectedSegment = 0;

    [[NSUserDefaults standardUserDefaults] setInteger:selectedSegment forKey:JHWebcamVideoQuality];
}

@end
