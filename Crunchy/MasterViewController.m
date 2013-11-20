//
//  MasterViewController.m
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-01-30.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Connection.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

@synthesize searchBar, loading;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    //208, 204, 201
//    0.8156862745098,0.8,0.78823529411765
	self.tableView.rowHeight = 50;
//    self.tableView.separatorColor = [UIColor colorWithRed:0.8156862745098 green:0.8 blue:0.78823529411765 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //rgb(104, 177, 195);
//    [self.navigationController.navigationBar setTintColor: [UIColor colorWithRed:.282 green:0.486 blue:0.506 alpha:1]];

    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.rowHeight, self.tableView.rowHeight)];
        imgView.tag = 10;
        
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
//        imgView.contentMode = UIViewContentModeRedraw;
        
//        imgView.layer.cornerRadius = 5.0f;
//        imgView.layer.masksToBounds = YES;
//        imgView.layer.borderWidth = 0.0f;
//        imgView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        //imageButton.layer.shadowColor = [UIColor greenColor].CGColor;
//        imgView.layer.shadowOpacity = 0.8;
//        imgView.layer.shadowRadius = 2;
//        imgView.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);

        [cell.contentView addSubview:imgView];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.rowHeight + 5, 0, 250, 30)];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Arial" size:15];
        label.font =  [UIFont boldSystemFontOfSize:15];

        label.numberOfLines = 2;
        label.tag = 11;
        label.backgroundColor = nil;
        label.opaque = NO;
        [cell.contentView addSubview:label];
        
        UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.rowHeight + 5, 20, 250, 30)];
        labelOne.textColor = [UIColor grayColor];
        labelOne.font = [UIFont fontWithName:@"Arial" size:12];
        labelOne.numberOfLines = 2;
        labelOne.tag = 12;
        labelOne.backgroundColor = nil;
        labelOne.opaque = NO;
        [cell.contentView addSubview:labelOne];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
//    cell.detailTextLabel.bounds = CGRectMake(cell.detailTextLabel.bounds.origin.x, cell.detailTextLabel.bounds.origin.y, cell.detailTextLabel.bounds.size.width, 120.0);
//    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
//    
//    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
//    cell.detailTextLabel.textColor = [UIColor grayColor];
//    //cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
//    cell.detailTextLabel.numberOfLines = 2;
    
    if (![[[_objects objectAtIndex: storyIndex] objectForKey: @"image"] isEqual: @""]){
        
        // Here we use the new provided setImageWithURL: method to load the web image

        
        NSURL *url = [NSURL URLWithString:[[_objects objectAtIndex: storyIndex] objectForKey: @"image"]];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        UIImage *img = [[UIImage alloc] initWithData:data];
//        
        UIImage *img = [UIImage imageNamed:@"aimage.png"];
        UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:10];
        [imgView setImageWithURL:url placeholderImage:nil];
    }
    
    UILabel *labelTitle = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *labelDesc = (UILabel *)[cell.contentView viewWithTag:12];
    
    labelTitle.text = [[_objects objectAtIndex: storyIndex] objectForKey: @"name"];
    labelDesc.text = [[_objects objectAtIndex: storyIndex] objectForKey: @"type"];
    
    // Configure the cell.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}
- (void) readObject: (NSDictionary *) object{
    
    [loading stopAnimating];
    self.tableView.allowsSelection = YES;
    item = [[NSMutableDictionary alloc] init];
    _objects = [[NSMutableArray alloc] init];
    
	NSArray *results = [object valueForKey:@"results"];
    int numberOfResults = [[object valueForKey:@"total"] intValue];
    
    
    //NSLog(@"returned %d results",numberOfResults);
    
    if (numberOfResults == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zero Results"
                                                        message:@"There are matches found. Please double check your keyword."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        NSLog(@"Zero results returned");
    }
    else{
        // Loop through each entry in the dictionary...
        for (NSDictionary *result in results)
        {
            NSDictionary *images = [result valueForKey:@"image"];
            
            if ([images valueForKey:@"available_sizes"] != (id)[NSNull null]){
                NSString* images_url = [NSString stringWithFormat:@"http://crunchbase.com/%@",[[[images valueForKey:@"available_sizes"] objectAtIndex:0] objectAtIndex:1]];
                NSString* images_large_url = [NSString stringWithFormat:@"http://crunchbase.com/%@",[[[images valueForKey:@"available_sizes"] objectAtIndex:2] objectAtIndex:1]];
                
                [item setObject:[NSString stringWithFormat:@"%@", images_url] forKey:@"image"];
                [item setObject:[NSString stringWithFormat:@"%@", images_large_url] forKey:@"image_large"];
                
                
            }
            
            if ([[result valueForKey:@"namespace"] isEqual:@"person"]){
                [item setObject:[NSString stringWithFormat:@"%@ %@", [result valueForKey:@"first_name"], [result valueForKey:@"last_name"]] forKey:@"name"];
            }
            else{
                [item setObject:[NSString stringWithFormat:@"%@", [result valueForKey:@"name"]] forKey:@"name"];
                
            }
            //NSLog(@"images_url:%@",images_url);
            [item setObject:[NSString stringWithFormat:@"%@", [result valueForKey:@"overview"]] forKey:@"overview"];
            [item setObject:[NSString stringWithFormat:@"%@", [result valueForKey:@"namespace"]] forKey:@"namespace"];
            [item setObject:[NSString stringWithFormat:@"%@", [result valueForKey:@"namespace"]] forKey:@"type"];
            [item setObject:[NSString stringWithFormat:@"http://api.crunchbase.com/v/1/%@/%@.json?",[result valueForKey:@"namespace"], [result valueForKey:@"permalink"]] forKey:@"permalink"];
            [_objects addObject:[item copy]];
            
        }
    }
    
    [self.tableView reloadData];
    NSLog(@"returned object: %d",_objects.count);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)uiSearchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSString* url = [[NSString stringWithFormat:@"http://api.crunchbase.com/v/1/search.js?query=%@&",uiSearchBar.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    Connection *con = [[Connection alloc] init];
    [con readJSON:url withSender:self];
    
    [searchBar resignFirstResponder];
    [loading startAnimating];
	[searchBar setShowsCancelButton:NO animated:YES];
    self.tableView.allowsSelection = NO;
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        NSLog(@"selected index path:%d",indexPath.row);
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
