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
#import "MapViewController.h"
#import "FundingsViewController.h"

@interface DetailViewController ()

@property (strong, nonatomic) Cruncher *crunch;

#define MAX_DATA 100
#define PASTLABEL_TAG 1
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
    crunch = [[Cruncher alloc] initWithDictionary:item[@"data"]];
    
//    [crunch setItemType: [self.detailItem objectForKey:@"type"]];
//    NSLog(@"data reloaded to detail length is : %d",(int)[item count]);
    [tableView reloadData];
    tableView.scrollEnabled = YES;
    [loading stopAnimating];
    
    NSString* image_url = [crunch getImage:NO];
    
    NSURL *url = [NSURL URLWithString:image_url];
//    NSLog(@"image url :%@",image_url);
    UIImage *img = [UIImage imageNamed:@"aimage.png"];
    [self.imageView sd_setImageWithURL:url placeholderImage:img];
    
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

- (void) viewWillAppear:(BOOL)animated{
    
    if ([item count] > 0) {
        crunch = [crunch initWithDictionary:item[@"data"]];
        [tableView reloadData];
        
        if ([[crunch getOverview] length] == 0) {
            self.navigationController.navigationItem.rightBarButtonItem = nil;
        }
            
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"overview"]) {
        OverviewViewController *overview = segue.destinationViewController;
        NSString *overviewTxt = [crunch getOverview];
        [overview sendOverviewText:overviewTxt];
    }
    else if ([[segue identifier] isEqualToString:@"imageview"]){
        
        ImageViewController *imageview = segue.destinationViewController;
        NSString *imageURL = [crunch getImage:NO];;
        NSLog(@"image large url = %@",imageURL);
        [imageview setImageURL:imageURL];
        
    }
    else if ([[segue identifier] isEqualToString:@"web"]){
        
        WebViewController* view = segue.destinationViewController;
        NSIndexPath *index = [tableView indexPathForSelectedRow];
        NSMutableDictionary *content = [crunch getContentAtIndexPath:index];
        
        NSString *fullURL = [content objectForKey:@"detail"];
        if ([[content objectForKey:@"detail"] isEqualToString:@"homepage url"]) {
            fullURL = [content objectForKey:@"text"];
        }
        view.url  = fullURL;
    }
    else if ([[segue identifier] isEqualToString:@"map"]){
        
        MapViewController* view = segue.destinationViewController;
        
        NSIndexPath *index = [tableView indexPathForSelectedRow];
        NSString *fullURL = [[crunch getContentAtIndexPath:index] objectForKey:@"text"];
        view.address  = fullURL;
        view.company  = self.title;
    }
    else if([[segue identifier] isEqualToString:@"fundingview"]){
        FundingsViewController * funding = segue.destinationViewController;
        
        NSIndexPath *index = [tableView indexPathForSelectedRow];
        funding.objects = [[[item objectForKey:@"funding_rounds"] objectAtIndex:index.row] objectForKey:@"investments"];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [crunch getSectionAtIndex:(int)section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [crunch getSectionsCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [crunch getSizeAtSection:section];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableDictionary *content = [crunch getContentAtIndexPath:indexPath];
    
    if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"General Info"]) {
        if ([[content objectForKey:@"detail"] isEqualToString:@"twitter"]) {
            NSLog(@"twitter tapped tho %@",[content objectForKey:@"text"]);
            [self openTwitter:[content objectForKey:@"text"]];
        }
        else if ([[content objectForKey:@"detail"] isEqualToString:@"homepage url"]){
            [self performSegueWithIdentifier:@"web" sender:self];
        }
    }
    else if([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"degrees"] || [[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"funds"]){
        
    }
    else if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"offices"] || [[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"headquarters"] || [[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"primary location"]){
        [self performSegueWithIdentifier:@"map" sender:self];
        
    }
    else if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"news"]){
        [self performSegueWithIdentifier:@"web" sender:self];
    }
    else if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"websites"]){
        [self performSegueWithIdentifier:@"web" sender:self];
    }
    else if([[crunch permalinkatIndexPath:indexPath] length] > 0){
        DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
        
        [self.navigationController pushViewController:detail animated:YES];
        
        [object setObject:[crunch permalinkatIndexPath:indexPath] forKey:@"permalink"];
        
        [detail setDetailItem:object];
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *content = [crunch getContentAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"MyIdentifier";
    UILabel *pastLabel;
    UIImageView *imgView;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        imgView.tag = 10;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imgView];
        
        
        BOOL isPast = [[content objectForKey:@"past"] boolValue];
        if (isPast) {
            pastLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 5.0, 40.0, 15.0)];
            pastLabel.tag = PASTLABEL_TAG;
            pastLabel.font = [UIFont boldSystemFontOfSize:13.0];
            pastLabel.textAlignment = NSTextAlignmentCenter;
            pastLabel.textColor = [UIColor blackColor];
            pastLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
            pastLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            pastLabel.text = @"PAST";
            [cell.contentView addSubview:pastLabel];
        }
    } else {
        pastLabel = (UILabel *)[cell.contentView viewWithTag:PASTLABEL_TAG];
        imgView = (UIImageView *)[cell.contentView viewWithTag:10];
    }
    
    NSString * sectionString = [crunch getSectionAtIndex:(int)indexPath.section];
    
    if (indexPath.section > 0 && [[crunch permalinkatIndexPath:indexPath] length] > 0 && ![sectionString isEqualToString:@"degrees"])
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    else if (indexPath.section == 0 && ([[content objectForKey:@"detail"] isEqualToString:@"homepage url"]))
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    else if ([sectionString isEqualToString:@"websites"] ||[sectionString isEqualToString:@"headquarters"] ||[sectionString isEqualToString:@"offices"]||[sectionString isEqualToString:@"news"])
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType =  UITableViewCellAccessoryNone;
    
    
    
    if ([sectionString isEqualToString:@"milestones"]) {
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.numberOfLines = 2;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];

    
    cell.textLabel.text = [content objectForKey:@"text"];
    cell.detailTextLabel.text = [content objectForKey:@"detail"];
    
    cell.imageView.image = nil;
    if (indexPath.section > 0 && [content objectForKey:@"image"]) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[content objectForKey:@"image"]] placeholderImage:nil];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"milestones"]) {
        return 60.0;
    }
    else{
        return 45;
    }
}


- (NSURL *) crunchyURLFromString:(NSString *) url{
    NSString *cleanURL = [NSString stringWithFormat:@"%@user_key=%@",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [Cruncher userKey]];
    NSLog(@"Browsing %@",cleanURL);
    return [NSURL URLWithString:cleanURL];
}
- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (void)openTwitter:(NSString *)screen {
    
    UIApplication *ourApplication = [UIApplication sharedApplication];
    NSString *ourPath = [NSString stringWithFormat:@"twitter://user?screen_name=%@",screen];
    NSURL *ourURL = [NSURL URLWithString:ourPath];
    [ourApplication openURL:ourURL];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"iAd failed to load: %@",[error description]);
}
@end
