//
//  JHApnsProviderUpdater.m
//  jHouse
//
//  Created by Greg on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHApnsProviderUpdater.h"
#import "JHConstants.h"

@implementation JHApnsProviderUpdater


- (void)updateProviderWithToken:(NSString *)token
{
    NSString *uuid = [[NSUserDefaults standardUserDefaults] valueForKey:JHConfigAppUUID];
    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    NSURL *serverURL = [NSURL URLWithString:serverURLString];
    NSURL *apnsUpdateURL = [serverURL URLByAppendingPathComponent:JHApnsUpdatePath];
    
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    [location setValue:uuid forKey:@"uuid"];
    [location setValue:[[UIDevice currentDevice] name] forKey:@"description"];
    [location setValue:token forKey:@"token"];
    
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:location 
                                                       options:NSJSONReadingMutableLeaves error:&error];
    
    if (apnsUpdateURL != nil)
    {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:apnsUpdateURL];
        [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPMethod:@"PUT"];
        [urlRequest setHTTPBody:jsonData];
        (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];  
    }
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
            // Untrusted certificate encountered and we're set to not ignore SSL errors
        }
    }
    // Handle a login/password failure
    else 
    {
        if ([challenge previousFailureCount] > 2)
        {
            // Could not authenticate with server
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
        else if ([challenge previousFailureCount] == 0) 
        {
            NSString *serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
            NSString *serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];
            
            NSURLCredential *newCredential;
            newCredential = [NSURLCredential credentialWithUser:serverLogin
                                                       password:serverPassword
                                                    persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:newCredential
                   forAuthenticationChallenge:challenge];
        } else 
        {
            // Could not authenticate with server
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

@end
