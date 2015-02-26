//
//  EntityViewCollectionController.h
//  Crunchy
//
//  Created by Mac5 on 2015-01-21.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntityViewCollectionController : UICollectionViewController{
    NSMutableDictionary * item;
}

- (void) setBarImage:(UIImage *) image;

@property (strong, nonatomic) id detailItem;

@end
