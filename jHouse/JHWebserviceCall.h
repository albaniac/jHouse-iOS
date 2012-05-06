//
//  JHWebserviceCall.h
//  jHouse
//
//  Created by Greg on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JHWebserviceCallDelegate <NSObject> 
@optional
- (void)webserviceCallDidSucceedForURL:(NSURL *)url withData:(id)data;
- (void)webserviceCallDidFailForURL:(NSURL *)url withDescription:(NSString *)description;
@end

@interface JHWebserviceCall : NSObject

+ (JHWebserviceCall *)initWithURL:(NSURL *)url delegate:(id)delegate;
+ (JHWebserviceCall *)initWithPutURL:(NSURL *)url body:(NSDictionary *)body delegate:(id)delegate;

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSDictionary *body;
@property (weak, nonatomic) id <JHWebserviceCallDelegate> delegate;

@end
