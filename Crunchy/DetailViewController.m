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
#import "NSString+HTML.h"

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
        self.descriptionLabel.text = [self flattenHTML:[self.detailItem objectForKey:@"overview"]];
        
        
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
    NSLog(@"Items: %d",[crunch getSectionsCount]);
}

- (NSString *)flattenHTML:(NSString *)html {
    return html;
//    if (html != (id)[NSNull null])
//        return [html stringByConvertingHTMLToPlainText];
//    else
//        return @"";
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    NSURL *url = [NSURL URLWithString: [self.detailItem objectForKey:@"image_large"]];
    NSLog(@"image:%@",[self.detailItem objectForKey:@"image_large"]);
    UIImage *img = [UIImage imageNamed:@"aimage.png"];
    [self.imageView setImageWithURL:url placeholderImage:img];
    
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
        NSString *overviewTxt = [self flattenHTML:[self.detailItem objectForKey:@"overview"]];
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
//    NSLog(@"type_string:%@,row:%d",[self getValue:@"type"],indexPath.row);
    
    DetailViewController *detail = [[DetailViewController alloc] init];
    
    
//
//    if (indexPath.section > 1){
//        [self viewOverview:self];
//        NSLog(@"loading overview");
//    }
//    else if ([[self permalinkAtIndexPath:item:indexPath] length] > 0 || ([[self getValue:@"type"] isEqualToString: @"product"] && indexPath.row == 0 && indexPath.section == 0)){
//        
//        if ([[self getValue:@"type"] isEqualToString: @"product"] && indexPath.row == 0 && indexPath.section == 0)
//            detail.permalink = [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json", [[item valueForKey:@"company"] valueForKey:@"permalink"]];
//        else
//            detail.permalink = [self permalinkAtIndexPath:item:indexPath];
//        
//        if ([[self getKeyAtIndex:item :indexPath.section] isEqualToString: @"products"]){
//            detail.[self getValue:@"type"] = @"product";
//        }
//        else if ([[self getKeyAtIndex:item :indexPath.section] isEqualToString: @"relationships"] && [[self getValue:@"type"] isEqualToString:@"company"]){
//            detail.[self getValue:@"type"] = @"person";
//        }
//        else if ([[self getKeyAtIndex:item :indexPath.section] isEqualToString: @"relationships"] && [[self getValue:@"type"] isEqualToString:@"person"]){
//            detail.[self getValue:@"type"] = @"company";
//        }
//        else
//            detail.[self getValue:@"type"] = @"company";
//        
//        
    
//        [self.navigationController pushViewController:detail animated:YES];
    
        
        
        
//        NSLog(@"permalink:%@",detail.permalink);
    
        
        //[data removeAllObjects];
        //name.text = @"";
        //self.title = @"";
        //lblDescription.text = @"";
        //[imageButton setImage:[UIImage imageNamed:@"d1.png"] forState:UIControlStateNormal];
        //[dataTable reloadData];
        
        //NSLog(@"Loading permalink:%@",permalinkPath);
        //[self readJSON:permalinkPath];
        
        
        
//    }
//    else 
//        NSLog(@"Click not Accepted");
    
    
    
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
