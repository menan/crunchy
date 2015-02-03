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


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    NSInteger contentSize = [self.crunchy getContentCountAtIndex:carousel.tag];
//    NSLog(@"carousel size %ld at %ld",contentSize,carousel.tag);
    return contentSize;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *imageFounder = nil;
    NSDictionary *data = [self.crunchy dataAtIndex:carousel.tag][index];
    
//    NSLog(@"showing data at :%@",data);
    
    NSString *path = data[@"path"];
    NSString *imageString = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",path];
    
    NSURL *imageUrl = [NSURL URLWithString:imageString];
    
    //create new view if no view is available for recycling
    if (view == nil)
    {        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,75.0f, 75.0f)];
        imageFounder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70.0f, 70.0f)];
        imageFounder.backgroundColor = [UIColor whiteColor];
        imageFounder.tag = 2;
        imageFounder.alpha = 0.0f;
        imageFounder.contentMode = UIViewContentModeScaleAspectFit;
        imageFounder.layer.masksToBounds = YES;
        imageFounder.clipsToBounds = YES;
        imageFounder.layer.cornerRadius = imageFounder.frame.size.height /2;
        
        
        [view addSubview:imageFounder];
        
        CGRect frame = imageFounder.bounds;
        
        frame.origin.y += 55;
        
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Hero" size:13.0f];
        label.textAlignment = NSTextAlignmentCenter;
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
    
    
    label.text = [self getName:data];
    
    
//    [imageFounder sd_setImageWithURL:imageUrl placeholderImage:nil];
    NSLog(@"gonna load image from %@",imageString);
    [imageFounder sd_setImageWithURL:imageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        NSLog(@"image loaded");
        if (image != nil) {
            imageFounder.image = image;
            [UIView animateWithDuration:0.2 animations:^(void) {
                imageFounder.alpha = 1.0f;
            }];
        }
        else{
            imageFounder.image = [UIImage imageNamed:@"profile-image"];
            [UIView animateWithDuration:0.2 animations:^(void) {
                imageFounder.alpha = 1.0f;
            }];
            NSLog(@"error loading image from %@ => %@",imageURL, [error localizedDescription]);
        }
    }];
    
    
    return view;
}

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
