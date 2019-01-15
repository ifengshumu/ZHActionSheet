//
//  ZHActionSheet.h
//
//  Created by Lee on 2016/12/11.
//  Copyright © 2016年 leezhihua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ActionSheetType) {
    ActionSheetTypeDefault,
    ActionSheetTypeSystem,
    ActionSheetTypeCustom,
};

@protocol ZHActionSheetDataSource;
@protocol ZHActionSheetDelegate;
@interface ZHActionSheet : UIView

/// 样式
@property (nonatomic, assign) ActionSheetType actionSheetType;

/// 自定义数据代理
@property (nonatomic, weak) id<ZHActionSheetDataSource> dataSource;

/// 代理
@property (nonatomic, weak) id<ZHActionSheetDelegate> delegate;

/// 点击ActionSheet外区域隐藏，默认NO
@property (nonatomic, assign) BOOL hideWhenTouchExtraArea;

/// 标题
@property (nonatomic, copy) NSString *title;
/// 标题属性
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleAttribute;

/// 副标题
@property (nonatomic, copy) NSString *subtitle;
/// 副标题属性
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *subtitleAttribute;

/// 内容Text
@property (nonatomic, strong) NSMutableArray<NSString *> *contents;

///取消Text
@property (nonatomic, strong) NSMutableArray<NSString *> *cancels;

///设置内容文本属性
- (void)setContentAttributes:(NSDictionary *)attrs atIndex:(NSUInteger)index;

///设置取消文本属性
- (void)setCancelAttributes:(NSDictionary *)attrs atIndex:(NSUInteger)index;


///显示ActionSheet
- (void)show;

///隐藏ActionSheet
- (void)dismiss;

/**
 初始化ActionSheet

 @param title 标题，可不传
 @param contents 内容，必传
 @param cancels 取消，可不传,如果actionSheetType=ActionSheetTypeSystem,只取第一个
 @return ActionSheet
 */
- (instancetype)initActionSheetWithTitle:(NSString *)title contents:(NSArray<NSString *> *)contents cancels:(NSArray<NSString *> *)cancels;

///初始化ActionSheet
+ (instancetype)actionSheetWithTitle:(NSString *)title contents:(NSArray<NSString *> *)contents cancels:(NSArray<NSString *> *)cancels;



///添加内容
- (void)addContent:(NSString *)content atIndex:(NSUInteger)index;

///移除内容，根据下标
- (void)removeContentAtIndex:(NSUInteger)index;

///移除内容，根据内容
- (void)removeContent:(NSString *)content;

///内容文本
- (NSString *)contentTextAtIndex:(NSUInteger)index;

///取消文本
- (NSString *)cancelTextAtIndex:(NSUInteger)index;



/// 点击Content的Block回调
@property (nonatomic, copy) void (^clickedContent)(ZHActionSheet *actionSheet, NSUInteger index);

/// 点击Cancel的Block回调
@property (nonatomic, copy) void (^clickedCancle)(ZHActionSheet *actionSheet, NSUInteger index);


/*********自定义Item********/
///自定义item标识，Nib和Class二者取其一
@property (nonatomic, strong) UINib *itemNib;
@property (nonatomic, strong) Class itemClass;

///item高,默认105/2.0
@property (nonatomic, assign) CGFloat itemHeight;

///返回item，可使用代理
@property (nonatomic, copy) UITableViewCell *(^itemConfigureForActionSheet)(ZHActionSheet *actionSheet, id configuredItem, NSInteger index);

@end


@protocol ZHActionSheetDataSource <NSObject>
- (UITableViewCell *)itemConfigureForActionSheet:(ZHActionSheet *)actionSheet configuredItem:(id)item atIndex:(NSInteger)index;
@end

@protocol ZHActionSheetDelegate <NSObject>
- (void)actionSheet:(ZHActionSheet *)actionSheet clickedContentAtIndex:(NSUInteger)index;
- (void)actionSheet:(ZHActionSheet *)actionSheet clickedCancelAtIndex:(NSUInteger)index;
@end




