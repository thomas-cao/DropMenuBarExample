//
//  DropMenuView.m
//  LinkageMenu
//
//  Created by 魏小庄 on 2018/6/27.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import "DropMenuView.h"
#import "MenuAction.h"
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface DropMenuView ()<UITableViewDelegate, UITableViewDataSource>
{
@private
    /** 保存 选择的数据(行数) */
    NSInteger selects[3];
}
/** 表视图数组 */
@property (nonatomic, strong) NSArray *tableViewArr;
@property (nonatomic, strong) MenuAction *action;
@property (nonatomic, strong) NSArray *oneListDataSource;
@property (nonatomic, strong) NSArray *twoListDataSource;
@property (nonatomic, strong) NSArray *threeListDataSource;

@property (nonatomic, assign) NSInteger firstSelectRow;
@property (nonatomic, assign) NSInteger secondSelectRow;
@property (nonatomic, assign) NSInteger lastSelectRow;
// 标记，用于记录是否是恢复上次的选中
@property (nonatomic, assign) BOOL flag;


@end

@implementation DropMenuView

- (instancetype)initWithAction:(MenuAction *)action {
    if (self = [super init]) {
        self.action = action;
        self.backgroundColor = [UIColor colorWithWhite:0.65 alpha:0.35];
        if (action.actionStyle == MenuActionTypeList) {
            [self adjustTableViewsWithCount:1];
        }
        /** 保存 初始值为-1 */
        for (int i = 0; i < 3; i++) {
            selects[i] = -1;
        }
    }
    return self;
}

-(void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)displayDropViewWithToobar:(UIView *)toobar {
    
    if (!self.superview) {
        // 初始位置 设置
        CGFloat x = 0.f;
        CGFloat y = toobar.frame.origin.y + toobar.frame.size.height;
        CGFloat w = kWidth;
        CGFloat h = kHeight - y;
        self.frame = CGRectMake(x, y, w, h);
        if (self.action.actionStyle == MenuActionTypeCustom) {
            if (self.action.displayCustomWithMenu) {
                UIView *customView = self.action.displayCustomWithMenu();
                [self addSubview:customView];
            }
        }else {
            [self adjustTableViewsWithCount:1];
            [self resetSelect];
        }
        [toobar.superview addSubview:self];
        if ([self.delegate respondsToSelector:@selector(dropMenuViewwillAppear:)]) {
            [self.delegate dropMenuViewwillAppear:self];
        }
    }else {
        [self dismiss];
    }
}

- (void)dismiss{
    
    if(self.superview) {
        
        [self endEditing:YES];
        if ([self.delegate respondsToSelector:@selector(dropMenuViewwillDisAppear:)]) {
            [self.delegate dropMenuViewwillDisAppear:self];
        }
        [self removeFromSuperview];
    }
}

- (void)reloadList {
    [self.tableViewArr enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL * _Nonnull stop) {
        [tableView reloadData];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    point.y += self.frame.origin.y;
    CALayer *layer = [self.layer hitTest:point];
    if (layer == self.layer) {
        [self dismiss];
    }
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableViewArr[0]) {
        self.oneListDataSource = self.action.ListDataSource;
        return self.action.ListDataSource.count;
    }else if (tableView == self.tableViewArr[1]) {
        // 根据第一层选中的索引获取包含的第二层数组
        ItemModel *firstModel =self.action.ListDataSource[self.firstSelectRow];
        self.twoListDataSource = firstModel.dataSource;
        return firstModel.dataSource.count;
    }else {
        
        ItemModel *firstModel =self.action.ListDataSource[self.firstSelectRow];
        ItemModel *secondModel = firstModel.dataSource[self.secondSelectRow];
        self.threeListDataSource = secondModel.dataSource;
        return secondModel.dataSource.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.backgroundColor = [UIColor clearColor];
    ItemModel *currentModel;
    if (tableView == self.tableViewArr[0]) {
        currentModel = self.action.ListDataSource[indexPath.row];
        
    }else if (tableView == self.tableViewArr[1]) {
        // 根据第一层选中的索引获取包含的第二层数组
        ItemModel *firstModel =self.action.ListDataSource[self.firstSelectRow];
        currentModel = firstModel.dataSource[indexPath.row];
        
    }else {
        ItemModel *firstModel =self.action.ListDataSource[self.firstSelectRow];
        ItemModel *secondModel = firstModel.dataSource[self.secondSelectRow];
        currentModel = secondModel.dataSource[indexPath.row];
    }
    cell.textLabel.text = currentModel.displayText;
    cell.textLabel.textColor = currentModel.seleceted ? [UIColor orangeColor] : [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 如果调用  [tableView reloadData]; 则 tableView.indexPathForSelectedRow.row; 就会清空， 故就此处理。
    if (tableView == self.tableViewArr[0]) {
        // 如果是恢复上次的选中，则不执行一下逻辑。
        if(self.flag){
            self.firstSelectRow = selects[0];
            self.flag = NO;
            return;
        }
        self.firstSelectRow = tableView.indexPathForSelectedRow.row;
        [self resetOldSelectWithDataSource:self.oneListDataSource selectRow:indexPath.row];
        [tableView reloadData];
        
        ItemModel *selectModel = self.oneListDataSource[indexPath.row];
        if (selectModel.dataSource.count) {
            UITableView *tableView = self.tableViewArr[1];
            [tableView reloadData];
            // 如果是二级列表，选择第一级时，重置第二级的选中。
            [self resetOldSelectWithDataSource:self.twoListDataSource selectRow:0];
            [self adjustTableViewsWithCount:2];
        }else {
            // 表明只有一层数据。。选中第一行则恢复初始的title. 反正显示选中的数据
            [self resetActionTitle:selectModel selectRow:indexPath.row];
            if (self.action.didSelectedMenuResult) {
                self.action.didSelectedMenuResult(indexPath.row, selectModel);
            }
            [self dismiss];
        }
        // 如果选中第一级的不限，重置所有选中
        if (indexPath.row == 0) {
            for (int i = 0; i < 3; i++) {
                selects[i] = -1;
            }
        }
        
    }else if (tableView == self.tableViewArr[1]) {
        if(self.flag) {
            self.flag = NO;
            self.secondSelectRow = selects[1];
            return;
        }
        ItemModel *selectModel = self.twoListDataSource[indexPath.row];
        // 点击第二层时保存第一层选中的。
        if (!selectModel.dataSource.count) {
            selects[0] = self.firstSelectRow;
            selects[1] = tableView.indexPathForSelectedRow.row;
        }
        self.secondSelectRow = tableView.indexPathForSelectedRow.row;
        [self resetOldSelectWithDataSource:self.twoListDataSource selectRow:indexPath.row];
        [tableView reloadData];
        
        if (selectModel.dataSource.count) {
            UITableView *tableView = self.tableViewArr[2];
            [tableView reloadData];
            // 如果是三级级列表，选择第二级时，重置第三级的选中。
            [self resetOldSelectWithDataSource:self.threeListDataSource selectRow:0];
            [self adjustTableViewsWithCount:3];
        }else {
            if(indexPath.row == 0) {
                // 清除第三级选中的记录
                selects[2] = -1;
                // 如果选中的是0， 则将上一级选中的数据返回
                [self resetActionTitle:self.oneListDataSource[self.firstSelectRow] selectRow:1];
                if (self.action.didSelectedMenuResult) {
                    self.action.didSelectedMenuResult(self.firstSelectRow, self.oneListDataSource[self.firstSelectRow]);
                }
                [self dismiss];
            }else {
                [self resetActionTitle:selectModel selectRow:indexPath.row];
                if (self.action.didSelectedMenuResult) {
                    self.action.didSelectedMenuResult(indexPath.row, selectModel);
                }
                [self dismiss];
            }
        }
        
    }else {
        if(self.flag) {
            self.flag = NO;
            self.lastSelectRow = selects[2];
            return;
        }
        self.lastSelectRow = tableView.indexPathForSelectedRow.row;
        selects[0] = self.firstSelectRow;
        selects[1] = self.secondSelectRow;
        selects[2] = tableView.indexPathForSelectedRow.row;
        
        [self resetOldSelectWithDataSource:self.threeListDataSource selectRow:indexPath.row];
        [tableView reloadData];
        
        ItemModel *selectModel = self.threeListDataSource[indexPath.row];
        if (indexPath.row == 0 ) {
            // 如果选中的是0， 则将上一级选中的数据返回
            [self resetActionTitle:self.twoListDataSource[self.secondSelectRow] selectRow:1];
            if (self.action.didSelectedMenuResult) {
                self.action.didSelectedMenuResult(self.secondSelectRow, self.twoListDataSource[self.secondSelectRow]);
            }
            
        }else {
            [self resetActionTitle:selectModel selectRow:indexPath.row];
            if (self.action.didSelectedMenuResult) {
                self.action.didSelectedMenuResult(indexPath.row, selectModel);
            }
        }
        
        [self dismiss];
    }
    
}


#pragma mark - 重置TableView的 位置
-(void)adjustTableViewsWithCount:(int)count{
    
    [self.tableViewArr enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL * _Nonnull stop) {
        tableView.frame = CGRectZero;
    }];
    for (int i = 0; i < count; i++) {
        UITableView *tableView = self.tableViewArr[i];
        CGRect adjustFrame = self.frame;
        adjustFrame.size.width = kWidth / count ;
        adjustFrame.origin.x = adjustFrame.size.width * i;
        adjustFrame.size.height = adjustFrame.size.height * 0.4;
        adjustFrame.origin.y = 0;
        
        tableView.frame = adjustFrame;
    }
}

#pragma mark - 重置选中
- (void)resetSelect {
    
    self.flag = NO;
    // 三级列表选中
    if(self.threeListDataSource.count && selects[2] >= 0) {
        [self adjustTableViewsWithCount:3];
        // 选中TableView某一行
        [self selectOldRecord:0];
        [self selectOldRecord:1];
        [self selectOldRecord:2];
        // 如果是两级列表 并且选中了第二例，则显示选中状态。
        [self resetOldSelectWithDataSource:self.oneListDataSource selectRow:selects[0]];
        [self resetOldSelectWithDataSource:self.twoListDataSource selectRow:selects[1]];
        [self resetOldSelectWithDataSource:self.threeListDataSource selectRow:selects[2]];
        
        // 两级列表选中
    }else if (selects[2] < 0 && self.twoListDataSource.count && selects[1] >= 0) {
        [self adjustTableViewsWithCount:2];
        // 选中TableView某一行
        [self selectOldRecord:0];
        [self selectOldRecord:1];
        // 如果是两级列表 并且选中了第二例，则显示选中状态。
        [self resetOldSelectWithDataSource:self.oneListDataSource selectRow:selects[0]];
        [self resetOldSelectWithDataSource:self.twoListDataSource selectRow:selects[1]];
        
    }else {
        // 如果是一级列表，直接返回
        if (!self.twoListDataSource.count)  return;
        [self resetOldSelectWithDataSource:self.oneListDataSource selectRow:0];
        [self.tableViewArr[0] setContentOffset:CGPointZero];
        [self.tableViewArr[0] reloadData];
    }
}

#pragma mark - 重置actionTitle 的文字
- (void)resetActionTitle:(ItemModel *)selectModel selectRow:(NSInteger)row {
    // 表明只有一层数据。。选中第一行则恢复初始的title. 反正显示选中的数据
    if(row == 0) {
        [self.action setTitle:self.action.title forState:UIControlStateNormal];
        [self.action setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else {
        [self.action setTitle:selectModel.displayText forState:UIControlStateNormal];
        [self.action setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
    [self.action adjustFrame];
}

#pragma Mark - 选中的列表切换时，重置选中状态
- (void)resetOldSelectWithDataSource:(NSArray *)dataSource selectRow:(NSInteger) row {
    [dataSource enumerateObjectsUsingBlock:^(ItemModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.seleceted = NO;
    }];
    ItemModel *selectModel = dataSource[row];
    selectModel.seleceted = YES;
}


- (void)selectOldRecord:(NSInteger)idx {
    self.flag = YES;
    // 选中TableView某一行
    UITableView *tableView = self.tableViewArr[idx];
    if ([tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [tableView.delegate tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:selects[idx] inSection:0]];
    }
    [tableView reloadData];
}


/** 懒加载 */
-(NSArray *)tableViewArr{
    
    if (_tableViewArr == nil) {
        
        _tableViewArr = @[[[UITableView alloc] init], [[UITableView alloc] init], [[UITableView alloc] init]];
        __weak typeof(self)weakSelf = self;
        [_tableViewArr enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DropCell"];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.frame = CGRectMake(0, 0, 0, 0);
            tableView.showsVerticalScrollIndicator = NO;
            tableView.tableFooterView = [UIView new];
            [weakSelf addSubview:tableView];
            switch (idx) {
                case 0:
                    tableView.backgroundColor = [UIColor whiteColor];
                    break;
                case 1:
                    tableView.backgroundColor = [UIColor colorWithRed:240/ 255.0 green:240/ 255.0 blue:240/ 255.0 alpha:1.0];
                    break;
                case 2:
                    tableView.backgroundColor = [UIColor colorWithRed:240/ 255.0 green:240/ 255.0 blue:240/ 255.0 alpha:1.0];
                    break;
                    
                default:
                    break;
            }
            
        }];
        
    }
    
    return _tableViewArr;
}

@end
