//
//  CSCell.m
//  Crunchy
//
//  Created by Mac5 on 2015-01-21.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import "CSCell.h"
#import "UIImageView+WebCache.h"

@implementation CSCell


//#pragma mark -
//#pragma mark iCarousel methods
//
//- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
//{
//    NSInteger contentSize = [self.crunchy getContentCountAtIndex:carousel.tag];
//    
//    CSCell *cell = (CSCell *) carousel.superview.superview;
//    UICollectionView *collectionView = (UICollectionView *)  carousel.superview.superview.superview;
////    NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
//    
////    NSLog(@"carousel size %ld at %ld %@ %@",contentSize,carousel.tag, self.crunchy,indexPath);
//    return contentSize;
//}
//
//- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
//{
//    UILabel *label = nil;
//    UIImageView *imageData = nil;
//    NSDictionary *data = [self.crunchy dataAtIndex:carousel.tag][index];
//    
//    CSCell *cell = (CSCell *) carousel.superview.superview;
//    UICollectionView *collectionView = (UICollectionView *)  carousel.superview.superview.superview;
////    NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
//    
//    NSLog(@"collection view is :%@ : %@",self.crunchy,self.titleLabel.text);
//    
//    NSString *path = data[@"path"];
//    NSString *imageString = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",path];
//    
////    NSURL *imageUrl = [NSURL URLWithString:imageString];
//    
//    //create new view if no view is available for recycling
//    if (view == nil)
//    {        
//        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,75.0f, 75.0f)];
//        imageData = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5.0f, 60.0f, 60.0f)];
//        imageData.backgroundColor = [UIColor whiteColor];
//        imageData.tag = 2;
//        imageData.alpha = 0.0f;
//        imageData.contentMode = UIViewContentModeScaleAspectFit;
//        imageData.layer.masksToBounds = YES;
//        imageData.clipsToBounds = YES;
//        imageData.layer.cornerRadius = imageData.frame.size.height /2;
//        
//        
//        [view addSubview:imageData];
//        
//        CGRect frame = imageData.bounds;
//        
//        frame.origin.y += 55;
//        frame.origin.x -= 5;
//        frame.size.width += 15;
//        
//        label = [[UILabel alloc] initWithFrame:frame];
//        label.backgroundColor = [UIColor clearColor];
//        label.font = [UIFont fontWithName:@"Hero" size:13.0f];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = [UIColor whiteColor];
//        label.minimumScaleFactor = .5;
//        label.tag = 1;
//        [view addSubview:label];
//    }
//    else
//    {
//        //get a reference to the label in the recycled view
//        label = (UILabel *)[view viewWithTag:1];
//        imageData = (UIImageView *)[view viewWithTag:2];
//    }
//    
//    
//    label.text = [self getName:data];
//    

//    [imageFounder sd_setImageWithURL:imageUrl placeholderImage:nil];
//    NSLog(@"gonna load image from %@",imageString);
//    [imageData sd_setImageWithURL:imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
////        NSLog(@"image loaded");
//        if (image != nil) {
//            imageData.image = image;
//            [UIView animateWithDuration:0.2 animations:^(void) {
//                imageData.alpha = 1.0f;
//            }];
//        }
//        else{
//            imageData.image = [UIImage imageNamed:@"profile-image"];
//            [UIView animateWithDuration:0.2 animations:^(void) {
//                imageData.alpha = 1.0f;
//            }];
////            NSLog(@"error loading image from %@ => %@",imageURL, [error localizedDescription]);
//        }
//    }];
//    
//    
//    return view;
//}

- (NSString *) getName:(NSDictionary *) data{
    if (data[@"first_name"] && data[@"last_name"])
        return [NSString stringWithFormat:@"%@ %@.",data[@"first_name"],[data[@"last_name"] substringWithRange:NSMakeRange(0, 1)]];
    else if (data[@"name"])
        return data[@"name"];
    else
        return @"N/A";
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1;
    }
    return value;
}


@end
