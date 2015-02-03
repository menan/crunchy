//
//  CSInfoCell.m
//  Crunchy
//
//  Created by Mac5 on 2015-01-22.
//  Copyright (c) 2015 Menan Vadivel. All rights reserved.
//

#import "CSInfoCell.h"
#import "UIImageView+WebCache.h"
#import "OfficeAnnotation.h"

@implementation CSInfoCell


- (void) updateLocation:(NSArray *) addresses{
    
    [self.mapView setDelegate:self];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    for (NSDictionary *addressData in addresses) {
        
        NSLog(@"address: %@ on %@",addressData[@"location"], addressData[@"title"]);
        [geocoder geocodeAddressString:addressData[@"location"] // You can pass aLocation here instead
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     
//                     dispatch_async(dispatch_get_main_queue(),^ {
                         // do stuff with placemarks on the main thread
                         
//                         if (placemarks.count == 1) {
                     
                             CLPlacemark *place = [placemarks objectAtIndex:0];
                             float spanX = 0.01725;
                             float spanY = 0.01725;
                             MKCoordinateRegion region;
                             region.center.latitude = place.location.coordinate.latitude;
                             region.center.longitude = place.location.coordinate.longitude;
                             region.span = MKCoordinateSpanMake(spanX, spanY);
                             
                             OfficeAnnotation *aView = [[OfficeAnnotation alloc] init];
                             aView.coordinate = place.location.coordinate;
                             aView.title = addressData[@"name"];
                             aView.subtitle = addressData[@"subtitle"];
                             [self.mapView setRegion:region animated:YES];
                             [self.mapView addAnnotation:aView];
                             
//                         }
                     
//                     });
                     
                 }];
    }
}


#pragma mark -
#pragma mark MKAnnotationView methods

- (MKAnnotationView *)mapView:(MKMapView *)mapViewThis
            viewForAnnotation:(id  <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapViewThis dequeueReusableAnnotationViewWithIdentifier:@","];
    pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
    
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    pinView.canShowCallout=YES;
    
    return pinView;
}


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
    
    
    label.text = [founder[@"name"] componentsSeparatedByString:@" "][0];
    
    [imageFounder sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"profile-image"]];
    
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
