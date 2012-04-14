//
//  JHConfig.m
//  jHouse
//
//  Created by Greg on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHConfig.h"

static JHConfig *sharedInstance;

@interface JHConfig ()
{
@private
    
}

@end

@implementation JHConfig

@synthesize webcamConfigURL = _webcamConfigURL;
@synthesize locationConfigURL = _locationConfigURL;

+ (JHConfig *)shared
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[JHConfig alloc] init];
    }
    
    return sharedInstance;
}

- (void)dehydrateToCache
{
    [[NSUserDefaults standardUserDefaults] setURL:self.webcamConfigURL forKey:@"cacheWebcamConfigURL"];    
    [[NSUserDefaults standardUserDefaults] setURL:self.locationConfigURL forKey:@"cacheLocationConfigURL"];
}

- (void)hydrateFromCache
{
    self.webcamConfigURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"cacheWebcamConfigURL"];
    self.locationConfigURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"cacheLocationConfigURL"];    
}

@end
