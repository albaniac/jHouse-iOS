//
//  JHWebcamDetailViewController.m
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHWebcamDetailViewController.h"
#import "JHWebcamConfigViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "JHConstants.h"

@interface JHWebcamDetailViewController ()
{
@private
    NSData *_endMarkerData;
    NSMutableData *_receivedData;
    MBProgressHUD *progressHUD;
    NSURLConnection *urlConnection;
}

@end

@implementation JHWebcamDetailViewController

@synthesize toolbar = _toolbar;
@synthesize webcamImageView = _webcamImageView;
@synthesize imageViewPanUp = _imageViewPanUp;
@synthesize imageViewPanDown = _imageViewPanDown;
@synthesize imageViewPanLeft = _imageViewPanLeft;
@synthesize imageViewPanRight = _imageViewPanRight;
@synthesize buttonPanUp = _buttonPanUp;
@synthesize buttonPanDown = _buttonPanDown;
@synthesize buttonPanLeft = _buttonPanLeft;
@synthesize buttonPanRight = _buttonPanRight;
@synthesize videoUrl = _videoUrl;
@synthesize panUpUrl = _panUpUrl;
@synthesize panDownUrl = _panDownUrl;
@synthesize panLeftUrl = _panLeftUrl;
@synthesize panRightUrl = _panRightUrl;
@synthesize panStopUrl = _panStopUrl;
@synthesize ptzEnabled = _ptzEnabled;

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
    
    [self showActivityIndicator];
    
    if (_endMarkerData == nil) 
    {
        uint8_t endMarker[2] = IMAGE_END_MARKER_BYTES;
        _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
    }
    
    // If this is a PTZ camera, enable and initialize the PTZ buttons
    if (_ptzEnabled == YES)
    {
        [self disableButtons:NO];
        
        [self setupButtons];        
    } else {
        [self disableButtons:YES];
    }    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show the bottom toolbar
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    // Register application state notifications so that we can handle them
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [self loadVideo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Unregister application state notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];

    // Close the connection when the view isn't active
    [urlConnection cancel];
}

- (void)viewDidUnload
{
    [self setWebcamImageView:nil];
    [self setImageViewPanUp:nil];
    [self setImageViewPanDown:nil];
    [self setImageViewPanLeft:nil];
    [self setImageViewPanRight:nil];
    [self setButtonPanUp:nil];
    [self setButtonPanDown:nil];
    [self setButtonPanLeft:nil];
    [self setButtonPanRight:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    else 
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{        
    [self fadeInAllButtons];
    
    [self performSelector:@selector(fadeOutAllButtons) withObject:nil afterDelay:2.0];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"WebcamConfigView"])
    {
        // Close the connection when the view isn't active
        [urlConnection cancel];

        JHWebcamConfigViewController *configViewController = (JHWebcamConfigViewController *)[segue destinationViewController];
        configViewController.parentDetailViewController = self;
    }
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Accept an untrusted SSL certificate
    BOOL ignoreSSLErrors = [[NSUserDefaults standardUserDefaults] boolForKey:JHServerIgnoreSSLErrors];

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && ignoreSSLErrors == YES)
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];        
    }
    // Handle a login/password failure
    else 
    {
        if ([challenge previousFailureCount] > 2)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Could not authenticate with server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
        else if ([challenge previousFailureCount] == 0) 
        {
            NSString *serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
            NSString *serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];

            NSURLCredential *newCredential;
            newCredential = [NSURLCredential credentialWithUser:serverLogin
                                                       password:serverPassword
                                                    persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:newCredential
                   forAuthenticationChallenge:challenge];
        } else 
        {
            [progressHUD hide:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Enter your login and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            if (challenge.proposedCredential != nil)
                [[alertView textFieldAtIndex:0] setText:[challenge.proposedCredential user]];
            [alertView show];
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _receivedData = nil;
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    _receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_receivedData == nil)
        _receivedData = [[NSMutableData alloc] init];
    
    [_receivedData appendData:data];
    
    NSRange endRange = [_receivedData rangeOfData:_endMarkerData 
                                          options:0 
                                            range:NSMakeRange(0, _receivedData.length)];
    
    long long endLocation = endRange.location + endRange.length;
    if (_receivedData.length >= endLocation) {
        NSData *imageData = [_receivedData subdataWithRange:NSMakeRange(0, endLocation)];
        UIImage *receivedImage = [UIImage imageWithData:imageData];
        if (receivedImage) {
            if (progressHUD != nil && progressHUD.isHidden == NO)
            {
                [progressHUD hide:YES];
                progressHUD = nil;
                
                [self fadeInAllButtons];
                [self performSelector:@selector(fadeOutAllButtons) withObject:nil afterDelay:2.0];        
            }
            self.webcamImageView.image = receivedImage;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    NSString *serverLogin = [alertView textFieldAtIndex:0].text;
    NSString *serverPassword = [alertView textFieldAtIndex:1].text;
    
    [[NSUserDefaults standardUserDefaults] setValue:serverLogin forKey:JHServerLogin];
    [[NSUserDefaults standardUserDefaults] setValue:serverPassword forKey:JHServerPassword];
    
    [self loadVideo];
}

#pragma mark - NSUserDefaults change observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:JHWebcamVideoQuality] &&
        [[change valueForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting)
    {
        [self loadVideo];
    }
}

#pragma mark - UIButton actions

- (IBAction)buttonPanUpTouchDown:(UIButton *)sender 
{
    [self fadeInButton:sender andImageView:self.imageViewPanUp];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panUpUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanUpTouchUp:(UIButton *)sender
{
    [self fadeOutButton:sender andImageView:self.imageViewPanUp];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panStopUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanDownTouchDown:(UIButton *)sender 
{
    [self fadeInButton:sender andImageView:self.imageViewPanDown];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panDownUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanDownTouchUp:(UIButton *)sender 
{
    [self fadeOutButton:sender andImageView:self.imageViewPanDown];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panStopUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanLeftTouchDown:(UIButton *)sender 
{
    [self fadeInButton:sender andImageView:self.imageViewPanLeft];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panLeftUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanLeftTouchUp:(UIButton *)sender 
{
    [self fadeOutButton:sender andImageView:self.imageViewPanLeft];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panStopUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanRightTouchDown:(UIButton *)sender 
{
    [self fadeInButton:sender andImageView:self.imageViewPanRight];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panRightUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

- (IBAction)buttonPanRightTouchUp:(UIButton *)sender 
{
    [self fadeOutButton:sender andImageView:self.imageViewPanRight];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.panStopUrl];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:nil];
}

#pragma mark - Utility methods

- (void)setupButtons
{
    static float const CORNER_RADIUS = 8.0f;
    
    [[self.buttonPanUp layer] setCornerRadius:CORNER_RADIUS];
    [[self.buttonPanUp layer] setMasksToBounds:YES];
    [[self.buttonPanUp layer] setBorderWidth:0.0f];
    
    [[self.buttonPanDown layer] setCornerRadius:CORNER_RADIUS];
    [[self.buttonPanDown layer] setMasksToBounds:YES];
    [[self.buttonPanDown layer] setBorderWidth:0.0f];
    
    [[self.buttonPanLeft layer] setCornerRadius:CORNER_RADIUS];
    [[self.buttonPanLeft layer] setMasksToBounds:YES];
    [[self.buttonPanLeft layer] setBorderWidth:0.0f];
    
    [[self.buttonPanRight layer] setCornerRadius:CORNER_RADIUS];
    [[self.buttonPanRight layer] setMasksToBounds:YES];
    [[self.buttonPanRight layer] setBorderWidth:0.0f];
}

- (void)disableButtons:(BOOL)disabled
{
    [self.buttonPanUp setHidden:disabled];
    [self.buttonPanDown setHidden:disabled];
    [self.buttonPanLeft setHidden:disabled];
    [self.buttonPanRight setHidden:disabled];
    
    [self.imageViewPanUp setHidden:disabled];
    [self.imageViewPanDown setHidden:disabled];
    [self.imageViewPanLeft setHidden:disabled];
    [self.imageViewPanRight setHidden:disabled];    
}

- (void)fadeInButton:(UIButton *)button andImageView:(UIImageView *)imageView
{
    [UIView animateWithDuration:0.25 animations:^{imageView.alpha = 1.0;}];
    [UIView animateWithDuration:0.25 animations:^{button.backgroundColor = [UIColor redColor];}];
}

- (void)fadeOutButton:(UIButton *)button andImageView:(UIImageView *)imageView
{
    [UIView animateWithDuration:0.25 animations:^{imageView.alpha = 0.0;}];
    [UIView animateWithDuration:0.25 animations:^{button.backgroundColor = [UIColor clearColor];}];
}

- (void)fadeInAllButtons
{
    [self fadeInButton:self.buttonPanUp andImageView:self.imageViewPanUp];
    [self fadeInButton:self.buttonPanDown andImageView:self.imageViewPanDown];
    [self fadeInButton:self.buttonPanLeft andImageView:self.imageViewPanLeft];
    [self fadeInButton:self.buttonPanRight andImageView:self.imageViewPanRight];
}

- (void)fadeOutAllButtons
{
    [self fadeOutButton:self.buttonPanUp andImageView:self.imageViewPanUp];
    [self fadeOutButton:self.buttonPanDown andImageView:self.imageViewPanDown];
    [self fadeOutButton:self.buttonPanLeft andImageView:self.imageViewPanLeft];
    [self fadeOutButton:self.buttonPanRight andImageView:self.imageViewPanRight];    
}

- (void)showActivityIndicator
{
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = @"Loading";
    progressHUD.dimBackground = NO;
    progressHUD.removeFromSuperViewOnHide = YES;
}

- (NSString *)videoQualityIntegerToString:(NSInteger)videoQualityInteger
{
    if (videoQualityInteger == 2)
        return @"HIGH";
    else if (videoQualityInteger == 1)
        return @"NORMAL";
    else
        return @"LOW";
}

- (void)loadVideo
{
    // TODO - Video doesn't reload on viewWillAppear after config change! why???
    if (urlConnection != nil)
    {
        [urlConnection cancel];
    }
    
    NSInteger videoQualityInteger = [[NSUserDefaults standardUserDefaults] integerForKey:JHWebcamVideoQuality];
    NSString *videoQualityString = [self videoQualityIntegerToString:videoQualityInteger];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self.videoUrl URLByAppendingPathComponent:videoQualityString]]; 
    urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];    
}

#pragma mark - App state handlers

- (void)willEnterForeground
{
    // Start video when the app comes back to the foreground
    [self loadVideo];
}

- (void)willResignActive
{
    // Close the connection when the app goes into the background
    if (urlConnection != nil)
    {
        [urlConnection cancel];
    }
}

@end
