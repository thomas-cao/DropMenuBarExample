
***
![一级筛选.gif](https://upload-images.jianshu.io/upload_images/3250089-12c8d14ce8213a76.gif?imageMogr2/auto-orient/strip)

![多级筛选.gif](https://upload-images.jianshu.io/upload_images/3250089-e2043536c69ee5a0.gif?imageMogr2/auto-orient/strip)
> 可以看出最多支持三级筛选，（一般最常用的筛选层级最多也就三级了）并且可以很简单的设计自定义筛选，

##### 这里简单说下几个要点。
1.  我们项目中使用时，筛选栏的初始宽度并不是屏幕的宽度，在点击展开筛选列表时，筛选栏的宽度才修改为屏幕的宽度，当收起筛选列表时，宽度又恢复原始值，这是和其他很多app不同的地方。所以这里我做了一层封装，动态修改`DropMenuBar`的宽度。
2.  大多数的地区筛选列表，产品一般都会设计为，每一级列表的第一列显示`不限` 第二列开始才为地区数据， 这里我们的需求是，
> 当点击第三级的不限，则根据第二级选中的区域做筛选，点击第二级的不限，则根据第一级的选中做筛选，点击第一级的不限，则是真的不限。并且还原actionTitle的显示。 通知刷新数据
``` object -c
 // 表明只有一层数据。。选中第一行则恢复初始的title. 反正显示选中的数据
            [self resetActionTitle:selectModel selectRow:indexPath.row];
            if (self.action.didSelectedMenuResult) {
                self.action.didSelectedMenuResult(indexPath.row, selectModel);
            }
            [self dismiss];
```
3. 展示的列数根据选中的级数展示， 及，默认展示一级列表，如果有选中二级或者三级，则再点击显示时，则显示当前选中的列表层级。
这里涉及到，保存选中的状态，以及何时保存最终选中状态， 我的处理是，先判断当前列表展示的层级，再保存选中。
``` object -c
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
```
4,我们项目中还有一个逻辑是，有一个筛选项需要从api获取，并且实时性很大，需要每次都获取最新的值，这里我借鉴了`UITableView`的做法，提供了一个`reloadData`的方法。
外部只需要 实现代理，重新赋值数据，刷新就可以完成。
``` 
- (void)dropMenuViewWillAppear:(DropMenuBar *)view selectAction:(MenuAction *)action {
    NSLog(@"即将显示");
    if ([action.title isEqualToString:@"one"]) {
        // 模拟每次点击时重新获取最新数据   网络请求返回数据
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            action.ListDataSource = self.oneList;
            [self.menuScreeningView reloadMenus];
            
        });
    }
    
}
```
5. 很大时候我们都需要有些更多自定义的筛选项，使用DropMenuBar 可以更容易的展示，只需要 就可以展示，不需要再关心下拉展示的逻辑，只需要专心设计自定义的筛选。
```
    MenuAction *custom = [MenuAction actionWithTitle:@"自定义" style:MenuActionTypeCustom];
    __weak typeof(self) weakSelf = self;
    custom.displayCustomWithMenu = ^UIView *{
        
        return weakSelf.filterView;
    };
    self.customAction = custom;
```
##### 关于使用
***
在需要展示筛选项的页面，只需要简单的创建；
```
 self.menuScreeningView = [[DropMenuBar alloc] initWithAction:@[one, two,three, custom]];
    self.menuScreeningView.delegate = self;
    self.menuScreeningView.frame = CGRectMake(20, 64, self.view.frame.size.width - 40, 45);
    self.menuScreeningView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.menuScreeningView];
```
实例每一个action,
```
 MenuAction *three = [MenuAction actionWithTitle:@"three" style:MenuActionTypeList];
    
    three.ListDataSource = self.threeuList;
    three.didSelectedMenuResult = ^(NSInteger index, ItemModel *selecModel) {
        NSLog(@"3333 ==== %@", selecModel.displayText);
    };
```
即可轻松展示，再也不用操心那些烦人的三级选中的逻辑了，（这种逻辑一次就够了，没啥技术含量的活就交给小弟）

