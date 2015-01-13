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

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *crunchy;
@property (weak, nonatomic) IBOutlet UILabel *tinritLabs;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UILabel *fontLabel;

@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation MainViewController

- (void)viewDidLoad {
    
    self.items = [NSMutableArray array];
    
    [self getRecentlyUpdated];
    
    self.carousel.type = iCarouselTypeLinear;
    
    [self.carousel reloadData];
    
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

    
    
    // Create and initialize a tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    // Specify that the gesture must be a single tap
    tapRecognizer.numberOfTapsRequired = 1;
    // Add the tap gesture recognizer to the view
    [self.view addGestureRecognizer:tapRecognizer];
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleBlackTranslucent;
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
    NSLog(@"just started editing");
    
    [UIView animateWithDuration:0.30
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.crunchy.alpha = 0.0f;
                         self.tinritLabs.alpha = 0.0f;
                         
                         self.searchLabel.transform = CGAffineTransformMakeTranslation( 0, -235.0f);
                         self.searchBar.transform = CGAffineTransformMakeTranslation( 0, -235.0f);
                         NSLog(@"new frame y: %f",self.searchBar.frame.origin.y);
                     }
                     completion:nil];
    
    //do stuff
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)thisSearchBar {
    NSLog(@"just finished editing");
    
    
    [UIView animateWithDuration:0.30
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.crunchy.alpha = 1.0f;
                         self.tinritLabs.alpha = 1.0f;
                         
                         self.searchLabel.transform = CGAffineTransformMakeTranslation( 0, 0);
                         self.searchBar.transform = CGAffineTransformMakeTranslation( 0, 0);
                         NSLog(@"new frame y: %f",self.searchBar.frame.origin.y);
                     }
                     completion:nil];
    
    
    //do stuff
    return YES;
}



- (void) getRecentlyUpdated{
    
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
    NSString* url = [[NSString stringWithFormat:@"%@/organizations?order=updated_at desc&user_key=%@", [Cruncher crunchBaseURL], [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
//                NSLog(@"recent data JSON: %@", data);
        
        self.items = data[@"data"][@"items"];
        
        [self.carousel reloadData];
        
        
        
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"error: %@", [error userInfo]);
//                                                                                            [loading stopAnimating];
                                                                                            
                                                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                                                                                            message:@"Unable to connect to the server."
                                                                                                                                           delegate:self
                                                                                                                                  cancelButtonTitle:@"OK"
                                                                                                                                  otherButtonTitles:nil];
                                                                                            [alert show];
                                                                                        }];
    [operation start];
    
    
}




#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSLog(@"carousel total count %lu", (unsigned long)self.items.count);
    //return the total number of items in the carousel
    return self.items.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        
        NSString *path = self.items[index][@"path"];
        NSString *imageString = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",path];
        
        NSURL *image_url = [NSURL URLWithString:imageString];
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75.0f, 75.0f)];
        [(UIImageView *)view sd_setImageWithURL:image_url placeholderImage:nil];
        
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        view.layer.cornerRadius = 45;
        
        CGRect frame = view.bounds;
        
        frame.origin.y += 50;
        
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [self.fontLabel.font fontWithSize:12];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = self.items[index][@"name"];
//    NSLog(@"carousel reading %@", self.items[index]);
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



@end
