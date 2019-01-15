//
//  ZHActionSheet.m
//
//  Created by Lee on 2016/12/11.
//  Copyright © 2016年 leezhihua. All rights reserved.
//

#import "ZHActionSheet.h"

#define PORTRAIT            (UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait || UIDevice.currentDevice.orientation == UIDeviceOrientationPortraitUpsideDown)
#define SCREEN_HEIGHT       (UIScreen.mainScreen.bounds.size.height)
#define SCREEN_WIDTH        (UIScreen.mainScreen.bounds.size.width)
#define BOTTOM_SAFE_HEIGHT  ((PORTRAIT ? SCREEN_HEIGHT : SCREEN_WIDTH) == 812.0 ? PORTRAIT ? 34 : 21 : 0)
#define TOP_SAFE_HEIGHT     ((PORTRAIT ? SCREEN_HEIGHT : SCREEN_WIDTH) == 812.0 ? PORTRAIT ? 44 : 0 : 0)
#define HEIGHT              105/2.0
#define SPACE               10
#define HEX                 243/256.0


@interface ZHActionSheetItem : UITableViewCell
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ZHActionSheetItem

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT)];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.adjustsFontSizeToFitWidth = YES;
        self.contentLabel = contentLabel;
        [self.contentView addSubview:contentLabel];
    }
    return self;
}
- (UIEdgeInsets)safeAreaInsets {
    return UIEdgeInsetsZero;
}
@end



static NSString *const identifier = @"ZHActionSheetCell";
static NSString *const identifierCustom = @"ZHActionSheetCustomCell";
@interface ZHActionSheet ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *contentAttrsDic;
@property (nonatomic, strong) NSMutableDictionary *cancelAttrsDic;
@end

@implementation ZHActionSheet
- (instancetype)initActionSheetWithTitle:(NSString *)title contents:(NSArray<NSString *> *)contents cancels:(NSArray<NSString *> *)cancels {
    self = [super initWithFrame:CGRectMake(0, TOP_SAFE_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-BOTTOM_SAFE_HEIGHT-TOP_SAFE_HEIGHT)];
    if (self) {
        self.title = title;
        self.contents = contents.mutableCopy;
        self.cancels = cancels.mutableCopy;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}
+ (instancetype)actionSheetWithTitle:(NSString *)title contents:(NSArray<NSString *> *)contents cancels:(NSArray<NSString *> *)cancels {
    return [[self alloc] initActionSheetWithTitle:title contents:contents cancels:cancels];
}

- (void)orientationDidChange {
    self.frame = CGRectMake(0, TOP_SAFE_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-BOTTOM_SAFE_HEIGHT-TOP_SAFE_HEIGHT);
    if (self.actionSheetType != ActionSheetTypeSystem) {
        [self show];
    }
}

#pragma mark - 布局
- (void)layoutSubViews {
    /*
     ActionSheetTypeSystem
     */
    if (self.actionSheetType == ActionSheetTypeSystem) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title message:self.subtitle preferredStyle:UIAlertControllerStyleActionSheet];
        [self.contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedContentAtIndex:)]) {
                    [self.delegate actionSheet:self clickedContentAtIndex:idx];
                }
                if (self.clickedContent) {
                    self.clickedContent(self, idx);
                }
            }];
            [alertController addAction:action];
        }];
        if (self.cancels.count) {
            NSString *cancel = self.cancels.firstObject;
            UIAlertAction *action = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedCancelAtIndex:)]) {
                    [self.delegate actionSheet:self clickedCancelAtIndex:0];
                }
                if (self.clickedCancle) {
                    self.clickedCancle(self, 0);
                }
            }];
            [alertController addAction:action];
        }
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
            self.hidden = YES;
        }];
        return;
    }
    /*
     ActionSheetTypeDefault & ActionSheetTypeCustom
     */
    //手势
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.hidden = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBlack)];
    tapGes.delegate = self;
    [self addGestureRecognizer:tapGes];
    self.hideWhenTouchExtraArea = NO;
    //变量
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat tableViewTop = 0.0;
    CGFloat tableViewHeight = 0.0;
    CGFloat cancelHeight = 0.0;
    BOOL canScroll = NO;
    
    CGFloat titleH = 0.0;
    NSString *title = self.title;
    if (title.length && self.subtitle.length) title = [title stringByAppendingFormat:@"\n%@", self.subtitle];
    if (!self.title.length && self.subtitle.length) title = self.subtitle;
    if (title.length) {
        titleH = [self caculateLabelSizeForContent:title scopeWidth:width font:[UIFont systemFontOfSize:18]].height+10;
        titleH = titleH<HEIGHT?HEIGHT:titleH;
    }
    CGFloat h = 0.0;
    if (self.cancels.count) {
        h = HEIGHT*self.cancels.count+SPACE+titleH;
        cancelHeight = (HEIGHT*self.cancels.count+SPACE);
    }
    CGFloat itemH = MAX(self.itemHeight, HEIGHT);
    if (height - h > self.contents.count * itemH) {
        tableViewHeight = self.contents.count * itemH;
        canScroll = NO;
    } else {
        tableViewHeight = height - h;
        canScroll = YES;
    }
    h += tableViewHeight;
    tableViewTop = h - cancelHeight - tableViewHeight;
    //containerView
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, height-h, width, h)];
    containerView.backgroundColor = [UIColor whiteColor];
    self.containerView = containerView;
    [self addSubview:containerView];
    //取消
    if (self.cancels.count) {
        __block NSUInteger index = 0;
        [self.cancels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat y = h - HEIGHT * (index + 1);
            UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, HEIGHT)];
            cancelLabel.tag = idx + 1000;
            cancelLabel.backgroundColor = [UIColor whiteColor];
            cancelLabel.textAlignment = NSTextAlignmentCenter;
            cancelLabel.adjustsFontSizeToFitWidth = YES;
            cancelLabel.layer.borderColor = [UIColor colorWithRed:HEX green:HEX blue:HEX alpha:1].CGColor;
            cancelLabel.layer.borderWidth = 1;
            if (self.cancelAttrsDic[@(idx)]) {
                NSAttributedString *attrs = [[NSAttributedString alloc] initWithString:obj attributes:self.cancelAttrsDic[@(idx)]];
                cancelLabel.attributedText = attrs;
            } else {
                cancelLabel.textColor = [UIColor blackColor];
                cancelLabel.font = [UIFont systemFontOfSize:16];
                cancelLabel.text = obj;
            }
            UITapGestureRecognizer *tapCancel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCancel:)];
            cancelLabel.userInteractionEnabled = YES;
            [cancelLabel addGestureRecognizer:tapCancel];
            [containerView addSubview:cancelLabel];
            index ++;
            if (idx == 0) {
                //分隔
                UIView *grayLineView = [[UIView alloc] initWithFrame:CGRectMake(0, y-SPACE, width, SPACE)];
                grayLineView.backgroundColor = [UIColor colorWithRed:HEX green:HEX blue:HEX alpha:1];
                [containerView addSubview:grayLineView];
            }
        }];
    }
    //action
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableViewTop, width, tableViewHeight) style:UITableViewStylePlain];
    if (self.actionSheetType == ActionSheetTypeCustom) {
        if (self.itemNib) {
            [tableView registerNib:self.itemNib forCellReuseIdentifier:identifierCustom];
        } else {
            [tableView registerClass:self.itemClass forCellReuseIdentifier:identifierCustom];
        }
        tableView.rowHeight = self.itemHeight?self.itemHeight:HEIGHT;
    } else {
        [tableView registerClass:[ZHActionSheetItem class] forCellReuseIdentifier:identifier];
        tableView.rowHeight = HEIGHT;
    }
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorColor = [UIColor colorWithRed:HEX green:HEX blue:HEX alpha:1];
    tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = canScroll;
    self.tableView = tableView;
    [containerView addSubview:tableView];
    //标题
    if (title.length) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y-titleH, width, titleH)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.numberOfLines = 0;
        [containerView addSubview:titleLabel];
        titleLabel.layer.borderColor = [UIColor colorWithRed:HEX green:HEX blue:HEX alpha:1].CGColor;
        titleLabel.layer.borderWidth = 1;
        
        if (self.subtitle.length) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 10;
            style.alignment = NSTextAlignmentCenter;
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:title];
            
            if (self.title && self.titleAttribute) {
                [attStr addAttributes:self.subtitleAttribute range:[title rangeOfString:self.title]];
            }
            
            NSRange subRange = [title rangeOfString:self.subtitle];
            if (self.subtitleAttribute) {
                [attStr addAttributes:self.subtitleAttribute range:subRange];
            }
            [attStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:[UIColor grayColor]} range:subRange];
            titleLabel.attributedText = attStr;
        } else {
            if (self.titleAttribute) {
                NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.title attributes:self.titleAttribute];
                titleLabel.attributedText = attStr;
            } else {
                titleLabel.text = self.title;
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contents.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionSheetType == ActionSheetTypeCustom) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCustom forIndexPath:indexPath];
        if (self.itemConfigureForActionSheet) {
            return self.itemConfigureForActionSheet(self, cell, indexPath.row);
        }
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(itemConfigureForActionSheet:configuredItem:atIndex:)]) {
            return [self.dataSource itemConfigureForActionSheet:self configuredItem:cell atIndex:indexPath.row];
        }
    } else {
        ZHActionSheetItem *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        if (self.contentAttrsDic[@(indexPath.row)]) {
            NSAttributedString *attrs = [[NSAttributedString alloc] initWithString:self.contents[indexPath.row] attributes:self.contentAttrsDic[@(indexPath.row)]];
            cell.contentLabel.attributedText = attrs;
        } else {
            cell.contentLabel.text = self.contents[indexPath.row];
        }
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismiss];
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedContentAtIndex:)]) {
        [self.delegate actionSheet:self clickedContentAtIndex:indexPath.row];
    }
    if (self.clickedContent) {
        self.clickedContent(self, indexPath.row);
    }
}

#pragma mark - 文本属性
- (void)setContentAttributes:(NSDictionary *)attrs atIndex:(NSUInteger)index {
    self.contentAttrsDic[@(index)] = attrs;
}

- (void)setCancelAttributes:(NSDictionary *)attrs atIndex:(NSUInteger)index {
    self.cancelAttrsDic[@(index)] = attrs;
}

#pragma mark - 显隐
- (void)show {
    if (!self.contents.count) return;

    [self layoutSubViews];
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [self.superview bringSubviewToFront:self];
    self.alpha = 0;
    self.hidden = NO;
    __block CGRect frame = self.containerView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.containerView.frame = frame;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
        frame.origin.y = self.frame.size.height - frame.size.height;
        self.containerView.frame = frame;
    }];
}

- (void)dismiss {
    __block CGRect frame = self.containerView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        frame.origin.y = SCREEN_HEIGHT;
        self.containerView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - public method
- (NSString *)contentTextAtIndex:(NSUInteger)index {
    return self.contents[index];
}
- (NSString *)cancelTextAtIndex:(NSUInteger)index {
    return self.actionSheetType == ActionSheetTypeSystem ? self.cancels.firstObject : self.cancels[index];
}
- (void)addContent:(NSString *)content atIndex:(NSUInteger)index {
    [self.contents insertObject:content atIndex:index];
}

- (void)removeContentAtIndex:(NSUInteger)index {
    [self.contents removeObjectAtIndex:index];
}
- (void)removeContent:(NSString *)content {
    [self.contents removeObject:content];
}

#pragma mark - private method
//点击灰色区域
- (void)tapBlack {
    if (self.hideWhenTouchExtraArea) [self dismiss];
}
//点击取消
- (void)tapCancel:(UITapGestureRecognizer *)sender {
    [self dismiss];
    UILabel *cancel = (UILabel *)sender.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:clickedCancelAtIndex:)]) {
        [self.delegate actionSheet:self clickedCancelAtIndex:cancel.tag-1000];
    }
    if (self.clickedCancle) {
        self.clickedCancle(self, cancel.tag-1000);
    }
}
//
- (CGSize)caculateLabelSizeForContent:(NSString *)content scopeWidth:(CGFloat)width font:(UIFont *)font {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 10;
    style.alignment = NSTextAlignmentCenter;
    NSMutableDictionary *attributesDic = [NSMutableDictionary dictionaryWithCapacity:0];
    attributesDic[NSFontAttributeName] = font;
    attributesDic[NSParagraphStyleAttributeName] = style;
    
    CGSize actualsize =[content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:attributesDic context:nil].size;
    return actualsize;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.containerView]) {
        return NO;
    }
    return YES;
}

#pragma mark - lazy init
- (NSMutableDictionary *)contentAttrsDic {
    if (!_contentAttrsDic) {
        _contentAttrsDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _contentAttrsDic;
}
- (NSMutableDictionary *)cancelAttrsDic {
    if (!_cancelAttrsDic) {
        _cancelAttrsDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _cancelAttrsDic;
}

@end
