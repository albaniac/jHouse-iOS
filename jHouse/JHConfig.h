//
//  JHConfig.h
//  jHouse
//
//  Created by Greg on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHConfig : NSObject

+ (JHConfig *)shared;

@property (nonatomic, retain) NSURL *webcamConfigURL;
@property (nonatomic, retain) NSURL *locationConfigURL;

@end
