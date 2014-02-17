//
//  WebViewController.m
//  Crunchy
//
//  Created by Mac5 on 2/17/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webview,url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) loadURL:(NSString *) urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webview loadRequest:requestObj];
    NSLog(@"loading URL:%@",urlStr);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadURL:url];
    webview.delegate = self;
	// Do any additional setup after loading the view.
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"starting to load");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
