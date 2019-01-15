# 默认样式、系统样式的ActionSheet，可以自定义；支持屏幕旋转。

## 支持cocoapods导入
```
pod 'ZHActionSheet'
```

### 系统样式
#### 示例图片
![system](https://github.com/leezhihua/ZHActionSheet/blob/master/ZHActionSheet/system.PNG)
#### 示例代码
```
ZHActionSheet *actionSheet = [[ZHActionSheet alloc] initActionSheetWithTitle:@"ActionSheet" contents:@[@"一",@"二",@"三",@"四",@"五"] cancels:@[@"取消",@"删除"]];
actionSheet.actionSheetType = ActionSheetTypeSystem;
actionSheet.subtitle = @"System Type";
[actionSheet addContent:@"〇" atIndex:0];
[actionSheet addContent:@"六" atIndex:6];
[actionSheet removeContentAtIndex:0];
[actionSheet setClickedContent:^(ZHActionSheet *actionSheet, NSUInteger index) {
    NSLog(@"==========ZHActionSheet click at index %ld", index);
}];
[actionSheet show];
```

### 默认样式

#### 示例图片
![default](https://github.com/leezhihua/ZHActionSheet/blob/master/ZHActionSheet/default.PNG)
#### 示例代码
```
ZHActionSheet *actionSheet = [[ZHActionSheet alloc] initActionSheetWithTitle:@"ActionSheet" contents:@[@"一",@"二",@"三",@"四",@"五"] cancels:@[@"取消",@"删除"]];
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
```

### 自定义样式
#### 示例图片
1.竖屏

![custi=om](https://github.com/leezhihua/ZHActionSheet/blob/master/ZHActionSheet/custom.PNG)

2.横屏

![custi=om](https://github.com/leezhihua/ZHActionSheet/blob/master/ZHActionSheet/custom_%20landscape.PNG)
#### 示例代码
```
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
```



```
//代理
- (void)actionSheet:(ZHActionSheet *)actionSheet clickedContentAtIndex:(NSUInteger)index {
    NSLog(@"==========ZHActionSheet click content %@ at index %ld", self.dataSource[index], index);
}
```
