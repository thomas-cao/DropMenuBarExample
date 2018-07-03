//
//  MoreFilterView.m
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/5/20.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import "MoreFilterView.h"
#import "OptionItem.h"

@interface MoreFilterView ()
@property (weak, nonatomic) IBOutlet UIStackView *SaleProgressView;
@property (weak, nonatomic) IBOutlet UIStackView *managerTypeView;
@property (weak, nonatomic) IBOutlet UIStackView *managerTypeView1;

@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;


@end

@implementation MoreFilterView

+ (instancetype) loadFilterView {
    MoreFilterView *filterView = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
    
    filterView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 350);
    return  filterView;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.clearButton.layer.cornerRadius = 4;
    self.clearButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.clearButton.layer.borderWidth = 1;
    [self.clearButton setClipsToBounds:YES];
    self.confirmButton.layer.cornerRadius = 4;

    [self.managerTypeView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OptionItem class]]) {
            OptionItem *item = obj;
            if (!item.titleLabel.text.length) return ;
            [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];

    [self.managerTypeView1.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OptionItem class]]) {
            OptionItem *item = obj;
            if (!item.titleLabel.text.length) return ;
            [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
    
    [self.SaleProgressView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[OptionItem class]]) {
            OptionItem *item = obj;
            if (!item.titleLabel.text.length) return ;
            [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
    
    [self.clearButton addTarget:self action:@selector(clearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)adjustSelectedType:(BOOL)selectedsType {
    
    if (selectedsType) {
        [self.managerTypeView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[OptionItem class]]) {
                OptionItem *item = obj;
                item.selected = NO;
            }
        }];
        [self.managerTypeView1.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[OptionItem class]]) {
                OptionItem *item = obj;
                item.selected = NO;
            }
        }];
    }else {
        [self.SaleProgressView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[OptionItem class]]) {
                OptionItem *item = obj;
                item.selected = NO;
            }
        }];
    }
}


#pragma mark - methods
- (void)itemClick:(OptionItem *)item {
    if ([item.superview isEqual:self.managerTypeView] || [item.superview isEqual:self.managerTypeView1]) {
        [self adjustSelectedType:YES];
    }else if ([item.superview isEqual:self.SaleProgressView]) {
        [self adjustSelectedType:NO];
    }
    
    item.selected = !item.selected;
}

- (void)clearButtonClick:(UIButton *)item {
    // 重置所有选中
    [self adjustSelectedType:YES];
    [self adjustSelectedType:NO];
}

- (void)confirmButtonClick:(UIButton *)btn {
    if (self.didConfirmClick) {
        self.didConfirmClick(@"选中");
    }
}

@end
