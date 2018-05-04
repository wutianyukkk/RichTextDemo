//
//  ZMRichView.h
//  zhangmen
//
//  Created by gaiay004 on 2018/3/13.
//  Copyright © 2018年 该亚中国 • 开发团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZMEditorViewController.h"

@protocol ZMRichViewDelegate <NSObject>

@optional

/**
 视图高度改变

 @param height 高度
 */
-(void)richViewContentHeightChange:(double)height;

/**
 链接地址的点击
 
 @param url 链接地址
 */
-(void)richViewWithUrlTapped:(NSString *)url;

@end

@interface ZMRichView : UIView
@property (nonatomic, weak) id<ZMRichViewDelegate> delegate;
@property (nonatomic, strong) NSString *bodyText;
@property (nonatomic, strong) ZMEditorView *editorView;

@end
