//
//  ItemModel.h
//  MenuToolDemo
//
//  Created by 魏小庄 on 2018/5/24.
//  Copyright © 2018年 wuchang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemModel : NSObject
// 筛选条上显示的文字
@property (nonatomic, copy) NSString *displayText;
// 当前筛选条的id;
@property (nonatomic, copy) NSString *currentID;
// 是否显示选中。
@property (nonatomic, assign) BOOL seleceted;
// 多级列表时，存储下一级的数据。
@property (nonatomic, strong) NSArray *dataSource;

+ (instancetype) modelWithText:(NSString *)text currentID:(NSString *)currentID isSelect:(BOOL)select;

@end
