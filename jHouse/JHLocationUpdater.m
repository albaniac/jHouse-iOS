//
//  JHLocationUpdater.m
//  jHouse
//
//  Created by Greg on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHLocationUpdater.h"
#import "JHConfig.h"
#import "JHConstants.h"

static JHLocationUpdater *sharedInstance;

@interface JHLocationUpdater ()
{
@private
    CLLocationManager *locationManager;
    NSDictionary *config;
    NSURL *userUpdateURL;
    UIBackgroundTaskIdentifier backgroundTask;
}
@end

@implementation JHLocationUpdater

+ (JHLocationUpdater *)shared
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[JHLocationUpdater alloc] init];
    }
    
    return sharedInstance;
}

- (void)enteringBackground
{
    if (locationManager != nil)
    {
        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
    }
}

- (void)stopAllUpdates
{
    if (locationManager == nil)
    {
        [locationManager stopMonitoringSignificantLocationChanges];
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];        
    }    
}

- (void)startUpdatingLocation
{
    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    NSURL *serverURL = [NSURL URLWithString:serverURLString];
    
    userUpdateURL = [serverURL URLByAppendingPathComponent:JHLocationUpdatePath];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.purpose = @"jHouse Location Services";
    
    NSInteger distanceFilter = [[NSUserDefaults standardUserDefaults] integerForKey:JHConfigLocationDistanceFilter];        
    locationManager.distanceFilter = distanceFilter;
    
    NSInteger locationAccuracy = [[NSUserDefaults standardUserDefaults] integerForKey:JHConfigLocationAccuracy];
    /*
     0 = kCLLocationAccuracyThreeKilometers;
     1 = kCLLocationAccuracyKilometer;
     2 = kCLLocationAccuracyHundredMeters;
     3 = kCLLocationAccuracyNearestTenMeters;
     4 = kCLLocationAccuracyBest;
     */
    
    switch (locationAccuracy) {
        case 0:
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            break;
        case 1:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            break;
        case 2:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        case 3:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case 4:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            break;
    }
    
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    // If location timestamp is not older than 60 seconds, use it
    if (abs([newLocation.timestamp timeIntervalSinceNow]) < 60.0)
    {
        NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
        [location setValue:[NSNumber numberWithDouble:newLocation.coordinate.latitude] forKey:@"latitude"];
        [location setValue:[NSNumber numberWithDouble:newLocation.coordinate.longitude] forKey:@"longitude"];
        [location setValue:[NSNumber numberWithDouble:newLocation.horizontalAccuracy] forKey:@"horizontalAccuracy"];
        [location setValue:[NSNumber numberWithDouble:newLocation.verticalAccuracy] forKey:@"verticalAccuracy"];
        [location setValue:[NSNumber numberWithDouble:newLocation.altitude] forKey:@"altitude"];
        [location setValue:[NSNumber numberWithDouble:newLocation.course] forKey:@"course"];
        [location setValue:[NSNumber numberWithDouble:newLocation.speed] forKey:@"speed"];
        [location setValue:[NSNumber numberWithLongLong:newLocation.timestamp.timeIntervalSince1970*1000] forKey:@"timestamp"];
        
        NSError *error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:location 
                                                           options:NSJSONReadingMutableLeaves error:&error];
        
        if (userUpdateURL != nil)
        {
            BOOL isInBackground = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
            if (isInBackground)
            {
                backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ [[UIApplication sharedApplication] endBackgroundTask:backgroundTask]; }];                
            }
                          
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:userUpdateURL];
            [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [urlRequest setHTTPMethod:@"PUT"];
            [urlRequest setHTTPBody:jsonData];
            (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];            
        }
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusAuthorized)
    {
        [self stopAllUpdates];
    }
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
            // Untrusted certificate encountered and we're set to not ignore SSL errors
        }
    }
    // Handle a login/password failure
    else 
    {
        if ([challenge previousFailureCount] > 2)
        {
            // Could not authenticate with server
            
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
            // Could not authenticate with server
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self endBackgroundTask];    
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self endBackgroundTask];
}

#pragma mark - Utility methods

- (void)endBackgroundTask
{
    BOOL isInBackground = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
    if (isInBackground && backgroundTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }    
}

@end
