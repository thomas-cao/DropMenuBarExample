//
//  MoreFilterView.h
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/5/20.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreFilterView : UIView
@property (nonatomic, copy) void (^didConfirmClick)(NSString *title);


+ (instancetype) loadFilterView;


@end
