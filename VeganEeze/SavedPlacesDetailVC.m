//
//  SavedPlacesDetailVC.m
//  VeganEeze
//
//  Created by Brandon Ruger on 8/22/15.
//  Copyright (c) 2015 Brandon Ruger. All rights reserved.
//

#import "SavedPlacesDetailVC.h"
#import "WebVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Parse/Parse.h>
#import "Reachability.h"
#import "CommentCell.h"
#import "RatingsVC.h"

@interface SavedPlacesDetailVC ()

@end

@implementation SavedPlacesDetailVC
@synthesize objectId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Access user's Twitter account on device
    ACAccountStore *accountStore = [[ACAccountStore alloc]init];
    if (accountStore != nil) {
        //Tell what type of account need to access
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        if (accountType != nil) {
            //Ask account store for direct access to Twitter account
            [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    //Success, we have access
                    NSArray *userTwitterAccts = [accountStore accountsWithAccountType:accountType];
                    if (userTwitterAccts != nil && userTwitterAccts.count > 0) {
                        //Access single account
                        ACAccount *currentAcct = [userTwitterAccts objectAtIndex:0];
                        if (currentAcct != nil) {
                        }
                        
                    } else {
                        //Disable Tweet button
                        [tweetButton setEnabled:NO];
                    }
                }
                else {
                    //User did not approve accessing Twitter account
                    
                    //Disable tweet button
                    [tweetButton setEnabled:NO];
                }
            }];
        }
    }
    
}

#pragma mark - Twitter Sharing
-(IBAction)shareToTwitter:(id)sender {
    
    //Check for active network connection
    if ([self isNetworkConnected]) {
        //Create view that allows user to post to Twitter
        SLComposeViewController *slComposeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        //Setup text for tweet post
        NSString *twitterPrefixString = @"Check this place out: ";
        NSString *twitterFullString = [twitterPrefixString stringByAppendingString:urlOfPlace];
        
        //Add in default text to share
        [slComposeVC setInitialText:twitterFullString];
        
        //Present view to user for posting
        [self presentViewController:slComposeVC animated:TRUE completion:nil];
    }
}

#pragma mark - Phone Dialer

-(IBAction)launchPhoneDialer:(id)sender {
    
    //Get string for phone number and append it to tel prefix
    NSString *phoneNum = [@"tel://" stringByAppendingString:phoneNoOfPlace];
    //Launch phone dialer
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
}

-(void)viewDidAppear:(BOOL)animated {
    //Check for active network connection
    if ([self isNetworkConnected]) {
        //Setup queries to check both classes for object ID
        PFQuery *favoritePlaceQuery = [PFQuery queryWithClassName:@"FavoritePlace"];
        PFQuery *placeToVisitQuery = [PFQuery queryWithClassName:@"PlaceToVisit"];
        
        //Run first query to check for object ID
        [favoritePlaceQuery getObjectInBackgroundWithId:objectId block:^(PFObject *savedPlace, NSError *error) {
            
            if (!error) {
                //Object ID was found
                //Get strings out of object
                nameOfPlace = savedPlace[@"name"];
                if (nameOfPlace != nil) {
                    nameLabel.text = nameOfPlace;
                }
                
                
                addressOfPlace = savedPlace[@"address"];
                if (addressOfPlace != nil) {
                    addressTV.text = addressOfPlace;
                } else {
                    addressTV.text = @"Address unknown";
                }
                
                urlOfPlace = savedPlace[@"url"];
                if (urlOfPlace == nil) {
                    //Disable website button
                    [urlLabel setEnabled:NO];
                }
                
                phoneNoOfPlace = savedPlace[@"phoneNo"];
                if (phoneNoOfPlace == nil) {
                    //Disable button
                    [phoneButton setEnabled:NO];
                }
                
                description = savedPlace[@"description"];
                if (description != nil) {
                    descriptionTV.text = description;
                } else {
                    descriptionTV.text = @"No description available";
                }
                
                itemID = savedPlace[@"itemID"];
                
                //Initialize array for reviews
                reviewsArray = [[NSMutableArray alloc]init];
                //Call method to retrieve reviews for the current object's item ID
                [self retrieveReviews: itemID];
                
            } else {
                //Run second query to check for Object ID
                [placeToVisitQuery getObjectInBackgroundWithId:objectId block:^(PFObject *savedPlace, NSError *error) {
                    
                    if (!error) {
                        //Object ID was found
                        //Get strings out of object
                        nameOfPlace = savedPlace[@"name"];
                        if (nameOfPlace != nil) {
                            nameLabel.text = nameOfPlace;
                        }
                        
                        addressOfPlace = savedPlace[@"address"];
                        if (addressOfPlace != nil) {
                            addressTV.text = addressOfPlace;
                        } else {
                            addressTV.text = @"Address unknown";
                        }
                        
                        
                        urlOfPlace = savedPlace[@"url"];
                        if (urlOfPlace == nil) {
                            [urlLabel setEnabled:NO];
                        }
                        
                        phoneNoOfPlace = savedPlace[@"phoneNo"];
                        if (phoneNoOfPlace == nil) {
                            //Disable button
                            [phoneButton setEnabled:NO];
                        }
                        
                        
                        description = savedPlace[@"description"];
                        if (description != nil) {
                            descriptionTV.text = description;
                        } else {
                            descriptionTV.text = @"No description available";
                        }
                        
                        itemID = savedPlace[@"itemID"];
                        
                        //Initialize array for reviews
                        reviewsArray = [[NSMutableArray alloc]init];
                        //Call method to retrieve reviews for the current object's item ID
                        [self retrieveReviews: itemID];
                    }
                }];
            }
            
        }];
        
    }
    
}

#pragma mark - Navigation

//Segue method to pass information to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"savedToWebSegue"]) {
        //Access the web view
        WebVC *webVC = segue.destinationViewController;
        //Pass restaurant's URL to web view
        webVC.websiteStr = urlOfPlace;
    }
    
    if ([segue.identifier isEqualToString:@"savedToRatingsSegue"]) {
        
        RatingsVC *ratingsVC = segue.destinationViewController;
        //Pass the review URI to ratings view to use as the ID
        
        ratingsVC.currentEventsID = itemID;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Comments/Ratings

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [reviewsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Create custom comment cell
    CommentCell *commentsCell = [tableView dequeueReusableCellWithIdentifier:@"savedCommentCell"];
    if (commentsCell != nil) {
        
        //Get current object out of array
        PFObject *currentReview = [reviewsArray objectAtIndex:indexPath.row];
        
        //Get index of row and use index to get username/comments from array
        NSString *currentUsername = currentReview[@"username"];
        NSString *currentComment = currentReview[@"review"];
        NSString *currentRating = currentReview[@"stars"];
        
        //Call cell's custom method to update cell
        [commentsCell updateCellWithComments:currentUsername userComment:currentComment usersRating:currentRating];
        
    }
    
    return commentsCell;
}

//Method to retrieve current item's reviews from Parse
-(void)retrieveReviews: (NSString*)placesID {
    
    //Check for valid network connection
    if ([self isNetworkConnected]) {
        
        if (itemID != nil) {
            PFQuery *reviewQuery = [PFQuery queryWithClassName:@"UserRating"];
            [reviewQuery whereKey:@"itemID" equalTo:placesID];
            
            [reviewQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    
                    //Loop through objects retrieved from the query
                    for (PFObject *object in objects) {
                        
                        //Add objects to eventReviewsArray
                        [reviewsArray addObject:object];
                    }
                    
                    //Refresh the tableview
                    [commentsTV reloadData];
                    
                } else {
                    //Do nothing
                }
            }];
        }
        
        
    }
}


@end
