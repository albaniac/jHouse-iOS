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

@interface JHLocationUpdater : NSObject <CLLocationManagerDelegate, JHServerConfigDelegate>

- (void)startUpdatingLocationAtUrl:(NSURL *)locationUrl;
- (void)stopAllUpdates;

@end
