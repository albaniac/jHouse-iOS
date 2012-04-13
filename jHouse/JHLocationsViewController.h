//
//  JHLocationsViewController.h
//  jHouse
//
//  Created by Greg on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "JHServerConfig.h"

@interface JHLocationsViewController : UIViewController <MKMapViewDelegate,NSURLConnectionDelegate, NSURLConnectionDataDelegate, JHServerConfigDelegate>

- (IBAction)refreshMapButton:(UIBarButtonItem *)sender;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshMap;

@end
