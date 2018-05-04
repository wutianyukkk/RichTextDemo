//
//  ZMEditorImageHandler.h
//  zhangmen
//
//  Created by zhao on 2017/11/20.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentConst.h"

@interface ZMEditorImageHandler : NSObject

-(void)addImages:(NSInteger)maxCount commplete:(ZMCommonBlock)commplete;
- (void)addImageWithCommplete:(ZMCommonBlock)commplete;

@end
