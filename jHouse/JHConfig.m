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

@synthesize webcamConfigURL;
@synthesize locationConfigURL;

+ (JHConfig *)shared
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[JHConfig alloc] init];
    }
    
    return sharedInstance;
}

@end
