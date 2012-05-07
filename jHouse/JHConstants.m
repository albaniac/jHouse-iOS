//
//  JHConstants.m
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHConstants.h"

@implementation JHConstants

// Config options
NSString * const JHServerURL = @"serverUrl";
NSString * const JHServerLogin = @"serverLogin";
NSString * const JHServerPassword = @"serverPassword";
NSString * const JHWebcamVideoQuality = @"webcamVideoQuality";
NSString * const JHServerIgnoreSSLErrors = @"serverIgnoreSSLErrors";
NSString * const JHConfigLocationAccuracy = @"locationAccuracy";
NSString * const JHConfigLocationSendUpdates = @"locationSendUpdates";
NSString * const JHConfigLocationBackgroundUpdates = @"locationBackgroundUpdates";
NSString * const JHConfigLocationDistanceFilter = @"locationDistanceFilter";
NSString * const JHConfigAppUUID = @"jHouseUUID";

// Web service locations
//NSString * const JHWebcamListUri = @"controllers/webcam/list.json";
NSString * const JHLocationUpdatePath = @"controllers/location/user";
NSString * const JHLocationNewestPath = @"controllers/location/newest";
NSString * const JHApnsUpdatePath = @"controllers/appleios/device_tokens";
NSString * const JHDevicesByLocationGetPath = @"controllers/device/all/bylocation";
NSString * const JHDeviceActionPath = @"controllers/device/%d/action/%@";

@end
