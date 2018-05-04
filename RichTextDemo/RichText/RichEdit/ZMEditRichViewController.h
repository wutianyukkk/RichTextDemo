//
//  ZMEditRichViewController.h
//  zhangmen
//
//  Created by zhao on 2017/10/24.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import "ZMEditorViewController.h"

@interface ZMEditRichViewController : ZMEditorViewController

@property (nonatomic, strong) NSString *navTitle;   //!< 头部显示 标题
@property (nonatomic, strong) NSString *content;    //!< 内容
@property (nonatomic, strong) NSString *placeholder;//!< 提示文字

@property (nonatomic, strong) ZMCommonBlock commplete;

@end
