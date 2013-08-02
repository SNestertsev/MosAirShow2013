//
//  ASExpoItemView.m
//  AirShow2013
//
//  Created by Sergey Nestertsev on 29.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import "ASExpoItemView.h"
#import "ASPlane.h"

@interface ASExpoItemView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation ASExpoItemView

@synthesize imageView = _imageView;

-(id)initWithFrame:(CGRect)frame modifier:(float)modifier andPlane:(ASPlane*)plane
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.plane = plane;
        
        if (self.plane.imageFileName.length > 0) {
            UIImage *image = [UIImage imageNamed:self.plane.imageFileName];
            //image = [ASExpoItemView imageWithShadowForImage:image andFlip:plane.flipImage];
            CGRect imageRect = CGRectMake(self.bounds.origin.x + self.plane.leftMargin / modifier, self.bounds.origin.y + self.plane.topMargin / modifier, self.bounds.size.width - self.plane.leftMargin / modifier - self.plane.rightMargin / modifier, self.bounds.size.height - self.plane.topMargin / modifier - self.plane.bottomMargin / modifier);
            self.imageView = [[UIImageView alloc] initWithFrame:imageRect];
            self.imageView.image = image;
            self.imageView.backgroundColor = [UIColor clearColor];
            self.imageView.opaque = NO;
            [self addSubview:self.imageView];
        }
        
        if (self.plane.name.length > 0) {
            self.nameLabel = [UILabel new];
            self.nameLabel.text = self.plane.name;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                self.nameLabel.font = [self.nameLabel.font fontWithSize:[UIFont labelFontSize] * 2];
            }
            [self.nameLabel sizeToFit];
            CGRect labelRect = self.nameLabel.frame;
            switch (self.plane.labelCorner) {
                case 0: // top left
                    labelRect.origin = CGPointMake(0, 0);
                    break;
                case 1: // top right
                    labelRect.origin = CGPointMake(frame.size.width - labelRect.size.width, 0);
                    break;
                case 2: // bottom right
                    labelRect.origin = CGPointMake(frame.size.width - labelRect.size.width, frame.size.height - labelRect.size.height);
                    break;
                default:    // bottom left
                    labelRect.origin = CGPointMake(0, frame.size.height - labelRect.size.height);
                    break;
            }
            self.nameLabel.frame = labelRect;
            self.nameLabel.opaque = NO;
            self.nameLabel.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.2f];
            [self addSubview:self.nameLabel];
        }
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:self.tapRecognizer];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{
    if (self.imageView) {
        [super drawRect:rect];
        return;
    }
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor blackColor] setStroke];
    [[UIColor grayColor] setFill];
    [path fill];
    [path stroke];
}*/

- (void)handleTap
{
    if (self.tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.delegate expoItemAction:self];
    }
}

+(UIImage*)imageWithShadowForImage:(UIImage*)initialImage andFlip:(BOOL)flip
{
    UIImage *shadowedImage;
    @try {
        float blurSize = 30.0f;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef shadowContext = CGBitmapContextCreate(NULL, initialImage.size.width + blurSize * 2, initialImage.size.height + blurSize * 2, CGImageGetBitsPerComponent(initialImage.CGImage), 0, colorSpace, kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        if (!shadowContext)
            return nil;
        
        if (flip) {
            CGContextSetShadowWithColor(shadowContext, CGSizeMake(-blurSize/2, -blurSize/2), blurSize, [UIColor blackColor].CGColor);
        }
        else {
            CGContextSetShadowWithColor(shadowContext, CGSizeMake(blurSize/2, -blurSize/2), blurSize, [UIColor blackColor].CGColor);
        }
        CGContextDrawImage(shadowContext, CGRectMake(blurSize, blurSize, initialImage.size.width, initialImage.size.height), initialImage.CGImage);
        
        CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
        CGContextRelease(shadowContext);
        
        if (flip) {
            shadowedImage = [UIImage imageWithCGImage:shadowedCGImage scale:initialImage.scale orientation:UIImageOrientationUpMirrored];
        }
        else {
            shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
        }
        CGImageRelease(shadowedCGImage);
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    return shadowedImage;
}

@end
