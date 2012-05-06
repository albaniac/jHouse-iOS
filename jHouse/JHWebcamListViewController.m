//
//  JHWebcamListViewController.m
//  jHouse
//
//  Created by Greg on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHWebcamListViewController.h"
#import "JHConstants.h"
#import "MBProgressHUD.h"
#import "JHWebcamDetailViewController.h"
#import "JHConfig.h"

@interface JHWebcamListViewController ()
{
@private
    NSDictionary *config;
    NSArray *webcams;
    NSURL *videoURL;
    NSURL *panUpURL;
    NSURL *panDownURL;
    NSURL *panLeftURL;
    NSURL *panRightURL;
    NSURL *panStopURL;
    NSMutableData *receivedData;
    NSString *serverLogin;
    NSString *serverPassword;
    MBProgressHUD *progressHUD;
}
@end

@implementation JHWebcamListViewController

@synthesize webcamTableView = _webcamTableView;

#pragma mark - View delegates

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:JHServerURL options:NSKeyValueObservingOptionNew context:nil];
    
    if (config == nil)
    {
        NSURL *configURL = [[JHConfig shared] webcamConfigURL];
        [self getConfigFromServerAtURL:configURL];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the bottom toolbar (only used in the detail view)
    [self.navigationController setToolbarHidden:YES animated:YES];    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"WebcamDetailView"])
    {
        JHWebcamDetailViewController *detailViewController = (JHWebcamDetailViewController *)[segue destinationViewController];
        
        detailViewController.title = [[webcams objectAtIndex:[self.tableView indexPathForSelectedRow].row] valueForKey:@"name"];
        
        NSString *beanName = [[webcams objectAtIndex:[self.tableView indexPathForSelectedRow].row] valueForKey:@"beanName"];
        BOOL ptzEnabled = [[[webcams objectAtIndex:[self.tableView indexPathForSelectedRow].row] objectForKey:@"ptz"] boolValue];
        
        detailViewController.videoUrl = [videoURL URLByAppendingPathComponent:beanName];
        detailViewController.panUpUrl = [panUpURL URLByAppendingPathComponent:beanName];
        detailViewController.panDownUrl = [panDownURL URLByAppendingPathComponent:beanName];
        detailViewController.panLeftUrl = [panLeftURL URLByAppendingPathComponent:beanName];
        detailViewController.panRightUrl = [panRightURL URLByAppendingPathComponent:beanName];
        detailViewController.panStopUrl = [panStopURL URLByAppendingPathComponent:beanName];
        detailViewController.ptzEnabled = ptzEnabled;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [webcams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell != nil && webcams != nil)
    {
        cell.textLabel.text = [[webcams objectAtIndex:indexPath.row] valueForKey:@"name"];
    }
    return cell;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{    
    receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (receivedData == nil)
        receivedData = [[NSMutableData alloc] init];
    
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self parseTableData];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Untrusted SSL certificate encountered, aborting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];            
        }
    }
    // Handle a login/password failure
    else 
    {
        if ([challenge previousFailureCount] > 2)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Could not authenticate with server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
        else if ([challenge previousFailureCount] == 0) 
        {
            NSURLCredential *newCredential;
            newCredential = [NSURLCredential credentialWithUser:serverLogin
                                                       password:serverPassword
                                                    persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:newCredential
                   forAuthenticationChallenge:challenge];
        } else 
        {
            [progressHUD hide:YES];

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Enter your login and password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            if (challenge.proposedCredential != nil)
                [[alertView textFieldAtIndex:0] setText:[challenge.proposedCredential user]];
            [alertView show];
            
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    receivedData = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    serverLogin = [alertView textFieldAtIndex:0].text;
    serverPassword = [alertView textFieldAtIndex:1].text;
    
    [[NSUserDefaults standardUserDefaults] setValue:serverLogin forKey:JHServerLogin];
    [[NSUserDefaults standardUserDefaults] setValue:serverPassword forKey:JHServerPassword];

    [self getTableData];
}

#pragma mark - JHServerConfigDelegate

- (void)didReceiveServerConfig:(id)theConfig
{
    config = (NSDictionary *)theConfig;
    
    [self parseConfigData:config];
}

- (void)didFailReceivingServerConfig:(NSString *)description
{
    [progressHUD hide:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

#pragma mark - Actions

- (IBAction)refreshTable:(UIBarButtonItem *)sender 
{
    [self getTableData];
}

#pragma mark - Web service calls

- (void)getConfigFromServerAtURL:(NSURL *)url
{
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHUD.labelText = @"Loading config";
    progressHUD.dimBackground = NO;
    
    [JHServerConfig initWithConfigURL:url delegate:self];    
}

- (void)getTableData
{    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    
    if (serverURLString != nil && serverURLString != @"")
    {        
        NSString *listPath = [config valueForKey:@"listPath"];
        
        if (listPath == nil)
        {
            [progressHUD hide:YES];
        }
        else
        {
            NSURL *serverURL = [NSURL URLWithString:serverURLString];
            serverURL = [serverURL URLByAppendingPathComponent:listPath];
            
            if (serverURL == nil)
            {
                [progressHUD hide:YES];                
            }
            else
            {
                progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                progressHUD.labelText = @"Loading webcams";
                progressHUD.dimBackground = NO;
                
                serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
                serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];
                
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:serverURL];
                [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
                (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];            
            }
        }
    }
}

#pragma mark - Utility methods

- (void)parseConfigData:(NSDictionary *)theConfig
{    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    NSURL *serverURL = [NSURL URLWithString:serverURLString];
    
    if ([theConfig objectForKey:@"videoPath"] != nil)
        videoURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"videoPath"]];

    if ([theConfig objectForKey:@"panUpPath"] != nil)
        panUpURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"panUpPath"]];
    
    if ([theConfig objectForKey:@"panDownPath"] != nil)
        panDownURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"panDownPath"]];
    
    if ([theConfig objectForKey:@"panLeftPath"] != nil)
        panLeftURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"panLeftPath"]];
    
    if ([theConfig objectForKey:@"panRightPath"] != nil)
        panRightURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"panRightPath"]];
    
    if ([theConfig objectForKey:@"panStopPath"] != nil)
        panStopURL = [serverURL URLByAppendingPathComponent:[theConfig objectForKey:@"panStopPath"]];
    
    [progressHUD hide:YES];
    
    [self getTableData];    
}

- (void)parseTableData
{
    NSError *jsonError = nil;
    NSDictionary *webcamJson = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if (jsonError != nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error Parsing Data" message:jsonError.debugDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];            
    }
    else
    {
        webcams = [webcamJson objectForKey:@"webcams"];        
    }
    
    [self.webcamTableView reloadData];
    [progressHUD hide:YES];
}

#pragma mark - NSUserDefaults change observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:JHServerURL])
    {
        [self getTableData];
    }
}

@end
