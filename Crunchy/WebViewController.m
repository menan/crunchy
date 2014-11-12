//
//  WebViewController.m
//  Crunchy
//
//  Created by Mac5 on 2/17/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingBar;

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
    NSURL *aUrl = [NSURL URLWithString:urlStr];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:aUrl];
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
    
    
    [self.loadingBar stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                    message:@"Unable to connect to the server."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];



}

- (IBAction)showSheet:(id)sender{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Open in Safari", nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)reloadPage:(id)sender{
    [self loadURL:url];
}
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [[UIApplication sharedApplication] openURL:self.webview.request.URL];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"starting to load");
    [self.loadingBar startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"finished loading");
    [self.loadingBar stopAnimating];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
