//
//  ASFirstViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASExpoViewController.h"
#import "ASExpoView.h"
#import "ASExpoItemView.h"
#import "ASPlanesModel.h"
#import "ASPlanesSection.h"
#import "ASPlane.h"
#import "ASPoint.h"
#import "ASPlanesViewController.h"
#import "ASPlaneDetailsViewController.h"
#import "Reachability.h"

#define kDataFileName @"expo.json"
//#define kWebServerName @"mosairshow2013.ucoz.ru"
#define kWebServerName @"sites.google.com"
//#define kDataFileOnWeb @"http://mosairshow2013.ucoz.ru/expo.json"
#define kDataFileOnWeb @"https://sites.google.com/site/mosairshow2013/expo.json?attredirects=0&d=1"
//#define kVersionsFileOnWeb @"http://mosairshow2013.ucoz.ru/versions.json"
#define kVersionsFileOnWeb @"https://sites.google.com/site/mosairshow2013/versions.json?attredirects=0&d=1"

@interface ASExpoViewController ()

@property (nonatomic, strong) ASPlanesModel* planes;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet ASExpoView *expoView;
@property (weak, nonatomic) ASExpoItemView *selectedItemView;
@property (strong, nonatomic) Reachability *reach;
@property (strong, nonatomic) NSDate *lastFileUpdate;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) ASPoint *userLocation;
@property (nonatomic, weak) UIImageView *userLocationView;
@property (nonatomic) CGRect lastViewBounds;

@end

@implementation ASExpoViewController

@synthesize planes = _planes;
@synthesize selectedItemView = _selectedItemView;

- (CLLocationManager*) locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
    }
    return _locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.lastViewBounds = CGRectMake(0, 0, 0, 0);
    
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
    ASPlanesModel *fileExpo = [[ASPlanesModel alloc] initWithJSON:json];

    if (checkVersion) {
        data = [NSData dataWithContentsOfFile:bundlePath];
        json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (!json) return;
        ASPlanesModel *bundleExpo = [[ASPlanesModel alloc] initWithJSON:json];
        if (bundleExpo.version > fileExpo.version) {
            [fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
            fileExpo = bundleExpo;
        }
    }
    self.planes = fileExpo;
    self.userLocation = [[ASPoint alloc] initWithX:-100 andY:-100];
    [self updateExpoItems];
    [self.locationManager startUpdatingLocation];
    
    // Initiate async update of the expo definition from server
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    self.lastFileUpdate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date] options:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanges:) name:kReachabilityChangedNotification object:nil];
    self.reach = [Reachability reachabilityWithHostName:kWebServerName];
    [self.reach startNotifier];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateExpoItems];
}

-(void)updateExpoItems
{
    CGRect viewRect = self.view.bounds;
    if (self.lastViewBounds.origin.x == viewRect.origin.x &&
        self.lastViewBounds.origin.y == viewRect.origin.y &&
        self.lastViewBounds.size.width == viewRect.size.width &&
        self.lastViewBounds.size.height == viewRect.size.height) {
        NSLog(@"Bounds are the same");
        [self updateUserLocationView];
        return;
    }

    // Remove all currently visible expo items
    for (UIView *item in self.scrollView.subviews) {
        if ([item isKindOfClass:[ASExpoItemView class]]) {
            [(ASExpoItemView*)item removeFromSuperview];
        }
    }
    
    // Set the scrolling area
    CGSize expoSize = self.planes.bounds;
    self.lastViewBounds = viewRect;
    float k = expoSize.width / viewRect.size.width;
    self.scrollView.contentSize = CGSizeMake(viewRect.size.width, expoSize.height / k);
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    
    // Put subViews into scrolling area
    for (ASPlanesSection *section in self.planes.sections) {
        for (ASPlane *plane in section.planes) {
            if (!plane.isVisible) continue;
            CGRect itemRect = CGRectMake(plane.screenRect.origin.x / k, plane.screenRect.origin.y / k, plane.screenRect.size.width / k, plane.screenRect.size.height / k);
            //NSLog(@"plane '%@' at %f:%f:%f:%f", plane.name, itemRect.origin.x, itemRect.origin.y, itemRect.size.width, itemRect.size.height);
            ASExpoItemView *itemView = [[ASExpoItemView alloc] initWithFrame:itemRect modifier:k andPlane:plane];
            itemView.opaque = NO;
            itemView.delegate = self;
            [self.scrollView addSubview:itemView];
        }
    }
    [self updateUserLocationView];
}

-(void)updateUserLocationView
{
    NSLog(@"User location on screen: %f - %f", self.userLocation.x, self.userLocation.y);
    if (!self.userLocationView) {
        UIImage *locationIcon = [UIImage imageNamed:@"location-icon.png"];
        UIImageView *locationView = [[UIImageView alloc] initWithImage:locationIcon];
        locationView.frame = CGRectMake(-100, -100, 14, 20);
        [self.scrollView addSubview:locationView];
        self.userLocationView = locationView;
    }
    CGSize expoSize = self.planes.bounds;
    CGRect viewRect = self.view.bounds;
    float k = expoSize.width / viewRect.size.width;

    CGRect newLocation = self.userLocationView.frame;
    newLocation.origin.x = self.userLocation.x / k - 7;
    newLocation.origin.y = self.userLocation.y / k - 20;
    self.userLocationView.frame = newLocation;
    [self.scrollView bringSubviewToFront:self.userLocationView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doAsyncUpdate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"ShowPlanesList"]) {
        ASPlanesViewController *destination = (ASPlanesViewController *)segue.destinationViewController;
        destination.planes = self.planes;
    }
    if ([segue.identifier isEqualToString:@"ShowPlaneDetails"]) {
        ASPlaneDetailsViewController *destination = (ASPlaneDetailsViewController*)segue.destinationViewController;
        destination.planeName = self.selectedItemView.plane.name;
        destination.descriptionFile = self.selectedItemView.plane.descriptionFile;
    }
}

-(void)expoItemAction:(ASExpoItemView *)item
{
    if (item.plane.descriptionFile.length == 0) {
        return;
    }
    self.selectedItemView = item;
    [self performSegueWithIdentifier:@"ShowPlaneDetails" sender:self];
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
        int serverExpoVersion = ((NSNumber*)[json objectForKey:@"expoVersion"]).intValue;
        if (serverExpoVersion > self.planes.version) {
            NSLog(@"New version of Expo is on the server: %d", serverExpoVersion);
            theURL = [NSURL URLWithString:kDataFileOnWeb];
            NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
            dataFileConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
        versionsFileConnection = nil;
    }
    else if (connection == dataFileConnection) {
        NSError *err;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
        if (!json) return;
        ASPlanesModel *newModel = [[ASPlanesModel alloc] initWithJSON:json];
        if (newModel.version > self.planes.version) {
            // Save new file on disk
            [responseData writeToFile:kDataFileName atomically:YES];
            self.planes = newModel;
            // Update the view
            [self updateExpoItems];
        }
        
        dataFileConnection = nil;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations objectAtIndex:locations.count - 1];
    self.userLocation = [self.planes transformGpsToModel:location.coordinate];
    [self updateUserLocationView];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorLocationUnknown) {
        // ignore
    }
    else if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    }
}


@end
