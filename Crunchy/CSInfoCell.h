//
//  CSInfoCell.h
//  Crunchy
//
//  Created by Mac5 on 2015-01-22.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "iCarousel.h"
#import "Cruncher.h"


@interface CSInfoCell : UICollectionViewCell<iCarouselDataSource, iCarouselDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *shortDescription;
@property (weak, nonatomic) IBOutlet iCarousel *founders;
@property (weak, nonatomic) IBOutlet UIButton *viewAllButton;
@property (strong, nonatomic) NSArray *foundersData;
@property (strong, nonatomic) Cruncher *crunchy;

- (void) updateLocation:(NSArray *) addresses;
@end
