//
//  SearchEventsVC.m
//  VeganEeze
//
//  Created by Brandon Ruger on 8/18/15.
//  Copyright (c) 2015 Brandon Ruger. All rights reserved.
//

#import "SearchEventsVC.h"
#import "EventResultsTVC.h"
#import "VeganEvent.h"
#import "Reachability.h"

@interface SearchEventsVC ()

@end

@implementation SearchEventsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Set search bars' delegate
    location.delegate = self;
    
    //Setup array with choices for picker
    pickerChoices = [[NSArray alloc]initWithObjects:@"Vegan", @"Vegetarian", @"Veg-Friendly", nil];
    
    //Connect picker view to delegates
    veganChoicePicker.dataSource = self;
    veganChoicePicker.delegate = self;
    
    searchCurrentLocation = TRUE;
    
    appKey = @"&app_key=VrdtgSDWhZCHjRcK";
    
    //Set default for picker choice
    pickerChoiceSelected = @"vegan";
    
    //Create location manager object
    locationMgr = [[CLLocationManager alloc]init];
    if (locationMgr != nil) {
        
        //Request permission to access location
        [locationMgr requestWhenInUseAuthorization];
    }
    
    //Add target selectors to segmented control buttons
    [searchSegmentedControl addTarget:self action:@selector(howToSearch:) forControlEvents:UIControlEventValueChanged];
    
    //Initalize NSMutableArray which will hold event objects
    eventObjects = [[NSMutableArray alloc]init];
    
    }

- (void)viewWillAppear:(BOOL)animated {
    
    //Clear text from search bars
    location.text = @"";
    
    //Remove all objects from array
    if (eventObjects != nil) {
        [eventObjects removeAllObjects];
    }
    
    //Check if Location Services are enabled on the device
    if([CLLocationManager locationServicesEnabled]){
        
        //Location Services enabled on device
        
        //Check if user has approved this app to use Location Services
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            //User has denied request for this app to use location services
            
            //Disable location button on segmented controller
            [searchSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            //Change default selection to search by city
            [searchSegmentedControl setSelectedSegmentIndex:1];
            
            
        } else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse) {
            //User has granted permission for this app to use locatioon services
            
            //Enable location button on segmented controller
            [searchSegmentedControl setEnabled:YES forSegmentAtIndex:0];
            
            //Get current location
            [self getCurrentLocation];
            
        } 
        
    } else {
        
        //Location Services are disabled on device
        
        //Disable location button on segmented controller
        [searchSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        //Change default selection to search by city
        [searchSegmentedControl setSelectedSegmentIndex:1];

    }
    
    //Call method to determine how to search
    [self howToSearch:searchSegmentedControl];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Bar

//Called when search button is clicked on keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //Call method to search for vegan events
    [self searchVeganEvents:nil];
    
    //Dismiss keyboard
    [self.view endEditing:YES];
    
}

//Called when cancel button on search bar is clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    //Dismiss keyboard
    [self.view endEditing:YES];
    
    //Clear text from search bar
    searchBar.text = @"";
}

//Method to check when search bar finishes editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    //Dismiss keyboard
    [self.view endEditing:YES];
    
}

#pragma mark - Segmented Control Button methods

//Method called when segmented control button changes
- (void)howToSearch:(UISegmentedControl *)sender {
    //Get index of button pressed
    NSInteger segmentControlSelected = sender.selectedSegmentIndex;
    
    if (segmentControlSelected == 0) {
        //Call the method to search by current location
        [self searchByCurrentLoc];
        
        //Set bool to true
        searchCurrentLocation = TRUE;
    } else {
        //Call method to search by city/state
        [self searchCityState];
        
        //Set bool to false
        searchCurrentLocation = FALSE;
    }
}

//Method called when segmented control is set to "search current location"
- (void)searchByCurrentLoc {
    
    //Hide location search bar
    location.hidden = TRUE;
}

//Method called when segmented control is set to "search by city/state"
- (void)searchCityState {
    
    //Show location search bar
    location.hidden = FALSE;
}

#pragma mark - Current Location

//Method to get user's current location
- (void)getCurrentLocation {
    
    //Create location manager object
    if (locationMgr != nil) {
        
        [locationMgr requestWhenInUseAuthorization];
        
        //Set location accuracy
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
        //Set delegate
        locationMgr.delegate = self;
        //Start gathering location info
        [locationMgr startUpdatingLocation];
    }
    
}

//Delegate method to get current locations
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation != nil) {
        //Get coordinates of current location
        CLLocationCoordinate2D coordinates = currentLocation.coordinate;
        
        //Convert latitude/longitude coordinates to strings
        latitudeCoord = [NSString stringWithFormat:@"%g", coordinates.latitude];
        longitudeCoord = [NSString stringWithFormat:@"%g", coordinates.longitude];

    }
}

#pragma mark - Picker View

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [pickerChoices count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return pickerChoices[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (row) {
        case 0:
            //User selected first row
            pickerChoiceSelected = @"vegan"; //Vegan
            break;
            
        case 1:
            //User selected second row
            pickerChoiceSelected = @"vegetarian"; //Vegetarian
            break;
            
        case 2:
            //User selected 3rd row
            pickerChoiceSelected = @"veg+friendly"; //Vegan-Friendly
            break;
            
        default:
            pickerChoiceSelected = @"vegan"; //Default choice is vegan
            break;
    }
}

#pragma mark - Eventful API calls

-(IBAction)searchVeganEvents:(id)sender {
    
    //Check for valid network connection
    if ([self isNetworkConnected]) {
        
        //Check how user wants to search
        if (searchCurrentLocation) {
            //User has chosen to search by current location
            
            //String used to access API
            partialURL = @"http://api.eventful.com/json/events/search?q=";
            
            //Add on picker choice selected to URL
            partialURL = [partialURL stringByAppendingString:pickerChoiceSelected];
            
            //Format location coordinates with parameters for URL
            NSString *locationCoordinates = [NSString stringWithFormat:@"&l=%@,%@&within=40&units=miles", latitudeCoord, longitudeCoord];
            
            //Add location
            NSString *locationURL = [partialURL stringByAppendingString:locationCoordinates];
            
            //Add App key
            completeURL = [locationURL stringByAppendingString:appKey];
            
            
        } else {
            //User wants to search by address
            partialURL = @"http://api.eventful.com/json/events/search?q=";
            
            //Add on picker choice selected to URL
            partialURL = [partialURL stringByAppendingString:pickerChoiceSelected];
            
            //Get string user entered in search field
            NSString *userEnteredLocation = location.text;
            
            //Encode text user entered
            NSString *encodedLocation = [userEnteredLocation stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            //Format encoded string for URL
            NSString *locationToSearch = [NSString stringWithFormat:@"&l=%@", encodedLocation];
            
            //Append string to form complete URL
            NSString *locationURL = [partialURL stringByAppendingString:locationToSearch];
            
            //Add App key
            completeURL = [locationURL stringByAppendingString:appKey];
            
        }
        
        //Set up URL for API call
        urlForAPICall = [[NSURL alloc] initWithString:completeURL];
        
        //Set up request to send to server
        requestForData = [[NSMutableURLRequest alloc]initWithURL:urlForAPICall];
        if (requestForData != nil) {
            
            //Set up connection to get data from the server
            apiConnection = [[NSURLConnection alloc]initWithRequest:requestForData delegate:self];
            //Create mutableData object to hold data
            dataRetrieved = [NSMutableData data];
        }
        
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
    }
}

//Method called when data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //Check to make sure data is valid
    if (data != nil) {
        //Add this data to mutableData object
        [dataRetrieved appendData:data];
    }
}

//Method called when all data from request has been retrieved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //Serialize JSON data
    dictOfJSONData = [NSJSONSerialization JSONObjectWithData:dataRetrieved options:0 error:nil];
    
    //Get events from JSON data
    NSDictionary *eventsRetrieved = [dictOfJSONData objectForKey:@"events"];
    NSArray *eventsRetrievedArray = [eventsRetrieved valueForKey:@"event"];
    
    //Check to make sure array is not null or empy
    if ([eventsRetrievedArray isEqual:[NSNull null]]) {
        
        //Alert user no results were found
        UIAlertController *noResults = [UIAlertController alertControllerWithTitle:@"No Events Found" message:@"No events found. Please revise your search and try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        //Add action to alert controller
        [noResults addAction:defaultOk];
        //Show alert
        [self presentViewController:noResults animated:YES completion:nil];
        
        
    } else {
        //Results found
        
        if ([eventsRetrievedArray isKindOfClass:[NSArray class]]) {
            
            for (int i=0; i<[eventsRetrievedArray count]; i++) {
                
                //Use custom method to grab each object from dictionary and add each object to mutable array
                VeganEvent *event = [self createEventObjects:[eventsRetrievedArray objectAtIndex:i]];
                if (event != nil) {
                    //Add object to array
                    [eventObjects addObject:event];
                }
            }
            
            
        } else if([eventsRetrievedArray isKindOfClass:[NSDictionary class]]){
            
            //Use custom method to create a single VeganEvent object
            VeganEvent *singleEvent = [self createSingleEvent:eventsRetrievedArray];
            if (singleEvent != nil) {
                //Add object to array
                [eventObjects addObject:singleEvent];
            }
            
        }
        
        //Instantiate results view controller
        EventResultsTVC *eventResultsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventResultsViewController"];
        //Pass the array of VeganEvent objects to the Results view controller
        eventResultsTVC.arrayOfEvents = eventObjects;
        //Push view controller onto screen
        [self.navigationController pushViewController:eventResultsTVC animated:YES];
    }
    
    
}

//Method to create custom AlcoholBeverage objects and initalize each object
-(VeganEvent*)createEventObjects:(NSDictionary*)eventDictionary {
    
    //Get data from dictionary
    NSString *eventName = [eventDictionary valueForKey:@"title"];
    NSString *eventAddress = [eventDictionary valueForKey:@"venue_address"];
    NSString *eventCity = [eventDictionary valueForKey:@"city_name"];
    NSString *eventState = [eventDictionary valueForKey:@"region_abbr"];
    NSString *eventZip = [eventDictionary valueForKey:@"postal_code"];
    NSString *eventWebsite = [eventDictionary valueForKey:@"url"];
    NSString *eventID = [eventDictionary valueForKey:@"id"];
    
    NSString *description = [eventDictionary valueForKey:@"description"];
    if (description != nil) {
        //Format description to make sure HTML tags are removed
        NSAttributedString *eventDescFormatted =[[NSAttributedString alloc] initWithData:[description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
        
        descriptionStrFinal = [eventDescFormatted string];
    }
    
    
    NSString *startTime = [eventDictionary valueForKey:@"start_time"];
    NSString *venue = [eventDictionary valueForKey:@"venue_name"];
    NSString *price = [eventDictionary valueForKey:@"price"];
    
    NSDictionary *imagesDictionary = [eventDictionary valueForKey:@"image"];
    NSDictionary *smallImg = [imagesDictionary valueForKey:@"small"];
    singleImg = [smallImg valueForKey:@"url"];
    
    if ([singleImg isEqual:[NSNull null]]) {
        
        //Set image to an empty string
        singleImg = @"";
        
    }
    
    if ([eventZip isEqual:[NSNull null]] || eventZip == nil) {
        eventZip = @"";
    }
    
    //Get latitude/longitude of venue
    Float32 eventLatitude = [[eventDictionary objectForKey:@"latitude"] floatValue];
    Float32 eventLongitude = [[eventDictionary objectForKey:@"longitude"] floatValue];
    
    
    //Use object's custom init method to initialize object
    VeganEvent *newEvent = [[VeganEvent alloc] initWithEvent:eventName addressForEvent:eventAddress cityOfEvent:eventCity stateOfEvent:eventState zipOfEvent:eventZip websiteForEvent:eventWebsite idForEvent:eventID descOfEvent:descriptionStrFinal startTime:startTime venue:venue price:price imageURL:singleImg eventLatitude:eventLatitude eventLongitude:eventLongitude];
    
    return newEvent;
}

-(VeganEvent*)createSingleEvent:(NSArray*)singleEventArray {
    NSString *eventName = [singleEventArray valueForKey:@"title"];
    NSString *eventAddress = [singleEventArray valueForKey:@"venue_address"];
    NSString *eventCity = [singleEventArray valueForKey:@"city_name"];
    NSString *eventState = [singleEventArray valueForKey:@"region_abbr"];
    NSString *eventZip = [singleEventArray valueForKey:@"postal_code"];
    NSString *eventWebsite = [singleEventArray valueForKey:@"url"];
    NSString *eventID = [singleEventArray valueForKey:@"id"];
    
    NSString *description = [singleEventArray valueForKey:@"description"];
    NSString *startTime = [singleEventArray valueForKey:@"start_time"];
    NSString *venue = [singleEventArray valueForKey:@"venue_name"];
    NSString *price = [singleEventArray valueForKey:@"price"];
    
    NSDictionary *imagesDictionary = [singleEventArray valueForKey:@"image"];
    NSDictionary *smallImg = [imagesDictionary valueForKey:@"small"];
    singleImg = [smallImg valueForKey:@"url"];
    
    if ([singleImg isEqual:[NSNull null]]) {
        
        //Set image to an empty string
        singleImg = @"";
        
    }
    
    if ([eventZip isEqual:[NSNull null]] || eventZip == nil) {
        eventZip = @"";
    }
    
    //Get latitude/longitude of venue
    Float32 eventLatitude = [[singleEventArray valueForKey:@"latitude"] floatValue];
    Float32 eventLongitude = [[singleEventArray valueForKey:@"longitude"] floatValue];
    
    
    //Use object's custom init method to initialize object
    VeganEvent *singleEvent = [[VeganEvent alloc] initWithEvent:eventName addressForEvent:eventAddress cityOfEvent:eventCity stateOfEvent:eventState zipOfEvent:eventZip websiteForEvent:eventWebsite idForEvent:eventID descOfEvent:description startTime:startTime venue:venue price:price imageURL:singleImg eventLatitude:eventLatitude eventLongitude:eventLongitude];
    
    return singleEvent;
    
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
        return FALSE;
    }
}

@end
