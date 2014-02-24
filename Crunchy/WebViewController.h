//
//  WebViewController.h
//  Crunchy
//
//  Created by Mac5 on 2/17/2014.
//  Copyright (c) 2014 Menan Vadivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) NSString *url;
- (void) loadURL:(NSString *) url;
@end
