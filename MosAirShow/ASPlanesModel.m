//
//  ASPlane.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASPlanesModel.h"
#import "ASPlanesSection.h"
#import "ASPlane.h"
#import "ASGpsBinding.h"

#define kExpoVersionAttribute @"expoVersion"
#define kExpoDateAttribute @"expoDate"
#define kDateFormat @"yyyy-MM-dd"
#define kBoundsWidthAttribute @"boundsWidth"
#define kBoundsHeightAttribute @"boundsHeight"
#define kSectionsArrayAttribute @"sections"
#define kGpsBindingsArrayAttribute @"gpsBindings"

@implementation ASPlanesModel

@synthesize sections = _sections;
@synthesize gpsBindings = _gpsBindings;

-(NSMutableArray *)sections
{
    if (!_sections) {
        _sections = [[NSMutableArray alloc] init];
    }
    return _sections;
}

-(NSMutableArray *)gpsBindings
{
    if (!_gpsBindings) {
        _gpsBindings = [[NSMutableArray alloc] init];
    }
    return _gpsBindings;
}

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        self.version = ((NSNumber*)[json objectForKey:kExpoVersionAttribute]).intValue;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kDateFormat];
        self.expoDate = [dateFormatter dateFromString:[json objectForKey:kExpoDateAttribute]];
        NSNumber *width = [json objectForKey:kBoundsWidthAttribute];
        NSNumber *height = [json objectForKey:kBoundsHeightAttribute];
        self.bounds = CGSizeMake(width.floatValue, height.floatValue);
        NSArray* jsonSections = [json objectForKey:kSectionsArrayAttribute];
        for (NSDictionary* jsonSection in jsonSections) {
            [self.sections addObject:[[ASPlanesSection alloc] initWithJSON:jsonSection]];
        }
        NSArray *jsonGpsBindings = [json objectForKey:kGpsBindingsArrayAttribute];
        for (NSDictionary *jsonBinding in jsonGpsBindings) {
            [self.gpsBindings addObject:[[ASGpsBinding alloc] initWithJSON:jsonBinding]];
        }
    }
    return self;
}

-(NSArray *)sectionNames
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:self.sections.count];
    for (ASPlanesSection *sec in self.sections) {
        [result addObject:sec.index];
    }
    return result;
}

-(ASPlanesSection *)addSectionWithName:(NSString *)name andIndex:(NSString *)index
{
    for (ASPlanesSection *sec in self.sections) {
        if ([sec.name isEqualToString:name]) {
            return sec;
        }
    }
    ASPlanesSection* newSection = [[ASPlanesSection alloc] init];
    newSection.name = name;
    newSection.index = index;
    [self.sections addObject:newSection];
    return newSection;
}

-(CGRect)getBounds
{
    float x = 0.0f;
    float y = 0.0f;
    float width = 0.0f;
    float height = 0.0f;
    for (ASPlanesSection *section in self.sections) {
        for (ASPlane *plane in section.planes) {
            if (plane.screenRect.origin.x + plane.screenRect.size.width > width) {
                width = plane.screenRect.origin.x + plane.screenRect.size.width;
            }
            if (plane.screenRect.origin.y + plane.screenRect.size.height > height) {
                height = plane.screenRect.origin.y + plane.screenRect.size.height;
            }
        }
    }
    return CGRectMake(x, y, width, height);
}

@end
