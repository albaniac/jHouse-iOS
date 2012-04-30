//
//  JHDevicesListViewController.m
//  jHouse
//
//  Created by Greg on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHDevicesListViewController.h"
#import "JHConstants.h"
#import "MBProgressHUD.h"

@interface JHDevicesListViewController ()
{
@private
    NSArray *devices;
    NSMutableData *receivedData;
    NSString *serverLogin;
    NSString *serverPassword;
    MBProgressHUD *progressHUD;
    
}
@end

@implementation JHDevicesListViewController
@synthesize devicesTableView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setDevicesTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getTableData];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell != nil && devices != nil)
    {
        cell.textLabel.text = [[devices objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.detailTextLabel.text = [[devices objectAtIndex:indexPath.row] valueForKey:@"text"];
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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

#pragma mark - Web service calls

- (void)getTableData
{    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    
    if (serverURLString != nil && serverURLString != @"")
    {                
        NSURL *serverURL = [NSURL URLWithString:serverURLString];
        serverURL = [serverURL URLByAppendingPathComponent:JHDevicesGetPath];
        
        if (serverURL == nil)
        {
            [progressHUD hide:YES];                
        }
        else
        {
            progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            progressHUD.labelText = @"Loading devices";
            progressHUD.dimBackground = NO;
            
            serverLogin = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerLogin];
            serverPassword = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerPassword];
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:serverURL];
            [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
            (void)[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];            
        }
        
    }
}

#pragma mark - Utility methods

- (void)parseTableData
{
    NSError *jsonError = nil;
    NSDictionary *devicesJson = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if (jsonError != nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error Parsing Data" message:jsonError.debugDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];            
    }
    else
    {
        devices = [devicesJson objectForKey:@"devices"];        
    }
    
    [self.devicesTableView reloadData];
    [progressHUD hide:YES];
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

#pragma mark - Actions

- (IBAction)refreshTable:(UIBarButtonItem *)sender
{
    [self getTableData];
}
@end
