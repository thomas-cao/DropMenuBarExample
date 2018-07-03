//
//  ItemModel.m
//  MenuToolDemo
//
//  Created by 魏小庄 on 2018/5/24.
//  Copyright © 2018年 wuchang. All rights reserved.
//

#import "ItemModel.h"

@implementation ItemModel
+ (instancetype)modelWithText:(NSString *)text currentID:(NSString *)currentID isSelect:(BOOL)select{
    ItemModel *model = [[ItemModel alloc]init];
    model.displayText = text;
    model.currentID = currentID;
    model.seleceted = select;
    return model;
}

@end
