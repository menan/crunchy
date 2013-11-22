//
//  DetailViewController.m
//  CrunchBase Mobile V2
//
//  Created by Menan Vadivel on 2013-01-30.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Connection.h"
#import "UIImageView+WebCache.h"
#import "OverviewViewController.h"
#import "ImageViewController.h"

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
        NSLog(@"title:%@",name);
        self.title = name;
        self.titleLabel.text = name;
        
        
        NSString* permUrl = [[self.detailItem objectForKey:@"permalink"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        item = [[NSMutableDictionary alloc] init];
        NSLog(@"comp url:%@",permUrl);
        Connection *con = [[Connection alloc] init];
        [con readJSON:permUrl withSender:self];
        
    }
}

- (void) readObject: (NSDictionary *) object{
    item = [object copy];
    
    crunch = [[Cruncher alloc] initWithDictionary:item];
    [crunch setItemType: [self.detailItem objectForKey:@"type"]];
    NSLog(@"data reloaded to detail length is : %d",[item count]);
    [tableView reloadData];
    tableView.scrollEnabled = YES;
    [loading stopAnimating];
    
    NSString* image_url = [crunch getImage:false];
    
    NSURL *url = [NSURL URLWithString:image_url];
    NSLog(@"image url :%@",image_url);
    UIImage *img = [UIImage imageNamed:@"aimage.png"];
    [self.imageView setImageWithURL:url placeholderImage:img];
    
    self.title = [crunch getTitle];
    
    NSLog(@"Items: %d",[crunch getSectionsCount]);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
//        NSLog(@"overview = %@",overviewTxt);
        [overview sendOverviewText:overviewTxt];
    }
    else if ([[segue identifier] isEqualToString:@"imageview"]){
        
        ImageViewController *imageview = segue.destinationViewController;
        NSString *imageURL = [self.detailItem objectForKey:@"image_large"];
        NSLog(@"image large url = %@",imageURL);
        [imageview setImageURL:imageURL];
        
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [crunch getSectionAtIndex:section];

//    if ([item count] > 0){
//        if(section == 0)
//            return @"General Info";
//        else if(section == 1)
//            return @"Overview";
//        else{
//            return [crunch titlizeString:[crunch getKeyAtIndexPath:section]];
//        }
//    }
//    else
//        return @"";
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [crunch getSectionsCount];
//    if ([crunch getSectionsCount] > 0)
//        return [crunch getSectionsCount] +1;
//    else
//        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"size at section:%d",[crunch getSizeAtSection:section]);
    return [crunch getSizeAtSection:section];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section > 0) {
        
//        DetailViewController *detail = [[DetailViewController alloc] init];
        DetailViewController *detail=[self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
        
        [self.navigationController pushViewController:detail animated:YES];
        
        [object setObject:[crunch permalinkatIndexPath:indexPath] forKey:@"permalink"];
        [object setObject:[crunch getTypeAtIndexPath:indexPath] forKey:@"type"];
        
        [detail setDetailItem:object];
    }
    
    
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

@end
