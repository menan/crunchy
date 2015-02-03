//
//  EntityViewController.m
//  Crunchy
//
//  Created by Mac5 on 2015-01-15.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import "EntityViewController.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "CSStickyHeaderFlowLayout.h"
#import "Cruncher.h"


@interface EntityViewController ()

//@property (weak, nonatomic) IBOutlet MKMapView *locations;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *shortDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *updatedLabel;
@property (strong, nonatomic) Cruncher *crunch;
@property (weak, nonatomic) IBOutlet iCarousel *founders;
@end


@implementation EntityViewController

@synthesize crunch,imageView;

#define MAX_DATA 100
#define PASTLABEL_TAG 1

CGRect initialFrame, labelFrame;

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
        NSString *name = self.detailItem[@"name"];
                NSLog(@"title:%@",name);
        self.title = name;
        
        item = [[NSMutableDictionary alloc] init];
                
        NSURLRequest *request = [NSURLRequest requestWithURL:[Cruncher crunchBaseURLForPath:self.detailItem[@"path"]]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                        NSLog(@"Read JSON: %@", JSON);
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
    [self.tableView reloadData];
    [self.founders reloadData];
    
    self.shortDescription.text = [crunch getShorDescription];
    
    self.tableView.scrollEnabled = YES;
    

//    [loading stopAnimating];
    
    
    NSString* image_url = [crunch getImage:NO];
    
    NSURL *url = [NSURL URLWithString:image_url];
    //    NSLog(@"image url :%@",image_url);
    UIImage *img = [UIImage imageNamed:@"aimage.png"];
    [self.imageView sd_setImageWithURL:url placeholderImage:img];
    
    self.title = [crunch getTitle];
    
    
    // Locate your layout
    CSStickyHeaderFlowLayout *layout = (id)self.tableView;
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(320, 200);
    }
    
    // Locate the nib and register it to your collection view
    UINib *headerNib = [UINib nibWithNibName:@"InfoView" bundle:nil];
//    [self.collectionView registerNib:headerNib
//          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
//                 withReuseIdentifier:@"header"];
    [self.tableView registerNib:headerNib forHeaderFooterViewReuseIdentifier:@"header"];
    
    //    NSLog(@"Sections: %d",[crunch getSectionsCount]);
}

//
- (void)viewDidLoad
{
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    [self.tableView setBackgroundView:
     [[UIImageView alloc] initWithImage:
      [UIImage imageNamed:@"crunchy-bg"]]];
    
    
    
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height /2;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Hero" size:18.0f],
      NSFontAttributeName, nil]];
    
    
    self.founders.centerItemWhenSelected = YES;
    self.founders.contentOffset = CGSizeMake(0, 0);
    
       
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void) viewWillAppear:(BOOL)animated{
    
    if ([item count] > 0) {
        crunch = [crunch initWithDictionary:item[@"data"]];
        [self.tableView reloadData];
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"overview"]) {
//        OverviewViewController *overview = segue.destinationViewController;
//        NSString *overviewTxt = [crunch getOverview];
//        [overview sendOverviewText:overviewTxt];
//    }
//    else if ([[segue identifier] isEqualToString:@"imageview"]){
//        
//        ImageViewController *imageview = segue.destinationViewController;
//        NSString *imageURL = [crunch getImage:NO];;
//        NSLog(@"image large url = %@",imageURL);
//        [imageview setImageURL:imageURL];
//        
//    }
//    else if ([[segue identifier] isEqualToString:@"web"]){
//        
//        WebViewController* view = segue.destinationViewController;
//        NSIndexPath *index = [tableView indexPathForSelectedRow];
//        NSMutableDictionary *content = [crunch getContentAtIndexPath:index];
//        
//        NSString *fullURL = [content objectForKey:@"detail"];
//        if ([[content objectForKey:@"detail"] isEqualToString:@"homepage url"]) {
//            fullURL = [content objectForKey:@"text"];
//        }
//        view.url  = fullURL;
//    }
//    else if ([[segue identifier] isEqualToString:@"map"]){
//        
//        MapViewController* view = segue.destinationViewController;
//        
//        NSIndexPath *index = [tableView indexPathForSelectedRow];
//        NSString *fullURL = [[crunch getContentAtIndexPath:index] objectForKey:@"text"];
//        view.address  = fullURL;
//        view.company  = self.title;
//    }
//    else if([[segue identifier] isEqualToString:@"fundingview"]){
//        FundingsViewController * funding = segue.destinationViewController;
//        
//        NSIndexPath *index = [tableView indexPathForSelectedRow];
//        funding.objects = [[[item objectForKey:@"funding_rounds"] objectAtIndex:index.row] objectForKey:@"investments"];
//    }
//}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [crunch getSectionAtIndex:(int)section];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [crunch getSectionsCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [crunch getSizeAtSection:section];
}

//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSMutableDictionary *content = [crunch getContentAtIndexPath:indexPath];
//    
//    if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"General Info"]) {
//        if ([[content objectForKey:@"detail"] isEqualToString:@"twitter"]) {
//            NSLog(@"twitter tapped tho %@",[content objectForKey:@"text"]);
//            [self openTwitter:[content objectForKey:@"text"]];
//        }
//        else if ([[content objectForKey:@"detail"] isEqualToString:@"homepage url"]){
//            [self performSegueWithIdentifier:@"web" sender:self];
//        }
//    }
//    else if([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"degrees"] || [[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"funds"]){
//        
//    }
//    else if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"offices"] || [[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"headquarters"] || [[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"primary location"]){
//        [self performSegueWithIdentifier:@"map" sender:self];
//        
//    }
//    else if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"news"]){
//        [self performSegueWithIdentifier:@"web" sender:self];
//    }
//    else if ([[crunch getSectionAtIndex:(int)indexPath.section] isEqualToString:@"websites"]){
//        [self performSegueWithIdentifier:@"web" sender:self];
//    }
//    else if([[crunch permalinkatIndexPath:indexPath] length] > 0){
//        DetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
//        NSMutableDictionary* object = [[NSMutableDictionary alloc] init];
//        
//        [self.navigationController pushViewController:detail animated:YES];
//        
//        [object setObject:[crunch permalinkatIndexPath:indexPath] forKey:@"permalink"];
//        
//        [detail setDetailItem:object];
//    }
//    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    
//}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *content = [crunch getContentAtIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"MyIdentifier";
    UILabel *pastLabel;
    UIImageView *imgView;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
            pastLabel.font = [self.updatedLabel.font fontWithSize:13.0f];
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
        cell.textLabel.font = [self.updatedLabel.font fontWithSize:14.0f];
        cell.textLabel.numberOfLines = 2;
    }
    cell.textLabel.font = [self.updatedLabel.font fontWithSize:14.0f];
    cell.detailTextLabel.font = [self.updatedLabel.font fontWithSize:14.0f];
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    
    cell.textLabel.text = [content objectForKey:@"text"];
    cell.detailTextLabel.text = [content objectForKey:@"detail"];
    
    cell.imageView.image = nil;
    if (indexPath.section > 0 && [content objectForKey:@"image"]) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[content objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"profile-image"]];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
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


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    // Check the kind if it's CSStickyHeaderParallaxHeader
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        
        UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        
        return cell;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        // Your code to configure your section header...
    } else {
        // other custom supplementary views
    }
    return nil;
}

- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section{
    // Check the kind if it's CSStickyHeaderParallaxHeader
    if (section == 0) {
        
        UITableViewHeaderFooterView *cell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
        return cell;
        
    }
    return nil;
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






#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //    NSLog(@"carousel total count %lu", (unsigned long)self.items.count);
    //return the total number of items in the carousel
    
    return [[crunch getFounders] count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *imageFounder = nil;
    NSDictionary *founder = [crunch getFounders][index];
    
    NSString *path = founder[@"path"];
    NSString *imageString = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",path];
    
    NSURL *imageUrl = [NSURL URLWithString:imageString];
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45.0f, 45.0f)];
        imageFounder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45.0f, 45.0f)];
        imageFounder.backgroundColor = [UIColor whiteColor];
        imageFounder.tag = 2;
        imageFounder.contentMode = UIViewContentModeScaleAspectFit;
        imageFounder.layer.masksToBounds = YES;
        imageFounder.clipsToBounds = YES;
        imageFounder.layer.cornerRadius = imageFounder.frame.size.height /2;
        
        
        [view addSubview:imageFounder];
        
        CGRect frame = imageFounder.bounds;
        
        frame.origin.y += 35;
        
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [self.updatedLabel.font fontWithSize:11];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        imageFounder = (UIImageView *)[view viewWithTag:2];
    }

    
    label.text = founder[@"name"];
    
    [imageFounder sd_setImageWithURL:imageUrl placeholderImage:nil];

    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1;
    }
    return value;
}

//- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
//    self.selectedObject = self.items[index];
//    [self performSegueWithIdentifier:@"detailView" sender:self];
//}

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
    initialFrame = CGRectMake(0, 0, 320, 300);
    labelFrame = CGRectMake(0, 0, 50, 300);
    
    float yVal = scrollView.contentOffset.y + 64;
    
    if (yVal < 0) {
        
        initialFrame.size.height -= yVal;
        
        self.tableHeaderView.frame = initialFrame;
        
        NSLog(@"y center at %f",self.tableHeaderView.center.y);
    }
}

- (void) swipedDown:(UISwipeGestureRecognizer*)swipeGesture {
            NSLog(@"swiping down %@",swipeGesture);
    // action
}



@end
