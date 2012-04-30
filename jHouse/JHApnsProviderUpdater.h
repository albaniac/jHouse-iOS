//
//  JHApnsProviderUpdater.h
//  jHouse
//
//  Created by Greg on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHApnsProviderUpdater : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (void)updateProviderWithToken:(NSString *)token;

@end
