//
//  PlacesToVisitTVC.m
//  VeganEeze
//
//  Created by Brandon Ruger on 8/20/15.
//  Copyright (c) 2015 Brandon Ruger. All rights reserved.
//

#import "PlacesToVisitTVC.h"
#import "SavedPlacesDetailVC.h"
#import <Parse/Parse.h>
#import "ViewController.h"
#import "Reachability.h"

@interface PlacesToVisitTVC ()

@end

@implementation PlacesToVisitTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize mutable array
    parsePlacesToVisit = [[NSMutableArray alloc]init];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [parsePlacesToVisit removeAllObjects];
    
    //Check for active network connection
    if ([self isNetworkConnected]) {
        //Check if user is logged in
        PFUser *loggedInUser = [PFUser currentUser];
        if (loggedInUser) {
            //User is logged in
            
            //Call method to retrieve objects from Parse server
            [self retrievePlacesToVisit];
            
        } else {
            [parsePlacesToVisit removeAllObjects];
            [placesToVisitTV reloadData];
            
            //User is not logged in, alert user
            UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You must login in order to view your saved places." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //Take user to login screen
                ViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                //Instantiate view controller
                [self.navigationController pushViewController:loginVC animated:YES];
                
            }];
            //Add action to alert controller
            [loginAlert addAction:defaultOk];
            //Show alert
            [self presentViewController:loginAlert animated:YES completion:nil];
            
            
        }
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [parsePlacesToVisit count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *resultsCell = [tableView dequeueReusableCellWithIdentifier:@"ToVisitCell"];
    if (resultsCell != nil) {
        
        if (parsePlacesToVisit.count > 0) {
            
            //Get current object
            PFObject *currentPlace = [parsePlacesToVisit objectAtIndex:indexPath.row];
            
            if (currentPlace != nil) {
                //Set labels for cell to data in the current object
                resultsCell.textLabel.text = currentPlace[@"name"];
                resultsCell.detailTextLabel.text = currentPlace[@"city"];
            }
        }
        
        
        
        
    }
    
    //Alternate color for every other row
    if (indexPath.row %2 == 0) {
        
        UIColor *alternateColor=[[UIColor alloc]initWithRed:239.0/255.0 green:252.0/255.0 blue:214.0/255.0 alpha:1];
        resultsCell.backgroundColor = alternateColor;
    } else {
        UIColor *otherColor=[[UIColor alloc]initWithRed:162.0/255.0 green:201.0/255.0 blue:142.0/255.0 alpha:1];
        resultsCell.backgroundColor = otherColor;
    }
    
    
    return resultsCell;
}

//Method called when delete button is pressed
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Check to make sure tableview is in delete mode
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //TableView is in delete mode
        
        PFObject *objToDelete = [parsePlacesToVisit objectAtIndex:indexPath.row];
        [objToDelete deleteInBackground];
        //Remove object from Array
        [parsePlacesToVisit removeObjectAtIndex:indexPath.row];
        
        
        //Remote the row from the tableview
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [placesToVisitTV reloadData];
    }
}

//Dynamically put tableview in edit mode
-(IBAction)editTableView:(id)sender {
    placesToVisitTV.editing = !placesToVisitTV.isEditing;
}

#pragma mark - Parse

//Method to retrieve Places to Visit saved on Parse
- (void)retrievePlacesToVisit {
    
    //Check for active network connection
    if ([self isNetworkConnected]) {
        
        //Create a PFQuery to search for the data on Parse
        PFQuery *placeToVisitQuery = [PFQuery queryWithClassName:@"PlaceToVisit"];
        
        [placeToVisitQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //No errors, found objects successfully
                
                //Loop through parse objects
                for (PFObject *object in objects) {
                    
                    [parsePlacesToVisit addObject:object];
                    
                }
                
                //Refresh tableview
                [placesToVisitTV reloadData];
                
            } else {
                //Do nothing
            }
        }];
        
    }
    
}

#pragma mark - Navigation

//Segue to pass data to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"placesToSavedSegue"]) {
        //Access detail view controller
        SavedPlacesDetailVC *savedDetailsVC = segue.destinationViewController;
        if (savedDetailsVC != nil) {
            
            //Get cell that was clicked on
            UITableViewCell *cellClicked = (UITableViewCell*)sender;
            //Get index of cell that was clicked
            NSIndexPath *indexOfCell = [placesToVisitTV indexPathForCell:cellClicked];
            
            //Get object ID for item clicked on
            PFObject *currentObj = [parsePlacesToVisit objectAtIndex:indexOfCell.row];
            NSString *currentObjId = currentObj.objectId;
            
            //Pass the object ID over to the detail view
            savedDetailsVC.objectId = currentObjId;
        }
    }
    
    
    
}

//Method to check if network is connected
- (BOOL) isNetworkConnected
{
    Reachability *currentConnection = [Reachability reachabilityForInternetConnection];
    if ([currentConnection isReachable]) {
        //Network connection active, return true
        return TRUE;
    } else {
        //No network connection
        
        //Alert user
        UIAlertController *noConnection = [UIAlertController alertControllerWithTitle:@"No network connection" message:@"You must have a valid network connection in order to proceed. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        //Add action to alert controller
        [noConnection addAction:defaultOk];
        //Show alert
        [self presentViewController:noConnection animated:YES completion:nil];
        
        return FALSE;
    }
}

@end
