//
//  ASSecondViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASFlightsViewController.h"
#import "ASFlightDetailsViewController.h"
#import "ASFlightsTableCell.h"
#import "ASFlightsModel.h"
#import "ASFlightsDay.h"
#import "ASFlight.h"
#import "NSDate+DateCategories.h"

#define kDataFileName @"flights.json"

@interface ASFlightsViewController ()

@property (nonatomic) BOOL firstAppearance;
@property (weak, nonatomic) IBOutlet UITableView *flightsTable;
@property (nonatomic, strong) ASFlightsModel *flights;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation ASFlightsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:kDataFileName];
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDataFileName];
    BOOL checkVersion = YES;
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
        checkVersion = NO;
    }
    
    NSError *err;
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    if (!json) return;
    ASFlightsModel *fileModel = [[ASFlightsModel alloc] initWithJSON:json];
    
    if (checkVersion) {
        data = [NSData dataWithContentsOfFile:bundlePath];
        json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (!json) return;
        ASFlightsModel *bundleModel = [[ASFlightsModel alloc] initWithJSON:json];
        if (bundleModel.version > fileModel.version) {
            [fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
            fileModel = bundleModel;
        }
    }
    self.flights = fileModel;
    self.firstAppearance = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.flightsTable deselectRowAtIndexPath:[self.flightsTable indexPathForSelectedRow] animated:NO];
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.firstAppearance) {
        [self scrollToNearestFlight];
        self.firstAppearance = NO;
    }
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshTable) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.refreshTimer invalidate];
    [super viewWillDisappear:animated];
}

-(void)refreshTable
{
    [self.flightsTable reloadData];
}

-(void)scrollToNearestFlight
{
    NSDate *now = [NSDate date];
    NSDate *today = [now dateWithNoTime];
    for (int i = 0; i < self.flights.days.count; i++) {
        ASFlightsDay *day = [self.flights.days objectAtIndex:i];
        if (![day.date isEqualToDate:today]) {
            continue;
        }
        for (int j = 0; j < day.flights.count; j++) {
            ASFlight *flight = [day.flights objectAtIndex:j];
            NSComparisonResult compEnd = [flight.endTime compare:now];
            if (compEnd == NSOrderedAscending) {
                continue;
            }
            [self.flightsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:j inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ASFlightDetailsViewController *destination = segue.destinationViewController;
    NSIndexPath *indexPath = self.flightsTable.indexPathForSelectedRow;
    ASFlightsDay *day = [self.flights.days objectAtIndex:indexPath.section];
    ASFlight *flight = [day.flights objectAtIndex:indexPath.row];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setTimeStyle:NSDateFormatterShortStyle];
    [timeFormat setDateStyle:NSDateFormatterNoStyle];
    destination.startTime = [timeFormat stringFromDate:flight.startTime];
    destination.endTime = [timeFormat stringFromDate:flight.endTime];
    destination.flightName = flight.name;
    destination.flightDetails = flight.descriptionText;
    destination.planeName = flight.planeName;
    destination.planeFileName = flight.planeFileName;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.flights.days.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ASFlightsDay *day = [self.flights.days objectAtIndex:section];
    return day.flights.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ASFlightsDay *day = [self.flights.days objectAtIndex:section];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeStyle:NSDateFormatterNoStyle];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormat stringFromDate:day.date];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASFlightsDay *day = [self.flights.days objectAtIndex:indexPath.section];
    ASFlight *flight = [day.flights objectAtIndex:indexPath.row];
    NSString *cellIdentifier;
    NSDate *now = [NSDate date];
    NSDate* today = [now dateWithNoTime];
    NSComparisonResult compStart = [flight.startTime compare:now];
    NSComparisonResult compEnd = [flight.endTime compare:now];
    NSString *timeToFlight;
    if (![[flight.startTime dateWithNoTime] isEqualToDate:today]) {
        // Flight is not today
        if (compEnd == NSOrderedAscending) {
            cellIdentifier = @"PassedCell";
        }
        else {
            cellIdentifier = @"FutureCell";
        }
    }
    else {
        // Flight is today
        NSDateComponents *deltaStart = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now toDate:flight.startTime options:0];
        if (compEnd == NSOrderedAscending) {
            cellIdentifier = @"PassedCell";
        }
        else if (compStart == NSOrderedAscending && compEnd == NSOrderedDescending)
        {
            cellIdentifier = @"NearestCell";
            timeToFlight = NSLocalizedStringFromTable(@"Now", @"Strings", nil);
            //timeToFlight = @"Now";
        }
        else if (deltaStart.hour == 0 && [day isFlight:flight within:3 nearTime:now]) {
            cellIdentifier = @"NearestCell";
            NSString *timeFormat = NSLocalizedStringFromTable(@"In %d minutes", @"Strings", nil);
            timeToFlight = [NSString stringWithFormat:timeFormat, deltaStart.minute + 1];
            //timeToFlight = [NSString stringWithFormat:@"In %d minutes", deltaStart.minute];
        }
        else {
            cellIdentifier = @"FutureCell";
        }
    }
    
    ASFlightsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setTimeStyle:NSDateFormatterShortStyle];
    [timeFormat setDateStyle:NSDateFormatterNoStyle];
    cell.startTimeLabel.text = [timeFormat stringFromDate:flight.startTime];
    cell.endTimeLabel.text = [timeFormat stringFromDate:flight.endTime];
    cell.nameLabel.text = flight.name;
    cell.timeToGoLabel.text = timeToFlight;
    [cell.timeToGoLabel sizeToFit];
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASFlightsDay *day = [self.flights.days objectAtIndex:indexPath.section];
    ASFlight *flight = [day.flights objectAtIndex:indexPath.row];
    NSDate *now = [NSDate date];
    NSDate* today = [now dateWithNoTime];
    NSComparisonResult compStart = [flight.startTime compare:now];
    NSComparisonResult compEnd = [flight.endTime compare:now];
    if (![[flight.startTime dateWithNoTime] isEqualToDate:today]) {
        // Flight is not today
        return 60;
    }
    else {
        // Flight is today
        NSDateComponents *deltaStart = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now toDate:flight.startTime options:0];
        if (compEnd == NSOrderedAscending) {
            return 60;  // @"PassedCell";
        }
        else if (compStart == NSOrderedAscending && compEnd == NSOrderedDescending)
        {
            return 90;  // @"NearestCell";
        }
        else if (deltaStart.hour == 0 && [day isFlight:flight within:3 nearTime:now]) {
            return 90;  // @"NearestCell";
        }
        else {
            return 60;  // @"FutureCell";
        }
    }
    return 60;
}

@end