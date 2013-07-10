//
//  ASPlane.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 29.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASPlane.h"

#define kNameAttribute @"name"
#define kLabelCornerAttribute @"labelCorner"
#define kRectTopAttribute @"rectTop"
#define kRectLeftAttribute @"rectLeft"
#define kRectWidthAttribute @"rectWidth"
#define kRectHeightAttribute @"rectHeight"
#define kImageFileAttribute @"imageFile"
#define kFlipImageAttribute @"flipImage"
#define kDescriptionAttribute @"description"
#define kLeftMarginAttribute @"leftMargin"
#define kRightMarginAttribute @"rightMargin"
#define kTopMarginAttribute @"topMargin"
#define kBottomMarginAttribute @"bottomMargin"

@implementation ASPlane

-(BOOL)isVisible
{
    return self.screenRect.size.width > 0 && self.screenRect.size.height > 0;
}

-(id)initWithName:(NSString *)name inRect:(CGRect)rect labelInCorner:(int)corner withImage:(NSString *)image andDescription:(NSString *)description
{
    if (self = [super init]) {
        self.name = name;
        self.labelCorner = corner;
        self.screenRect = rect;
        self.imageFileName = image;
        self.descriptionFile = description;
    }
    return self;
}

-(id)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        self.name = [json objectForKey:kNameAttribute];
        self.labelCorner = ((NSNumber*)[json objectForKey:kLabelCornerAttribute]).intValue;
        NSNumber *top = [json objectForKey:kRectTopAttribute];
        NSNumber *left = [json objectForKey:kRectLeftAttribute];
        NSNumber *width = [json objectForKey:kRectWidthAttribute];
        NSNumber *height = [json objectForKey:kRectHeightAttribute];
        self.screenRect = CGRectMake(left.floatValue, top.floatValue, width.floatValue, height.floatValue);
        self.imageFileName = [json objectForKey:kImageFileAttribute];
        self.flipImage = ((NSNumber*)[json objectForKey:kFlipImageAttribute]).boolValue;
        self.descriptionFile = [json objectForKey:kDescriptionAttribute];
        NSNumber *margin = [json objectForKey:kLeftMarginAttribute];
        self.leftMargin = margin.floatValue;
        margin = [json objectForKey:kRightMarginAttribute];
        self.rightMargin = margin.floatValue;
        margin = [json objectForKey:kTopMarginAttribute];
        self.topMargin = margin.floatValue;
        margin = [json objectForKey:kBottomMarginAttribute];
        self.bottomMargin = margin.floatValue;
    }
    return self;
}

@end
