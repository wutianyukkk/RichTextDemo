#import <UIKit/UIKit.h>
#import "ZMEditorView.h"
#import "ZMEditorField.h"
#import "WPImageMeta.h"
#import "ZMEditorImageHandler.h"

typedef enum
{
    kZMEditorViewControllerModePreview = 0,
    kZMEditorViewControllerModeEdit
}
ZMEditorViewControllerMode;

@interface ZMEditorViewController : UIViewController

@property (nonatomic, copy) NSString *bodyText;
@property (nonatomic, copy) NSString *bodyPlaceholderText;

@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) NSArray *localImagePaths; //获取本地添加的图片

@property (nonatomic, assign) NSInteger photoMax;      //!< 允许插入图片的最大数量

#pragma mark - Properties: Editor View
@property (nonatomic, strong, readonly) ZMEditorView *editorView;

@property (nonatomic, strong) ZMEditorImageHandler *editorImageHandler;

#pragma mark - Initializers

/**
 *	@brief		Initializes the VC with the specified mode.
 *
 *	@param		mode	The mode to initialize the VC in.
 *
 *	@returns	The initialized object.
 */
- (instancetype)initWithMode:(ZMEditorViewControllerMode)mode;

/**
 用网络地址替换本地添加的图片地址
 
 @param urls URL地址
 */
- (void)replaceLocalImageWithUrls:(NSArray *)urls;

#pragma mark - Appearance
/**
 *	@brief		This method allows should be implement by view controllers that want customize the appearance 
 *  of the editor view and toolbar
 *
 */
- (void)customizeAppearance;

#pragma mark - Editing

/**
 *	@brief		Call this method to know if the VC is in edit mode.
 *	@details	Edit mode has to be manually turned on and off, and is not reliant on fields gaining
 *				or losing focus.
 *
 *	@returns	YES if the VC is in edit mode, NO otherwise.
 */
- (BOOL)isEditing;

/**
 *	@brief		Starts editing.
 */
- (void)startEditing;

- (void)startEditingFocus;

/**
 *  @brief		Stop all editing activities.
 */
- (void)stopEditing;

#pragma mark - Override these in subclasses

/**
 *  Gets called when the insert URL picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertURLAlternatePicker;

/**
 *  Gets called when the insert Image picker button is tapped in an alertView
 *
 *  @warning The default implementation of this method is blank and does nothing
 */
- (void)showInsertImageAlternatePicker;

/** 编辑开始 */
- (void)editorDidBeginEditing;

/** 编辑内容改变 */
- (void)editorTextDidChange;

/** 编辑结束 */
- (void)editorDidEndEditing;

/** 加载内容完成 */
- (void)editorDidFinishLoadingDOM;

/**
 工具栏状态变化
 
 @param isEnabled 使能状态
 */
- (void)editorFormatBarStatusChangedEnabled:(BOOL)isEnabled;

/** 多媒体事件 */
- (void)editorDidPressMedia;

//增加图片UIImage数组进入内容中
- (void)addLocalImageArrayToContent:(NSArray *)imageArray;

/** 滚动回调 */
- (void)editorViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)editorViewDidScroll:(UIScrollView*)scrollView;

/**
 实例创建成功回调
 @param field 内容实例对象
 */
- (void)editorViewWithFieldCreated:(ZMEditorField*)field;
/** 链接点击事件 */
- (void)editorViewWithUrlTapped:(NSURL *)url;
/** 图片点击事件 */
- (void)editorViewWithImageTapped:(NSString *)imageId url:(NSURL *)url;
/** 图片数据事件处理 */
- (void)editorViewWithImageTapped:(NSString *)imageId url:(NSURL *)url imageMeta:(WPImageMeta *)imageMeta;
/** 视频点击事件 */
- (void)editorViewWithVideoTapped:(NSString *)videoID url:(NSURL *)url;
/** 图片替换事件 */
- (void)editorViewWithImageReplaced:(NSString *)imageId;
/** 视频替换事件 */
- (void)editorViewWithVideoReplaced:(NSString *)videoID;
/** 图片粘贴事件 */
- (void)editorViewWithImagePasted:(UIImage *)image;
/** 视频信息事件 */
- (void)editorViewWithVideoPressInfoRequest:(NSString *)videoID;
/** 多媒体移除事件 */
- (void)editorViewWithMediaRemoved:(NSString *)mediaID;
/** 内容高度改变 */
- (void)editorViewHeightChange;

@end
