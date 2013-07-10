//
//  ASFlightDetailsViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 30.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASFlightDetailsViewController.h"

@interface ASFlightDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
