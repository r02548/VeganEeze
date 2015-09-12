//
//  VeganResourcesTVC.h
//  VeganEeze
//
//  Created by Brandon Ruger on 8/20/15.
//  Copyright (c) 2015 Brandon Ruger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VeganResourcesTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate>

{
    NSString *websiteAddress;
    
    IBOutlet UITableView *resourcesTV;
    
    NSMutableArray *resources;
}

@end
