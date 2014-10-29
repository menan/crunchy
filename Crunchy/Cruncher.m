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

- (id) initWithDictionary: (NSMutableDictionary *) dict{
    item = [[NSMutableDictionary alloc] initWithDictionary:dict];

    NSMutableDictionary* gi = [[NSMutableDictionary alloc] init];
    
    if (![self isNull:@"homepage_url"])
        [gi setValue:[item valueForKey:@"homepage_url"] forKey:@"url"];
    
    if (![self isNull:@"category_code"])
        [gi setValue:[self titlizeString:[item valueForKey:@"category_code"]] forKey:@"category"];
    
    if (![self isNull:@"founded_year"])
        [gi setValue:[item valueForKey:@"founded_year"] forKey:@"founded"];
    
    if (![self isNull:@"deadpooled_year"])
        [gi setValue:[item valueForKey:@"deadpooled_year"] forKey:@"deadpooled"];
    
    if (![self isNull:@"number_of_employees"])
        [gi setValue:[item valueForKey:@"number_of_employees"] forKey:@"employees"];
    
    if (![self isNull:@"twitter_username"])
        [gi setValue:[item valueForKey:@"twitter_username"] forKey:@"twitter"];
    
    
    
    [item setObject:gi forKey:@"general_info"];
    
//    NSMutableDictionary *miles = [item objectForKey:@"milestones"];
    
    [item removeObjectForKey:@"milestones"];
    
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
//    NSLog(@"items length: %d", item.count);
    return self;
}


- (int) getSectionsCount{
    int i = 0;
    for (id key in [item allKeys]) {
        if ([[item objectForKey:key] isKindOfClass:[NSArray class]]){
            i++;
        }
    }
    return i + 1;
}
- (int) getSizeAtSection:(NSInteger) section{
//    NSLog(@"section at %d", section);
    int size = 0;
    if (section == 0) {
        size = (int) [[item objectForKey:@"general_info"] count];
    }
    else{
        int i = 0;
        for (id key in [item allKeys]) {
            if ([[item objectForKey:key] isKindOfClass:[NSArray class]]){
                i++;
                if (section == i){
                    size = (int) [[item objectForKey:key] count];
                }
            }
        }
    }
//    NSLog(@"size at %d is %d", section, size);
    
    if (size > MAX_DATA) {
        size = MAX_DATA;
    }
    return size;
}

- (NSString *) getSectionAtIndex: (int) index{
    NSString *returnVal = @"";
    int i = 0;
    if (index == 0 && [self getSizeAtSection:index] > 0) {
        returnVal = @"General Info";
    }
    else{
        for (id key in [item allKeys]) {
            if ([[item objectForKey:key] isKindOfClass:[NSArray class]]){
                i++;
                if (index == i){
                    returnVal = [key stringByReplacingOccurrencesOfString:@"_" withString:@" "];
                }
            }
        }
    }
    return returnVal;
}

- (NSString *) getSectionNameAtIndex: (int) index{
    NSString *returnVal = @"";
    int i = 0;
    if (index == 0) {
        returnVal = @"general_info";
    }
    else{
        for (id key in [item allKeys]) {
            if ([[item objectForKey:key] isKindOfClass:[NSArray class]]){
                i++;
                if (index == i){
                    returnVal = key;
                }
            }
        }
    }
    return returnVal;
}

- (NSString *) getImage: (BOOL) small {
    NSDictionary *images = [item valueForKey:@"image"];
    if ([images valueForKey:@"available_sizes"] != (id)[NSNull null]){
        NSString* images_url = [[[images valueForKey:@"available_sizes"] objectAtIndex:0] objectAtIndex:1];
        NSString* images_large_url = [[[images valueForKey:@"available_sizes"] objectAtIndex:2] objectAtIndex:1];
        NSLog(@"images: %@", images_url);
        
        if (small){
            return images_url;
        }
        else{
            return images_large_url;
        }
    }
    else{
        return @"";
    }

}

- (NSString *) getOverview{
    return [[item valueForKey:@"overview"] stringByConvertingHTMLToPlainText];
}

- (NSString *) getTitle{
    NSString *title = @"";
    if (type == Person){
        title = [NSString stringWithFormat:@"%@ %@", [item valueForKey:@"first_name"], [item valueForKey:@"last_name"]];
    }
    else{
        title = [item valueForKey:@"name"];

    }
    return title;
}


- (NSMutableDictionary *)getContentAtIndexPath:(NSIndexPath *)index{
//    NSLog(@"all keys: %@",);
    
    NSMutableDictionary *returnObject = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"text", @"2", @"detail", nil];
    
    
    int i = 0;
    if (index.section == 0) {
        
        for (id key in [[item objectForKey:@"general_info"] allKeys]) {
            if (index.row == i){
                id value = [[item objectForKey:@"general_info"] valueForKey:key];
                [returnObject setObject:[NSString stringWithFormat:@"%@",value] forKey:@"text"];
                [returnObject setObject:key forKey:@"detail"];
            }
            i++;
        }
    }
    else{
        for (id key in [item allKeys]) {
            if ([[item objectForKey:key] isKindOfClass:[NSArray class]]){
                i++;
                if (index.section == i){
                    if ([key isEqualToString:@"relationships"]) {
                        NSString* name;
                        if (type == Person){
                            name = [[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"firm"] valueForKey:@"name"]; //it would be a company name if its a person profile
                        }
                        else{
                            name = [NSString stringWithFormat:@"%@ %@",[[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"person"] valueForKey:@"first_name"],[[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"person"] valueForKey:@"last_name"]];
                             //it would be a person name if its a person profile
                        }
                        
                        NSString* isPast = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"is_past"];
                        
                        NSString* title = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"title"];
                        [returnObject setObject:name forKey:@"text"];
                        [returnObject setObject:title forKey:@"detail"];
                        [returnObject setObject:isPast forKey:@"past"];
                    }
                    else if ([key isEqualToString:@"offices"]) {
                        NSString* name = [NSString stringWithFormat:@"%@, %@",[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"city"],[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"country_code"]];
                        NSString* desc = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"description"];
                        [returnObject setObject:name forKey:@"text"];
                        [returnObject setObject:desc forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"products"]) {
                        NSString* title = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"name"];
                        NSString* permalink = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"permalink"];
                        [returnObject setObject:title forKey:@"text"];
                        [returnObject setObject:permalink forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"external_links"]) {
                        NSString* url = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"external_url"];
                        NSString* title = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"title"];
                        [returnObject setObject:title forKey:@"text"];
                        [returnObject setObject:url forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"providerships"]) {
                        NSString* title = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"title"];
                        NSString* provider_name = [[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"provider"] valueForKey:@"name"];
                        [returnObject setObject:provider_name forKey:@"text"];
                        [returnObject setObject:title forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"milestones"]) {
                        NSString* title = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"description"];
                        NSString* url = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"source_url"];
                        [returnObject setObject:title forKey:@"text"];
                        [returnObject setObject:url forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"competitions"]) {
                        NSString* competitor = [[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"competitor"] valueForKey:@"name"];
                        NSString* link = [[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"competitor"] valueForKey:@"permalink"];
                        [returnObject setObject:competitor forKey:@"text"];
                        [returnObject setObject:link forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"acquisitions"]) {
                        NSString* company = [[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"company"] valueForKey:@"name"];
                        NSString* amount = [self prettifyAmount:[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"price_amount"]];
                        [returnObject setObject:company forKey:@"text"];
                        [returnObject setObject:amount forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"funding_rounds"]) {
                        NSString* type = [self prettifyFundingRound:[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"round_code"]];
                        NSString* title = [NSString stringWithFormat:@"%@ in %@",[self prettifyAmount:[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"raised_amount"]], [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"funded_year"]];
                        [returnObject setObject:title forKey:@"text"];
                        [returnObject setObject:type forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"funds"]) {
                        NSString* type = [[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"name"];
                        NSString* title = [NSString stringWithFormat:@"%@ in %@",[self prettifyAmount:[[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"raised_amount"]], [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"funded_year"]];
                        [returnObject setObject:type forKey:@"text"];
                        [returnObject setObject:title forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"investments"]) {
                        NSString* type = [self prettifyFundingRound:[[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"funding_round"] objectForKey:@"round_code"]];
                        NSString* company = [[[[[item valueForKey:key] objectAtIndex:index.row] objectForKey:@"funding_round"] objectForKey:@"company"] valueForKey:@"name"];
                        
                        NSString* title = [NSString stringWithFormat:@"%@ as %@ in %@",[self prettifyAmount:[[[[item valueForKey:key] objectAtIndex:index.row]  objectForKey:@"funding_round"] valueForKey:@"raised_amount"]],type, [[[[item valueForKey:key] objectAtIndex:index.row]  objectForKey:@"funding_round"] valueForKey:@"funded_year"]];
                        [returnObject setObject:company forKey:@"text"];
                        [returnObject setObject:title forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"web_presences"]) {
                        NSString* title = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"title"];
                        NSString* url = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"external_url"];
                        [returnObject setObject:title forKey:@"text"];
                        [returnObject setObject:url forKey:@"detail"];
                    }
                    else if ([key isEqualToString:@"degrees"]) {
                        NSString* title = [self getDegree:[[item valueForKey:key] objectAtIndex:index.row]];
                        NSString* desc = [[[item valueForKey:key] objectAtIndex:index.row] valueForKey:@"institution"];
                        [returnObject setObject:desc forKey:@"text"];
                        [returnObject setObject:title forKey:@"detail"];
                    }
                }
            }
        }
    }
    return returnObject;
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
        
        if ([matched_key isEqualToString:@"competitions"]){
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json", [[object valueForKey:@"competitor"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"relationships"]){
            if ([[self getValue:@"type"] isEqualToString:@"person"])
                return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json", [[object valueForKey:@"firm"] valueForKey:@"permalink"]];
            else{
                return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/person/%@.json",[[object valueForKey:@"person"] valueForKey:@"permalink"]];
            }
        }
        else if ([matched_key isEqualToString:@"products"]){
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/product/%@.json",[object valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"acquisitions"]){
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json", [[object valueForKey:@"company"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"providerships"]){
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json", [[object valueForKey:@"provider"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"investments"]){
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json",[[[object valueForKey:@"funding_round"] valueForKey:@"company"] valueForKey:@"permalink"]];
        }
        else if ([matched_key isEqualToString:@"company"]){
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json",[[object valueForKey:@"company"] valueForKey:@"permalink"]];
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
    
    if ([key isEqualToString:@"competitions"]){
        return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json?", [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"competitor"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"relationships"]){
        if (type == Person)
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json?", [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"firm"] valueForKey:@"permalink"]];
        else{
            return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/person/%@.json?",[[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"person"] valueForKey:@"permalink"]];
        }
    }
    else if ([key isEqualToString:@"products"]){
        return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/product/%@.json?",[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"acquisitions"]){
        return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json?", [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"company"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"providerships"]){
        return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json?", [[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"provider"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"investments"]){
        return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json?",[[[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"funding_round"] valueForKey:@"company"] valueForKey:@"permalink"]];
    }
    else if ([key isEqualToString:@"company"]){
        return [NSString stringWithFormat:@"http://api.crunchbase.com/v/1/company/%@.json?",[[[[item objectForKey:key] objectAtIndex:index.row] valueForKey:@"company"] valueForKey:@"permalink"]];
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
    else if ([[NSString stringWithFormat:@"%@",[item objectForKey:key]] isEqualToString:@""])
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
    
    if ([aType isEqualToString:@"company"]) {
        type = Company;
    }
    else if ([aType isEqualToString:@"person"]){
        type = Person;
    }
    else if ([aType isEqualToString:@"product"]){
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
- (NSString *) prettifyAmount: (NSDecimalNumber *) amt{
    if ([amt isKindOfClass:[NSNull class]]) {
        return @"Unspecified Amount";
    }
    else{
        
        int amount = [amt intValue];
//        NSLog(@"int value of the amount is %d", amount);
        if (amount/1000000000 >= 1) {
            return [NSString stringWithFormat:@"$%.1fM", amount/1000000000.0];
        }
        else if (amount/1000000 >= 1) {
            return [NSString stringWithFormat:@"$%.1fM", amount/1000000.0];
        }
        else if (amount/1000 >= 1) {
            return [NSString stringWithFormat:@"$%.1fK", amount/1000.0];
        }
        else{
            return [NSString stringWithFormat:@"%d", amount];
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
