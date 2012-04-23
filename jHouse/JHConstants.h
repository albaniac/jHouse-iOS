//
//  JHConstants.h
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHConstants : NSObject

// Config options
extern NSString * const JHServerURL;
extern NSString * const JHServerLogin;
extern NSString * const JHServerPassword;
extern NSString * const JHWebcamVideoQuality;
extern NSString * const JHServerIgnoreSSLErrors;
extern NSString * const JHConfigLocationAccuracy;
extern NSString * const JHConfigLocationSendUpdates;
extern NSString * const JHConfigLocationBackgroundUpdates;
extern NSString * const JHConfigLocationDistanceFilter;
extern NSString * const JHConfigAppUUID;

// Web service locations
//extern NSString * const JHWebcamListUri;
extern NSString * const JHLocationUpdatePath;

@end
