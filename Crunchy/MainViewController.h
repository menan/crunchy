//
//  MainViewController.h
//  Crunchy
//
//  Created by Menan Vadivel on 2015-01-10.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface MainViewController : UIViewController<UISearchBarDelegate,iCarouselDataSource, iCarouselDelegate,UITableViewDelegate, UITableViewDataSource>

@end
