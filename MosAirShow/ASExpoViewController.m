//
//  ASFirstViewController.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASExpoViewController.h"
#import "ASExpoItemView.h"
#import "ASPlanesModel.h"
#import "ASPlanesSection.h"
#import "ASPlane.h"
#import "ASPoint.h"
#import "ASPlanesViewController.h"
#import "ASPlaneDetailsViewController.h"
#import "Reachability.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <ImageIO/CGImageProperties.h>

#define kDataFileName @"expo.json"
#define kWebServerName @"sites.google.com"
#define kDataFileOnWeb @"https://sites.google.com/site/mosairshow2013/expo.json?attredirects=0&d=1"
#define kVersionsFileOnWeb @"https://sites.google.com/site/mosairshow2013/versions.json?attredirects=0&d=1"

@interface ASExpoViewController ()

@property (nonatomic, strong) ASPlanesModel* planes;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ASExpoItemView *selectedItemView;
@property (strong, nonatomic) Reachability *reach;
@property (strong, nonatomic) NSDate *lastFileUpdate;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) ASPoint *userLocation;
@property (nonatomic, weak) UIImageView *userLocationView;
@property (nonatomic) CGRect lastViewBounds;

@property (strong, atomic) ALAssetsLibrary* photoLibrary;
@property (strong, nonatomic) UIBarButtonItem *cameraButton;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *photoPromptLabel;
@property (nonatomic) BOOL makingPhoto;

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
    
    self.photoPromptLabel.hidden = YES;
    self.makingPhoto = NO;
    BOOL canMakePhotos = NO;
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (hasCamera) {
        NSArray* arr = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([arr indexOfObject:(NSString*)kUTTypeImage] != NSNotFound) {
            canMakePhotos = YES;
            self.photoLibrary = [[ALAssetsLibrary alloc] init];
        }
    }
    if (canMakePhotos) {
        self.cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto:)];
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPhoto:)];
        NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!toolbarButtons) {
            toolbarButtons = [[NSMutableArray alloc] init];
        }
        if (![toolbarButtons containsObject:self.cameraButton]) {
            [toolbarButtons addObject:self.cameraButton];
        }
        [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
    }
    
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
    UIImage *background = [UIImage imageNamed:@"Blueprint.jpg"];
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:background];
    //self.scrollView.backgroundColor = [UIColor lightGrayColor];
    
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
        UIImage *locationIcon = [UIImage imageNamed:@"you-are-here1.png"];
        UIImageView *locationView = [[UIImageView alloc] initWithImage:locationIcon];
        int imageSize = 20;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            imageSize = 40;
        }
        locationView.frame = CGRectMake(-100, -100, imageSize, imageSize);
        [self.scrollView addSubview:locationView];
        self.userLocationView = locationView;
    }
    CGSize expoSize = self.planes.bounds;
    CGRect viewRect = self.view.bounds;
    float k = expoSize.width / viewRect.size.width;

    CGRect newLocation = self.userLocationView.frame;
    newLocation.origin.x = self.userLocation.x / k - newLocation.size.width / 2;
    newLocation.origin.y = self.userLocation.y / k - newLocation.size.height;
    self.userLocationView.frame = newLocation;
    [self.scrollView bringSubviewToFront:self.userLocationView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
    [self doAsyncUpdate];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
    [self cancelPhoto:nil];
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
        return; // Игнорируем "Входы"
    }
    self.selectedItemView = item;
    
    if (self.makingPhoto) {
        [self useCamera];
    }
    else {
        [self performSegueWithIdentifier:@"ShowPlaneDetails" sender:self];
    }
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

- (void)takePhoto:(id)sender
{
    if (self.makingPhoto) return;
    self.makingPhoto = YES;
    self.photoPromptLabel.hidden = NO;
    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    [toolbarButtons removeObject:self.cameraButton];
    if (![toolbarButtons containsObject:self.cancelButton]) {
        [toolbarButtons addObject:self.cancelButton];
    }
    [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
}

-(void)cancelPhoto:(id)sender
{
    if (!self.makingPhoto) return;
    self.makingPhoto = NO;
    self.photoPromptLabel.hidden = YES;
    NSMutableArray *toolbarButtons = [self.navigationItem.rightBarButtonItems mutableCopy];
    [toolbarButtons removeObject:self.cancelButton];
    if (![toolbarButtons containsObject:self.cameraButton]) {
        [toolbarButtons addObject:self.cameraButton];
    }
    [self.navigationItem setRightBarButtonItems:toolbarButtons animated:YES];
}

-(void)useCamera
{
    @try {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePickerController.editing = NO;
        imagePickerController.delegate = (id)self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Error while using camera: %@", exception);
    }
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
        self.lastFileUpdate = [NSDate date];
        versionsFileConnection = nil;
    }
    else if (connection == dataFileConnection) {
        NSError *err;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&err];
        if (!json) return;
        ASPlanesModel *newModel = [[ASPlanesModel alloc] initWithJSON:json];
        if (newModel.version > self.planes.version) {
            // Save new file on disk
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:kDataFileName];
            [responseData writeToFile:filePath atomically:YES];
            NSLog(@"Exposition saved to: %@", filePath);
            self.planes = newModel;
            // Update the view
            self.lastViewBounds = CGRectMake(0, 0, 0, 0);
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
    if (self.userLocation.x > 0) {
        if (self.userLocation.x < self.planes.bounds.width / 3) {
            self.userLocation.x = self.planes.bounds.width / 3;
        }
        else if (self.userLocation.x > self.planes.bounds.width * 2 / 3) {
            self.userLocation.x = self.planes.bounds.width * 2 / 3;
        }
    }
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

#pragma mark - UIImagePickerControllerDelegate Delegate methods
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* originalImage = info[UIImagePickerControllerOriginalImage];    
    NSDictionary* metadata = info[UIImagePickerControllerMediaMetadata];
    NSMutableDictionary* mutableMetadata = [metadata mutableCopy];
    if (self.selectedItemView.plane.name.length > 0) {
        NSMutableDictionary* iptc = [mutableMetadata objectForKey:(NSString*)kCGImagePropertyIPTCDictionary];
        if (iptc == nil) {
            iptc = [NSMutableDictionary dictionary];
            [mutableMetadata setObject:iptc forKey:(NSString*)kCGImagePropertyIPTCDictionary];
        }
        [iptc setObject:self.selectedItemView.plane.name forKey:(NSString*)kCGImagePropertyIPTCCaptionAbstract];
    }
    NSBundle* bundle = [NSBundle mainBundle];
    NSDictionary* bundleInfo = [bundle infoDictionary];
    NSString* bundleName = [bundleInfo objectForKey:@"CFBundleDisplayName"];
    [self.photoLibrary saveImage:originalImage metadata:mutableMetadata toAlbum:bundleName withCompletionBlock:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error while saving photo to library: %@", error.description);
        }
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self cancelPhoto:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self cancelPhoto:nil];
}

@end
