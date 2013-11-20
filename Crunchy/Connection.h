//
//  Connection.h
//  roadsight5
//
//  Created by Menan Vadivel on 2012-12-04.
//  Copyright (c) 2012 Menan Vadivel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
//#import "ASIFormDataRequest.h"

@interface Connection : NSObject <SBJsonStreamParserAdapterDelegate>{
    
	SBJsonStreamParser *parser;
	SBJsonStreamParserAdapter *adapter;
    
	NSMutableArray *content;
	NSMutableArray * data;
	NSMutableData * dataReceived;
	NSMutableDictionary * item;

}
-(void)readJSON:(NSString *) strURL withSender:(id) sender;

@property (nonatomic, retain) id viewController;

@end
