//
//  ZMRichView.m
//  zhangmen
//
//  Created by gaiay004 on 2018/3/13.
//  Copyright © 2018年 该亚中国 • 开发团队. All rights reserved.
//

#import "ZMRichView.h"

@interface ZMRichView() <ZMEditorViewDelegate>

@property (nonatomic) BOOL didFinishLoadingEditor;

@property (nonatomic, strong) NSString *showContent;
@end

@implementation ZMRichView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        [self initSubviews];
    }
    return self;
}

#pragma mark - UIViewController
-(void)initSubviews {
    self.didFinishLoadingEditor = NO;
    [self buildTextViews];
}

#pragma mark - Builders

- (void)buildTextViews
{
    if (!self.editorView) {
        CGFloat viewWidth = CGRectGetWidth(self.frame);
        UIViewAutoresizing mask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGRect frame = CGRectMake(0.0, 0.0, viewWidth, CGRectGetHeight(self.frame));
        
        self.editorView = [[ZMEditorView alloc] initWithFrame:frame];
        self.editorView.delegate = self;
        self.editorView.autoresizesSubviews = YES;
        self.editorView.autoresizingMask = mask;
        self.editorView.backgroundColor = [UIColor whiteColor];
        // Default placeholder text
    }
    [self.editorView setBouncesEnable:NO];
    [self addSubview:self.editorView];
}

#pragma mark - Getters and Setters

- (NSString*)bodyText {
    return [self.editorView html];
}

- (void)setBodyText:(NSString*)bodyText {
    _showContent = bodyText;
    if(self.didFinishLoadingEditor){
        [self.editorView.contentField setHtml:bodyText];
        [self.editorView refreshFooterViewContentSize];
    }
}

- (void)setBodyPlaceholderText:(NSString*)bodyPlaceholderText {
    [self.editorView.contentField setPlaceholderText:@""];
}

#pragma mark - Actions
- (void)didTouchMediaOptions {
}
#pragma mark - Editing
/**
 *    @brief        Disables editing.
 */
- (void)disableEditing
{
    if (self.didFinishLoadingEditor)
    {
        [self.editorView disableEditing];
    }
}

#pragma mark - ZMEditorViewDelegate

- (void)editorView:(ZMEditorView*)editorView willBeginDragging:(UIScrollView *)scrollView {
    [self editorViewWillBeginDragging:scrollView];
}

- (void)editorView:(ZMEditorView *)editorView didScroll:(UIScrollView *)scrollView {
    [self editorViewDidScroll:scrollView];
}

- (void)editorTextDidChange:(ZMEditorView*)editorView {
    [self editorTextDidChange];
}

- (void)editorViewDidFinishLoadingDOM:(ZMEditorView*)editorView {
    // DRM: the reason why we're doing is when the DOM finishes loading, instead of when the full
    // content finishe loading, is that the content may not finish loading at all when the device is
    // offline and the content has remote subcontent (such as pictures).
    //
    self.didFinishLoadingEditor = YES;
    [self.editorView disableEditing];

    [self tellOurDelegateEditorDidFinishLoadingDOM];
}

- (void)editorView:(ZMEditorView*)editorView fieldCreated:(ZMEditorField*)field {
    if (field == self.editorView.contentField) {
        
        [field setRightToLeftTextEnabled:[self isCurrentLanguageDirectionRTL]];
        [field setMultiline:YES];
        [field setPlaceholderText:@""];
        [field setPlaceholderColor:[UIColor whiteColor]];
    }
    [self editorViewWithFieldCreated:field];
}

- (void)editorView:(ZMEditorView*)editorView fieldFocused:(ZMEditorField*)field {
}

- (void)editorView:(ZMEditorView*)editorView sourceFieldFocused:(UIView*)view {
}

- (BOOL)editorView:(ZMEditorView*)editorView linkTapped:(NSURL *)url title:(NSString*)title {
    [self editorViewWithUrlTapped:url];
    return YES;
}

- (void)editorView:(ZMEditorView*)editorView imageTapped:(NSString *)imageId url:(NSURL *)url imageMeta:(WPImageMeta *)imageMeta {
    [self editorViewWithImageTapped:imageId url:url imageMeta:imageMeta];
}

- (BOOL)editorView:(ZMEditorView*)editorView imageTapped:(NSString *)imageId url:(NSURL *)url {
    [self editorViewWithImageTapped:imageId url:url];
    return YES;
}

- (void)editorView:(ZMEditorView*)editorView videoTapped:(NSString *)videoId url:(NSURL *)url {
    [self editorViewWithVideoTapped:videoId url:url];
}

- (void)editorView:(ZMEditorView *)editorView heightChangeField:(ZMEditorField *)field {
    [self editorViewHeightChange];
}

#pragma mark - Utilities

- (BOOL)isCurrentLanguageDirectionRTL
{
    return ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft);
}

#pragma mark - Action calls
//子类实现
/** 编辑内容改变 */
- (void)editorTextDidChange {
}
/** 加载内容完成 */
- (void)editorDidFinishLoadingDOM {
    [self.editorView.contentField setHtml:self.showContent?:@""];
    [self.editorView refreshFooterViewContentSize];
}

/**
 滚动回调
 @param scrollView 容器视图
 */
- (void)editorViewWillBeginDragging:(UIScrollView *)scrollView {
    
}
- (void)editorViewDidScroll:(UIScrollView*)scrollView {
}

/**
 实例创建成功回调
 @param field 内容实例对象
 */
- (void)editorViewWithFieldCreated:(ZMEditorField*)field {
}

/** 链接事件处理 */
- (void)editorViewWithUrlTapped:(NSURL *)url {
    if(_delegate && [_delegate respondsToSelector:@selector(richViewWithUrlTapped:)]){
        [_delegate richViewWithUrlTapped:url.absoluteString];
    }
}

/** 图片点击事件 */
- (void)editorViewWithImageTapped:(NSString *)imageId url:(NSURL *)url {
}
/** 图片数据事件处理 */
- (void)editorViewWithImageTapped:(NSString *)imageId url:(NSURL *)url imageMeta:(WPImageMeta *)imageMeta {
}
/** 视频点击事件 */
- (void)editorViewWithVideoTapped:(NSString *)videoID url:(NSURL *)url {
}
/** 高度改变 */
- (void)editorViewHeightChange {
    double height = [self.editorView.contentField contentHeight];
    
    height += 50;
    self.editorView.zm_height = height;
    
    if(_delegate && [_delegate respondsToSelector:@selector(richViewContentHeightChange:)]){
        [_delegate richViewContentHeightChange:height];
    }
}

#pragma mark - 调用方法
- (void)tellOurDelegateEditorDidFinishLoadingDOM {
    [self editorDidFinishLoadingDOM];
}

@end
