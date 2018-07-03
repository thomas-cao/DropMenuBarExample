//
//  DropMenuView.h
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/6/27.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuAction, DropMenuView;

@protocol DropMenuViewDelegate <NSObject>
- (void)dropMenuViewwillAppear:(DropMenuView *)view;
- (void)dropMenuViewwillDisAppear:(DropMenuView *)view;
@end

@interface DropMenuView : UIView
@property (nonatomic, weak) id<DropMenuViewDelegate> delegate;

- (instancetype)initWithAction:(MenuAction *)action;

- (void)displayDropViewWithToobar:(UIView *)toobar;

- (void)dismiss;

- (void)reloadList;
@end
