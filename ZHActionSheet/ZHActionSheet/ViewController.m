//
//  ViewController.m
//  ZHActionSheet
//
//  Created by Lee on 2018/10/11.
//  Copyright © 2018年 leezhihua. All rights reserved.
//

#import "ViewController.h"
#import <ZHActionSheet/ZHActionSheet.h>
#import "ActionSheetItemCell.h"

@interface ViewController ()<ZHActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataSource = @[@"Objective-C",@"Swift",@"React Native",@"Java",@"HTML 5"].mutableCopy;
    
}
- (IBAction)showSystemActionSheet:(UIButton *)sender {
    ZHActionSheet *actionSheet = [[ZHActionSheet alloc] initActionSheetWithTitle:@"ActionSheet" contents:@[@"一",@"二",@"三",@"四",@"五"] cancels:@[@"取消",@"删除"]];
    actionSheet.actionSheetType = ActionSheetTypeSystem;
    actionSheet.subtitle = @"System Type";
    [actionSheet addContent:@"〇" atIndex:0];
    [actionSheet addContent:@"六" atIndex:6];
    [actionSheet removeContentAtIndex:0];
    NSLog(@"---%@", actionSheet.contents);
    [actionSheet setClickedContent:^(ZHActionSheet *actionSheet, NSUInteger index) {
        NSLog(@"==========ZHActionSheet click at index %ld", index);
    }];
    [actionSheet show];
}

- (IBAction)showDefaultActionSheet:(UIButton *)sender {
    ZHActionSheet *actionSheet = [[ZHActionSheet alloc] initActionSheetWithTitle:nil contents:@[@"一",@"二",@"三",@"四",@"五"] cancels:@[@"取消",@"删除"]];
    actionSheet.actionSheetType = ActionSheetTypeDefault;
    actionSheet.subtitle = @"Default Type";
    [actionSheet addContent:@"〇" atIndex:0];
    [actionSheet addContent:@"六" atIndex:6];
    [actionSheet setCancelAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor purpleColor]} atIndex:0];
    [actionSheet setCancelAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor redColor]} atIndex:1];
    [actionSheet setClickedContent:^(ZHActionSheet *actionSheet, NSUInteger index) {
        NSLog(@"==========ZHActionSheet click content at index %ld", index);
    }];
    actionSheet.clickedCancle = ^(ZHActionSheet *actionSheet, NSUInteger index) {
        NSLog(@"==========ZHActionSheet click cancel at index %ld", index);
    };
    [actionSheet show];
}
- (IBAction)showCustomActionSheet:(UIButton *)sender {
    ZHActionSheet *actionSheet = [ZHActionSheet actionSheetWithTitle:nil contents:self.dataSource cancels:@[@"取消"]];
    actionSheet.actionSheetType = ActionSheetTypeCustom;
    //actionSheet.dataSource = self;
    actionSheet.delegate = self;
    actionSheet.itemNib = [UINib nibWithNibName:@"ActionSheetItemCell" bundle:nil];
    actionSheet.itemHeight = 60;
    actionSheet.itemConfigureForActionSheet = ^UITableViewCell *(ZHActionSheet *actionSheet, id configuredItem, NSInteger index) {
        ActionSheetItemCell *cell = (ActionSheetItemCell *)configuredItem;
        cell.image.image = [UIImage imageNamed:self.dataSource[index]];
        cell.label.text = self.dataSource[index];
        return cell;
    };
    [actionSheet show];
}

- (void)actionSheet:(ZHActionSheet *)actionSheet clickedContentAtIndex:(NSUInteger)index {
    NSLog(@"==========ZHActionSheet click content %@ at index %ld", self.dataSource[index], index);
}
- (void)actionSheet:(ZHActionSheet *)actionSheet clickedCancelAtIndex:(NSUInteger)index {
    
}



@end
