//
//  JHLocationUpdater.h
//  jHouse
//
//  Created by Greg on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "JHServerConfig.h"

@interface JHLocationUpdater : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, CLLocationManagerDelegate>

//@property (weak, nonatomic) NSURL *configURL;

//+ (JHLocationUpdater *)initWithURL:(NSURL *)url;
+ (JHLocationUpdater *)shared;

//- (void)startUpdatingLocationAtUrl:(NSURL *)locationUrl;
- (void)startUpdatingLocation;
- (void)enteringBackground;
//- (void)becomingActive;
- (void)stopAllUpdates;

@end
