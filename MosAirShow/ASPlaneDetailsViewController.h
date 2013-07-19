//
//  ASPlaneDetailsViewController.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 29.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPlaneDetailsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *planeName;
@property (nonatomic, strong) NSString *descriptionFile;

@end
