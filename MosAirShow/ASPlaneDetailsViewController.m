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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
