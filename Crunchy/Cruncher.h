//
//  Cruncher.h
//  CrunchBase Mobile V2
//
//  Created by Mac5 on 13-08-08.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cruncher : NSObject
typedef enum ItemType : NSUInteger {
    Product,
    Company,
    Person,
    Provider,
    None
} ItemType;


- (id) initWithDictionary: (NSMutableDictionary *) dict;
- (BOOL) isNull:(NSString *) key;
- (NSString *) getValue: (NSString *) key;

- (NSString *)permalinkatIndexPath:(NSIndexPath *)index;
- (BOOL) linkAtIndex: (NSIndexPath*) index;
- (NSString *) getDateFor: (NSString *) prep forKey: (NSString *) key andRow: (int) row;
- (NSString *) getDateFormatForDay:(NSString *)strDay andMonth:(NSString *) strMonth andYear:(NSString*) strYear;
- (NSString *) getDateFor: (NSString *) prep fromObject: (NSMutableDictionary *) obj;
- (NSString *) titlizeString:(NSString *) title;
- (int) getSizeAtSection:(NSInteger) section;
- (int) getSectionsCount;
- (NSString *) getSectionAtIndex: (int) index;
- (NSMutableDictionary *)getContentAtIndexPath:(NSIndexPath *)index;
- (BOOL) isAcquired;
- (NSString *) getAcquiredInfo;

- (NSString *) getImage: (BOOL) small;
- (NSString *) getOverview;
- (NSString *) getTitle;

+ (NSString *) userKey;
+ (NSString *) crunchBaseURL;
+ (NSURL *) crunchBaseURLForPath:(NSString *)path;

- (NSString *) getShorDescription;

- (NSArray *) getFounders;
@end
