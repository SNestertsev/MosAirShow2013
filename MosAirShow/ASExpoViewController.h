//
//  ASFirstViewController.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 28.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASExpoItemView.h"

@interface ASExpoViewController : UIViewController <ASExpoItemDelegate> {
    NSURLConnection *versionsFileConnection;
    NSURLConnection *dataFileConnection;
    NSURL *theURL;
    NSMutableData *responseData;
}

@end
