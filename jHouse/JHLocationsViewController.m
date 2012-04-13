//
//  JHLocationsViewController.m
//  jHouse
//
//  Created by Greg on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHLocationsViewController.h"
#import "JHConstants.h"
#import "MBProgressHUD.h"
#import "JHConfig.h"

@interface JHLocationsViewController ()
{
@private
    NSDictionary *config;
    NSURL *allNewestLocationURL;
    MKCoordinateRegion localRegion;
    MBProgressHUD *progressHUD;
    NSString *serverLogin;
    NSString *serverPassword;
    NSMutableData *receivedData;
    NSArray *userLocations;
}
@end

@implementation JHLocationsViewController
@synthesize mapView = _mapView;
@synthesize refreshMap = _refreshMap;

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
    
    if (config == nil)
    {
        NSURL *configURL = [[JHConfig shared] locationConfigURL];
        [self getConfigFromServerAtURL:configURL];
    }

    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;   
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;    
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setRefreshMap:nil];
    [self setRefreshMap:nil];
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

#pragma mark - JHServerConfigDelegate

- (void)didReceiveServerConfig:(id)theConfig
{
    config = (NSDictionary *)theConfig;
    
    [self parseConfigData:config];
}

- (void)didFailReceivingServerConfig:(NSString *)description
{

}

#pragma mark - Utility methods

- (void)parseConfigData:(NSDictionary *)theConfig
{    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    NSURL *serverURL = [NSURL URLWithString:serverURLString];
    
    if ([theConfig objectForKey:@"getAllNewestLocation"] != nil)
        allNewestLocationURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"getAllNewestLocation"]];
    

    [progressHUD hide:YES];

    [self getMapAnnotations];
}

- (void)parseLocationData
{
    NSError *jsonError = nil;
    NSDictionary *webcamJson = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if (jsonError != nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error Parsing Data" message:jsonError.debugDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];            
    }
    else
    {
        userLocations = [webcamJson objectForKey:@"newestLocations"];
        for (NSDictionary *location in userLocations)
        {
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[location valueForKey:@"latitude"] doubleValue];
            coordinate.longitude = [[location valueForKey:@"longitude"] doubleValue];
            [point setCoordinate:coordinate];
            [point setTitle:[NSString stringWithFormat:@"%@ %@", [location valueForKey:@"firstname"], [location valueForKey:@"lastname"]]];
            [point setSubtitle:[NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:[[location valueForKey:@"timestamp"] doubleValue] / 1000.0] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
            [self.mapView addAnnotation:point];
        }
    }
    
    [progressHUD hide:YES];
}

#pragma mark - Web service calls

- (void)getConfigFromServerAtURL:(NSURL *)url
{
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = @"Loading config";
    progressHUD.dimBackground = NO;
    
    [JHServerConfig initWithConfigURL:url delegate:self];    
}

-(void)getMapAnnotations
{
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    
    if (serverURLString != nil && serverURLString != @"")
    {        
        NSString *newestAll = [config valueForKey:@"newestAll"];
        
        if (newestAll == nil)
        {
            [progressHUD hide:YES];
        }
        else
        {
            NSURL *serverURL = [NSURL URLWithString:serverURLString];
            serverURL = [serverURL URLByAppendingPathComponent:newestAll];
            
            if (serverURL == nil)
            {
                [progressHUD hide:YES];                
            }
            else
            {
                progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                progressHUD.labelText = @"Loading locations";
                progressHUD.dimBackground = NO;
                
                serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
                serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];
                
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:serverURL];
                [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];            
            }
        }
    }

}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    localRegion.span.latitudeDelta = 0.01;
    localRegion.span.longitudeDelta = 0.01;
    localRegion.center.latitude = self.mapView.userLocation.location.coordinate.latitude;
    localRegion.center.longitude = self.mapView.userLocation.location.coordinate.longitude;
    [self.mapView setRegion:localRegion animated:NO];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    static NSString *viewIdentifier = @"annotationView";

    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:viewIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewIdentifier];
        //[annotationView setAnimatesDrop:YES];
        [annotationView setCanShowCallout:YES];
    }
    
    return annotationView;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (receivedData == nil)
        receivedData = [[NSMutableData alloc] init];
    
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseLocationData];
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // Accept an untrusted SSL certificate?
        BOOL ignoreSSLErrors = [[NSUserDefaults standardUserDefaults] boolForKey:JHServerIgnoreSSLErrors];
        
        if (ignoreSSLErrors == YES)
        {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];  
        }
        else 
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Untrusted SSL certificate encountered, aborting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];            
        }
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
    receivedData = nil;
}

#pragma mark - UIButton actions

- (IBAction)refreshMapButton:(UIBarButtonItem *)sender 
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self getMapAnnotations];
}

@end
