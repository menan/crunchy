//
//  EntityViewController.h
//  Crunchy
//
//  Created by Mac5 on 2015-01-15.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cruncher.h"
#import <iAd/iAd.h>
#import "iCarousel.h"


@interface EntityViewController : UITableViewController<iCarouselDataSource, iCarouselDelegate>{
    NSMutableDictionary * item;
}


@property (strong, nonatomic) id detailItem;
- (void)configureView;
@end
