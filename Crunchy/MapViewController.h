//
//  MapViewController.h
//  Crunchy
//
//  Created by Mac5 on 2/17/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
@property (weak, nonatomic) NSString *address;
@property (weak, nonatomic) NSString *company;

@end
