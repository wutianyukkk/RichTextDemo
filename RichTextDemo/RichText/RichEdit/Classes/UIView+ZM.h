//
//  UIView+ZM.h
//  zhangmen
//
//  Created by gaiay004 on 2017/3/9.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tag)

//防止设置Tag为零
-(void)zm_setTag:(NSInteger)tag;

-(NSInteger)zm_tag;

-(UIView *)zm_viewWithTag:(NSInteger)tag;

@end

@interface UIView (Frame)

@property (nonatomic) CGFloat zm_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat zm_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat zm_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat zm_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat zm_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat zm_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat zm_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat zm_centerY;
/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint zm_origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize zm_size;

//找到自己的vc
- (UIViewController *)zm_viewController;

@end

