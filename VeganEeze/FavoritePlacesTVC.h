//
//  FavoritePlacesTVC.h
//  VeganEeze
//
//  Created by Brandon Ruger on 8/20/15.
//  Copyright (c) 2015 Brandon Ruger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FavoritePlacesTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>

{
    NSMutableArray *parseFavorites;
    
    IBOutlet UITableView *placesTableView;
        
}

@end
