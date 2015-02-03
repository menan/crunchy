//
//  EntityViewCollectionController.m
//  Crunchy
//
//  Created by Mac5 on 2015-01-21.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import "EntityViewCollectionController.h"
#import "CSCell.h"
#import "CSInfoCell.h"
#import "CSStickyHeaderFlowLayout.h"
#import "AFJSONRequestOperation.h"
#import "Cruncher.h"
#import "UIImageView+WebCache.h"

@interface EntityViewCollectionController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) UINib *headerNib;
@property (strong, nonatomic) Cruncher *crunch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation EntityViewCollectionController

NSArray *relationships;
static NSString * const reuseIdentifier = @"Cell";


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
    
    [self loadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.collectionView setBackgroundView:
     [[UIImageView alloc] initWithImage:
      [UIImage imageNamed:@"crunchy-bg"]]];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Hero" size:18.0f],
      NSFontAttributeName, nil]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{UITextAttributeFont:[UIFont fontWithName:@"Hero" size:20.0f]
       } forState:UIControlStateNormal];
    
    
    relationships = [NSArray new];
    
    
    // Locate your layout
    CSStickyHeaderFlowLayout *layout = (id)self.collectionViewLayout;
    
    if ([layout isKindOfClass:[CSStickyHeaderFlowLayout class]]) {
        layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.size.width, 300);
        layout.itemSize = CGSizeMake(self.view.frame.size.width, layout.itemSize.height);
    }
    

    
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = self.imageView.frame.size.height /2;
    
    // Setting the minimum size equal to the reference size results
    // in disabled parallax effect and pushes up while scrolls
    layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(self.view.frame.size.width, 250);
    
    
//    layout.disableStickyHeaders = YES;
//    
//    // Also insets the scroll indicator so it appears below the search bar
//    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(200, 0, 0, 0);
    
    
    
    // Locate the nib and register it to your collection view
    UINib *headerNib = [UINib nibWithNibName:@"InfoView" bundle:nil];
    [self.collectionView registerNib:headerNib
          forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                 withReuseIdentifier:@"header"];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) loadData{
    
    if (self.detailItem) {
        NSString *name = self.detailItem[@"name"];
        NSLog(@"title:%@",name);
        self.title = name;
        
        item = [[NSMutableDictionary alloc] init];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[Cruncher crunchBaseURLForPath:self.detailItem[@"path"]]];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
        [self readObject:JSON[@"data"]];
            
        } failure:nil];
        [operation start];
        
    }
}


- (void) readObject:(NSMutableDictionary *) data{
    self.crunch = [[Cruncher alloc] initWithDictionary:data];
    
    [self.collectionView reloadData];
    
    relationships = [self.crunch getRelationships];
    
    NSString* image_url = [self.crunch getImage:NO];
    
    NSURL *url = [NSURL URLWithString:image_url];
    //    NSLog(@"image url :%@",image_url);
    UIImage *img = [UIImage imageNamed:@"aimage.png"];
    [self.imageView sd_setImageWithURL:url placeholderImage:img];
    
    self.title = [self.crunch getTitle];
    
    
}

#pragma mark <UICollectionViewDataSource>


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [relationships count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                             forIndexPath:indexPath];
//    NSLog(@"section: %ld",(long)indexPath.section);
    if (cell.crunchy == nil) {
        cell.carousel.tag = indexPath.section;
        cell.carousel.centerItemWhenSelected = NO;
//        cell.carousel.contentOffset = CGSizeMake(-100, 10);
//        cell.carousel.decelerationRate = 1;
//        cell.carousel.bounceDistance = 0.1f;
//        cell.carousel.pagingEnabled = YES;

        cell.crunchy = self.crunch;
        [cell.carousel reloadData];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    // Check the kind if it's CSStickyHeaderParallaxHeader
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        
        CSInfoCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"header"
                                                                                   forIndexPath:indexPath];
        
        
        cell.foundersData = [self.crunch getFounders];
        
        cell.founders.viewpointOffset = CGSizeMake(130, 0);
        
        [cell updateLocation:[self.crunch getAddressData]];
        
        
        
        
        
        [cell.founders reloadData];
        cell.shortDescription.text = [self.crunch getShorDescription];
        return cell;
    } else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        //         Your code to configure your section header...

        CSCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"sectionHeader"
                                                                forIndexPath:indexPath];
        
        cell.carousel.tag = indexPath.section;
        cell.titleLabel.text = [self.crunch getTitleAtIndex:indexPath.section];
        cell.totalItemsCount.text = [@([self.crunch getContentCountAtIndex:indexPath.section]) stringValue];
        
        
        cell.crunchy = self.crunch;
        [cell.carousel reloadData];
        
        
        cell.layer.borderWidth=0.5f;
        cell.layer.borderColor=[UIColor whiteColor].CGColor;
        
        return cell;
        
    }  else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        //         Your code to configure your section header...
//        NSDictionary *obj = self.sections[indexPath.section];
        CSCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                          withReuseIdentifier:@"sectionFooter"
                                                                 forIndexPath:indexPath];
        
        cell.layer.borderWidth=0.5f;
        cell.layer.borderColor=[UIColor whiteColor].CGColor;

        cell.carousel.tag = indexPath.section;
        return cell;
        
    } else {
        // other custom supplementary views
        
    }
    return nil;
}






@end
