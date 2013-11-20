//
//  Connection.m
//  cNews
//
//  Created by Menan Vadivel on 2012-11-30.
//  Copyright (c) 2012 Menan Vadivel. All rights reserved.
//

#import "Connection.h"
#import "MasterViewController.h"

@implementation Connection
int action;


@synthesize viewController;
- (id) init{
    data = [[NSMutableArray alloc] init];
    item = [[NSMutableDictionary alloc] init];
    dataReceived = [[NSMutableData alloc] init];
    return self;
}

#pragma NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData
{
    [dataReceived appendData:newData];
    
    //NSLog(@"Connection receiving data");
	
	// Parse the new chunk of data. The parser will append it to
	// its internal buffer, then parse from where it left off in
	// the last chunk.
	SBJsonStreamParserStatus status = [parser parse:newData];
	
	if (status == SBJsonStreamParserError) {
		NSLog(@"Parser error: %@", parser.error);
		
	} else if (status == SBJsonStreamParserWaitingForData) {
		//NSLog(@"Parser waiting for more data");
	}
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [(UIActivityIndicatorView *)[viewController navigationController].navigationItem.rightBarButtonItem.customView startAnimating];
    NSLog(@"Connection finished loading.");
        
}


-(void)readJSON:(NSString *) strURL withSender:(id) sender {
    viewController = sender;
	adapter = [SBJsonStreamParserAdapter new];
	adapter.delegate = self;
	parser = [SBJsonStreamParser new];
	parser.delegate = adapter;
    NSString *urlString = [NSString stringWithFormat:@"%@api_key=vb4f9vwfty979hbyp7ry3wwk",strURL];
	NSLog(@"reading data from: %@",urlString);
	parser.multi = YES;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:urlString]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    [(UIActivityIndicatorView *)[viewController navigationController].navigationItem.rightBarButtonItem.customView startAnimating];
    
}


- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    
    //call the controller in this class
    [viewController readObject:dict];
}


#pragma SBJson parser delegates
- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    
}
@end
