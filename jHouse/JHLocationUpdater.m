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

@interface JHLocationUpdater ()
{
@private
    CLLocationManager *locationManager;
    NSDictionary *config;
    NSURL *userUpdateURL;
    NSURL *configURL;
}
@end

@implementation JHLocationUpdater

- (void)stopAllUpdates
{
    if (locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];        
}

- (void)startUpdatingLocationAtUrl:(NSURL *)url
{
    [JHServerConfig initWithConfigURL:url delegate:self];
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
                                                           options:NSJSONWritingPrettyPrinted error:&error];
        
        if (userUpdateURL != nil)
        {
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:userUpdateURL];
            [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [urlRequest setHTTPMethod:@"POST"];
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
    if (locationManager != nil && status != kCLAuthorizationStatusAuthorized)
    {
        [locationManager stopUpdatingLocation];
    }
}

#pragma mark - JHServerConfigDelegate

- (void)didReceiveServerConfig:(id)theConfig
{
    config = (NSDictionary *)theConfig;
    
    [self parseConfigData:config];
}

- (void)didFailReceivingServerConfig
{
}

#pragma mark - Utility methods

- (void)parseConfigData:(NSDictionary *)theConfig
{    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    NSURL *serverURL = [NSURL URLWithString:serverURLString];
    
    userUpdateURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"userUpdate"]];
    
    if (userUpdateURL != nil)
    {
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.purpose = @"jHouse Location Services";

        NSInteger locationAccuracy = [[NSUserDefaults standardUserDefaults] integerForKey:JHConfigLocationAccuracy];
        /*
         0 = significant updates only
         1 = kCLLocationAccuracyThreeKilometers;
         2 = kCLLocationAccuracyKilometer;
         3 = kCLLocationAccuracyHundredMeters;
         4 = kCLLocationAccuracyNearestTenMeters;
         5 = kCLLocationAccuracyBest;
         */

        switch (locationAccuracy) {
            case 0:
                [locationManager startMonitoringSignificantLocationChanges];
                break;
            case 1:
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                [locationManager startUpdatingLocation];
                break;
            case 2:
                locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                [locationManager startUpdatingLocation];
                break;
            case 3:
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                [locationManager startUpdatingLocation];
                break;
            case 4:
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                [locationManager startUpdatingLocation];
                break;
            case 5:
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                [locationManager startUpdatingLocation];
                break;
                
            default:
                [locationManager startMonitoringSignificantLocationChanges];
                break;
        }
    }

}

@end
