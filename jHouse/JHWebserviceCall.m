//
//  JHWebserviceCall.m
//  jHouse
//
//  Created by Greg on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHWebserviceCall.h"
#import "JHConstants.h"

@interface JHWebserviceCall ()
{
@private
    NSString *_serverLogin;
    NSString *_serverPassword;
    NSMutableData *_receivedData;
}
@end

@implementation JHWebserviceCall

@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize method = _method;
@synthesize body = _body;

+ (JHWebserviceCall *)initWithURL:(NSURL *)url delegate:(id)delegate
{
    JHWebserviceCall *service = [[JHWebserviceCall alloc] init];
    service.delegate = delegate;
    service.url = url;
    service.method = @"GET";
    [service connect];
    return service;
}

+ (JHWebserviceCall *)initWithPutURL:(NSURL *)url body:(NSDictionary *)body delegate:(id)delegate
{
    JHWebserviceCall *service = [[JHWebserviceCall alloc] init];
    service.delegate = delegate;
    service.url = url;
    service.body = body;
    service.method = @"PUT";
    [service connect];
    return service;
}

- (void)connect
{
    _serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
    _serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
    
    if (self.method)
    {
        [urlRequest setHTTPMethod:self.method];
    }
    
    if (self.body)
    {
        NSError *error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.body 
                                                           options:NSJSONReadingMutableLeaves error:&error];
        [urlRequest setHTTPBody:jsonData];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];            
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    _receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_receivedData == nil)
        _receivedData = [[NSMutableData alloc] init];
    
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseConfigData];
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // Accept an untrusted SSL certificate?
        BOOL ignoreSSLErrors = [[NSUserDefaults standardUserDefaults] boolForKey:JHServerIgnoreSSLErrors];
        
        if (ignoreSSLErrors == YES)
        {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            
            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];  
        }
        else 
        {
            if ([self.delegate respondsToSelector:@selector(webserviceCallDidFail::)])
            {
                [self.delegate webserviceCallDidFailForURL:self.url withDescription:@"SSL certificate error"];
                return;
            }
        }
    }
    // Handle a login/password failure
    else 
    {
        if ([challenge previousFailureCount] > 0)
        {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            if ([self.delegate respondsToSelector:@selector(webserviceCallDidFail::)])
            {
                [self.delegate webserviceCallDidFailForURL:self.url withDescription:@"Access is denied"];
                return;
            }
        }
        else if ([challenge previousFailureCount] == 0) 
        {
            NSURLCredential *newCredential;
            newCredential = [NSURLCredential credentialWithUser:_serverLogin
                                                       password:_serverPassword
                                                    persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:newCredential
                   forAuthenticationChallenge:challenge];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _receivedData = nil;
}

#pragma mark - Utility methods

- (void)parseConfigData
{
    NSError *jsonError = nil;
    id data = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if (jsonError != nil)
    {
        if ([self.delegate respondsToSelector:@selector(webserviceCallDidFail::)])
        {
            [self.delegate webserviceCallDidFailForURL:self.url withDescription:@"Error parsing data"];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(webserviceCallDidSucceed::)])
        [self.delegate webserviceCallDidSucceedForURL:self.url withData:data];
}

@end
