//
//  JHServerConfig.h
//  jHouse
//
//  Created by Greg on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JHServerConfigDelegate <NSObject> 
- (void)didReceiveServerConfig:(id)theConfig;
@optional
- (void)didFailReceivingServerConfig:(NSString *)description;
@end

@interface JHServerConfig : NSObject

+ (JHServerConfig *)initWithConfigURL:(NSURL *)url delegate:(id)delegate;

@property (strong, nonatomic) NSDictionary *config;
@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) id <JHServerConfigDelegate> delegate;

@end
