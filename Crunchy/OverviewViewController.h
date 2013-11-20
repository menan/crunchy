//
//  OverviewViewController.h
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-02-09.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *overviewText;
-(void) sendOverviewText: (NSString *) text;
@end
