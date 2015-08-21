//
//  SearchEventsVC.h
//  VeganEeze
//
//  Created by Brandon Ruger on 8/18/15.
//  Copyright (c) 2015 Brandon Ruger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchEventsVC : UIViewController <UISearchBarDelegate>

{
    IBOutlet UISearchBar *keyword;
    IBOutlet UISearchBar *location;
    IBOutlet UIButton *cancelButton;
}

@end
