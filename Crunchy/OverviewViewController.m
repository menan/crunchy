//
//  OverviewViewController.m
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-02-09.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import "OverviewViewController.h"

@interface OverviewViewController (){
    
    NSString *text;
}
@end

@implementation OverviewViewController

@synthesize overviewText;
- (void)sendOverviewText:(NSString *)overview
{
    text = overview;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
//    NSLog(@"text came was: %@",text);
    self.overviewText.text = text;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setOverviewText:nil];
    [super viewDidUnload];
}
@end
