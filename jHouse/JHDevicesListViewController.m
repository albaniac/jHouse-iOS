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
#import "JHWebserviceCall.h"

@interface JHDevicesListViewController ()
{
@private
    NSMutableArray *devices;
    NSMutableData *receivedData;
    NSString *serverLogin;
    NSString *serverPassword;
    MBProgressHUD *progressHUD;    
}
@end

@implementation JHDevicesListViewController

@synthesize devicesTableView = _devicesTableView;

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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    return [devices count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [devices count];
    return [(NSArray *)[devices objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    if ([(NSArray *)[devices objectAtIndex:section] count] > 0)
    {
        NSString *floor = [[(NSArray *)[devices objectAtIndex:section] objectAtIndex:0] valueForKey:@"floor"];
        NSString *room = [[(NSArray *)[devices objectAtIndex:section] objectAtIndex:0] valueForKey:@"room"];
        title = [NSString stringWithFormat:@"%@ - %@", floor, room];
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DefaultCellId = @"DefaultCell";
    static NSString *BinarySwitchCellId = @"BinarySwitchCell";
    static NSString *MultilevelSwitchCellId = @"MultilevelSwitchCell";
    
    //NSArray *deviceClasses = [[devices objectAtIndex:indexPath.row] objectForKey:@"classes"];
    NSArray *deviceClasses = [[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"classes"];
    
    if ([deviceClasses containsObject:@"net.gregrapp.jhouse.device.classes.MultilevelSwitch"] == YES)
    {
        JHCellMultilevelSwitch *cell = [tableView dequeueReusableCellWithIdentifier:MultilevelSwitchCellId];
        //[cell.label setText:[[devices objectAtIndex:indexPath.row] valueForKey:@"name"]];
        [cell.label setText:[[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"name"]];
        [cell setDelegate:self];
        //NSInteger value = [[[devices objectAtIndex:indexPath.row] valueForKey:@"value"] integerValue];
        NSInteger value = [[[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"value"] integerValue];
        [cell.slider setValue:value];
        
        return cell;        
    }
    else if ([deviceClasses containsObject:@"net.gregrapp.jhouse.device.classes.BinarySwitch"] == YES)
    {
        JHCellBinarySwitch *cell = [tableView dequeueReusableCellWithIdentifier:BinarySwitchCellId];
        [cell.label setText:[[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"name"]];
        //[cell.label setText:[[devices objectAtIndex:indexPath.row] valueForKey:@"name"]];        
        [cell setDelegate:self];
        //NSInteger value = [[[devices objectAtIndex:indexPath.row] valueForKey:@"value"] integerValue];
        NSInteger value = [[[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"value"] integerValue];
        if (value == 255)
        {
            [cell.binarySwitch setOn:YES];
        }
        else
        {
            [cell.binarySwitch setOn:NO];
        }
        
        return cell;
    }
    else 
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultCellId];                
        //cell.textLabel.text = [[devices objectAtIndex:indexPath.row] valueForKey:@"name"];
        [cell.textLabel setText:[[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"name"]];
        //cell.detailTextLabel.text = [[devices objectAtIndex:indexPath.row] valueForKey:@"text"];
        [cell.detailTextLabel setText:[[(NSArray *)[devices objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"text"]];
        return cell;
    }
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
        serverURL = [serverURL URLByAppendingPathComponent:JHDevicesByLocationGetPath];
        
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
    NSMutableDictionary *devicesJson = [NSJSONSerialization JSONObjectWithData:receivedData options:(NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers)  error:&jsonError];
    
    if (jsonError != nil)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:jsonError.debugDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];            
    }
    else
    {
        devices = [devicesJson objectForKey:@"devices"];
        
        // Sort the array alphabetically based on "floor - room"
        devices = (NSMutableArray *)[devices sortedArrayUsingComparator:^(id a, id b) {
            NSString *floor1 = [[(NSArray *)a objectAtIndex:0] valueForKey:@"floor"];
            NSString *room1 = [[(NSArray *)a objectAtIndex:0] valueForKey:@"room"];
            NSString *first = [NSString stringWithFormat:@"%@ - %@", floor1, room1];

            NSString *floor2 = [[(NSArray *)b objectAtIndex:0] valueForKey:@"floor"];
            NSString *room2 = [[(NSArray *)b objectAtIndex:0] valueForKey:@"room"];
            NSString *second = [NSString stringWithFormat:@"%@ - %@", floor2, room2];

            return [first compare:second];
        }];
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

- (void)cellForBinarySwitchChange:(JHCellBinarySwitch *)sender
{
    NSIndexPath *indexPath = [self.devicesTableView indexPathForCell:sender];
    NSInteger deviceId = [[[devices objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue];
    NSString *action = sender.binarySwitch.on?@"setOn":@"setOff";
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    
    if (serverURLString != nil && serverURLString != @"")
    {                
        NSURL *serverURL = [NSURL URLWithString:serverURLString];
        serverURL = [serverURL URLByAppendingPathComponent:[NSString stringWithFormat:JHDeviceActionPath, deviceId, action]];
        
        if (serverURL == nil)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Server URL is nil" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];            
        }
        else
        {
            // Create an empty args list or the server will freak out
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[[NSArray alloc] init] forKey:@"args"];
            [JHWebserviceCall initWithPutURL:serverURL body:dictionary delegate:nil];
            
            // Update device array to reflect new device state
            NSNumber *state = [NSNumber numberWithInt:sender.binarySwitch.on?255:0];
            [[devices objectAtIndex:indexPath.row] setValue:state forKey:@"value"];
        }
    }
}

- (void)cellForMultilevelSwitchChange:(JHCellMultilevelSwitch *)sender
{
    NSIndexPath *indexPath = [self.devicesTableView indexPathForCell:sender];
    NSInteger deviceId = [[[devices objectAtIndex:indexPath.row] valueForKey:@"id"] integerValue];
    NSString *action = @"setLevel";
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] stringForKey:JHServerURL];
    
    if (serverURLString != nil && serverURLString != @"")
    {                
        NSURL *serverURL = [NSURL URLWithString:serverURLString];
        serverURL = [serverURL URLByAppendingPathComponent:[NSString stringWithFormat:JHDeviceActionPath, deviceId, action]];
        
        if (serverURL == nil)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Server URL is nil" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];            
        }
        else
        {
            // Create an empty args list or the server will freak out
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[NSArray arrayWithObject:[NSNumber numberWithInt:sender.slider.value]] forKey:@"args"];
            [JHWebserviceCall initWithPutURL:serverURL body:dictionary delegate:nil];
            
            // Update device array to reflect new device state
            NSNumber *level = [NSNumber numberWithInt:sender.slider.value];
            [[devices objectAtIndex:indexPath.row] setValue:level forKey:@"value"];
        }
    }
}
@end
