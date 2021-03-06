//
//  ASPlaneDetailsViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 29.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASPlaneDetailsViewController.h"

#define kLayoutMargings 10

@interface ASPlaneDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ASPlaneDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
	// Do any additional setup after loading the view.
    if (self.planeName.length > 0) {
        self.title = self.planeName;
    }
    if (self.descriptionFile.length > 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:self.descriptionFile ofType:nil];
        if (path.length > 0) {
            NSString *htmlPage = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            [self.webView loadHTMLString:htmlPage baseURL:[[NSBundle mainBundle] bundleURL]];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *javascript = @"var style = document.createElement(\"style\"); document.head.appendChild(style); style.innerHTML = \"html{-webkit-text-size-adjust: none;}\";var viewPortTag=document.createElement('meta');viewPortTag.id=\"viewport\";viewPortTag.name = \"viewport\";viewPortTag.content = \"width=320; initial-scale=1.0; maximum-scale=5.0; user-scalable=1;\";document.getElementsByTagName('head')[0].appendChild(viewPortTag);";
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
