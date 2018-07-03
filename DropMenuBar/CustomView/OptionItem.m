//
//  OptionItem.m
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/5/21.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import "OptionItem.h"

@interface OptionItem ()
@property (nonatomic, strong) UIImageView *signImageView;

@end

@implementation OptionItem
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self prepareUI];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 4;
    [self setClipsToBounds:YES];
    self.signImageView.frame = CGRectMake(self.frame.size.width - 10, 0, 10, 10);
}

- (void)prepareUI {
    
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];

    if (self.titleLabel.text) {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0;
        [self addSubview:self.signImageView];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.signImageView.hidden = !selected;
    if (selected) {
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    }else {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}


#pragma mark - lazy

- (UIImageView *)signImageView {
    if (!_signImageView) {
        _signImageView = [[UIImageView alloc]init];
        _signImageView.image = [UIImage imageNamed:@"image_new_sure"];
        _signImageView.contentMode = UIViewContentModeScaleAspectFit;
        _signImageView.hidden = YES;
    }
    return _signImageView;
}
@end
