//
//  MasterViewController.h
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-01-30.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController{
	NSMutableDictionary * item;
}

//- (void) readObject: (NSDictionary *) object;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@end
