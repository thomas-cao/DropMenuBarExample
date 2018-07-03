//
//  ViewController.m
//  DropMenuDemo
//
//  Created by 魏小庄 on 2018/7/3.
//  Copyright © 2018年 魏小庄. All rights reserved.
//

#import "ViewController.h"
#import "MoreFilterView.h"
#import "DropMenuBar.h"
#import "MenuAction.h"
#import "ItemModel.h"

@interface ViewController () <DropMenuBarDelegate>
@property (nonatomic, strong) DropMenuBar *menuScreeningView;  //条件选择器

@property (nonatomic, strong) MoreFilterView *filterView;

@property (nonatomic, strong) NSMutableArray *oneList;
@property (nonatomic, strong) NSMutableArray *twoList;
@property (nonatomic, strong) NSMutableArray *threeuList;
@property (nonatomic, weak) MenuAction *customAction;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.oneList = [NSMutableArray arrayWithCapacity:0];
    self.twoList = [NSMutableArray arrayWithCapacity:0];
    self.threeuList = [NSMutableArray arrayWithCapacity:0];
    
    
    [self creatData];
    
    self.navigationController.navigationBar.barTintColor =  [UIColor colorWithRed:0.0 green:145.0f/255.0f blue:67.0f/255.0f alpha:1.000];
    self.view.backgroundColor = [UIColor yellowColor];
    
    MenuAction *one = [MenuAction actionWithTitle:@"one" style:MenuActionTypeList];
    //     one.ListDataSource = self.oneList;
    one.didSelectedMenuResult = ^(NSInteger index, ItemModel *selecModel) {
        NSLog(@"1111 === %@", selecModel.displayText);
    };
    MenuAction *two = [MenuAction actionWithTitle:@"two" style:MenuActionTypeList];
    two.ListDataSource = self.twoList;
    two.didSelectedMenuResult = ^(NSInteger index, ItemModel *selecModel) {
        NSLog(@"2222 ==== %@", selecModel.displayText);
    };
    
    MenuAction *three = [MenuAction actionWithTitle:@"three" style:MenuActionTypeList];
    
    three.ListDataSource = self.threeuList;
    three.didSelectedMenuResult = ^(NSInteger index, ItemModel *selecModel) {
        NSLog(@"3333 ==== %@", selecModel.displayText);
    };
    
    MenuAction *custom = [MenuAction actionWithTitle:@"自定义" style:MenuActionTypeCustom];
    __weak typeof(self) weakSelf = self;
    custom.displayCustomWithMenu = ^UIView *{
        
        return weakSelf.filterView;
    };
    self.customAction = custom;
    
    self.menuScreeningView = [[DropMenuBar alloc] initWithAction:@[one, two,three, custom]];
    self.menuScreeningView.delegate = self;
    self.menuScreeningView.frame = CGRectMake(20, 64, self.view.frame.size.width - 40, 45);
    self.menuScreeningView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.menuScreeningView];
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)creatData {
    
    for (int i = 0; i < 15; i++) {
        BOOL select = i == 0;
        ItemModel *model = [ItemModel modelWithText:[NSString stringWithFormat:@" == %d", i] currentID:[NSString stringWithFormat:@"%d", i] isSelect:select];
        [self.oneList addObject:model];
    }
    
    
    // 两级列表
    for (int i = 0; i < 15; i++) {
        ItemModel *model;
        
        if(i != 0) {
            model = [ItemModel modelWithText:[NSString stringWithFormat:@" <=> %d", i] currentID:[NSString stringWithFormat:@"%d", i] isSelect:i == 0];
            NSMutableArray *temp = [NSMutableArray array];
            for (int j = 0; j < 10; j++) {
                
                ItemModel *layerModel = [ItemModel modelWithText:[NSString stringWithFormat:@"%d $$ %d",i, j] currentID:[NSString stringWithFormat:@"%d", j] isSelect:j == 0];
                [temp addObject:layerModel];
            }
            model.dataSource = temp;
        }else {
            model = [ItemModel modelWithText:[NSString stringWithFormat:@"不限"] currentID:[NSString stringWithFormat:@"%d", i] isSelect:i == 0];
        }
        
        [self.twoList addObject:model];
    }
    
    
    
    
    
    
    // 三级列表
    for (int i = 0; i < 15; i++) {
        ItemModel *model;
        if(i == 0) {
            model = [ItemModel modelWithText:[NSString stringWithFormat:@"不限"] currentID:[NSString stringWithFormat:@"%d", i] isSelect:i == 0];
        }else {
            
            model = [ItemModel modelWithText:[NSString stringWithFormat:@" <一级> %d", i] currentID:[NSString stringWithFormat:@"%d", i] isSelect:i == 0];
            
            
            NSMutableArray *temp = [NSMutableArray array];
            for (int j = 0; j < 10; j++) {
                ItemModel *layerModel;
                if (j == 0) {
                    layerModel = [ItemModel modelWithText:[NSString stringWithFormat:@"不限"] currentID:[NSString stringWithFormat:@"%d", j] isSelect:j == 0];
                }else {
                    
                    layerModel = [ItemModel modelWithText:[NSString stringWithFormat:@"%d 二级 %d",i, j] currentID:[NSString stringWithFormat:@"%d", j] isSelect:j == 0];
                    
                    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
                    for (int x = 0; x < 12; x++) {
                        ItemModel *layerModel;
                        
                        if (x == 0) {
                            layerModel = [ItemModel modelWithText:[NSString stringWithFormat:@"不限"] currentID:[NSString stringWithFormat:@"%d", x] isSelect:x == 0];
                        }else {
                            layerModel = [ItemModel modelWithText:[NSString stringWithFormat:@"%d 三级 %d",j, x] currentID:[NSString stringWithFormat:@"%d", x] isSelect:x == 0];
                            
                        }
                        [temp addObject:layerModel];
                    }
                    layerModel.dataSource = temp;
                    
                }
                
                [temp addObject:layerModel];
                
                
            }
            model.dataSource = temp;
            
            
        }
        
        
        [self.threeuList addObject:model];
    }
}

#pragma mark - DropMenuBarDelegate

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

- (void)dropMenuViewWillDisAppear:(DropMenuBar *)view selectAction:(MenuAction *)action {
    NSLog(@"即将消失");
}



- (MoreFilterView *)filterView {
    if (!_filterView) {
        _filterView = [MoreFilterView loadFilterView];
        __weak typeof(self) weakSelf = self;
        _filterView.didConfirmClick = ^(NSString *title) {
            [weakSelf.customAction adjustTitle:title textColor:[UIColor orangeColor]];
        };
    }
    return _filterView;
}




@end
