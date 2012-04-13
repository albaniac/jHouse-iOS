//
//  JHServerConfig.m
//  jHouse
//
//  Created by Greg on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHServerConfig.h"
#import "JHConstants.h"

@interface JHServerConfig ()
{
@private
    NSString *_serverLogin;
    NSString *_serverPassword;
    NSMutableData *_receivedData;
}
@end

@implementation JHServerConfig

@synthesize config = _config;
@synthesize url = _url;
@synthesize delegate = _delegate;

+ (JHServerConfig *)initWithConfigURL:(NSURL *)url delegate:(id) delegate
{
    JHServerConfig *serverConfig = [[JHServerConfig alloc] init];
    serverConfig.delegate = delegate;
    serverConfig.url = url;
    [serverConfig connect];
    return serverConfig;
}

- (void)connect
{
    _serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
    _serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url];
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
            if ([self.delegate respondsToSelector:@selector(didFailReceivingServerConfig:)])
            {
                [self.delegate didFailReceivingServerConfig:@"SSL certificate error"];
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
            if ([self.delegate respondsToSelector:@selector(didFailReceivingServerConfig:)])
            {
                [self.delegate didFailReceivingServerConfig:@"Access is denied"];
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
    id config = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if (jsonError != nil)
    {
        if ([self.delegate respondsToSelector:@selector(didFailReceivingServerConfig:)])
        {
            [self.delegate didFailReceivingServerConfig:@"Error parsing config"];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didReceiveServerConfig:)])
        [self.delegate didReceiveServerConfig:config];
}

@end

