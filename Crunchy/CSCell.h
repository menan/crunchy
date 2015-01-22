//
//  CSCell.h
//  Crunchy
//
//  Created by Mac5 on 2015-01-21.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "Cruncher.h"

@interface CSCell : UICollectionViewCell<iCarouselDataSource, iCarouselDelegate>
@property (weak, nonatomic) IBOutlet UILabel *totalItemsCount;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIButton *viewAllButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) Cruncher *crunchy;
@end
