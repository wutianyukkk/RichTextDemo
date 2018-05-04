//
//  SeeViewController.m
//  RichTextDemo
//
//  Created by zhao on 2018/5/4.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "SeeViewController.h"
#import "ZMRichView.h"
#import "UIView+ZM.h"

@interface SeeViewController ()

@property (nonatomic, strong) ZMRichView *richView;

@end

@implementation SeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _richView = [[ZMRichView alloc] initWithFrame:self.view.bounds];
    _richView.delegate = self;
    [self.view addSubview:_richView];
    
    _richView.bodyText = _content?:@"";
}
#pragma mark - ZMRichViewDelegate
//视图高度改变
-(void)richViewContentHeightChange:(double)height {
    _richView.zm_height = height;
}

@end
