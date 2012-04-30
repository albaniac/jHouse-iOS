//
//  JHInitialViewController.m
//  jHouse
//
//  Created by Greg on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHInitialViewController.h"
#import "JHConstants.h"
#import "JHConfig.h"
#import "JHLocationUpdater.h"
#import <QuartzCore/QuartzCore.h>

@interface JHInitialViewController ()
{
@private
    NSString *serverLogin;
    NSString *serverPassword;
    NSMutableData *receivedData;
}
@end

@implementation JHInitialViewController
@synthesize loadingImage;
@synthesize loadingLabel;
@synthesize activityIndicator;

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
    
    [self.activityIndicator startAnimating];
    
    [self getConfigFromServer];        
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setLoadingImage:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - JHServerConfigDelegate

- (void)didReceiveServerConfig:(id)theConfig
{
    theConfig = (NSDictionary *)theConfig;
    
    [self parseConfigData:theConfig];
}

- (void)didFailReceivingServerConfig:(NSString *)description
{
    loadingLabel.text = description;
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Web service calls

- (void)getConfigFromServer
{
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    
    if (serverURLString != nil && serverURLString != @"")
    {                
        NSURL *serverURL = [NSURL URLWithString:serverURLString];
        
        if (serverURL != nil)
        {
            [JHServerConfig initWithConfigURL:serverURL delegate:self];            
        }
    }    
}

#pragma mark - Utility methods

- (void)parseConfigData:(NSDictionary *)theConfig
{
    if (theConfig == nil)
    {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        [self.loadingLabel setHidden:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to retrieve data from server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView setAlertViewStyle:UIAlertViewStyleDefault];
        [alertView show]; 
    }
    else
    {
        NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
        
        NSURL *serverURL = [NSURL URLWithString:serverURLString];
        
        NSDictionary *controllers = (NSDictionary *)[theConfig objectForKey:@"controllers"];
        
        NSURL *webcamURL = [serverURL URLByAppendingPathComponent:[controllers objectForKey:@"webcam"]];
        NSURL *locationURL = [serverURL URLByAppendingPathComponent:[controllers objectForKey:@"location"]];
        
        [[JHConfig shared] setWebcamConfigURL:webcamURL];
        [[JHConfig shared] setLocationConfigURL:locationURL];
                
        [self performSegueWithIdentifier:@"LoadApp" sender:self];
        
        [self.activityIndicator stopAnimating];
    }
}

@end
