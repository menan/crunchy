//
//  MainViewController.m
//  Crunchy
//
//  Created by Menan Vadivel on 2015-01-10.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import "MainViewController.h"
#import "Cruncher.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "EntityViewCollectionController.h"
#import "EntityURLRequest.h"


@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *crunchy;
@property (weak, nonatomic) IBOutlet UILabel *tinritLabs;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UILabel *fontLabel;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteAuthor;
@property (weak, nonatomic) UIImage *imageNavigationBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *objects;
@property (strong, nonatomic) NSMutableDictionary *imagesPaths;
@property (nonatomic, strong) NSDictionary *selectedObject;

@property (nonatomic, strong) Cruncher *crunch;
@end

@implementation MainViewController

BOOL searching = NO;

- (void)viewDidLoad {

    
    self.items = [NSMutableArray array];
    self.imagesPaths = [NSMutableDictionary new];
    self.crunch = [[Cruncher alloc] init];
    
    [self getRecentlyUpdated];
    
    self.carousel.type = iCarouselTypeLinear;
    
    self.buttonDone.alpha = 0.0f;
    
    for (id object in [[[self.searchBar subviews] objectAtIndex:0] subviews])
    {
        if ([object isKindOfClass:[UITextField class]])
        {
            UITextField *textFieldObject = (UITextField *)object;
            
            textFieldObject.textColor = [UIColor whiteColor];
            textFieldObject.layer.borderColor = [[UIColor whiteColor] CGColor];
            textFieldObject.layer.borderWidth = 1.0;
            textFieldObject.layer.cornerRadius = 4.0;
            break;
        }
    }
    
    self.tableView.rowHeight = 55;
    self.tableView.separatorColor = [UIColor whiteColor];
    
    self.imageNavigationBar = [self.navigationController.navigationBar shadowImage];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
//
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) respondToTapGesture:(id) sender{
//    NSLog(@"gesture received");
    [self.searchBar resignFirstResponder];
}

#pragma UISearchBar Delegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)thisSearchBar {
    [self showSearchView];
    searching = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)thisSearchBar {
    [self hideSearchView];
    return YES;
}



- (void) getRecentlyUpdated{
    
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSString* url = [[NSString stringWithFormat:@"%@/organizations?order=updated_at desc&user_key=%@", [Cruncher crunchBaseURL], [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    EntityURLRequest *request = [EntityURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
//                                                                                            NSLog(@"request : %@",request);
                                                                                            self.items = data[@"data"][@"items"];
                                                                                            [self.carousel reloadData];
                                                                                            [self.activityView stopAnimating];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"error: %@", [error userInfo]);
                                                                                            [self.activityView stopAnimating];
                                                                                            
                                                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                                                                                            message:@"Unable to connect to the server."
                                                                                                                                           delegate:self
                                                                                                                                  cancelButtonTitle:@"OK"
                                                                                                                                  otherButtonTitles:nil];
                                                                                            [alert show];
                                                                                        }];
    [operation start];
    
    
}


- (void) showSearchView{
    
    if (!searching) {
        self.tableView.alpha = 0.0f;
        self.tableView.hidden = NO;
        
        [UIView animateWithDuration:0.2
                              delay:0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.tinritLabs.alpha = 0.0f;
                             self.carousel.alpha = 0.0f;
                             self.searchLabel.alpha = 0.0f;
                             
                             self.quoteAuthor.alpha = 0.0f;
                             self.quoteLabel.alpha = 0.0f;
                             
                             self.buttonDone.alpha = 1.0f;
                             
                             self.tableView.alpha = 1.0f;
                             self.tableView.transform = CGAffineTransformMakeTranslation( 0, 105.0f);
                             
                             
                             CGAffineTransform transform = CGAffineTransformMakeScale(.5, .5);
                             transform = CGAffineTransformTranslate(transform, 0, -155.0f);
                             self.crunchy.transform = transform;
//                             self.crunchy.textColor = [UIColor blackColor];
                             
                             
                             self.searchBar.transform = CGAffineTransformMakeTranslation( 0, -175.0f);
                             //                         NSLog(@"new frame y: %f",self.searchBar.frame.origin.y);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void) hideSearchView{
    
    if (!searching) {
        
        [UIView animateWithDuration:0.2
                              delay:0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.crunchy.alpha = 1.0f;
                             self.tinritLabs.alpha = 1.0f;
                             self.carousel.alpha = 1.0f;
                             
                             
                             self.quoteAuthor.alpha = 0.5f;
                             self.quoteLabel.alpha = 0.8f;
                             
                             self.buttonDone.alpha = 0.0f;
                             
                             self.tableView.transform = CGAffineTransformMakeTranslation( 0, 0);
                             self.tableView.alpha = 0.0f;
                             
                             self.searchLabel.alpha = 1.0f;
                             
                             CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
                             transform = CGAffineTransformTranslate(transform, 0, 0);
                             self.crunchy.transform = transform;
                             self.crunchy.textColor = [UIColor whiteColor];
                             
                             
                             self.searchBar.transform = CGAffineTransformMakeTranslation( 0, 0);
                             //                         NSLog(@"new frame y: %f",self.searchBar.frame.origin.y);
                         }
                         completion:^(BOOL finished) {
                             self.tableView.hidden = YES;
                         }];
    }
}




-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}


- (void) parseData: (NSDictionary *) data{
    
    [self.activityView stopAnimating];
    self.tableView.allowsSelection = YES;
    NSMutableDictionary* item = [[NSMutableDictionary alloc] init];
    self.objects = [[NSMutableArray alloc] init];
    
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
            [item setObject:path forKey:@"path"];
            [item setObject:[NSString stringWithFormat:@"%@/%@?",[Cruncher crunchBaseURL], path] forKey:@"permalink"];
            
            [self.objects addObject:[item copy]];
        }
    }
    [self.tableView reloadData];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)uiSearchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSString* url = [[NSString stringWithFormat:@"%@/organizations?query=%@&user_key=%@", [Cruncher crunchBaseURL], uiSearchBar.text, [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.activityView startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                                                                                            NSLog(@"Read JSON: %@", JSON);
                                                                                            [self parseData:JSON];
                                                                                            [self.activityView stopAnimating];
                                                                                            
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"error: %@", [error userInfo]);
                                                                                            
                                                                                            [self.activityView stopAnimating];
                                                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                                                                                            message:@"Unable to connect to the server."
                                                                                                                                           delegate:self
                                                                                                                                  cancelButtonTitle:@"OK"
                                                                                                                                  otherButtonTitles:nil];
                                                                                            [alert show];
                                                                                        }];
    [operation start];
    
    searching = YES;
    
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    self.tableView.allowsSelection = NO;
    
    [self.objects removeAllObjects];
    [self.tableView reloadData];
    
    
}


- (IBAction)doneButtonTapped:(id)sender {
    searching = NO;
    [self.searchBar resignFirstResponder];
    [self hideSearchView];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 45, 45)];
        imgView.tag = 10;
        imgView.image = nil;
        imgView.backgroundColor = [UIColor whiteColor];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.layer.masksToBounds = YES;
        imgView.clipsToBounds = YES;
        imgView.layer.cornerRadius = imgView.frame.size.height /2;
        
        [cell.contentView addSubview:imgView];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.rowHeight + 25, 10, cell.bounds.size.width - 100, 30)];
        label.textColor = [UIColor whiteColor];
        label.font = [self.fontLabel.font fontWithSize:15];
        
        label.numberOfLines = 2;
        label.tag = 11;
        label.backgroundColor = nil;
        label.opaque = NO;
        [cell.contentView addSubview:label];
        
        // set selection color
        UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
        myBackView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        cell.selectedBackgroundView = myBackView;
    }
    
    int storyIndex = (int) [indexPath indexAtPosition: [indexPath length] - 1];
    NSString * urlString = _objects[storyIndex][@"image_large"];

    
    NSURL *url = [NSURL URLWithString:urlString];
    
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:10];
    [imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile-image"]];
    
    UILabel *labelTitle = (UILabel *)[cell.contentView viewWithTag:11];
    labelTitle.text = _objects[storyIndex][@"name"];
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell.
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"whats up bro");
    self.selectedObject = _objects[indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"detailView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"detailView"] && self.selectedObject) {
        [[segue destinationViewController] setBarImage:self.imageNavigationBar];
        [[segue destinationViewController] setDetailItem:self.selectedObject];
    }
    
}

//- (void) setImageFromPath: (NSString *)path forImageView:(UIImageView *) imgView{
//    NSString* url = [[NSString stringWithFormat:@"%@/%@/primary_image?user_key=%@", [Cruncher crunchBaseURL], path, [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    if (!self.imagesPaths[path]) {
//        EntityURLRequest *request = [[EntityURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
//        request.imageView = imgView;
//        request.path = path;
//        
//        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
//                EntityURLRequest *thisRequest = (EntityURLRequest*) request;
//                NSString *stringURL = [NSString stringWithFormat:@"%@%@",data[@"metadata"][@"image_path_prefix"],data[@"data"][@"items"][0][@"path"]];
//                
//                NSURL *urlImage = [NSURL URLWithString:stringURL];
//                
//                [self.imagesPaths setObject:urlImage forKey:thisRequest.path];
//                
//                
//                [thisRequest.imageView sd_setImageWithURL:urlImage placeholderImage:[UIImage imageNamed:@"profile-image"]];
//                
//            }
//            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                NSLog(@"error: %@ : %@",path, [error localizedDescription]);
//                
//                EntityURLRequest *thisRequest = (EntityURLRequest*) request;
//                [self.imagesPaths setObject:[NSURL URLWithString:@""] forKey:thisRequest.path];
//                
//                thisRequest.imageView.image = [UIImage imageNamed:@"profile-image"];
//           }];
//        [operation start];
//        
//    }
//    else{
//        
//        [imgView sd_setImageWithURL:self.imagesPaths[path] placeholderImage:[UIImage imageNamed:@"profile-image"]];
//    }
//    
//}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
//    NSLog(@"carousel total count %lu", (unsigned long)self.items.count);
    //return the total number of items in the carousel
    int max = 20;
    if (self.items.count > max)
        return max;
    return self.items.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *imageView = nil;
    
    NSString *path = self.items[index][@"path"];
    
    
//    NSString *imageString = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150&user_key=%@",path,[Cruncher userKey]];
    
//    NSURL *image_url = [NSURL URLWithString:imageString];
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75.0f, 75.0f)];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75.0f, 75.0f)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.tag = 2;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.height/2;
        
        
        [view addSubview:imageView];
        
        CGRect frame = imageView.bounds;
        
        frame.origin.y += 50;
        
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [self.fontLabel.font fontWithSize:11];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        imageView = (UIImageView *)[view viewWithTag:2];
    }
    
    [self.crunch setImageFromPath:path forImageView:imageView];
    
    label.text = self.items[index][@"name"];
    
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

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    self.selectedObject = self.items[index];
    [self performSegueWithIdentifier:@"detailView" sender:self];
}


@end
