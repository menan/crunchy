//
//  OfficeAnnotation.h
//  Crunchy
//
//  Created by Menan Vadivel on 2/20/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface OfficeAnnotation : NSObject<MKAnnotation>{
    
    NSString *title;
    NSString *subtitle;
    NSString *note;
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;


@end
