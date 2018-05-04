#import "ZMEditorViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import "ZMEditorToolBarView.h"

@interface ZMEditorViewController () <ZMEditorToolbarViewDelegate, ZMEditorViewDelegate>

@property (nonatomic, strong) NSArray *editorItemsEnabled;
@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) NSString *selectedImageAlt;
@property (nonatomic) BOOL didFinishLoadingEditor;
@property (nonatomic, weak) ZMEditorField* focusedField;

#pragma mark - Properties: First Setup On View Will Appear
@property (nonatomic, assign, readwrite) BOOL isFirstSetupComplete;

#pragma mark - Properties: Editing
@property (nonatomic, assign, readwrite, getter=isEditingEnabled) BOOL editingEnabled;
@property (nonatomic, assign, readwrite, getter=isEditing) BOOL editing;
@property (nonatomic, assign, readwrite) BOOL wasEditing;

#pragma mark - Properties: Editor View
@property (nonatomic, strong, readwrite) ZMEditorView *editorView;

#pragma mark - Properties: Toolbar

@property (nonatomic, strong) ZMEditorToolBarView *toolbarView;

@end

@implementation ZMEditorViewController

#pragma mark - Initializers

- (instancetype)init
{
	return [self initWithMode:kZMEditorViewControllerModeEdit];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
	{
		[self sharedInitializationWithEditing:YES];
	}
	
	return self;
}

- (instancetype)initWithMode:(ZMEditorViewControllerMode)mode
{
	self = [super init];
	
	if (self) {
        _photoMax = 30;         //默认插入图片数量30张
		BOOL editing = NO;
		
		if (mode == kZMEditorViewControllerModePreview) {
			editing = NO;
		} else {
			editing = YES;
		}
		
		[self sharedInitializationWithEditing:editing];
	}
	
	return self;
}

#pragma mark - Shared Initialization Code

- (void)sharedInitializationWithEditing:(BOOL)editing
{
    self.editorImageHandler = [[ZMEditorImageHandler alloc]init];
    
	if (editing == kZMEditorViewControllerModePreview) {
		_editing = NO;
	} else {
		_editing = YES;
	}
}

#pragma mark - Creation of subviews

- (void)createToolbarView
{
    NSAssert(!_toolbarView, @"The toolbar view should not exist here.");
    _toolbarView = [[ZMEditorToolBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _toolbarView.delegate = self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
}

-(void)initSubviews {
    
    self.isFirstSetupComplete = NO;
    self.didFinishLoadingEditor = NO;
    [self createToolbarView];
    [self buildTextViews];
    [self customizeAppearance];
}

- (void)customizeAppearance {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    if (!self.isFirstSetupComplete) {
        // When restoring state, the navigationController is nil when the view loads,
        // so configure its appearance here instead.
//        self.navigationController.navigationBar.translucent = NO;
//        
//        for (UIView *view in self.navigationController.toolbar.subviews) {
//            [view setExclusiveTouch:YES];
//        }


        if (self.isEditing) {
            [self startEditing];
        }
    }
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstSetupComplete) {
        [self restoreEditSelection];
    } else {
        // Note: Very important this is set here otherwise the post will not initially
        // load properly in the editor. Please be careful if you make a change here and
        // test the editor within WPiOS!
        self.isFirstSetupComplete = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // It's important to save the edit selection before the view disappears, because as soon as it
    // disappears the first responder is changed.
    //
    [self saveEditSelection];
}

- (void)traitCollectionDidChange:(UITraitCollection *) previousTraitCollection
{
    [super traitCollectionDidChange: previousTraitCollection];
    [self recoverFromViewSizeChange];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self recoverFromViewSizeChange];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self.toolbarView setNeedsLayout];
}

#pragma mark - Keyboard shortcuts

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (NSArray<UIKeyCommand *> *)keyCommands
{
//    if (self.isEditingTitle) {
//        return @[];
//    }

    // Note that due to an iOS 9 bug, the custom methods for bold and italic
    // don't actually get called: http://www.openradar.me/25463955
    return @[
             [UIKeyCommand keyCommandWithInput:@"B" modifierFlags:UIKeyModifierCommand action:@selector(setBold)],
             [UIKeyCommand keyCommandWithInput:@"I" modifierFlags:UIKeyModifierCommand action:@selector(setItalic)],
             [UIKeyCommand keyCommandWithInput:@"K" modifierFlags:UIKeyModifierCommand action:@selector(linkBarButtonTapped)],
             [UIKeyCommand keyCommandWithInput:@"M" modifierFlags:UIKeyModifierCommand|UIKeyModifierAlternate action:@selector(didTouchMediaOptions)]
             ];
}

- (void)handleKeyCommandStrikethrough
{
    [self setStrikethrough];

    // Ensure that the toolbar button is appropriately selected / deselected
    [self.toolbarView toggleSelectionForToolBarItemWithTag:ZMEditorViewElementTagStrikeThroughBarButton];
}

#pragma mark - Toolbar: helper methods

- (void)clearToolbar
{
    //清除所有的标记
//    [self.toolbarView clearSelectedToolbarItems];
}

- (UIColor *)placeholderColor {
    if (!_placeholderColor) {
        return [UIColor lightGrayColor];
    }
    return _placeholderColor;
}

#pragma mark - Builders

- (void)buildTextViews
{
    if (!self.editorView) {
        CGFloat viewWidth = CGRectGetWidth(self.view.frame);
        UIViewAutoresizing mask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGRect frame = CGRectMake(0.0, 0.0, viewWidth, CGRectGetHeight(self.view.frame));
        
        self.editorView = [[ZMEditorView alloc] initWithFrame:frame];
        self.editorView.delegate = self;
        self.editorView.autoresizesSubviews = YES;
        self.editorView.autoresizingMask = mask;
        self.editorView.backgroundColor = [UIColor whiteColor];
        // Default placeholder text
    }
	
    [self.view addSubview:self.editorView];
}

#pragma mark - Getters and Setters

- (NSString*)bodyText
{
    return [self.editorView html];
}

- (void)setBodyText:(NSString*)bodyText
{
    [self.editorView.contentField setHtml:bodyText];
    [self.editorView refreshFooterViewContentSize];
}

- (void)setBodyPlaceholderText:(NSString*)bodyPlaceholderText
{
    NSParameterAssert(bodyPlaceholderText);
    if (![bodyPlaceholderText isEqualToString:_bodyPlaceholderText]) {
        _bodyPlaceholderText = bodyPlaceholderText;
        [self.editorView.contentField setPlaceholderText:_bodyPlaceholderText?:@""];
        [self.editorView.contentField setPlaceholderColor:self.placeholderColor];
    }
}

/**
 获取本地添加的图片
 
 @return 返回图片地址数组
 */
- (NSArray *)localImagePaths {
    return [self.editorView localImagePaths];
}

/**
 用网络地址替换本地添加的图片地址

 @param urls URL地址
 */
- (void)replaceLocalImageWithUrls:(NSArray *)urls {
    return [self.editorView replaceLocalImageWithUrls:urls];
}

#pragma mark - Actions

- (void)didTouchMediaOptions {
    [self editorDidPressMedia];
}

#pragma mark - Editor and Misc Methods

- (BOOL)isBodyTextEmpty
{
    if(!self.bodyText
       || self.bodyText.length == 0
       || [[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]
       || [[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<br>"]
       || [[self.bodyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"<br />"]) {
        return YES;
    }
    return NO;
}

#pragma mark - Editing

/**
 *	@brief		Enables editing.
 */
- (void)enableEditing
{
	self.editingEnabled = YES;
	
	if (self.didFinishLoadingEditor)
	{
		[self.editorView enableEditing];
	}
}

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing
{
	self.editingEnabled = NO;
	
	if (self.didFinishLoadingEditor)
	{
		[self.editorView disableEditing];
	}
}

/**
 *  @brief      Restored the previously saved edit selection.
 *  @details    Will only really do anything if editing is enabled.
 */
- (void)restoreEditSelection
{
    if (self.isEditing) {
        [self.editorView restoreSelection];
    }
}

/**
 *  @brief      Saves the current edit selection, if any.
 */
- (void)saveEditSelection
{
    if (self.isEditing) {
        [self.editorView saveSelection];
    }
}

- (void)startEditing
{
	self.editing = YES;
	
	// We need the editor ready before executing the steps in the conditional block below.
	// If it's not ready, this method will be called again on webViewDidFinishLoad:
	//
	if (self.didFinishLoadingEditor)
	{
        [self enableEditing];
		[self tellOurDelegateEditingDidBegin];
	}
}

- (void)startEditingFocus
{
    self.editing = YES;
    
    // We need the editor ready before executing the steps in the conditional block below.
    // If it's not ready, this method will be called again on webViewDidFinishLoad:
    //
    if (self.didFinishLoadingEditor)
    {
        [self enableEditing];
        [self.editorView focus];
        [self tellOurDelegateEditingDidBegin];
    }
}

- (void)stopEditing
{
	self.editing = NO;
	
	[self disableEditing];
	[self tellOurDelegateEditingDidEnd];
}

#pragma mark - ZMEditorToolbarViewDelegate

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView insertImage:(ZMEditorToolbarButton *)barButtonItem
{
    [self didTouchMediaOptions];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setBold:(ZMEditorToolbarButton *)barButtonItem
{
    [self setBold];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setItalic:(ZMEditorToolbarButton *)barButtonItem
{
    [self setItalic];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setBlockquote:(ZMEditorToolbarButton *)barButtonItem
{
    [self setBlockQuote];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setUnorderedList:(ZMEditorToolbarButton *)barButtonItem
{
    [self setUnorderedList];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setOrderedList:(ZMEditorToolbarButton *)barButtonItem
{
    [self setOrderedList];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setStrikeThrough:(ZMEditorToolbarButton *)barButtonItem
{
    [self setStrikethrough];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView insertLink:(ZMEditorToolbarButton *)barButtonItem
{
    [self linkBarButtonTapped];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH1:(ZMEditorToolbarButton *)barButtonItem
{
    [self heading1];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH2:(ZMEditorToolbarButton *)barButtonItem
{
    [self heading2];
}

- (void)editorToolbarView:(ZMEditorToolBarView*)editorToolbarView setH3:(ZMEditorToolbarButton *)barButtonItem
{
    [self heading3];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH4:(ZMEditorToolbarButton *)barButtonItem
{
    [self heading4];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setJustifyLeft:(ZMEditorToolbarButton *)barButtonItem
{
    [self alignLeft];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setJustifyCenter:(ZMEditorToolbarButton *)barButtonItem
{
    [self alignCenter];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setJustifyRight:(ZMEditorToolbarButton *)barButtonItem
{
    [self alignRight];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setTextColor:(ZMEditorToolbarButton *)barButtonItem color:(UIColor *)color
{
    [self textColor:color];
}

- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setKeyBoard:(ZMEditorToolbarButton *)barButtonItem
{
    [self.view endEditing:YES];
}



#pragma mark - Editor Interaction
- (void)removeFormat
{
    [self.editorView removeFormat];
}

- (void)alignLeft
{
    [self.editorView alignLeft];
}

- (void)alignCenter
{
    [self.editorView alignCenter];
}

- (void)alignRight
{
    [self.editorView alignRight];
}

- (void)alignFull
{
    [self.editorView alignFull];
}

- (void)setBold
{
    [self.editorView setBold];
    [self clearToolbar];
}

- (void)setBlockQuote
{
    [self.editorView setBlockQuote];
    [self clearToolbar];
}

- (void)setItalic
{
    [self.editorView setItalic];
    [self clearToolbar];
}

- (void)setSubscript
{
    [self.editorView setSubscript];
}

- (void)setUnderline
{
	[self.editorView setUnderline];
    [self clearToolbar];
}

- (void)setSuperscript
{
	[self.editorView setSuperscript];
}

- (void)setStrikethrough
{
    [self.editorView setStrikethrough];
    [self clearToolbar];
}

- (void)setUnorderedList
{
    [self.editorView setUnorderedList];
    [self clearToolbar];
}

- (void)setOrderedList
{
    [self.editorView setOrderedList];
    [self clearToolbar];
}

- (void)setHR
{
    [self.editorView setHR];
}

- (void)setIndent
{
    [self.editorView setIndent];
}

- (void)setOutdent
{
    [self.editorView setOutdent];
}

- (void)heading1
{
	[self.editorView heading1];
}

- (void)heading2
{
    [self.editorView heading2];
}

- (void)heading3
{
    [self.editorView heading3];
}

- (void)heading4
{
	[self.editorView heading4];
}

- (void)heading5
{
	[self.editorView heading5];
}

- (void)heading6
{
	[self.editorView heading6];
}

- (void)textColor:(UIColor *)color
{
    // Save the selection location
	[self.editorView saveSelection];
    // tag: 1 文字颜色  2  北京颜色
    [self.editorView setSelectedColor:color tag:1];
}

- (void)bgColor
{
    // Save the selection location
	[self.editorView saveSelection];
    
    // tag: 1 文字颜色  2  北京颜色
    // [self.editorView setSelectedColor:color tag:tag];
}

- (void)undo:(ZMEditorToolbarButton *)barButtonItem
{
    [self.editorView undo];
}

- (void)redo:(ZMEditorToolbarButton *)barButtonItem
{
    [self.editorView redo];
}

- (void)linkBarButtonTapped
{
	if ([self.editorView isSelectionALink]) {
		[self removeLink];
	} else {
		[self showInsertLinkDialogWithLink:self.editorView.selectedLinkURL title:[self.editorView selectedText]];
	}
}

- (void)showInsertLinkDialogWithLink:(NSString*)url title:(NSString*)title {
    __weak __typeof(self) weakSelf = self;
    BOOL isInsertingNewLink = (url == nil);
    
    if (!url) {
//        NSURL* pasteboardUrl = [self urlFromPasteboard];
//        url = [pasteboardUrl absoluteString];
        url = @"";
    }
    
    NSString *insertButtonTitle = isInsertingNewLink ? @"添加链接" : @"更新";
    NSString *removeButtonTitle = @"移除链接";
    NSString *cancelButtonTitle = @"取消";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:insertButtonTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"http://";
        if (url) {
            textField.text = url;
        }
        [textField addTarget:weakSelf action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"链接名称";
        textField.secureTextEntry = NO;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        textField.spellCheckingType = UITextSpellCheckingTypeDefault;
        
        if (title) {
            textField.text = title;
        }
    }];
    
    UIAlertAction* insertAction = [UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             [weakSelf.editorView restoreSelection];
                                                             
                                                             NSString *linkURL = alertController.textFields.firstObject.text;
                                                             NSString *linkTitle = alertController.textFields.lastObject.text;
                                                             
                                                             if ([linkTitle length] == 0) {
                                                                 linkTitle = linkURL;
                                                             }
                                                             
                                                             if (isInsertingNewLink) {
                                                                 [weakSelf insertLink:linkURL title:linkTitle];
                                                             } else {
                                                                 [weakSelf updateLink:linkURL title:linkTitle];
                                                             }
                                                         }];
    
    UIAlertAction* removeAction = [UIAlertAction actionWithTitle:removeButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             [weakSelf.editorView restoreSelection];
                                                             [weakSelf removeLink];
                                                         }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                             [weakSelf.editorView restoreSelection];
                                                         }];
    
    [alertController addAction:insertAction];
    if (!isInsertingNewLink) {
        [alertController addAction:removeAction];
    }
    [alertController addAction:cancelAction];
    
    // Disabled until url is entered into field
    UITextField *urlField = alertController.textFields.firstObject;
    insertAction.enabled = urlField.text.length > 0;
    
    [self.editorView saveSelection];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *urlField = alertController.textFields.firstObject;
        UIAlertAction *insertAction = alertController.actions.firstObject;
        insertAction.enabled = urlField.text.length > 0;
    }
}

- (void)insertLink:(NSString *)url
			 title:(NSString*)title
{
	[self.editorView insertLink:url title:title];
}

- (void)updateLink:(NSString *)url
			 title:(NSString*)title
{
	[self.editorView updateLink:url title:title];
}

- (void)removeLink
{
    [self.editorView removeLink];
}

- (void)quickLink
{
    [self.editorView quickLink];
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt
{
    [self.editorView insertImage:url alt:alt];
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt
{
    [self.editorView updateImage:url alt:alt];
}

#pragma mark - UIPasteboard interaction

/**
 *	@brief		Returns an URL from the general pasteboard.
 */
- (NSURL*)urlFromPasteboard
{
	NSURL* url = nil;
	
	UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
	
	NSString* const kURLPasteboardType = (__bridge NSString*)kUTTypeURL;
	NSString* const kTextPasteboardType = (__bridge NSString*)kUTTypeText;
	
	if ([pasteboard containsPasteboardTypes:@[kURLPasteboardType]]) {
		url = [pasteboard valueForPasteboardType:kURLPasteboardType];
	} else if ([pasteboard containsPasteboardTypes:@[kTextPasteboardType]]) {
		NSString* urlString = [pasteboard valueForPasteboardType:kTextPasteboardType];
		
        url = [self urlFromStringOnlyIfValid:urlString];
	}
	
	return url;
}

/**
 *	@brief		Validates a URL.
 *	@details	The validations we perform here are pretty basic.  But the idea of having this
 *				method is to add any additional checks we want to perform, as we come up with them.
 *
 *	@parameter	url		The URL to validate.  You will usually call [NSURL URLWithString] to create
 *						this URL from a string, before passing it to this method.  Cannot be nil.
 */
- (BOOL)isURLValid:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    return url && url.scheme && url.host;
}

/**
 *  @brief      Returns the url from a string only if the final URL is valid.
 *
 *  @param      urlString       The url string to normalize.  Cannot be nil.
 *
 *  @returns    The normalized URL.
 */
- (NSURL*)urlFromStringOnlyIfValid:(NSString*)urlString {
    NSParameterAssert([urlString isKindOfClass:[NSString class]]);
    
    if ([urlString hasPrefix:@"www"]) {
        urlString = [self.editorView normalizeURL:urlString];
    }
    
    NSURL* prevalidatedUrl = [NSURL URLWithString:urlString];
    NSURL* url = nil;
    
    if (prevalidatedUrl && [self isURLValid:prevalidatedUrl]) {
        url = prevalidatedUrl;
    }
    
    return url;
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
    
//    if (self.editing) {
//        [self startEditing];
//    } else {
//        [self.editorView disableEditing];
//    }
    
    [self tellOurDelegateEditorDidFinishLoadingDOM];
}

- (void)editorView:(ZMEditorView*)editorView fieldCreated:(ZMEditorField*)field {
    if (field == self.editorView.contentField) {
        field.inputAccessoryView = self.toolbarView;
        
        [field setRightToLeftTextEnabled:[self isCurrentLanguageDirectionRTL]];
        [field setMultiline:YES];
        [field setPlaceholderText:self.bodyPlaceholderText];
        [field setPlaceholderColor:self.placeholderColor];
    }
    [self editorViewWithFieldCreated:field];
}

- (void)editorView:(ZMEditorView*)editorView fieldFocused:(ZMEditorField*)field {
    [self.toolbarView enableToolbarItems:YES shouldShowSourceButton:YES];
    [self tellOurDelegateFormatBarStatusHasChanged:YES];
}

- (void)editorView:(ZMEditorView*)editorView sourceFieldFocused:(UIView*)view {
    [self.toolbarView enableToolbarItems:YES shouldShowSourceButton:YES];
}

- (BOOL)editorView:(ZMEditorView*)editorView linkTapped:(NSURL *)url title:(NSString*)title {
	if (self.isEditing) {
        [self showInsertLinkDialogWithLink:url.absoluteString title:title];
	} else {
        [self editorViewWithUrlTapped:url];
	}
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

- (void)editorView:(ZMEditorView*)editorView imageReplaced:(NSString *)imageId {
    [self editorViewWithImageReplaced:imageId];
}

- (void)editorView:(ZMEditorView*)editorView videoReplaced:(NSString *)videoId {
    [self editorViewWithVideoReplaced:videoId];
}

- (void)editorView:(ZMEditorView *)editorView videoPressInfoRequest:(NSString *)videoPressID {
    [self editorViewWithVideoPressInfoRequest:videoPressID];
}

- (void)editorView:(ZMEditorView *)editorView mediaRemoved:(NSString *)mediaID {
    [self editorViewWithMediaRemoved:mediaID];
}

- (void)editorView:(ZMEditorView*)editorView stylesForCurrentSelection:(NSArray*)styles {
    self.editorItemsEnabled = styles;
	[self.toolbarView selectToolbarItemsForStyles:styles];
}

- (void)editorView:(ZMEditorView *)editorView imagePasted:(UIImage *)image {
    [self editorViewWithImagePasted:image];
}

- (void)editorView:(ZMEditorView *)editorView heightChangeField:(ZMEditorField *)field {
    [self editorViewHeightChange];
}

#ifdef DEBUG
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    DDLogError(@"Loading error: %@", error);
	NSAssert(NO,
			 @"This should never happen since the editor is a local HTML page of our own making.");
}
#endif

#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker
{
    // Blank method. User should implement this in their subclass
	NSAssert(NO, @"Blank method. User should implement this in their subclass");
}

- (void)showInsertImageAlternatePicker
{
    // Blank method. User should implement this in their subclass
	NSAssert(NO, @"Blank method. User should implement this in their subclass");
}

#pragma mark - Utilities

- (void)recoverFromViewSizeChange
{
    // This hack forces the input accessory view to refresh itself and resize properly.
    if (self.isFirstSetupComplete) {
        ZMEditorField *field = [self.editorView focusedField];
        [self.editorView saveSelection];
        [field blur];
        [field focus];
        [self.editorView restoreSelection];
    }
}

- (UIColor *)barButtonItemDefaultColor
{
    if (self.toolbarView.itemTintColor) {
        return self.toolbarView.itemTintColor;
    }
    return [UIColor grayColor];
}

- (UIColor *)barButtonItemSelectedDefaultColor
{
    if (self.toolbarView.selectedItemTintColor) {
        return self.toolbarView.selectedItemTintColor;
    }    
    return [UIColor blueColor];;
}

- (BOOL)isCurrentLanguageDirectionRTL
{
    return ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft);
}

#pragma mark - Action calls
//子类实现
/** 编辑开始 */
- (void)editorDidBeginEditing {
}

/** 编辑内容改变 */
- (void)editorTextDidChange {
}

/** 编辑结束 */
- (void)editorDidEndEditing {
}

/** 加载内容完成 */
- (void)editorDidFinishLoadingDOM {
}

/**
 工具栏状态变化

 @param isEnabled 使能状态
 */
- (void)editorFormatBarStatusChangedEnabled:(BOOL)isEnabled {
}

/** 多媒体事件 */
- (void)editorDidPressMedia {
    NSInteger imageCount = self.editorView.imageCount;
    
    __weak __typeof(self)weakSelf = self;
    [self.editorImageHandler addImages:MIN(_photoMax - imageCount, 9) commplete:^(id  _Nullable response, NSError * _Nullable error) {
        [weakSelf addLocalImageArrayToContent:((NSArray *)response)];
    }];
}

- (void)addLocalImageArrayToContent:(NSArray *)imageArray {
    for(UIImage *image in imageArray) {
        
        NSString *imageID = [self randoFileName];
        
        NSString *path = [self saveImage:image imageName:imageID];
        [self.editorView insertLocalImage:[[NSURL fileURLWithPath:path] absoluteString] uniqueId:imageID width:image.size.width height:image.size.height];
    }
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
/** 图片替换事件 */
- (void)editorViewWithImageReplaced:(NSString *)imageId {
}
/** 视频替换事件 */
- (void)editorViewWithVideoReplaced:(NSString *)videoID {
}
/** 图片粘贴事件 */
- (void)editorViewWithImagePasted:(UIImage *)image {
    [self addLocalImageArrayToContent:@[image]];
}
/** 视频信息事件 */
- (void)editorViewWithVideoPressInfoRequest:(NSString *)videoID {
}
/** 多媒体移除事件 */
- (void)editorViewWithMediaRemoved:(NSString *)mediaID {
}

/** 高度改变 */
- (void)editorViewHeightChange {
    
}

#pragma mark - 调用方法
- (void)tellOurDelegateEditingDidBegin {
    [self editorDidBeginEditing];
}

- (void)tellOurDelegateEditingDidEnd {
    [self editorDidEndEditing];
}

- (void)tellOurDelegateEditorDidFinishLoadingDOM {
    [self editorDidFinishLoadingDOM];
}

- (void)tellOurDelegateFormatBarStatusHasChanged:(BOOL)isEnabled {
   [self editorFormatBarStatusChangedEnabled:isEnabled];
}


- (NSString*)randoFileName {
    NSMutableString *fileName = [NSMutableString string];
    NSArray * array = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",nil];
    for (int i = 0 ; i < 20; ++i) {
        int x = rand()%34;
        [fileName appendFormat:@"%@",[array objectAtIndex:x]];
    }
    return fileName;
}

- (NSString *)saveImage:(UIImage *)image imageName:(NSString *)imageName {
    
    NSArray *dirArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [dirArray firstObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imageName]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:path atomically:YES];
    
    return path;
}

@end
