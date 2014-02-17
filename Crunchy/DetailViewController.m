//
//  DetailViewController.m
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-01-30.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "OverviewViewController.h"
#import "ImageViewController.h"
#import "AFJSONRequestOperation.h"
#import "WebViewController.h"

@interface DetailViewController ()

@property (strong, nonatomic) Cruncher *crunch;

#define MAX_DATA 100
- (void)configureView;
@end

@implementation DetailViewController

@synthesize loading,tableView,crunch;
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        NSString *name = [self.detailItem objectForKey:@"name"];
//        NSLog(@"title:%@",name);
        self.title = name;
        self.titleLabel.text = name;
        
        item = [[NSMutableDictionary alloc] init];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[self crunchyURLFromString:[self.detailItem objectForKey:@"permalink"]]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//            NSLog(@"Read JSON: %@", JSON);
            item = [JSON copy];
            [self readObject];
            
        } failure:nil];
        [operation start];
        
    }
}

- (void) readObject{
    crunch = [[Cruncher alloc] initWithDictionary:item];
    [crunch setItemType: [self.detailItem objectForKey:@"type"]];
    NSLog(@"data reloaded to detail length is : %d",[item count]);
    [tableView reloadData];
    tableView.scrollEnabled = YES;
    [loading stopAnimating];
    
    NSString* image_url = [crunch getImage:NO];
    
    NSURL *url = [NSURL URLWithString:image_url];
//    NSLog(@"image url :%@",image_url);
    UIImage *img = [UIImage imageNamed:@"aimage.png"];
    [self.imageView setImageWithURL:url placeholderImage:img];
    
    self.title = [crunch getTitle];
    
//    NSLog(@"Sections: %d",[crunch getSectionsCount]);
}

//
- (void)viewDidLoad
{
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}
-(void)viewDidAppear:(BOOL)animated{
    if ([item count] > 0) {
        crunch = [crunch initWithDictionary:item];
        [crunch setItemType: [self.detailItem objectForKey:@"type"]];
    }
//    NSLog(@"-- viewDidAppear items %@, %@",self.title, [crunch getTitle]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue id: %@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"overview"]) {
        OverviewViewController *overview = segue.destinationViewController;
        NSString *overviewTxt = [crunch getOverview];
//        NSLog(@"overview = %@",overviewTxt);
        [overview sendOverviewText:overviewTxt];
    }
    else if ([[segue identifier] isEqualToString:@"imageview"]){
        
        ImageViewController *imageview = segue.destinationViewController;
        NSString *imageURL = [self.detailItem objectForKey:@"image_large"];
        NSLog(@"image large url = %@",imageURL);
        [imageview setImageURL:imageURL];
        
    }
    else if ([[segue identifier] isEqualToString:@"web"]){
        
        WebViewController* view = segue.destinationViewController;
        
        NSIndexPath *index = [tableView indexPathForSelectedRow];
        NSString *fullURL = [[crunch getContentAtIndexPath:index] objectAtIndex:1];
        view.url  = fullURL;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [crunch getSectionAtIndex:section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [crunch getSectionsCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [crunch getSizeAtSection:section];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"title: %@",[crunch getSectionAtIndex:indexPath.section]);
    
    if ([[crunch getSectionAtIndex:indexPath.section] isEqualToString:@"general Info"]) {
        
    }
    else if ([[crunch getSectionAtIndex:indexPath.section] isEqualToString:@"offices"]){
        
    }
    else if ([[crunch getSectionAtIndex:indexPath.section] isEqualToString:@"milestones"]){
        [self performSegueWithIdentifier:@"web" sender:self];
    }
    else if ([[crunch getSectionAtIndex:indexPath.section] isEqualToString:@"external links"]){
        [self performSegueWithIdentifier:@"web" sender:self];
    }
    else{
        DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
        
        [self.navigationController pushViewController:detail animated:YES];
        
        [object setObject:[crunch permalinkatIndexPath:indexPath] forKey:@"permalink"];
        [object setObject:[crunch getTypeAtIndexPath:indexPath] forKey:@"type"];
        
        [detail setDetailItem:object];
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    if (indexPath.section > 0)
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType =  UITableViewCellAccessoryNone;
    
    // Set up the cell...
    
//    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
//    cell.textLabel.numberOfLines = 2;
    NSArray *content = [NSArray arrayWithArray: [crunch getContentAtIndexPath:indexPath]];

    
    cell.textLabel.text = [content objectAtIndex:0];
    cell.detailTextLabel.text = [content objectAtIndex:1];
    return cell;
}

- (NSURL *) crunchyURLFromString:(NSString *) url{
    NSString *cleanURL = [NSString stringWithFormat:@"%@api_key=vb4f9vwfty979hbyp7ry3wwk",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"Browsing %@",cleanURL);
    return [NSURL URLWithString:cleanURL];
}
@end
