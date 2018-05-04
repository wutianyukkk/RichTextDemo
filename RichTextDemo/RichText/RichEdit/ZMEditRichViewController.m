//
//  ZMEditRichViewController.m
//  zhangmen
//
//  Created by zhao on 2017/10/24.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import "ZMEditRichViewController.h"
#import "SeeViewController.h"

@interface ZMEditRichViewController ()

@end

@implementation ZMEditRichViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _navTitle?:@"";
    if(self.isEditing){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"查看" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    }
}

- (BOOL)canPopViewController {
    NSString *html = self.bodyText;
    
    if(![html isEqualToString:_content]){
        [self showAlertView];
        return NO;
    }
    return YES;
}

-(void)showAlertView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否保存此次编辑？"  message:nil preferredStyle:UIAlertControllerStyleAlert]; // @"是否保存此次编辑？"
    [alertController addAction:[UIAlertAction actionWithTitle:@"不保存"  style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *editImgePaths = self.localImagePaths;
        
        [self setBodyText:_content?:@""];
        
        NSArray *imgePaths = self.localImagePaths;
 
        if(editImgePaths && editImgePaths.count > 0){
            [editImgePaths enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(![imgePaths containsObject:obj]){
                    [[NSFileManager defaultManager]  removeItemAtPath:obj error:nil];
                }
            }];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self rightBarButtonAction];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - WPEditorViewControllerDelegate

- (void)editorDidFinishLoadingDOM {
    [self.editorView.contentField setLetterSpacing:1];
    [self setBodyPlaceholderText:_placeholder?:@""];
    [self setBodyText:_content?:@""];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startEditingFocus];
    });
    
}

- (void)rightBarButtonAction {
    
    _content = self.bodyText;
    if(_commplete){
        _commplete(_content,nil);
    }
    
    SeeViewController *controller = [[SeeViewController alloc] init];
    controller.content = _content;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (NSString *)content {
    _content = self.bodyText;
    return _content;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
