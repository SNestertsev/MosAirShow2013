//
//  ASPlanesViewController.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASPlanesModel;

@interface ASPlanesViewController : UIViewController <UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) ASPlanesModel *planes;

@end
