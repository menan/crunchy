//
//  CSInfoCell.m
//  Crunchy
//
//  Created by Mac5 on 2015-01-22.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import "CSInfoCell.h"
#import "UIImageView+WebCache.h"

@implementation CSInfoCell



#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //    NSLog(@"carousel total count %lu", (unsigned long)self.items.count);
    //return the total number of items in the carousel
    
    return [self.foundersData count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *imageFounder = nil;
    NSDictionary *founder = self.foundersData[index];
    
    NSString *path = founder[@"path"];
    NSString *imageString = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",path];
    
    NSURL *imageUrl = [NSURL URLWithString:imageString];
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45.0f, 45.0f)];
        imageFounder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45.0f, 45.0f)];
        imageFounder.backgroundColor = [UIColor whiteColor];
        imageFounder.tag = 2;
        imageFounder.contentMode = UIViewContentModeScaleAspectFit;
        imageFounder.layer.masksToBounds = YES;
        imageFounder.clipsToBounds = YES;
        imageFounder.layer.cornerRadius = imageFounder.frame.size.height /2;
        
        
        [view addSubview:imageFounder];
        
        CGRect frame = imageFounder.bounds;
        
        frame.origin.y += 35;
        
        label = [[UILabel alloc] initWithFrame:frame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [self.shortDescription.font fontWithSize:11];
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
    
    
    label.text = founder[@"name"];
    
    [imageFounder sd_setImageWithURL:imageUrl placeholderImage:nil];
    
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
