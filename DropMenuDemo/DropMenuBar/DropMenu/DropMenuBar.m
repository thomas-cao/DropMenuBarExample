//
//  DropMenuBar.m
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/6/27.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import "DropMenuBar.h"
#import "DropMenuView.h"
#import "MenuAction.h"

#define kHeight [UIScreen mainScreen].bounds.size.height

@interface DropMenuBar ()<DropMenuViewDelegate>
@property (nonatomic, strong) NSMutableArray *menus;

@property (nonatomic, assign) CGRect orginFrame;

@property (nonatomic, assign) CGRect showFilterFrame;

@property (nonatomic, weak) MenuAction *currentAction;

@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, weak) DropMenuView *showMenuView;
@end

@implementation DropMenuBar

- (instancetype)initWithAction:(NSArray <MenuAction *> *)actions {
    
    if (self = [super init]) {
        _actions = actions;
        [self prepareUIWithItems];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
        /** 最下面横线 */
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width / self.actions.count;
    [self.actions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MenuAction *item = obj;
        item.frame = CGRectMake(idx * width, 0, width, self.frame.size.height);
        [item adjustFrame];
    }];
    if (!self.orginFrame.size.width) {
        self.orginFrame = self.frame;
    }
    self.showFilterFrame = CGRectMake(0, self.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.frame.size.height);
    
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - 0.8, self.frame.size.width, 0.8);
    
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}


#pragma mark - setUpUI
- (void)prepareUIWithItems {
    __weak typeof(self) weakSelf = self;
    [self.actions enumerateObjectsUsingBlock:^(MenuAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [weakSelf addSubview:obj];
        [obj addTarget:self action:@selector(actionDidClick:) forControlEvents:UIControlEventTouchUpInside];
        void (^didDismissDropMenu)(void) = ^{
            [weakSelf dismiss];
        };
        [obj setValue:didDismissDropMenu forKeyPath:@"didDismissDropMenu"];
        
        DropMenuView *menuView = [[DropMenuView alloc]initWithAction:obj];
        menuView.delegate = self;
        [weakSelf.menus addObject:menuView];
    }];
    
}

#pragma mark - public
- (void)setActions:(NSArray<MenuAction *> *)actions {
    if (_actions.count)return;
    _actions = actions;
    [self prepareUIWithItems];
}

- (void)reloadMenus {
    [self.showMenuView reloadList];
}

#pragma mark - 按钮点击推出菜单 (并且其他的菜单收起)
-(void)actionDidClick:(MenuAction *)action{
    
    [self.actions enumerateObjectsUsingBlock:^(MenuAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqual:action]) {
            obj.selected = NO;
        }
    }];
    self.currentAction = action;
    NSUInteger index = [self.actions indexOfObject:action];
    DropMenuView *showMenuView = self.menus[index];
    //  将其他的菜单移除
    [self.menus enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DropMenuView *menuView = obj;
        if (![menuView isEqual:showMenuView]) {
            [menuView dismiss];
        }
    }];
    self.showMenuView = showMenuView;
    [showMenuView displayDropViewWithToobar:self];
    
}

- (void)adjustFrameWithShowDetail:(BOOL)show {
    if (show) {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = self.showFilterFrame;
            self.layer.cornerRadius = 0;
            self.currentAction.selected = YES;
            self.bottomLine.hidden = NO;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = self.orginFrame;
            self.layer.cornerRadius = 4;
            self.currentAction.selected = NO;
            self.bottomLine.hidden = YES;
        }];
    }
}

- (void)dismiss {
    //  将其他的菜单移除
    [self.menus enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DropMenuView *menuView = obj;
        [menuView dismiss];
    }];
}


#pragma mark - 协议实现
- (void)dropMenuViewwillDisAppear:(DropMenuView *)view {
    [self adjustFrameWithShowDetail:NO];
    if ([self.delegate respondsToSelector:@selector(dropMenuViewWillDisAppear:selectAction:)]) {
        [self.delegate dropMenuViewWillDisAppear:self selectAction:self.currentAction];
    }
}
- (void)dropMenuViewwillAppear:(DropMenuView *)view {
    [self adjustFrameWithShowDetail:YES];
    if ([self.delegate respondsToSelector:@selector(dropMenuViewWillAppear:selectAction:)]) {
        [self.delegate dropMenuViewWillAppear:self selectAction:self.currentAction];
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)menus {
    
    if (!_menus) {
        _menus = [NSMutableArray arrayWithCapacity:0];
    }
    return _menus;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = [UIColor colorWithWhite:0.85 alpha:0.8];
        _bottomLine.hidden = YES;
    }
    return _bottomLine;
}

@end
