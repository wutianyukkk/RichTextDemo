//
//  ZMEditorImageHandler.m
//  zhangmen
//
//  Created by zhao on 2017/11/20.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import "ZMEditorImageHandler.h"
#import <AVFoundation/AVFoundation.h>

@interface ZMEditorImageHandler() <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) ZMCommonBlock commplete;

@property (nonatomic, assign) BOOL systemPicker;   //是否为系统选择器

@end


@implementation ZMEditorImageHandler

- (void)addImageWithCommplete:(ZMCommonBlock)commplete {
    _commplete = commplete;
    _systemPicker = YES;
    [self showAlertViewWithMaxCount:1];
}


-(void)addImages:(NSInteger)maxCount commplete:(ZMCommonBlock)commplete {
    
    _commplete = commplete;
    _systemPicker = NO;
    [self showAlertViewWithMaxCount:maxCount];
}

- (void)showAlertViewWithMaxCount:(NSInteger)maxCount {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }]];
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *controller = window.rootViewController;
    [controller presentViewController:alertController animated:YES completion:nil];
}


-(void)takePhoto {
    //拍照
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = sourceType;
    
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *controller = window.rootViewController;
    [controller presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark ===UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:@"public.image"]) {
            UIImage * image=[info objectForKey:UIImagePickerControllerOriginalImage];
            //保存图片
            [self addLocalImageArrayToContent:[NSArray arrayWithObjects:image, nil]];
        }
    }];
}

- (void)addLocalImageArrayToContent:(NSArray *)imageArray {
    if(_commplete){
        _commplete(imageArray,nil);
    }
}


@end
