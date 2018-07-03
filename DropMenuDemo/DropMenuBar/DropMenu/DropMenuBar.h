//
//  DropMenuBar.h
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/6/27.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuAction, DropMenuBar;
@protocol DropMenuBarDelegate <NSObject>
- (void)dropMenuViewWillAppear:(DropMenuBar *)view selectAction:(MenuAction *)action;
- (void)dropMenuViewWillDisAppear:(DropMenuBar *)view selectAction:(MenuAction *)action;
@end


@interface DropMenuBar : UIView
/**  */
@property (nonatomic, strong) NSArray <MenuAction *>*actions;

@property (nonatomic, weak) id<DropMenuBarDelegate> delegate;

- (instancetype)initWithAction:(NSArray <MenuAction *> *)actions;

// 刷新筛选菜单
- (void)reloadMenus;
@end
