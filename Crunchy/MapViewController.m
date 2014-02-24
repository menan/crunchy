//
//  MapViewController.m
//  Crunchy
//
//  Created by Mac5 on 2/17/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import "MapViewController.h"
#import "OfficeAnnotation.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize address,company;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"location: %@",address);
    NSString *addressLocal = address;
    [self.mapview setDelegate:self];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:address // You can pass aLocation here instead
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       dispatch_async(dispatch_get_main_queue(),^ {
                           // do stuff with placemarks on the main thread
                           
                           if (placemarks.count == 1) {
                               
                               CLPlacemark *place = [placemarks objectAtIndex:0];
                               NSLog(@"placemark: %@",[place addressDictionary]);
                               
                               float spanX = 0.01725;
                               float spanY = 0.01725;
                               MKCoordinateRegion region;
                               region.center.latitude = place.location.coordinate.latitude;
                               region.center.longitude = place.location.coordinate.longitude;
                               region.span = MKCoordinateSpanMake(spanX, spanY);
                               
                               OfficeAnnotation *aView = [[OfficeAnnotation alloc] init];
                               aView.coordinate = place.location.coordinate;
                               aView.title = company;
                               NSLog(@"address: %@",addressLocal);
                               aView.subtitle = addressLocal;
                               [self.mapview setRegion:region animated:YES];
                               [self.mapview addAnnotation:aView];
                               
                           }
                           
                       });
                       
                   }];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
