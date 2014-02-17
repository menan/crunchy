//
//  DetailViewController.h
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-01-30.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cruncher.h"

@interface DetailViewController : UIViewController <UITableViewDataSource>{
	NSMutableDictionary * item;
}

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
- (void) readObject;
@end
