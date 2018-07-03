//
//  MenuAction.m
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/5/18.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import "MenuAction.h"

@interface MenuAction ()
@property (nonatomic, assign, readwrite) MenuActionStyle actionStyle;
@property (nonatomic, copy, readwrite) NSString *title;
/** 私有属性用于自定义视图 主动移除筛选列表  */
@property (nonatomic, copy) void (^didDismissDropMenu)(void);

@end

@implementation MenuAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MenuActionStyle)style {
    MenuAction *action = [[MenuAction alloc]init];
    action.actionStyle = style;
    action.title = title;
    [action setTitle:title forState:UIControlStateNormal];
    action.titleLabel.font =  [UIFont systemFontOfSize:14];
    action.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [action setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [action setImage:[UIImage imageNamed:@"btn_sx_down"] forState:UIControlStateNormal];
    [action setImage:[UIImage imageNamed:@"btn_triangle"] forState:UIControlStateSelected];
    
    return action;
}


-(void)adjustFrame {
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.imageView.bounds.size.width + 2, 0, self.imageView.bounds.size.width + 10)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width + 10, 0, -self.titleLabel.bounds.size.width + 2)];
}

- (void)adjustTitle:(NSString *)title textColor:(UIColor *)color {
     if (![title isKindOfClass:[NSString class]]) return;
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateNormal];
    [self adjustFrame];
    // 移除筛选列表
    if(self.didDismissDropMenu){
        self.didDismissDropMenu();
    }
}

@end
