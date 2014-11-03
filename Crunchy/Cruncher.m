//
//  Cruncher.m
//  CrunchBase Mobile V2
//
//  Created by Mac5 on 13-08-08.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import "Cruncher.h"
#import "NSString+HTML.h"

@implementation Cruncher

ItemType type = Company;
#define MAX_DATA 50

NSMutableDictionary *item;
NSMutableDictionary *relationships;
NSMutableArray *sections;
NSMutableArray *infoSections;

+ (NSString *) userKey{
    return @"00aba8c514f4e90b191bafe88ce9fceb";
}

+ (NSString *) crunchBaseURL{
    return @"http://api.crunchbase.com/v/2";
}

- (id) initWithDictionary: (NSMutableDictionary *) dict{
    item = [[NSMutableDictionary alloc] initWithDictionary:dict];
    relationships = [[NSMutableDictionary alloc] initWithDictionary:dict[@"relationships"]];
    
    NSMutableDictionary* gi = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    infoSections = [[NSMutableArray alloc] init];
    
    
    
    if (![self isNull:@"homepage_url"]){
        
        [gi setValue:item[@"properties"][@"homepage_url"] forKey:@"url"];
        [infoSections addObject:@"url"];
    }
    
    if (![self isNull:@"founded_on"]){
        
        [gi setValue:item[@"properties"][@"founded_on"] forKey:@"founded on"];
        [infoSections addObject:@"founded on"];
    }
    
    if (![self isNull:@"closed_on_year"]){
        
        [gi setValue:item[@"properties"][@"closed_on_year"] forKey:@"closed on"];
        [infoSections addObject:@"closed on"];
    }
    
    if (![self isNull:@"number_of_employees"]){
        
        [gi setValue:item[@"properties"][@"number_of_employees"] forKey:@"number of employees"];
        [infoSections addObject:@"number of employees"];
    }
    
    if (![self isNull:@"total_funding_usd"]){
        [gi setValue:[self prettifyAmount:item[@"properties"][@"total_funding_usd"]] forKey:@"total raised"];
        [infoSections addObject:@"total raised"];
    }
    if (![self isNull:@"number_of_investments"]){
        int investments = [item[@"properties"][@"number_of_investments"] intValue];
        if (investments > 0) {
            [gi setValue:item[@"properties"][@"number_of_investments"] forKey:@"number of investments"];
            [infoSections addObject:@"number of investments"];
        }
    }
    
    
    
    
    
    [item setObject:gi forKey:@"general_info"];
    
//    NSMutableDictionary *miles = [item objectForKey:@"milestones"];
    
    [relationships removeObjectForKey:@"milestones"];
    [relationships removeObjectForKey:@"images"];
    [relationships removeObjectForKey:@"primary_image"];
    
    [sections addObject:@"general_info"];
    [sections addObjectsFromArray:[relationships allKeys]];
    
//    [item setObject:miles forKey:@"milestones"];
    
    
    for (id key in [item allKeys]) {
        if ([[item objectForKey:key] isKindOfClass:[NSArray class]]){
            if ([[item objectForKey:key] count] == 0 || [key isEqualToString:@"image"] || [key isEqualToString:@"partners"]|| [key isEqualToString:@"screenshots"]|| [key isEqualToString:@"video_embeds"]) {
                [item removeObjectForKey:key];
            }
            else{
//                NSLog(@"we're gonna keep key: %@",key);
            }
        }
        else if ([[item objectForKey:key] isKindOfClass:[NSNull class]]){
            [item removeObjectForKey:key];
        }
        else if ([[item objectForKey:key] isKindOfClass:[NSString class]]){
            if ([[item objectForKey:key] isEqualToString:@""]) {
                [item removeObjectForKey:key];
            }
            else{
//                NSLog(@"we're gonna keep key: %@",key);
            }
        }
        else{
//            NSLog(@"we're gonna keep key: %@",key);
        }
    }
//    NSLog(@"items length: %@", gi);
    return self;
}


- (int) getSectionsCount{
    return (int) [sections count];
}
- (int) getSizeAtSection:(NSInteger) section{
    //    NSLog(@"section at %d", section);
    int size = 0;
    if (section == 0) {
        size = (int) [[item objectForKey:sections[section]] count];
    }
    else{
        size = (int) [relationships[sections[section]][@"items"] count];
    }
    
    if (size > MAX_DATA) {
        size = MAX_DATA;
    }
    return size;
}

- (NSString *) getSectionAtIndex: (int) index{
    NSString *returnVal = @"";
    if (index == 0 && [self getSizeAtSection:index] > 0) {
        returnVal = @"General Info";
    }
    else{
        returnVal = [sections[index] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    }
    return returnVal;
}

- (NSString *) getSectionNameAtIndex: (NSInteger) index{
    return sections[index];
}



- (NSString *) getImage: (BOOL) small {
    NSDictionary *images = item[@"relationships"][@"primary_image"];
    NSString *typeString = [item[@"type"] lowercaseString];
    NSString *imageURLLarge = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/%@/primary-image/raw",typeString,item[@"properties"][@"permalink"]];
    
    if ([images[@"items"] count] > 0){
        NSString* images_path = images[@"items"][0][@"path"];
        NSString* images_url = [NSString stringWithFormat:@"http://images.crunchbase.com/%@",images_path];
        return images_url;
    }
    else{
        return imageURLLarge;
    }

}

- (NSString *) getOverview{
    return [item[@"properties"][@"description"] stringByConvertingHTMLToPlainText];
}



- (NSString *) getTitle{
    NSString *title = @"";
    if (type == Person){
        title = [NSString stringWithFormat:@"%@ %@", item[@"first_name"], item[@"last_name"]];
    }
    else{
        title = item[@"properties"][@"name"];

    }
    return title;
}



- (NSMutableDictionary *)getContentAtIndexPath:(NSIndexPath *)index{
    //    NSLog(@"all keys: %@",);
    
    NSMutableDictionary *returnObject = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"text", @"2", @"detail", nil];
    
    if (index.section == 0) {
        id value = item[sections[index.section]][infoSections[index.row]];
        [returnObject setObject:[NSString stringWithFormat:@"%@",value] forKey:@"text"];
        [returnObject setObject:infoSections[index.row] forKey:@"detail"];
    }
    else{
        NSDictionary *itemData = relationships[sections[index.section]][@"items"][index.row];
        NSString *section = sections[index.section];
        NSLog(@"section : %@",section);
        if ([section isEqualToString:@"current_team"] || [section isEqualToString:@"past_team"]|| [section isEqualToString:@"board_members_and_advisors"]){
            NSString *name = [NSString stringWithFormat:@"%@ %@", itemData[@"first_name"], itemData[@"last_name"]];
            [returnObject setObject:name forKey:@"text"];
            [returnObject setObject:itemData[@"title"] forKey:@"detail"];
            NSString* image = [NSString stringWithFormat:@"http://www.crunchbase.com/organization/%@/primary-image/raw?w=150&h=150",itemData[@"path"]];
            
            [returnObject setObject:image forKey:@"image"];
        }
        else if ([section isEqualToString:@"websites"] || [section isEqualToString:@"news"]){
            
            [returnObject setObject:itemData[@"title"] forKey:@"text"];
            [returnObject setObject:itemData[@"url"] forKey:@"detail"];
        }
        else if ([section isEqualToString:@"offices"] || [section isEqualToString:@"headquarters"]){
            
            [returnObject setObject:[self flattenLocationFromObject:itemData]  forKey:@"text"];
            [returnObject setObject:itemData[@"name"] forKey:@"detail"];
        }
        else if ([section isEqualToString:@"funding_rounds"]){
            [returnObject setObject:[self fundingAmountFromObject:itemData[@"name"]] forKey:@"text"];
            [returnObject setObject:[self fundingRoundFromObject:itemData[@"name"]] forKey:@"detail"];
            
        }
        else if ([section isEqualToString:@"investments"]){
            [returnObject setObject:itemData[@"invested_in"][@"name"] forKey:@"text"];
            [returnObject setObject:@"" forKey:@"detail"];
            
        }
        else{
            [returnObject setObject:itemData[@"name"] forKey:@"text"];
            [returnObject setObject:@"" forKey:@"detail"];
            
            if ([section isEqualToString:@"products"]) {
                NSString* image = [NSString stringWithFormat:@"http://www.crunchbase.com/organization/%@/primary-image/raw?w=150&h=150",itemData[@"path"]];
                [returnObject setObject:image forKey:@"image"];
            }
            
        }
    }
    
    return returnObject;
    
}


- (NSString *) flattenLocationFromObject:(NSDictionary *) object{
    NSMutableString *location = [[NSMutableString alloc] init];
    NSArray *locationKeys = @[@"street_1",@"street_2",@"city",@"region",@"country_code"];
    
    for (NSString *key in locationKeys) {
        if (object[key] != (id)[NSNull null] && ![object[key] isEqualToString:@"<null>"] && ![object[key] isEqualToString:@""]){
            [location appendString: [NSString stringWithFormat:@"%@ ", object[key]]];
        }
    }
    
    
    return location;
    
    
}

- (NSString *) fundingAmountFromObject:(NSString *) roundText{
    int index = (int) [roundText rangeOfString:@" in "].location;
    
    int start = 15;
    NSDecimalNumber *funds = [NSDecimalNumber decimalNumberWithString:[roundText substringWithRange:NSMakeRange(start, index - start)]];
    return [self prettifyAmount:funds];
}

- (NSString *) fundingRoundFromObject:(NSString *) roundText{
    int index = (int) [roundText rangeOfString:@" in "].location;
    
    
    return [roundText substringFromIndex:index];
}

- (NSString *) getDegree:(id) obj{
    if ([[obj valueForKey:@"degree_type"] isEqualToString:@""] && [[obj valueForKey:@"subject"] isEqualToString:@""]) {
        return @"";
    }
    else if ([[obj valueForKey:@"subject"] isEqualToString:@""]){
        return [obj valueForKey:@"degree_type"];
    }
    else if ([[obj valueForKey:@"degree_type"] isEqualToString:@""]){
        return [obj valueForKey:@"subject"];
    }
    else{
        return [NSString stringWithFormat:@"%@ in %@", [obj valueForKey:@"degree_type"],[obj valueForKey:@"subject"]];
    }
    
}


- (NSString *)permalinkFromDictionary:(NSMutableDictionary *)dict atIndexPath:(NSIndexPath *)index{
    if ([dict count] > 0){
        int i = 0;
        NSString* matched_key = [[NSString alloc] init];
        NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
        for (id key in dict) {
//            NSLog(@"permalinkForDictionary: each key is: %@",key);
            if (i == index.section-1 ){
                object = [[dict valueForKey:key] objectAtIndex:index.row];
            }
            i++;
        }
        
        NSString *url = [Cruncher crunchBaseURL];
        
        
        if ([matched_key isEqualToString:@"competitions"]){
            return [NSString stringWithFormat:@"%@/company/%@.json", url, [[object valueForKey:@"competitor"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"relationships"]){
            if ([[self getValue:@"type"] isEqualToString:@"person"])
                return [NSString stringWithFormat:@"%@/company/%@.json",url, [[object valueForKey:@"firm"] valueForKey:@"permalink"]];
            else{
                return [NSString stringWithFormat:@"%@/person/%@.json",url, [[object valueForKey:@"person"] valueForKey:@"permalink"]];
            }
        }
        else if ([matched_key isEqualToString:@"products"]){
            return [NSString stringWithFormat:@"%@/product/%@.json",url, [object valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"acquisitions"]){
            return [NSString stringWithFormat:@"%@/company/%@.json", url, [[object valueForKey:@"company"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"providerships"]){
            return [NSString stringWithFormat:@"%@/company/%@.json",url,  [[object valueForKey:@"provider"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"investments"]){
            return [NSString stringWithFormat:@"%@/company/%@.json",url, [[[object valueForKey:@"funding_round"] valueForKey:@"company"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"company"]){
            return [NSString stringWithFormat:@"%@/company/%@.json",url, [[object valueForKey:@"company"] valueForKey:@"permalink"]];
        }
        else
            return @"";
    }
    else{
        return @"";
    }
}


- (NSString *)permalinkatIndexPath:(NSIndexPath *)index{
    
    NSString *key = [self getSectionNameAtIndex:index.section];
    
    //    NSLog(@"matched key is %@", key);
    NSString *url = [Cruncher crunchBaseURL];
    
    if ([key isEqualToString:@"competitions"]){
        return [NSString stringWithFormat:@"%@/company/%@.json?",url, [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"competitor"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"relationships"]){
        if (type == Person)
            return [NSString stringWithFormat:@"%@/company/%@.json?",url, [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"firm"] valueForKey:@"permalink"]];
        else{
            return [NSString stringWithFormat:@"%@/person/%@.json?",url,[[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"person"] valueForKey:@"permalink"]];
        }
    }
    else if ([key isEqualToString:@"products"]){
        return [NSString stringWithFormat:@"%@/product/%@.json?",url,[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"acquisitions"]){
        return [NSString stringWithFormat:@"%@/company/%@.json?",url, [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"company"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"providerships"]){
        return [NSString stringWithFormat:@"%@/company/%@.json?",url, [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"provider"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"investments"]){
        return [NSString stringWithFormat:@"%@/company/%@.json?",url,[[[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"funding_round"] valueForKey:@"company"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"company"]){
        return [NSString stringWithFormat:@"%@/company/%@.json?",url,[[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"company"] valueForKey:@"permalink"]];
    }
    else
        return @"";
}

- (NSString *)getTypeAtIndexPath:(NSIndexPath *)index {
    
    NSString *key = [self getSectionNameAtIndex:(int) index.section];
    
    NSLog(@"matched key is %@", key);

    if ([key isEqualToString:@"competitions"]){
        return @"company";
    }
    else if ([key isEqualToString:@"relationships"]){
        if (type == Person)
            return @"company";
        else{
            return @"person";
        }
    }
    else if ([key isEqualToString:@"products"]){
        return @"product";
    }
    else if ([key isEqualToString:@"acquisitions"]){
        return @"company";
    }
    else if ([key isEqualToString:@"providerships"]){
        return @"company";
    }
    else if ([key isEqualToString:@"investments"]){
        return @"company";
    }
    else
        return @"";
    
}


- (BOOL) linkAtIndex: (NSIndexPath*) index {
    
    if ([[self permalinkFromDictionary:item atIndexPath:index] length] > 0 || ([[self getValue:@"type"] isEqualToString: @"product"] && index.row == 0 && index.section == 0)){
        return true;
    }
    else
        return false;
}

- (NSString *)getKeyAtIndexPath:(NSInteger)index{
    int i = 0;
    NSString* matched_key = [[NSString alloc] init];
    for (id key in item) {
        //NSLog(@"looping thru key:%@",key);
        if (i == index-1){
            matched_key = key;
            //NSLog(@"found key:%@ at index:%d",key,i);
        }
        i++;
    }
    return matched_key;
}

- (int)getSizeAtIndex:(NSInteger)index{
    int i = 0;
    int size = 0;
//    NSLog(@"item: %@",item);
    for (id key in item) {
//        NSLog(@"looping thru key:%@",key);
        if (i == index - 1 && [[item valueForKey:key] isKindOfClass:[NSArray class]]){
            NSLog(@"item value is: %@",[item valueForKey:key]);
            size = (int) [[item valueForKey:key] count];
//            NSLog(@"found size:%d at index:%d",size,i);
        }
        i++;
    }
    return size;
}


- (NSString *) getDateFor: (NSString *) prep forKey: (NSString *) key andRow: (int) row{
    NSString *keyDay = [NSString stringWithFormat:@"%@_day",prep];
    NSString *keyMonth = [NSString stringWithFormat:@"%@_month",prep];
    NSString *keyYear = [NSString stringWithFormat:@"%@_year",prep];
    return [self getDateFormatForDay:[[[item valueForKey:key] objectAtIndex:row] valueForKey:keyDay] andMonth:[[[item valueForKey:key] objectAtIndex:row] valueForKey:keyMonth] andYear:[[[item valueForKey:key] objectAtIndex:row] valueForKey:keyYear]];
}

- (NSString *) getDateFor: (NSString *) prep fromObject: (NSMutableDictionary *) obj{
    NSString *keyDay = [NSString stringWithFormat:@"%@_day",prep];
    NSString *keyMonth = [NSString stringWithFormat:@"%@_month",prep];
    NSString *keyYear = [NSString stringWithFormat:@"%@_year",prep];
    return [self getDateFormatForDay:[obj valueForKey:keyDay] andMonth:[obj valueForKey:keyMonth] andYear:[obj valueForKey:keyYear]];
}




- (NSString *) getDateFormatForDay:(NSString *)strDay andMonth:(NSString *) strMonth andYear:(NSString*) strYear{
    //NSLog(@"formatting: %@,%@,%@",strDay,strMonth,strYear);
    if (strDay  != (id)[NSNull null] && strMonth  != (id)[NSNull null] && strYear  != (id)[NSNull null])
        return [NSString stringWithFormat:@"%@/%@/%@",strDay,strMonth,strYear];
    else if(strDay  != (id)[NSNull null] && strMonth  != (id)[NSNull null])
        return [NSString stringWithFormat:@"%@/%@",strMonth,strYear];
    else if(strYear  != (id)[NSNull null])
        return [NSString stringWithFormat:@"%@",strYear];
    else
        return [NSString stringWithFormat:@""];
}



- (NSString *) titlizeString:(NSString *) title{
    title = [title stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[title substringToIndex:1] uppercaseString]];
    title = [title stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    return title;
}


- (BOOL) isNull:(NSString *) key{
    if ([item objectForKey:key] == (id)[NSNull null]) //([item objectForKey:key] == nil || [[item objectForKey:key] isEqualToString:@"<null>"])
        return true;
    else if ([[NSString stringWithFormat:@"%@",item[@"properties"][key]] isEqualToString:@""])
        return true;
    else if ([[NSString stringWithFormat:@"%@",item[@"properties"][key]] isEqualToString:@"<null>"])
        return true;
    else
        return false;
}
- (NSString *) getValue: (NSString *) key{
    if (![self isNull:key])
        return [item objectForKey:key];
    else
        return @"";
}

- (void) setItemType: (NSString *) aType{
    NSLog(@"type is %@",aType);
    
    if ([aType isEqualToString:@"Organization"]) {
        type = Company;
    }
    else if ([aType isEqualToString:@"Person"]){
        type = Person;
    }
    else if ([aType isEqualToString:@"Product"]){
        type = Product;
    }
    else if ([aType isEqualToString:@"service-provider"]){
        type = Provider;
    }
    else{
        type = None;
    }
}


- (NSString *) prettifyFundingRound: (NSString *) round{
    if ([round isEqualToString:@"angel"] || [round isEqualToString:@"seed"] || [round isEqualToString:@"unattributed"] || [round isEqualToString:@"debt_round"])
        return [round capitalizedString];
    else if([round isEqualToString:@"secondary_market"])
        return @"Secondary Market";
    else
        return [NSString stringWithFormat:@"Series %@",[round capitalizedString]];

}


- (BOOL) isAcquired{
//    NSLog(@"%hhd",[self isNull:@"acquisition"]);
    return ![self isNull:@"acquisition"];
}
- (NSString *) prettifyAmount: (id) amt{
    if ([amt isKindOfClass:[NSNull class]]) {
        return @"Unspecified Amount";
    }
    else{
        float amount = [amt floatValue];

        if (amount/1000000000 >= 1) {
            return [NSString stringWithFormat:@"$%.1fB", amount/1000000000.0];
        }
        else if (amount/1000000 >= 1) {
            return [NSString stringWithFormat:@"$%.1fM", amount/1000000.0];
        }
        else if (amount/1000 >= 1) {
            return [NSString stringWithFormat:@"$%.1fK", amount/1000.0];
        }
        else{
            return [NSString stringWithFormat:@"$%.1f", amount];
        }
    }
}

- (NSString *) getAcquiredInfo{
    if ([self isAcquired]){
        
        NSString* dateOfAcq = [self getDateFor:@"acquired" fromObject:[item objectForKey: @"acquisition"]];
        
        NSString* companyOfAcq = @"";
        NSString* permCompanyOfAcq = @"";
        NSString* purchase_currency = @"";
        NSString* amountOfPurchase = @"";
        
        if (![self isNull:@"acquiring_company"]){
            companyOfAcq = [[[item objectForKey: @"acquisition"] objectForKey:@"acquiring_company"] valueForKey:@"name"];
            permCompanyOfAcq = [[[item objectForKey: @"acquisition"] objectForKey:@"acquiring_company"] valueForKey:@"permalink"];
            amountOfPurchase = [self prettifyAmount:[[item objectForKey: @"acquisition"] valueForKey:@"price_amount"]];
            purchase_currency = [[item objectForKey: @"acquisition"] valueForKey:@"price_currency_code"];
            
            if ([dateOfAcq isEqualToString:@""]){
                return [NSString stringWithFormat:@"Acquired by %@ on %@ for %@ %@",companyOfAcq, dateOfAcq, amountOfPurchase,purchase_currency];
            }
            else{
                return [NSString stringWithFormat:@"Acquired by %@ for %@ %@", companyOfAcq, amountOfPurchase,purchase_currency];
            }
        }
        else{
            if ([dateOfAcq isEqualToString:@""]){
                return @"Acquired";
            }
            else{
                return [NSString stringWithFormat:@"Acquired on %@",dateOfAcq];
            }
        }
    }
    else{
        return @"Not Acquired";
    }
}


@end
