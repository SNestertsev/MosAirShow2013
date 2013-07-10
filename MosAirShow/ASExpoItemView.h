//
//  ASExpoItemView.h
//  AirShow2013
//
//  Created by Sergey Nestertsev on 29.05.13.
//  Copyright (c) 2013 Sergey Nestertsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASExpoItemView;
@class ASPlane;

@protocol ASExpoItemDelegate <NSObject>

-(void)expoItemAction:(ASExpoItemView*)item;

@end

@interface ASExpoItemView : UIView

@property (nonatomic, strong) ASPlane* plane;
@property (nonatomic, weak) id<ASExpoItemDelegate> delegate;

- (id)initWithFrame:(CGRect)frame modifier:(float)modifier andPlane:(ASPlane*)plane;

@end
