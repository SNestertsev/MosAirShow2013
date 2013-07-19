//
//  ASFlightDetailsViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASFlightDetailsViewController.h"
#import "ASPlaneDetailsViewController.h"

@interface ASFlightDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *planeButton;

@end

@implementation ASFlightDetailsViewController

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
    self.startTimeLabel.text = self.startTime;
    self.endTimeLabel.text = self.endTime;
    self.nameLabel.text = self.flightName;
    self.descriptionText.text = self.flightDetails;

    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    if (self.planeName.length > 0 && self.planeFileName.length > 0) {
        if (![toolbarButtons containsObject:self.planeButton]) {
            [toolbarButtons addObject:self.planeButton];
            [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
        }
        self.planeButton.title = self.planeName;
    }
    else {
        [toolbarButtons removeObject:self.planeButton];
        [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPlaneOfFlight"]) {
        ASPlaneDetailsViewController *destination = (ASPlaneDetailsViewController*)segue.destinationViewController;
        destination.planeName = self.planeName;
        destination.descriptionFile = self.planeFileName;
    }
}

@end
