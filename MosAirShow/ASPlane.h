//
//  ASPlane.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 29.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASPlane : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CGRect screenRect;
@property (nonatomic) int labelCorner;
@property (nonatomic, strong) NSString *imageFileName;
@property (nonatomic) BOOL flipImage;
@property (nonatomic, strong) NSString *descriptionFile;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) float leftMargin;
@property (nonatomic) float topMargin;
@property (nonatomic) float rightMargin;
@property (nonatomic) float bottomMargin;

-(id)initWithName:(NSString*)name inRect:(CGRect)rect labelInCorner:(int)corner withImage:(NSString *)image andDescription:(NSString *)description;
-(id)initWithJSON:(NSDictionary *)json;

@end
