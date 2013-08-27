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
#import "Reachability.h"

#define kDataFileName @"flights.json"
//#define kWebServerName @"mosairshow2013.ucoz.ru"
#define kWebServerName @"sites.google.com"
//#define kDataFileOnWeb @"http://mosairshow2013.ucoz.ru/expo.json"
#define kDataFileOnWeb @"https://sites.google.com/site/mosairshow2013/flights.json?attredirects=0&d=1"
//#define kVersionsFileOnWeb @"http://mosairshow2013.ucoz.ru/versions.json"
#define kVersionsFileOnWeb @"https://sites.google.com/site/mosairshow2013/versions.json?attredirects=0&d=1"

@interface ASFlightsViewController ()

@property (nonatomic) BOOL firstAppearance;
@property (weak, nonatomic) IBOutlet UITableView *flightsTable;
@property (nonatomic, strong) ASFlightsModel *flights;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (strong, nonatomic) Reachability *reach;
@property (strong, nonatomic) NSDate *lastFileUpdate;

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

    // Initiate async update of the flights list from server
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    self.lastFileUpdate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanges:) name:kReachabilityChangedNotification object:nil];
    self.reach = [Reachability reachabilityWithHostName:kWebServerName];
    [self.reach startNotifier];
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
    [self doAsyncUpdate];
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

-(void)reachabilityChanges: (NSNotification*)notification
{
    [self doAsyncUpdate];
}

-(void)doAsyncUpdate
{
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:self.lastFileUpdate toDate:[NSDate date] options:0];
    if (comps.hour <= 0) return;    // Less than an hour since the file was updated last time
    NetworkStatus status = [self.reach currentReachabilityStatus];
    if (status != ReachableViaWiFi && status != ReachableViaWWAN) {
        return;
    }
    if (versionsFileConnection != nil || dataFileConnection != nil) {
        return; // File is already loading
    }
    
    // Download versions.json
    theURL = [NSURL URLWithString:kVersionsFileOnWeb];
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    versionsFileConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
    //NSComparisonResult compStart = [flight.startTime compare:now];
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
        //NSDateComponents *deltaStart = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now toDate:flight.startTime options:0];
        if (compEnd == NSOrderedAscending) {
            cellIdentifier = @"PassedCell";
        }
        /*else if (compStart == NSOrderedAscending && compEnd == NSOrderedDescending)
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
        }*/
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
    //NSComparisonResult compStart = [flight.startTime compare:now];
    NSComparisonResult compEnd = [flight.endTime compare:now];
    if (![[flight.startTime dateWithNoTime] isEqualToDate:today]) {
        // Flight is not today
        return 60;
    }
    else {
        // Flight is today
        //NSDateComponents *deltaStart = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now toDate:flight.startTime options:0];
        if (compEnd == NSOrderedAscending) {
            return 60;  // @"PassedCell";
        }
        /*else if (compStart == NSOrderedAscending && compEnd == NSOrderedDescending)
        {
            return 90;  // @"NearestCell";
        }
        else if (deltaStart.hour == 0 && [day isFlight:flight within:3 nearTime:now]) {
            return 90;  // @"NearestCell";
        }*/
        else {
            return 60;  // @"FutureCell";
        }
    }
    return 60;
}

#pragma mark - NSURLConnection Delegate methods

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    @autoreleasepool {
        theURL = [request URL];
    }
    return request;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (responseData == nil) {
        responseData = [[NSMutableData alloc] init];
    }
    [responseData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Error = %@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *content = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
    //NSLog(@"Data = %@", content);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (connection == versionsFileConnection) {
        NSError *err;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
        if (!json) return;
        int serverFlightsVersion = ((NSNumber*)[json objectForKey:@"flightsVersion"]).intValue;
        if (serverFlightsVersion > self.flights.version) {
            NSLog(@"New version of Flights list is on the server: %d", serverFlightsVersion);
            theURL = [NSURL URLWithString:kDataFileOnWeb];
            NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
            dataFileConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
        self.lastFileUpdate = [NSDate date];
        versionsFileConnection = nil;
    }
    else if (connection == dataFileConnection) {
        NSError *err;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
        if (!json) return;
        ASFlightsModel *newModel = [[ASFlightsModel alloc] initWithJSON:json];
        if (newModel.version > self.flights.version) {
            // Save new file on disk
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:kDataFileName];
            [responseData writeToFile:filePath atomically:YES];
            NSLog(@"Flights list saved to: %@", filePath);
            self.flights = newModel;
            // Update the view
            [self.flightsTable reloadData];
        }
        
        dataFileConnection = nil;
    }
}

@end
