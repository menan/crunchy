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
#import "AFJSONRequestOperation.h"

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
    self.tableView.separatorInset = UIEdgeInsetsZero;
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
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, self.tableView.rowHeight, self.tableView.rowHeight)];
        imgView.tag = 10;

        
        imgView.contentMode = UIViewContentModeScaleAspectFit;

        [cell.contentView addSubview:imgView];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.rowHeight + 25, 10, cell.bounds.size.width - 100, 30)];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Arial" size:15];
        label.font =  [UIFont boldSystemFontOfSize:15];

        label.numberOfLines = 2;
        label.tag = 11;
        label.backgroundColor = nil;
        label.opaque = NO;
        [cell.contentView addSubview:label];
        
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	int storyIndex = (int) [indexPath indexAtPosition: [indexPath length] - 1];
    NSString * urlString = [[_objects objectAtIndex: storyIndex] objectForKey: @"image"];
    NSLog(@"url string: %@",urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];

    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:10];
    [imgView sd_setImageWithURL:url placeholderImage:nil];

    UILabel *labelTitle = (UILabel *)[cell.contentView viewWithTag:11];
    labelTitle.text = _objects[storyIndex][@"name"];
    
    cell.indentationWidth = 0;
    cell.indentationLevel = 0;
    
    
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
                NSString* images_url = [[[images valueForKey:@"available_sizes"] objectAtIndex:0] objectAtIndex:1];
                NSString* images_large_url = [[[images valueForKey:@"available_sizes"] objectAtIndex:2] objectAtIndex:1];
                
                [item setObject:images_url forKey:@"image"];
                [item setObject:images_large_url forKey:@"image_large"];
                
                
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
            [item setObject:[NSString stringWithFormat:@"%@/%@/%@.json?",[Cruncher crunchBaseURL], [result valueForKey:@"namespace"], [result valueForKey:@"permalink"]] forKey:@"permalink"];
            [_objects addObject:[item copy]];
            
        }
    }
    
    [self.tableView reloadData];
    NSLog(@"returned object: %lu",(unsigned long)_objects.count);
}


- (void) parseData: (NSDictionary *) data{
    
    [loading stopAnimating];
    self.tableView.allowsSelection = YES;
    item = [[NSMutableDictionary alloc] init];
    _objects = [[NSMutableArray alloc] init];
    
    NSArray *results = data[@"data"][@"items"];
    int numberOfResults = [data[@"data"][@"paging"][@"total_items"] intValue];
    
    if (numberOfResults == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Zero Results"
                                                        message:@"There are matches found, double check your keyword."
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
            
            NSString *path = result[@"path"];
            NSString *image_url = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",path];
            NSString *image_url_raw = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw",path];
            NSString *name = result[@"name"];
            NSString *type = result[@"type"];
            
            
            [item setObject:image_url forKey:@"image"];
            [item setObject:image_url_raw forKey:@"image_large"];
            [item setObject:name forKey:@"name"];
            [item setObject:type forKey:@"type"];
            [item setObject:[NSString stringWithFormat:@"%@/%@?",[Cruncher crunchBaseURL], path] forKey:@"permalink"];
            
            [_objects addObject:[item copy]];
        }
    }
    [self.tableView reloadData];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)uiSearchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSString* url = [[NSString stringWithFormat:@"%@/organizations?query=%@&user_key=%@", [Cruncher crunchBaseURL], uiSearchBar.text, [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Read JSON: %@", JSON);
        [self parseData:JSON];
        
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error: %@", [error userInfo]);
        [loading stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                        message:@"Unable to connect to the server."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
                                                                                        }];
    [operation start];
    
//    Connection *con = [[Connection alloc] init];
//    [con readJSON:url withSender:self];
    
    [searchBar resignFirstResponder];
    [loading startAnimating];
	[searchBar setShowsCancelButton:NO animated:YES];
    self.tableView.allowsSelection = NO;
    
    
}
- (IBAction)aboutTapped:(id)sender {
    
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSString *ourPath = @"twitter://user?screen_name=MenanV";
    NSURL *ourURL = [NSURL URLWithString:ourPath];
    [ourApplication openURL:ourURL];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        NSLog(@"selected index path:%ld",(long)indexPath.row);
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
