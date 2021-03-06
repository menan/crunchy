//
//  Cruncher.m
//  CrunchBase Mobile V2
//
//  Created by Mac5 on 13-08-08.
//  Copyright (c) 2013 Menan Vadivel. All rights reserved.
//

#import "Cruncher.h"
#import "NSString+HTML.h"
#import "AFJSONRequestOperation.h"
#import "UIImageView+WebCache.h"
#import "EntityURLRequest.h"

@implementation Cruncher

#define MAX_DATA 50

NSMutableDictionary *item;
NSMutableDictionary *relationships;
NSMutableArray *sections;
NSMutableArray *infoSections;
NSMutableArray *sectionTitles;
NSMutableArray *relationshipsNew;

NSMutableArray *imagesData;
NSMutableArray *imagesDispatched;
NSMutableDictionary *imagesPaths;
NSMutableDictionary *fetchedData;

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)


+ (NSString *) userKey{
    return @"00aba8c514f4e90b191bafe88ce9fceb";
}

+ (NSString *) crunchBaseURL{
    return @"http://api.crunchbase.com/v/2";
}

+ (NSURL *) crunchBaseURLForPath:(NSString *)path{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@?user_key=%@",[Cruncher crunchBaseURL],path, [Cruncher userKey]];
    return [NSURL URLWithString:urlString];
}

- (id) init{
    
    imagesPaths = [NSMutableDictionary new];
    imagesData = [[NSMutableArray alloc] init];
    fetchedData = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (id) initWithDictionary: (NSMutableDictionary *) dict{
    item = [[NSMutableDictionary alloc] initWithDictionary:dict];
    relationships = [[NSMutableDictionary alloc] initWithDictionary:dict[@"relationships"]];
    
    NSMutableDictionary* gi = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    infoSections = [[NSMutableArray alloc] init];
    sectionTitles = [NSMutableArray new];
    relationshipsNew = [NSMutableArray new];
    imagesPaths = [NSMutableDictionary new];
    imagesData = [[NSMutableArray alloc] init];
    imagesDispatched = [NSMutableArray new];
    fetchedData = [[NSMutableDictionary alloc] init];
    
    
    NSArray *blacklisted = @[@"created_at", @"closed_on_trust_code", @"role_company", @"updated_at", @"permalink", @"num_employees_max", @"num_employees_min", @"primary_role", @"founded_on_month", @"founded_on_year", @"founded_on_day",@"announced_on_month", @"announced_on_year", @"announced_on_day", @"founded_on_trust_code", @"description", @"is_closed", @"secondary_role_for_profit", @"money_raised_usd", @"opening_valuation_usd", @"opening_share_price_usd", @"post_moeny_valuation_currency_code", @"canonical_currency_code", @"money_raised_currency_code", @"location_uuid",@"bio",@"died_on_trust_code",@"role_investor",@"born_on_year",@"born_on_month",@"born_on_day",@"born_on_trust_code",@"post_money_valuation_currency_code",@"announced_on_trust_code",@"name",@"price_currency_code",@"owner_path",@"launched_on_trust_code",@"launched_on_month",@"launched_on_year",@"launched_on_day",@"videos",@"opening_share_price_currency_code",@"went_public_on_trust_code",@"went_public_on_day",@"went_public_on_month",@"went_public_on_year",@"opening_valuation_currency_code",@"target_money_raised_currency_code",@"closed_on_month",@"closed_on_year",@"closed_on_day",@"secondary_role_early_stage_vendor",@"secondary_role_seed",@"secondary_role_venture_capital",@"secondary_role_debt_financing",@"secondary_role_private_equity",@"secondary_role_large_stage_venture",@"sectors",@"secondary_role_early_stage_venture",@"secondary_role_later_stage_venture",@"secondary_role_incubator",@"short_description",@"also_known_as",@"price_usd",@"completed_on_day",@"completed_on_month",@"completed_on_year",@"completed_on_trust_code",@"regions"];
    
    NSMutableArray *propertyBlacklisted = [[NSMutableArray alloc] initWithArray:blacklisted];
    
    if ([item[@"type"] isEqualToString:@"Product"]) {
        [propertyBlacklisted addObject:@"short_description"];
    }
    
    int investments = [item[@"properties"][@"number_of_investments"] intValue];
    
    if (investments == 0) {
        NSLog(@"number oof investments %d",investments);
        [propertyBlacklisted addObject:@"number_of_investments"];
    }

    for (NSString *property in item[@"properties"]) {
        if (![self isNull:property] && ![propertyBlacklisted containsObject:property]){            
            if ([property isEqualToString:@"total_funding_usd"] || [property isEqualToString:@"price"]|| [property isEqualToString:@"money_raised"]|| [property isEqualToString:@"opening_valuation"]|| [property isEqualToString:@"opening_share_price"] ||  [property isEqualToString:@"post_money_valuation"]){
                [gi setValue:[self prettifyAmount:item[@"properties"][property] withPrefix:@"$"] forKey:[property stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
                [infoSections addObject:[property stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
            }
            else if ([property isEqualToString:@"shares_outstanding"] || [property isEqualToString:@"shares_sold"]){
                
                [gi setValue:[self prettifyAmount:item[@"properties"][property] withPrefix:@""] forKey:[property stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
                [infoSections addObject:[property stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
            }
            else{
                
                [gi setValue:item[@"properties"][property] forKey:[property stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
                [infoSections addObject:[property stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
            }
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
    if ([item[@"type"] isEqualToString:@"Person"])
        return [item[@"properties"][@"bio"] stringByConvertingHTMLToPlainText];
    else if ([item[@"type"] isEqualToString:@"Product"])
        return [item[@"properties"][@"short_description"] stringByConvertingHTMLToPlainText];
    else
        return [item[@"properties"][@"description"] stringByConvertingHTMLToPlainText];
}



- (NSString *) getTitle{
    NSString *title = @"";
    if ([item[@"type"] isEqualToString:@"Person"]){
        title = [NSString stringWithFormat:@"%@ %@", item[@"properties"][@"first_name"], item[@"properties"][@"last_name"]];
    }
    else{
        title = item[@"properties"][@"name"];

    }
    return title;
}



- (NSMutableDictionary *)getContentAtIndexPath:(NSIndexPath *)index{
    //    NSLog(@"all keys: %@",);
    
    NSMutableDictionary *returnObject = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"",@"text", @"", @"detail", nil];
    
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
            NSString* image = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",itemData[@"path"]];
            
            [returnObject setObject:image forKey:@"image"];
        }
        else if ([section isEqualToString:@"websites"] || [section isEqualToString:@"news"]){
            if (itemData[@"title"] != [NSNull null])
                [returnObject setObject:itemData[@"title"] forKey:@"text"];
            
            if (itemData[@"url"] != [NSNull null])
                [returnObject setObject:itemData[@"url"] forKey:@"detail"];
        }
        else if ([section isEqualToString:@"offices"] || [section isEqualToString:@"headquarters"]){
            
            [returnObject setObject:[self flattenLocationFromObject:itemData]  forKey:@"text"];
            if (itemData[@"name"] != [NSNull null])
                [returnObject setObject:itemData[@"name"] forKey:@"detail"];
        }
        else if ([section isEqualToString:@"funding_rounds"]){
            [returnObject setObject:[self fundingAmountFromObject:itemData[@"name"]] forKey:@"text"];
            [returnObject setObject:[self fundingRoundFromObject:itemData[@"name"]] forKey:@"detail"];
            
        }
        else if ([section isEqualToString:@"investments"]){
            if ([item[@"type"] isEqualToString:@"FundingRound"]) {
                
                if([itemData[@"investor"][@"type"] isEqualToString:@"Person"]){
                    
                    [returnObject setObject:[NSString stringWithFormat:@"%@ %@",itemData[@"investor"][@"first_name"],itemData[@"investor"][@"last_name"]] forKey:@"text"];
                }
                else{
                    
                    if (itemData[@"investor"][@"name"] != [NSNull null])
                        [returnObject setObject:itemData[@"investor"][@"name"] forKey:@"text"];
                }
            }
            else{
                
                if (itemData[@"invested_in"][@"name"] != [NSNull null])
                    [returnObject setObject:itemData[@"invested_in"][@"name"] forKey:@"text"];
            }
            
            
        }
        else if ([section isEqualToString:@"primary_affiliation"] || [section isEqualToString:@"advisor_at"] || [section isEqualToString:@"experience"]){
            
            if (itemData[@"organization_name"] != (id)[NSNull null])
                [returnObject setObject:itemData[@"organization_name"] forKey:@"detail"];
            
            if (itemData[@"title"] != (id)[NSNull null])
                [returnObject setObject:itemData[@"title"] forKey:@"text"];
        }
        else if ([section isEqualToString:@"degrees"]){
            
            if (itemData[@"degree_subject"] != (id)[NSNull null])
                [returnObject setObject:itemData[@"degree_subject"] forKey:@"detail"];
            if (itemData[@"organization_name"] != (id)[NSNull null])
                [returnObject setObject:itemData[@"organization_name"] forKey:@"text"];
        }
        else{
            if (itemData[@"name"] != (id)[NSNull null] && itemData[@"name"] != nil)
                [returnObject setObject:itemData[@"name"] forKey:@"text"];
            
            if ([section isEqualToString:@"products"] || [section isEqualToString:@"competitors"] || [section isEqualToString:@"customers"] || [section isEqualToString:@"founders"] || [section isEqualToString:@"members"]|| [section isEqualToString:@"acquiree"]|| [section isEqualToString:@"acquirer"]) {
                NSString* image = [NSString stringWithFormat:@"http://www.crunchbase.com/%@/primary-image/raw?w=150&h=150",itemData[@"path"]];
                [returnObject setObject:image forKey:@"image"];
            }
            
        }
    }
    
    return returnObject;
    
}


- (NSString *) flattenLocationFromObject:(NSDictionary *) object{
    NSMutableString *location = [[NSMutableString alloc] init];
    NSArray *locationKeys = @[@"street_1",@"street_2",@"city",@"region",@"country"];
    
    for (NSString *key in locationKeys) {
        NSString *value = object[key];
        if (object[key] != (id)[NSNull null] && ![value isEqualToString:@""]){
            [location appendString: [NSString stringWithFormat:@"%@ ", object[key]]];
        }
    }
    
    
    return location;
    
    
}

- (NSString *) fundingAmountFromObject:(NSString *) roundText{
    int index = (int) [roundText rangeOfString:@" in "].location;
    
    int start = 15;
    if (index < [roundText length]) {
        NSDecimalNumber *funds = [NSDecimalNumber decimalNumberWithString:[roundText substringWithRange:NSMakeRange(start, index - start)]];
        return [self prettifyAmount:funds withPrefix:@"$"];
    }
    else{
        return roundText;
    }
}

- (NSString *) fundingRoundFromObject:(NSString *) roundText{
    int index = (int) [roundText rangeOfString:@" in "].location;
    
    
    if (index < [roundText length]) {
        return [roundText substringFromIndex:index];
    }
    else{
        return roundText;
    }
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


- (NSString *)permalinkatIndexPath:(NSIndexPath *)index{
    
    NSString *key = [self getSectionNameAtIndex:index.section];
    NSString *url = [Cruncher crunchBaseURL];
    
    NSString *fullpath = @"";
    if ([key isEqualToString:@"investments"]) {
        if ([item[@"type"] isEqualToString:@"FundingRound"]) {
            if (item[@"relationships"][key][@"items"][index.row][@"investor"][@"path"] && item[@"relationships"][key][@"items"][index.row][@"investor"][@"path"] != [NSNull null])
                fullpath = [NSString stringWithFormat:@"%@/%@?",url,item[@"relationships"][key][@"items"][index.row][@"investor"][@"path"]];
        }
        else{
            if (item[@"relationships"][key][@"items"][index.row][@"funding_round"][@"path"] && item[@"relationships"][key][@"items"][index.row][@"funding_round"][@"path"] != [NSNull null])
                fullpath = [NSString stringWithFormat:@"%@/%@?",url,item[@"relationships"][key][@"items"][index.row][@"funding_round"][@"path"]];
        }
    }
    else if (![key isEqualToString:@"categories"]) {
        if (item[@"relationships"][key][@"items"][index.row][@"path"] && item[@"relationships"][key][@"items"][index.row][@"path"] != [NSNull null])
            fullpath = [NSString stringWithFormat:@"%@/%@?",url,item[@"relationships"][key][@"items"][index.row][@"path"]];
        else if (item[@"relationships"][key][@"items"][index.row][@"organization_path"] && item[@"relationships"][key][@"items"][index.row][@"organization_path"] != [NSNull null])
            fullpath = [NSString stringWithFormat:@"%@/%@?",url,item[@"relationships"][key][@"items"][index.row][@"organization_path"]];
    }
    
    return fullpath;
}

- (BOOL) linkAtIndex: (NSIndexPath*) index {
    
    if ([[self permalinkatIndexPath:index] length] > 0 || (index.row == 0 && index.section == 0)){
        return true;
    }
    else
        return false;
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
    else if ([[NSString stringWithFormat:@"%@",item[@"properties"][key]] isEqualToString:@"<null>"] || [[NSString stringWithFormat:@"%@",item[@"properties"][key]] isEqualToString:@"(null)"])
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
- (NSString *) prettifyAmount: (id) amt withPrefix:(NSString *) prefix{
    if ([amt isKindOfClass:[NSNull class]]) {
        return @"Unspecified Amount";
    }
    else{
        float amount = [amt floatValue];

        if (amount/1000000000 >= 1) {
            return [NSString stringWithFormat:@"%@%.1fB", prefix, amount/1000000000.0];
        }
        else if (amount/1000000 >= 1) {
            return [NSString stringWithFormat:@"%@%.1fM", prefix, amount/1000000.0];
        }
        else if (amount/1000 >= 1) {
            return [NSString stringWithFormat:@"%@%.1fK", prefix, amount/1000.0];
        }
        else{
            return [NSString stringWithFormat:@"%@%.1f", prefix, amount];
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
            amountOfPurchase = [self prettifyAmount:[[item objectForKey: @"acquisition"] valueForKey:@"price_amount"] withPrefix:@"$"];
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

- (NSString *) getShorDescription{
    return item[@"properties"][@"short_description"];
}

- (NSArray *) getFounders{
    NSArray* founders = item[@"relationships"][@"founders"][@"items"];   
    return founders;
}

- (NSArray *) getRelationships{
    
    NSArray *requiredStrings = @[@"current_team",@"past_team",@"acquisitions",@"board_members_and_advisors",@"competitors",@"funding_rounds",@"investments",@"members",@"products"];
    
    for (NSString* itemTitle in requiredStrings) {
        if (item[@"relationships"][itemTitle] && [item[@"relationships"][itemTitle] count] > 0) {
            [sectionTitles addObject:itemTitle];
        }
    }
    return sectionTitles;
}


- (NSString *) getTitleAtIndex:(NSInteger)index{
    
    NSDictionary *titlesAndKeys = @{@"current_team":@"Current Team", @"past_team": @"Past Team", @"acquisitions":@"Purchases", @"board_members_and_advisors":@"Board Members",@"competitors":@"Competitors",@"funding_rounds":@"Funding Rounds",@"investments":@"Investments",@"members":@"Members",@"products":@"Products"};
    return [titlesAndKeys objectForKey:sectionTitles[index]];
}


- (NSInteger) getContentCountAtIndex:(NSInteger)index{
    return [item[@"relationships"][sectionTitles[index]][@"items"] count];
}
- (NSArray *) dataAtIndex:(NSInteger) index{
//    [self updateImagesURL:index];
    return item[@"relationships"][sectionTitles[index]][@"items"];
}

- (BOOL) hasDispatched:(NSString *) path{
    
    for (NSDictionary* dict in imagesDispatched) {
        if ([dict[@"path"] isEqualToString:path]) {
            return YES;
        }
    }
    return NO;
}
- (NSString *) pathFromURL:(NSString *)url{
    NSRange prefixRange = [url rangeOfString:@"api.crunchbase.com/v/2/"];
    NSRange suffixRange = [url rangeOfString:@"/primary_image"];
    return [url substringWithRange:NSMakeRange(prefixRange.location + prefixRange.length, suffixRange.location - 30)];
}


- (NSArray *) getAddressData{
    NSMutableArray *addressData = [NSMutableArray new];
    
    for (NSDictionary* office in item[@"relationships"][@"offices"][@"items"]) {
        NSString *addressString = [self flattenLocationFromObject:office];
        [addressData addObject:@{@"title":@"Office", @"subtitle":[self getTitle], @"location":addressString}];
    }
    
//    NSLog(@"Address data: %@ ", addressData);
    return addressData;
    
}

- (void) setDataFromPath:(NSString *)path forView:(UIView *) view{
    NSString* url;
    
    if (contains(path,@"person") || contains(path,@"organization")) {
        UIImageView* imageView = (UIImageView*) [view viewWithTag:2];
        [self setImageFromPath:path forImageView:imageView];
    }
    else if (contains(path,@"acquisition")){
        url = [[NSString stringWithFormat:@"%@/%@/acquiree?user_key=%@", [Cruncher crunchBaseURL], path, [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (!fetchedData[@"path"]) {
            EntityURLRequest *request = [[EntityURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            request.view = view;
            request.path = path;
            NSLog(@"downloading info %@",path);
            [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
                     EntityURLRequest *thisRequest = (EntityURLRequest*) request;
                     if (thisRequest.path && data) {
                         [fetchedData setObject:data[@"data"] forKey:thisRequest.path];
                         
                         UIImageView* imageView = (UIImageView*) [view viewWithTag:2];
                         UILabel* label = (UILabel*) [view viewWithTag:1];
                         //    UILabel* subLabel = (UILabel*) [view viewWithTag:3];
                         
                         if ([data[@"items"] count] > 0) {
                             NSString *entityName = data[@"items"][0][@"name"];
                             NSString *entityPath = data[@"items"][0][@"path"];
                             label.text = entityName;
                             [self setImageFromPath:entityPath forImageView:imageView];
                         }
                         
                     }
                     else{
                         [fetchedData setObject:@"" forKey:thisRequest.path];
                     }
                 }
                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                     EntityURLRequest *thisRequest = (EntityURLRequest*) request;
                     [fetchedData setObject:@"" forKey:thisRequest.path];
                 }] start];
        }
        else{
            
        }
    }
    else if (contains(path,@"funding-round")){
        url = [[NSString stringWithFormat:@"%@/%@?user_key=%@", [Cruncher crunchBaseURL], path, [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (!fetchedData[@"path"]) {
            EntityURLRequest *request = [[EntityURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            request.view = view;
            request.path = path;
            NSLog(@"downloading info %@",path);
            [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
                     EntityURLRequest *thisRequest = (EntityURLRequest*) request;
                     if (thisRequest.path && data) {
                         [fetchedData setObject:data[@"data"] forKey:thisRequest.path];
                         
                         UIImageView* imageView = (UIImageView*) [view viewWithTag:2];
                         UILabel* label = (UILabel*) [view viewWithTag:1];
                         //    UILabel* subLabel = (UILabel*) [view viewWithTag:3];
                         
//                         if ([data[@"items"] count] > 0) {
//                             NSString *entityName = data[@"items"][0][@"name"];
//                             NSString *entityPath = data[@"items"][0][@"path"];
//                             label.text = entityName;
//                             [self setImageFromPath:entityPath forImageView:imageView];
//                         }
                         
                     }
                     else{
                         [fetchedData setObject:@"" forKey:thisRequest.path];
                     }
                 }
                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                     EntityURLRequest *thisRequest = (EntityURLRequest*) request;
                     [fetchedData setObject:@"" forKey:thisRequest.path];
                 }] start];
        }
        else{
            
        }
        
        
    }
}

- (void) populateView:(UIView *) view withData: (NSDictionary *) data{
    
    UIImageView* imageView = (UIImageView*) [view viewWithTag:2];
    UILabel* label = (UILabel*) [view viewWithTag:1];
//    UILabel* subLabel = (UILabel*) [view viewWithTag:3];
    
    if ([data[@"items"] count] > 0) {
        NSString *entityName = data[@"items"][0][@"name"];
        NSString *entityPath = data[@"items"][0][@"path"];
        label.text = entityName;
        [self setImageFromPath:entityPath forImageView:imageView];
    }
    
    
}


- (void) setImageFromPath: (NSString *)path forImageView:(UIImageView *) imgView{
    NSString* url = [[NSString stringWithFormat:@"%@/%@/primary_image?user_key=%@", [Cruncher crunchBaseURL], path, [Cruncher userKey]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (!imagesPaths[path]) {
        NSLog(@"downloading image for %@",path);
        EntityURLRequest *request = [[EntityURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        request.imageView = imgView;
        request.path = path;
        
        [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
                EntityURLRequest *thisRequest = (EntityURLRequest*) request;
                NSString *stringURL = [NSString stringWithFormat:@"%@%@",data[@"metadata"][@"image_path_prefix"],data[@"data"][@"items"][0][@"path"]];
                
                NSURL *urlImage = [NSURL URLWithString:stringURL];
                
                if (thisRequest.path) {
                    [imagesPaths setObject:urlImage forKey:thisRequest.path];
                }
                
    //                                                                                                NSLog(@"image for at %@ : %@ ",path, urlImage);
                
                [thisRequest.imageView sd_setImageWithURL:urlImage placeholderImage:[UIImage imageNamed:@"profile-image"]];
                
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                EntityURLRequest *thisRequest = (EntityURLRequest*) request;
                NSLog(@"error: %@ : %@",thisRequest.path, [error localizedDescription]);
                if (thisRequest.path) {
                    [imagesPaths setObject:[NSURL URLWithString:@""] forKey:thisRequest.path];
                }
                
                thisRequest.imageView.image = [UIImage imageNamed:@"profile-image"];
            }] start];
        
    }
    else{
        [imgView sd_setImageWithURL:imagesPaths[path] placeholderImage:[UIImage imageNamed:@"profile-image"]];
        
    }
    
}

@end
