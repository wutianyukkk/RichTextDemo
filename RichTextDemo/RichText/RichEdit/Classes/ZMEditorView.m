//
//  Copyright (c) 2014 Automattic Inc.
//
//  This source file is based on ZSSRichTextEditorViewController.m from ZSSRichTextEditor
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import "ZMEditorView.h"

#import "UIWebView+GUIFixes.h"
#import "ZMEditorField.h"
#import "WPImageMeta.h"

typedef void(^ZMEditorViewCallbackParameterProcessingBlock)(NSString* parameterName, NSString* parameterValue);
typedef void(^ZMEditorViewNoParamsCompletionBlock)();

static NSString* const kDefaultCallbackParameterSeparator = @"~";
static NSString* const kDefaultCallbackParameterComponentSeparator = @"=";
static NSString* const kZMEditorViewFieldHeaderId = @"header_content";
static NSString* const kZMEditorViewFieldContentId = @"zss_field_content";
static NSString* const kZMEditorViewFieldFooterId = @"footer_content";


static NSString* const ZMEditorViewWebViewContentSizeKey = @"contentSize";

@interface ZMEditorView () <UIWebViewDelegate, UIScrollViewDelegate>

#pragma mark - Cached caret & line data
@property (nonatomic, strong, readwrite) NSNumber *caretYOffset;
@property (nonatomic, strong, readwrite) NSNumber *lineHeight;

#pragma mark - Editor height
@property (nonatomic, assign, readwrite) NSInteger lastEditorHeight;

#pragma mark - Editing state
@property (nonatomic, assign, readwrite, getter = isEditing) BOOL editing;

#pragma mark - Selection
@property (nonatomic, strong, readwrite) NSString *selectedLinkURL;
@property (nonatomic, strong, readwrite) NSString *selectedLinkTitle;
@property (nonatomic, strong, readwrite) NSString *selectedImageURL;
@property (nonatomic, strong, readwrite) NSString *selectedImageAlt;

#pragma mark - Subviews
@property (nonatomic, strong, readonly) UIWebView* webView;

#pragma mark - Editor loading support
@property (nonatomic, copy, readwrite) NSString* preloadedHTML;

#pragma mark - Fields
@property (nonatomic, weak, readwrite) ZMEditorField* focusedField;

@end

@implementation ZMEditorView

#pragma mark - NSObject

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopObservingWebViewContentSizeChanges];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) {
		[self createWebViewWithFrame:frame];
		[self setupHTMLEditor];
	}
	
	return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
    } else {
        [self startObservingKeyboardNotifications];
    }
}

- (void)createWebViewWithFrame:(CGRect)frame
{
	NSAssert(!_webView, @"The web view must not exist when this method is called!");
	
	_webView = [[UIWebView alloc] initWithFrame:frame];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_webView.delegate = self;
	_webView.scalesPageToFit = YES;
	_webView.dataDetectorTypes = UIDataDetectorTypeNone;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    _webView.usesGUIFixes = YES;
    _webView.keyboardDisplayRequiresUserAction = NO;
    _webView.scrollView.bounces = YES;
    _webView.allowsInlineMediaPlayback = YES;
    [self startObservingWebViewContentSizeChanges];
    
    _webView.scrollView.delegate = self;
    
	[self addSubview:_webView];
    if(@available(iOS 11, *)){
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    
    if(self.headerView){
         [_webView.scrollView addSubview:self.headerView];
        [self refreshHeaderViewContentSize];
    }
    
    if(self.footerView){
        [_webView.scrollView addSubview:self.footerView];
        [self refreshFooterViewContentSize];
    }
}

- (void)setupHTMLEditor
{
    NSBundle * bundle = [NSBundle bundleForClass:[ZMEditorView class]];
    NSURL * editorURL = [bundle URLForResource:@"editor" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]];
}

#pragma mark - UIScrollViewDelegate  代理实现

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(editorView:willBeginDragging:)]) {
        [self.delegate editorView:self willBeginDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(editorView:didScroll:)]) {
        [self.delegate editorView:self didScroll:scrollView];
    }
}

#pragma mark - Custom Herder Footer  size update  调整头部 和 底部 视图大小

-(void)setHeaderView:(UIView *)headerView {
    if(_headerView) {
        [_headerView removeFromSuperview];
    }
    
    if(headerView){
        _headerView = headerView;
        [_webView.scrollView addSubview:_headerView];
    }
    [self refreshHeaderViewContentSize];
}

-(void)setBouncesEnable:(BOOL)enable {
    _webView.scrollView.bounces = enable;
}

- (void)refreshHeaderViewContentSize {
    if(self.headerView){
        [self.headerField setFieldHeight:self.headerView.zm_height];
    } else {
        [self.headerField setFieldHeight:0];
    }
}

-(void)setFooterView:(UIView *)footerView {
    if(_footerView) {
        [_footerView removeFromSuperview];
    }
    
    _footerView = footerView;
    if(footerView){
        [_webView.scrollView addSubview:_footerView];
    }
    [self refreshFooterViewContentSize];
}
- (void)refreshFooterViewContentSize {
    if(self.footerView){
        [self.footerField setFieldHeight:self.footerView.zm_height];
        
        [self refreshFooterViewContentTop];
    } else {
        [self.footerField setFieldHeight:0];
    }
}

- (void)refreshFooterViewContentTop {
    if(self.footerView) {
        NSString* footerTopString = [self.webView stringByEvaluatingJavaScriptFromString:@"$('#footer_content').position().top;"];
        double footerTop = [footerTopString doubleValue];
        
        if(self.headerView){
            if(footerTop < self.headerView.zm_height){
                footerTop = self.headerView.zm_bottom;
            }
        }
        self.footerView.zm_top = footerTop;
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.webView.scrollView) {
        
        if ([keyPath isEqualToString:ZMEditorViewWebViewContentSizeKey]) {
            NSValue *newValue = change[NSKeyValueChangeNewKey];
            
            CGSize newSize = [newValue CGSizeValue];
        
            if (newSize.height != self.lastEditorHeight) {
                
                // First make sure that the content size is not changed without us recalculating it.
                //
                self.webView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), self.lastEditorHeight);
                [self workaroundBrokenWebViewRendererBug];
                
                // Then recalculate it asynchronously so the UIWebView doesn't break.
                //
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self refreshVisibleViewportAndContentSize];
                    [self refreshFooterViewContentTop];
                    [self callDelegateEditorViewHeightChange];
                });
            }
        }
	}
}

- (void)startObservingWebViewContentSizeChanges
{
    [_webView.scrollView addObserver:self
                          forKeyPath:ZMEditorViewWebViewContentSizeKey
                             options:NSKeyValueObservingOptionNew
                             context:nil];
}

- (void)stopObservingWebViewContentSizeChanges
{
    [self.webView.scrollView removeObserver:self
                                 forKeyPath:ZMEditorViewWebViewContentSizeKey];
}


#pragma mark - Bug Workarounds

/**
 *  @brief      Redraws the web view, since [webView setNeedsDisplay] doesn't seem to work.
 */
- (void)redrawWebView
{
    NSArray *views = self.webView.scrollView.subviews;
    
    for(int i = 0; i< views.count; i++){
        UIView *view = views[i];
        
        [view setNeedsDisplay];
    }
}

/**
 *  @brief      Works around a problem caused by another workaround we're using, that's causing the
 *              web renderer to be interrupted before finishing.
 *  @details    When we know of a contentSize change in the web view's scroll view, we override the
 *              operation to manually calculate the proper new size and set it.  This is causing the
 *              web renderer to fail and interrupt.  Drawing doesn't finish properly.  This method
 *              offers a sort of forced redraw mechanism after a very short delay.
 */
- (void)workaroundBrokenWebViewRendererBug
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self redrawWebView];
    });
}

#pragma mark - Keyboard notifications

- (void)startObservingKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Keyboard status

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self scrollToCaretAnimated:NO];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self refreshKeyboardInsetsWithShowNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // WORKAROUND: sometimes the input accessory view is not taken into account and a
    // keyboardWillHide: call is triggered instead.  Since there's no way for the source view now
    // to have focus, we'll just make sure the inputAccessoryView is taken into account when
    // hiding the keyboard.
    //
    CGFloat vOffset = 0;
//    if(self.focusedField){
//        vOffset = self.contentField.inputAccessoryView.frame.size.height;
//    }
    
    if(@available(iOS 11, *)){
        //不做处理
    } else {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0.0f, vOffset, 0.0f);
        self.webView.scrollView.contentInset = insets;
        self.webView.scrollView.scrollIndicatorInsets = insets;
    }
}


#pragma mark - Keyboard Misc.

/**
 *  @brief      Takes care of calculating and setting the proper insets when the keyboard is shown.
 *  @details    This method can be called from both keyboardWillShow: and keyboardDidShow:.
 *
 *  @param      notification        The notification containing the size info for the keyboard.
 *                                  Cannot be nil.
 */
- (void)refreshKeyboardInsetsWithShowNotification:(NSNotification*)notification
{
    NSParameterAssert([notification isKindOfClass:[NSNotification class]]);
    
    NSDictionary *info = notification.userInfo;
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect localizedKeyboardEnd = [self convertRect:keyboardEnd fromView:nil];
    CGPoint keyboardOrigin = localizedKeyboardEnd.origin;
    
    if (keyboardOrigin.y > 0) {
        
        CGFloat vOffset = CGRectGetHeight(self.frame) - keyboardOrigin.y;
        
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0.0f, vOffset, 0.0f);
        
        if(@available(iOS 11, *)){
            //不做处理
        } else {
            self.webView.scrollView.contentInset = insets;
            self.webView.scrollView.scrollIndicatorInsets = insets;
        }
    }
}

- (void)refreshVisibleViewportAndContentSize
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.refreshVisibleViewportSize(%@);", @(_editing)];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
#ifdef DEBUG
    [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.logMainElementSizes();"];
#endif
    
    NSString* newHeightString = [self.webView stringByEvaluatingJavaScriptFromString:@"$(document.body).height();"];
    NSInteger newHeight = [newHeightString integerValue];
    
    self.lastEditorHeight = newHeight;
    self.webView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), newHeight);
}

#pragma mark - UIWebViewDelegate

-            (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
			navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
    
	BOOL shouldLoad = NO;
	
	if (navigationType != UIWebViewNavigationTypeLinkClicked) {
		BOOL handled = [self handleWebViewCallbackURL:url];
		shouldLoad = !handled;
	}
    
	return shouldLoad;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if ([self.delegate respondsToSelector:@selector(editorViewDidFinishLoading:)]) {
		[self.delegate editorViewDidFinishLoading:self];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self setupHTMLEditor];
}

#pragma mark - Handling callbacks

/**
 *	@brief		Handles UIWebView callbacks.
 *
 *	@param		url		The url for the callback.  Cannot be nil.
 *
 *	@returns	YES if the callback was handled, NO otherwise.
 */
- (BOOL)handleWebViewCallbackURL:(NSURL*)url
{
	NSParameterAssert([url isKindOfClass:[NSURL class]]);

	BOOL handled = NO;

	NSString *scheme = [url scheme];
	
//    DDLogDebug(@"WebEditor callback received: %@", url);
	
    if (scheme) {
        if ([self isFocusInScheme:scheme]) {
            [self handleFocusInCallback:url];
            handled = YES;
        } else if ([self isFocusOutScheme:scheme]) {
            [self handleFocusOutCallback:url];
            handled = YES;
        } else if ([self isInputCallbackScheme:scheme]) {
            [self handleInputCallback:url];
            handled = YES;
        } else if ([self isLinkTappedScheme:scheme]) {
            [self handleLinkTappedCallback:url];
            handled = YES;
        } else if ([self isImageTappedScheme:scheme]) {
            [self handleImageTappedCallback:url];
            handled = YES;
        } else if ([self isVideoTappedScheme:scheme]) {
            [self handleVideoTappedCallback:url];
            handled = YES;
        } else if ([self isLogCallbackScheme:scheme]){
            [self handleLogCallbackScheme:url];
            handled = YES;
        } else if ([self isLogErrorCallbackScheme:scheme]){
            [self handleLogErrorCallbackScheme:url];
            handled = YES;
        } else if ([self isNewFieldCallbackScheme:scheme]) {
            [self handleNewFieldCallback:url];
            handled = YES;
        } else if ([self isSelectionChangedCallbackScheme:scheme]){
            [self handleSelectionChangedCallback:url];
            handled = YES;
        } else if ([self isSelectionStyleScheme:scheme]) {
            [self handleSelectionStyleCallback:url];
            handled = YES;
        } else if ([self isDOMLoadedScheme:scheme]) {
            [self handleDOMLoadedCallback:url];
            handled = YES;
        } else if ([self isImageReplacedScheme:scheme]) {
            [self handleImageReplacedCallback:url];
            handled = YES;
        } else if ([self isVideoReplacedScheme:scheme]) {
            [self handleVideoReplacedCallback:url];
            handled = YES;
        } else if ([self isVideoFullScreenStartedScheme:scheme]) {
            [self handleVideoFullScreenStartedCallback:url];
            handled = YES;
        } else if ([self isVideoFullScreenEndedScheme:scheme]) {
            [self handleVideoFullScreenEndedCallback:url];
            handled = YES;
        } else if ([self isVideoPressInfoRequestScheme:scheme]) {
            [self handleVideoPressInfoRequestCallback:url];
            handled = YES;
        } else if ([self isMediaRemovedScheme:scheme]) {
            [self handleMediaRemovedCallback:url];
            handled = YES;
        } else if ([self isPasteCallbackScheme:scheme]) {
            [self handlePasteCallback];
            handled = YES;
        }
        
    }
	
	return handled;
}

/**
 *	@brief		Handles a DOM loaded callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleDOMLoadedCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    [self.contentField handleDOMLoaded];
    [self.footerField handleDOMLoaded];
    
    if ([self.delegate respondsToSelector:@selector(editorViewDidFinishLoadingDOM:)]) {
        [self.delegate editorViewDidFinishLoadingDOM:self];
    }
}

- (void)handleFocusInCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString* const kFieldIdParameterName = @"id";
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kFieldIdParameterName]) {
             if ([parameterValue isEqualToString:kZMEditorViewFieldContentId]) {
                 self.focusedField = self.contentField;
             } else if ([parameterValue isEqualToString:kZMEditorViewFieldHeaderId]){
                 self.focusedField = self.headerField;
             } else if ([parameterValue isEqualToString:kZMEditorViewFieldFooterId]){
                 self.focusedField = self.footerField;
             }
             self.webView.customInputAccessoryView = self.focusedField.inputAccessoryView;
         }
     } onComplete:^{
         [self callDelegateFieldFocused:self.focusedField];
     }];
}

/**
 *	@brief		Handles a focus out callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleFocusOutCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    self.focusedField = nil;
    [self callDelegateFieldFocused:self.focusedField];
}

/**
 *	@brief		Handles a key pressed callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleInputCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString* const kFieldIdParameterName = @"id";
    static NSString* const kYOffsetParameterName = @"yOffset";
    static NSString* const kLineHeightParameterName = @"height";
    
    self.caretYOffset = nil;
    self.lineHeight = nil;
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kFieldIdParameterName]) {
             if ([parameterValue isEqualToString:kZMEditorViewFieldContentId]) {
                 [self callDelegateEditorTextDidChange];
             } else if ([parameterValue isEqualToString:kZMEditorViewFieldHeaderId]){
                 
             } else if ([parameterValue isEqualToString:kZMEditorViewFieldFooterId]){
                 
             }
             
             self.webView.customInputAccessoryView = self.focusedField.inputAccessoryView;
         } else if ([parameterName isEqualToString:kYOffsetParameterName]) {
             
             self.caretYOffset = @([parameterValue floatValue]);
         } else if ([parameterName isEqualToString:kLineHeightParameterName]) {
             
             self.lineHeight = @([parameterValue floatValue]);
         }
     } onComplete:^() {
         
         // WORKAROUND: it seems that without this call, typing doesn't always follow the caret
         // position.
         //
         // HOW TO TEST THIS: disable the following line, and run the demo... type in the contents
         // field while also showing the virtual keyboard.  You'll notice the caret can, at times,
         // go behind the virtual keyboard.
         //
         [self refreshVisibleViewportAndContentSize];
         [self scrollToCaretAnimated:NO];
     }];
}

/**
 *	@brief		Handles a link tapped callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleLinkTappedCallback:(NSURL*)url
{
	NSParameterAssert([url isKindOfClass:[NSURL class]]);
	
	static NSString* const kTappedUrlParameterName = @"url";
	static NSString* const kTappedUrlTitleParameterName = @"title";
	
	__block NSURL* tappedUrl = nil;
	__block NSString* tappedUrlTitle = nil;
	
	[self parseParametersFromCallbackURL:url
		 andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
	{
		if ([parameterName isEqualToString:kTappedUrlParameterName]) {
			tappedUrl = [NSURL URLWithString:[self stringByDecodingURLFormat:parameterValue]];
		} else if ([parameterName isEqualToString:kTappedUrlTitleParameterName]) {
			tappedUrlTitle = [self stringByDecodingURLFormat:parameterValue];
		}
	} onComplete:^{		
		if ([self.delegate respondsToSelector:@selector(editorView:linkTapped:title:)]) {
			[self.delegate editorView:self linkTapped:tappedUrl title:tappedUrlTitle];
		}
	}];
}

/**
 *	@brief		Handles a image tapped callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleImageTappedCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString *const kTappedUrlParameterName = @"url";
    static NSString *const kTappedIdParameterName = @"id";
    static NSString *const kTappedMetaName = @"meta";
    
    __block NSURL *tappedUrl = nil;
    __block NSString *tappedId = nil;
    __block NSString *tappedMeta = nil;
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kTappedUrlParameterName]) {
             tappedUrl = [NSURL URLWithString:[self stringByDecodingURLFormat:parameterValue]];
         } else if ([parameterName isEqualToString:kTappedIdParameterName]) {
             tappedId = [self stringByDecodingURLFormat:parameterValue];
         } else if ([parameterName isEqualToString:kTappedMetaName]) {
             tappedMeta = [self stringByDecodingURLFormat:parameterValue];
         }
     } onComplete:^{
         if ([self.delegate respondsToSelector:@selector(editorView:imageTapped:url:imageMeta:)]) {
             WPImageMeta *imageMeta = [WPImageMeta imageMetaFromJSONString:tappedMeta];
             [self.delegate editorView:self imageTapped:tappedId url:tappedUrl imageMeta:imageMeta];
         }
     }];
}

/**
 *	@brief		Handles a video tapped callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleVideoTappedCallback:(NSURL *)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);

    static NSString *const kTappedUrlParameterName = @"url";
    static NSString *const kTappedIdParameterName = @"id";

    __block NSURL *tappedUrl = nil;
    __block NSString *tappedId = nil;

    [self parseParametersFromCallbackURL:url andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue) {
         if ([parameterName isEqualToString:kTappedUrlParameterName]) {
             tappedUrl = [NSURL URLWithString:[self stringByDecodingURLFormat:parameterValue]];
         } else if ([parameterName isEqualToString:kTappedIdParameterName]) {
             tappedId = [self stringByDecodingURLFormat:parameterValue];
         }
    } onComplete:^{
         if ([self.delegate respondsToSelector:@selector(editorView:videoTapped:url:)]) {
             [self.delegate editorView:self videoTapped:tappedId url:tappedUrl];
         }
    }];
}

/**
 *	@brief		Handles a video entered fullscreen callback
 *
 *	@param		aURL		The url with all the callback information.
 */
- (void)handleVideoFullScreenStartedCallback:(NSURL *)aURL
{
    NSParameterAssert([aURL isKindOfClass:[NSURL class]]);
    [self saveSelection];
    // FIXME: SergioEstevao 2015/03/25 - It looks there is a bug on iOS 8 that makes
    // the keyboard not to be hidden when a video is made to run in full screen inside a webview.
    // this workaround searches for the first responder and dismisses it
    UIView *firstResponder = [self findFirstResponder:self];
    [firstResponder resignFirstResponder];
}
/**
 *  Finds the first responder in the view hierarchy starting from the currentView
 *
 *  @param currentView the view to start looking for the first responder.
 *
 *  @return the view that is the current first responder nil if none was found.
 */
- (UIView *)findFirstResponder:(UIView *)currentView
{
    if (currentView.isFirstResponder) {
        [currentView resignFirstResponder];
        return currentView;
    }
    for (UIView *subView in currentView.subviews) {
        UIView *result = [self findFirstResponder:subView];
        if (result) {
            return result;
        }
    }
    return nil;
}

/**
 *	@brief		Handles a video ended fullscreen callback.
 *
 *	@param		aURL		The url with all the callback information.
 */
- (void)handleVideoFullScreenEndedCallback:(NSURL *)aURL
{
    NSParameterAssert([aURL isKindOfClass:[NSURL class]]);

    [self restoreSelection];
}



/**
 *	@brief		Handles a image replaced callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleImageReplacedCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString *const kImagedIdParameterName = @"id";
    
    __block NSString *imageId = nil;
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kImagedIdParameterName]) {
             imageId = [self stringByDecodingURLFormat:parameterValue];
         }
     } onComplete:^{
         if ([self.delegate respondsToSelector:@selector(editorView:imageReplaced:)]) {
             [self.delegate editorView:self imageReplaced:imageId];
         }
     }];
}

/**
 *	@brief		Handles a video replaced callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleVideoReplacedCallback:(NSURL *)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);

    static NSString *const kVideoIdParameterName = @"id";

    __block NSString *videoId = nil;

    [self parseParametersFromCallbackURL:url andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
    {
         if ([parameterName isEqualToString:kVideoIdParameterName]) {
             videoId = [self stringByDecodingURLFormat:parameterValue];
         }
    } onComplete:^{
         if ([self.delegate respondsToSelector:@selector(editorView:videoReplaced:)]) {
             [self.delegate editorView:self videoReplaced:videoId];
         }
    }];
}

- (void)handleVideoPressInfoRequestCallback:(NSURL *)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString *const kVideoIdParameterName = @"id";
    
    __block NSString *videoId = nil;
    
    [self parseParametersFromCallbackURL:url andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kVideoIdParameterName]) {
             videoId = [self stringByDecodingURLFormat:parameterValue];
         }
     } onComplete:^{
         if ([self.delegate respondsToSelector:@selector(editorView:videoPressInfoRequest:)]) {
             [self.delegate editorView:self videoPressInfoRequest:videoId];
         }
     }];

}

- (void)handleMediaRemovedCallback:(NSURL *)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString *const kMediaIdParameterName = @"id";
    
    __block NSString *mediaId = nil;
    
    [self parseParametersFromCallbackURL:url andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kMediaIdParameterName]) {
             mediaId = [self stringByDecodingURLFormat:parameterValue];
         }
     } onComplete:^{
         if ([self.delegate respondsToSelector:@selector(editorView:mediaRemoved:)]) {
             [self.delegate editorView:self mediaRemoved:mediaId];
         }
     }];
    
}

/**
 *	@brief		Handles a log callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleLogCallbackScheme:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString* const kMessageParameterName = @"msg";
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kMessageParameterName]) {
//         (@"WebEditor log:%@", [self stringByDecodingURLFormat:parameterValue]);
         }
     } onComplete:nil];
}

/**
 *	@brief		Handles a log error callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleLogErrorCallbackScheme:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString* const kLineParameterName = @"line";
    static NSString* const kMessageParameterName = @"msg";
    static NSString* const kURLParameterName = @"url";
    
    __block NSString *line = nil;
    __block NSString *message = nil;
    __block NSString *errorUrl = nil;
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kLineParameterName]) {
             line = [self stringByDecodingURLFormat:parameterValue];
         } else if ([parameterName isEqualToString:kMessageParameterName]) {
             message = [self stringByDecodingURLFormat:parameterValue];
         } else if ([parameterName isEqualToString:kURLParameterName]) {
             errorUrl = [self stringByDecodingURLFormat:parameterValue];
         }
     } onComplete:^{
         static NSString* const ErrorFormat = @"WebEditor error:\r\n  In file: %@\r\n  In line: %@\r\n  %@";
         
//         DDLogError(ErrorFormat, errorUrl, line, message);
     }];
}

/**
 *	@brief		Handles a new field callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleNewFieldCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString* const kFieldIdParameterName = @"id";
    
    __block NSString* fieldId = nil;
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kFieldIdParameterName]) {
             NSAssert([parameterValue isKindOfClass:[NSString class]],
                      @"We're expecting a non-nil NSString object here.");
             
             fieldId = parameterValue;
         }
     } onComplete:^{
         
         ZMEditorField* newField = [self createFieldWithId:fieldId];
         
         [self callDelegateFieldCreated:newField];
     }];
}

/**
 *	@brief		Handles a selection changed callback.
 *
 *	@param		url		The url with all the callback information.
 */
- (void)handleSelectionChangedCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    static NSString* const kYOffsetParameterName = @"yOffset";
    static NSString* const kLineHeightParameterName = @"height";
    
    self.caretYOffset = nil;
    self.lineHeight = nil;
    
    [self parseParametersFromCallbackURL:url
         andExecuteBlockForEachParameter:^(NSString *parameterName, NSString *parameterValue)
     {
         if ([parameterName isEqualToString:kYOffsetParameterName]) {
             
             self.caretYOffset = @([parameterValue floatValue]);
         } else if ([parameterName isEqualToString:kLineHeightParameterName]) {
             
             self.lineHeight = @([parameterValue floatValue]);
         }
     } onComplete:^() {
         [self scrollToCaretAnimated:NO];
     }];
}

- (void)handleSelectionStyleCallback:(NSURL*)url
{
    NSParameterAssert([url isKindOfClass:[NSURL class]]);
    
    NSString* styles = [[url resourceSpecifier] stringByReplacingOccurrencesOfString:@"//" withString:@""];
    
    [self processStyles:styles];
}

- (void)handlePasteCallback
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (pasteboard.image != nil) {
        UIImage *pastedImage = pasteboard.image;
        
        if ([self.delegate respondsToSelector:@selector(editorView:imagePasted:)])
        {
            [self.delegate editorView:self imagePasted:pastedImage];
        }
    }
}

#pragma mark - Handling callbacks: identifying schemes

- (BOOL)isDOMLoadedScheme:(NSString*)scheme
{
	static NSString* const kCallbackScheme = @"callback-dom-loaded";
	
	return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isFocusInScheme:(NSString*)scheme
{
	static NSString* const kCallbackScheme = @"callback-focus-in";
	
	return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isFocusOutScheme:(NSString*)scheme
{
	static NSString* const kCallbackScheme = @"callback-focus-out";
	
	return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isLinkTappedScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
	static NSString* const kCallbackScheme = @"callback-link-tap";
	
	return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isImageTappedScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-image-tap";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isImageReplacedScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-image-replaced";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isVideoTappedScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-video-tap";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isVideoReplacedScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-video-replaced";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isLogCallbackScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-log";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isLogErrorCallbackScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-log-error";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isNewFieldCallbackScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-new-field";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isSelectionChangedCallbackScheme:(NSString*)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString* const kCallbackScheme = @"callback-selection-changed";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isVideoFullScreenStartedScheme:(NSString *)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");

    static NSString *const kCallbackScheme = @"callback-video-fullscreen-started";

    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isVideoFullScreenEndedScheme:(NSString *)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");

    static NSString *const kCallbackScheme = @"callback-video-fullscreen-ended";

    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isVideoPressInfoRequestScheme:(NSString *)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString *const kCallbackScheme = @"callback-videopress-info-request";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isMediaRemovedScheme:(NSString *)scheme
{
    NSAssert([scheme isKindOfClass:[NSString class]],
             @"We're expecting a non-nil string object here.");
    
    static NSString *const kCallbackScheme = @"callback-media-removed";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isSelectionStyleScheme:(NSString*)scheme
{
	static NSString* const kCallbackScheme = @"callback-selection-style";

	return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isInputCallbackScheme:(NSString*)scheme
{
	static NSString* const kCallbackScheme = @"callback-input";
	
	return [scheme isEqualToString:kCallbackScheme];
}

- (BOOL)isPasteCallbackScheme:(NSString *)scheme
{
    static NSString* const kCallbackScheme = @"callback-paste";
    
    return [scheme isEqualToString:kCallbackScheme];
}

- (void)processStyles:(NSString *)styles
{
    NSArray *styleStrings = [styles componentsSeparatedByString:kDefaultCallbackParameterSeparator];
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
	
	self.selectedImageURL = nil;
	self.selectedImageAlt = nil;
	self.selectedLinkURL = nil;
	self.selectedLinkTitle = nil;
	
    for (NSString *styleString in styleStrings) {
        NSString *updatedItem = styleString;
        if ([styleString hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [self stringByDecodingURLFormat:[styleString stringByReplacingOccurrencesOfString:@"link:" withString:@""]];
        } else if ([styleString hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[styleString stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else if ([styleString hasPrefix:@"image:"]) {
            updatedItem = @"image";
            self.selectedImageURL = [styleString stringByReplacingOccurrencesOfString:@"image:" withString:@""];
        } else if ([styleString hasPrefix:@"image-alt:"]) {
            self.selectedImageAlt = [self stringByDecodingURLFormat:[styleString stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
        }
        [itemsModified addObject:updatedItem];
    }
	
    styleStrings = [NSArray arrayWithArray:itemsModified];
    
	if ([self.delegate respondsToSelector:@selector(editorView:stylesForCurrentSelection:)])
	{
		[self.delegate editorView:self stylesForCurrentSelection:styleStrings];
	}
}

#pragma mark - Viewport rect

/**
 *  @brief      Obtain the current viewport.
 *
 *  @returns    The current viewport.
 */
- (CGRect)viewport
{
    UIScrollView* scrollView = self.webView.scrollView;
    
    CGRect viewport;
    
    viewport.origin = scrollView.contentOffset;
    viewport.size = scrollView.bounds.size;
    
    if(@available(iOS 11, *)){
        viewport.size.height -= (scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom);
        viewport.size.width -= (scrollView.adjustedContentInset.left + scrollView.adjustedContentInset.right);
    } else {
        viewport.size.height -= (scrollView.contentInset.top + scrollView.contentInset.bottom);
        viewport.size.width -= (scrollView.contentInset.left + scrollView.contentInset.right);
    }
    return viewport;
}

#pragma mark - Callback parsing

/**
 *	@brief		Extract the components that make up a parameter.
 *	@details	Should always be two (for example: 'value=65' would return @['value', '65']).
 *
 *	@param		parameter	The string parameter to parse.  Cannot be nil.
 *
 *	@returns	An array containing each component.
 */
- (NSArray*)componentsFromParameter:(NSString*)parameter
{
	NSParameterAssert([parameter isKindOfClass:[NSString class]]);
    
    NSRange range = [parameter rangeOfString:kDefaultCallbackParameterComponentSeparator];
    
    NSString* parameterName = [parameter substringToIndex:range.location];
    NSString* parameterValue = [parameter substringFromIndex:range.location + range.length];
    
    NSArray* components = @[parameterName, parameterValue];
	NSAssert([components count] == 2,
			 @"We're expecting exactly two components here.");
	
	return components;
}

/**
 *	@brief		This is a very helpful method for parsing through a callback's parameters and
 *				performing custom processing when each parameter and value is identified.
 *
 *	@param		url					The callback URL to process.  Cannot be nil.
 *	@param		block				Will be executed one time for each parameter identified by the
 *									parser.  Cannot be nil.
 *	@param		onCompleteBlock		The block to execute when the parsing finishes.  Can be nil.
 */
- (void)parseParametersFromCallbackURL:(NSURL*)url
	   andExecuteBlockForEachParameter:(ZMEditorViewCallbackParameterProcessingBlock)block
							onComplete:(ZMEditorViewNoParamsCompletionBlock)onCompleteBlock
{
	NSParameterAssert([url isKindOfClass:[NSURL class]]);
	NSParameterAssert(block);
	
	NSArray* parameters = [self parametersFromCallbackURL:url];
	
	for (NSString* parameter in parameters) {
		NSAssert([parameter isKindOfClass:[NSString class]],
				 @"We're expecting to have a non-nil NSString object here.");
		
        NSArray* components = [self componentsFromParameter:parameter];
        NSAssert([components count] == 2,
                 @"We're expecting exactly two components here.");
		
		block([components objectAtIndex:0], [components objectAtIndex:1]);
	}
	
	if (onCompleteBlock) {
		onCompleteBlock();
	}
}

/**
 *	@brief		Extract the parameters that make up a callback URL.
 *
 *	@param		url		The callback URL to parse.  Cannot be nil.
 *
 *	@returns	An array containing each parameter.
 */
- (NSArray*)parametersFromCallbackURL:(NSURL*)url
{
	NSParameterAssert([url isKindOfClass:[NSURL class]]);
	
	NSArray* parameters = [[url resourceSpecifier] componentsSeparatedByString:kDefaultCallbackParameterSeparator];
	
	return parameters;
}

#pragma mark - Fields

/**
 *  @brief      Creates a field for the specified id.
 *  @todo       At some point it would be nice to have ZMEditorView be able to handle a custom list
 *              of fields, instead of expecting the HTML page to only have a title and a content
 *              field.
 *
 *  @param      fieldId     The id of the field to create.  This is the id of the html node that
 *                          our new field will wrap.  Cannot be nil.
 *
 *  @returns    The newly created field.
 */
- (ZMEditorField*)createFieldWithId:(NSString*)fieldId
{
    NSAssert([fieldId isKindOfClass:[NSString class]],
             @"We're expecting a non-nil NSString object here.");
    
    ZMEditorField* newField = nil;
    
    if ([fieldId isEqualToString:kZMEditorViewFieldContentId]) {
        NSAssert(!_contentField,
                 @"We should never have to set this twice.");
        
        _contentField = [[ZMEditorField alloc] initWithId:fieldId webView:self.webView];
        newField = self.contentField;
    } else if ([fieldId isEqualToString:kZMEditorViewFieldHeaderId]) {
        _headerField = [[ZMEditorField alloc] initWithId:fieldId webView:self.webView];
        [self refreshHeaderViewContentSize];
        newField = self.headerField;
    } else if ([fieldId isEqualToString:kZMEditorViewFieldFooterId]) {
        _footerField = [[ZMEditorField alloc] initWithId:fieldId webView:self.webView];
        [self refreshFooterViewContentSize];
        newField = self.footerField;
    }
    NSAssert([newField isKindOfClass:[ZMEditorField class]],
             @"A new field should've been created here.");
    
    return newField;
}

#pragma mark - URL & HTML utilities

/**
 *  @brief      Adds slashes to the specified HTML string, to prevent injections when calling JS
 *              code.
 *
 *  @param      html        The HTML string to add slashes to.  Cannot be nil.
 *
 *  @returns    The HTML string with the added slashes.
 */
- (NSString *)addSlashes:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    
    return html;
}

- (NSString *)stringByDecodingURLFormat:(NSString *)string
{
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByRemovingPercentEncoding];
    return result;
}

#pragma mark - Interaction

- (void)undo
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.undo();"];
	
    [self callDelegateEditorTextDidChange];
}

- (void)redo
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.redo();"];
	
    [self callDelegateEditorTextDidChange];
}

#pragma mark - Text Access

//获取纯文字
- (NSString*)contentText {
    NSString* text = [self.contentField contentText];
    return text;
}

- (NSString*)contentHtml
{
    NSString* contentHtml = [self.contentField contentHtml];
    return contentHtml;
}

- (NSString*)html
{
    NSString* html = [self.contentField html];
    return html;
}

- (void)focus {
    [self.contentField focus];
}

#pragma mark - Scrolling support

/**
 *  @brief      Scrolls to a position where the caret is visible. This uses the values stored in caretYOffest and lineHeight properties.
 *  @param      animated    If the scrolling shoud be animated  The offset to show.
 */
- (void)scrollToCaretAnimated:(BOOL)animated
{
    BOOL notEnoughInfoToScroll = self.caretYOffset == nil || self.lineHeight == nil;
    
    if (notEnoughInfoToScroll) {
        return;
    }
    
    CGRect viewport = [self viewport];
    CGFloat caretYOffset = [self.caretYOffset floatValue];
    CGFloat lineHeight = [self.lineHeight floatValue];
    CGFloat offsetBottom = caretYOffset + lineHeight;
    
    BOOL mustScroll = (caretYOffset < viewport.origin.y || offsetBottom > viewport.origin.y + CGRectGetHeight(viewport));
    
    if (mustScroll) {
        // DRM: by reducing the necessary height we avoid an issue that moves the caret out
        // of view.
        //
        CGFloat necessaryHeight = viewport.size.height / 3;
        
        // DRM: just make sure we don't go out of bounds with the desired yOffset.
        //
        caretYOffset = MIN(caretYOffset, self.webView.scrollView.contentSize.height - necessaryHeight) - necessaryHeight/2;
        if(caretYOffset < 0){
            caretYOffset = 0;
        }
        CGRect targetRect = CGRectMake(0.0f,caretYOffset,CGRectGetWidth(viewport),necessaryHeight);
        [self.webView.scrollView scrollRectToVisible:targetRect animated:animated];
    }
}

#pragma mark - Selection

- (void)restoreSelection
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.restoreRange();"];
}

- (void)saveSelection
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.backupRange();"];
}

- (NSString*)selectedText
{
    NSString* selectedText = [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.getSelectedText();"];
	return selectedText;
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag
{
    NSString *hex = [CommUntil hexStringFromColor:color];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"ZSSEditor.setTextColor(\"#%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"ZSSEditor.setBackgroundColor(\"#%@\");", hex];
    }
	
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];
	
    [self callDelegateEditorTextDidChange];
}

//获取图片总数
- (NSInteger)imageCount {
    NSString *length = [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.getImageCount();"];
    return length.integerValue;
}


- (NSArray *)localImagePaths
{
    NSString* pathsString = [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.getContentLocalImagePaths();"];
    if(pathsString == nil || pathsString.length == 0) {
        return [NSArray array];
    }
    
    NSArray *array = [pathsString componentsSeparatedByString:@","];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    
    NSMutableArray *missArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(NSString  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = [NSURL URLWithString:obj];
        NSString *path = url.resourceSpecifier;
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [imageArray addObject:path];
        } else {
            [missArray addObject:obj];
        }
    }];
    [self removeLocalImageWithUrls:missArray];
    return imageArray;
}

- (void)replaceLocalImageWithUrls:(NSArray *)urls {
    NSString *urlString = [urls componentsJoinedByString:@","];
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.replaceContentUrlPaths(\"%@\");", urlString];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)removeLocalImageWithUrls:(NSArray *)urls {
    if(urls && urls.count > 0){
        NSString *urlString = [urls componentsJoinedByString:@","];
        NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.removeContentUrlPaths(\"%@\");", urlString];
        [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    }
}

//获取底部本地图片地址
- (NSArray *)localFooterImagePaths
{
    NSString* pathsString = [self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.getFooterLocalImagePaths();"];
    if(pathsString == nil || pathsString.length == 0) {
        return [NSArray array];
    }
    
    NSArray *array = [pathsString componentsSeparatedByString:@","];
    
    NSMutableArray *imageArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(NSString  * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = [NSURL URLWithString:obj];
        [imageArray addObject:url.resourceSpecifier];
    }];
    return imageArray;
}

- (void)replaceFooterLocalImageWithUrls:(NSArray *)urls {
    NSString *urlString = [urls componentsJoinedByString:@","];
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.replaceFooterUrlPaths(\"%@\");", urlString];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - Images

- (void)insertLocalImage:(NSString*)url uniqueId:(NSString*)uniqueId width:(CGFloat)width height:(CGFloat)height
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.insertLocalImagePath(\"%@\", \"%@\", \"%@\", \"%@\");", uniqueId, url, @(width),@(height)];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.insertImage(\"%@\", \"%@\");", url, alt];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)replaceLocalImageWithRemoteImage:(NSString*)url uniqueId:(NSString*)uniqueId mediaId:(NSString *)mediaId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.replaceLocalImageWithRemoteImage(\"%@\", \"%@\", %@);", uniqueId, url, mediaId];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateCurrentImageMeta:(WPImageMeta *)imageMeta
{
    NSString *jsonString = [imageMeta jsonStringRepresentation];
    jsonString = [self addSlashes:jsonString];
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.updateCurrentImageMeta(\"%@\");", jsonString];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setProgress:(double) progress onImage:(NSString*)uniqueId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.setProgressOnImage(\"%@\", %f);", uniqueId, progress];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)markImage:(NSString *)uniqueId failedUploadWithMessage:(NSString*) message;
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.markImageUploadFailed(\"%@\", \"%@\");", uniqueId, message];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)unmarkImageFailedUpload:(NSString *)uniqueId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.unmarkImageUploadFailed(\"%@\");", uniqueId];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)removeImage:(NSString*)uniqueId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.removeImage(\"%@\");", uniqueId];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];

}

#pragma mark - Videos

- (void)insertVideo:(NSString *)videoURL posterImage:(NSString *)posterImageURL alt:(NSString *)alt
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.insertVideo(\"%@\", \"%@\", \"%@\");", videoURL, posterImageURL, alt];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)insertInProgressVideoWithID:(NSString *)uniqueId
                   usingPosterImage:(NSString *)posterImageURL
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.insertInProgressVideoWithIDUsingPosterImage(\"%@\", \"%@\");", uniqueId, posterImageURL];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setProgress:(double)progress onVideo:(NSString *)uniqueId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.setProgressOnVideo(\"%@\", %f);", uniqueId, progress];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)replaceLocalVideoWithID:(NSString *)uniqueID
                 forRemoteVideo:(NSString *)videoURL
                   remotePoster:(NSString *)posterURL
                     videoPress:(NSString *)videoPressID
{
    NSString *videoPressSafeID = videoPressID;
    if (!videoPressSafeID) {
        videoPressSafeID = @"";
    }
    NSString *posterURLSafe = posterURL;
    if (!posterURLSafe) {
        posterURLSafe = @"";
    }
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.replaceLocalVideoWithRemoteVideo(\"%@\", \"%@\", \"%@\", \"%@\");", uniqueID, videoURL, posterURLSafe, videoPressSafeID];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)markVideo:(NSString *)uniqueId failedUploadWithMessage:(NSString*) message;
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.markVideoUploadFailed(\"%@\", \"%@\");", uniqueId, message];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)unmarkVideoFailedUpload:(NSString *)uniqueId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.unmarkVideoUploadFailed(\"%@\");", uniqueId];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)removeVideo:(NSString*)uniqueId
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.removeVideo(\"%@\");", uniqueId];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setVideoPress:(NSString *)videoPressID source:(NSString *)videoURL poster:(NSString *)posterURL
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.setVideoPressLinks(\"%@\", \"%@\", \"%@\");", videoPressID, videoURL, posterURL];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (void)pauseAllVideos
{
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.pauseAllVideos();"];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - Localization

- (void)setImageEditText:(NSString *)text
{
	NSParameterAssert([text isKindOfClass:[NSString class]]);
	
	NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.localizedEditText = \"%@\"", text];
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - URL normalization

- (NSString*)normalizeURL:(NSString*)url
{
    static NSString* const kDefaultScheme = @"http://";
    static NSString* const kURLSchemePrefix = @"://";
    
    NSString* normalizedURL = url;
    NSRange substringRange = [url rangeOfString:kURLSchemePrefix];

    if (substringRange.length == 0) {
        normalizedURL = [kDefaultScheme stringByAppendingString:url];
    }
    
    return normalizedURL;
}

#pragma mark - Links

- (void)insertLink:(NSString *)url title:(NSString*)title {
	NSParameterAssert([url isKindOfClass:[NSString class]]);
	NSParameterAssert([title isKindOfClass:[NSString class]]);
	
    url = [self normalizeURL:url];
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.insertLink(\"%@\",\"%@\");", url, title];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
		
    [self callDelegateEditorTextDidChange];
}

- (BOOL)isSelectionALink
{
	return self.selectedLinkURL != nil;
}

- (void)updateLink:(NSString *)url title:(NSString*)title
{
    NSParameterAssert([url isKindOfClass:[NSString class]]);
	NSParameterAssert([title isKindOfClass:[NSString class]]);
    
    url = [self normalizeURL:url];
    
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.updateLink(\"%@\",\"%@\");", url, title];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
    [self callDelegateEditorTextDidChange];
}

- (void)removeLink
{
	[self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.unlink();"];
}

- (void)quickLink
{
	[self.webView stringByEvaluatingJavaScriptFromString:@"ZSSEditor.quickLink();"];
}

#pragma mark - Editor: HTML interaction

// Inserts HTML at the caret position
- (void)insertHTML:(NSString *)html
{
    NSString *cleanedHTML = [self addSlashes:html];
    NSString *trigger = [NSString stringWithFormat:@"ZSSEditor.insertHTML(\"%@\");", cleanedHTML];
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - Editing
- (void)endEditing;
{
	[self.webView endEditing:YES];
}

#pragma mark - Editing lock

- (void)disableEditing
{
    _editing = NO;
    [self.contentField disableEditing];
}

- (void)enableEditing
{
    _editing = YES;
    [self.contentField enableEditing];
}

#pragma mark - Styles

- (void)alignLeft
{
    NSString *trigger = @"ZSSEditor.setJustifyLeft();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
    [self callDelegateEditorTextDidChange];
}

- (void)alignCenter
{
    NSString *trigger = @"ZSSEditor.setJustifyCenter();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)alignRight
{
    NSString *trigger = @"ZSSEditor.setJustifyRight();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)alignFull
{
    NSString *trigger = @"ZSSEditor.setJustifyFull();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setBold
{
    NSString *trigger = @"ZSSEditor.setBold();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    [self callDelegateEditorTextDidChange];
}

- (void)setBlockQuote
{
    NSString *trigger = @"ZSSEditor.setBlockquote();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
    [self callDelegateEditorTextDidChange];
}

- (void)setItalic
{
    NSString *trigger = @"ZSSEditor.setItalic();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
    [self callDelegateEditorTextDidChange];
}

- (void)setSubscript
{
    NSString *trigger = @"ZSSEditor.setSubscript();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setUnderline
{
    NSString *trigger = @"ZSSEditor.setUnderline();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];
    
    [self callDelegateEditorTextDidChange];
}

- (void)setSuperscript
{
    NSString *trigger = @"ZSSEditor.setSuperscript();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setStrikethrough
{
    NSString *trigger = @"ZSSEditor.setStrikeThrough();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setUnorderedList
{
    NSString *trigger = @"ZSSEditor.setUnorderedList();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setOrderedList
{
    NSString *trigger = @"ZSSEditor.setOrderedList();";
    [self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setHR
{
    NSString *trigger = @"ZSSEditor.setHorizontalRule();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setIndent
{
    NSString *trigger = @"ZSSEditor.setIndent();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)setOutdent
{
    NSString *trigger = @"ZSSEditor.setOutdent();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)heading1
{
    NSString *trigger = @"ZSSEditor.setHeading('h1');";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)heading2
{
    NSString *trigger = @"ZSSEditor.setHeading('h2');";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)heading3
{
    NSString *trigger = @"ZSSEditor.setHeading('h3');";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)heading4
{
    NSString *trigger = @"ZSSEditor.setHeading('h4');";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)heading5
{
    NSString *trigger = @"ZSSEditor.setHeading('h5');";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)heading6
{
    NSString *trigger = @"ZSSEditor.setHeading('h6');";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

- (void)removeFormat
{
    NSString *trigger = @"ZSSEditor.removeFormating();";
	[self.webView stringByEvaluatingJavaScriptFromString:trigger];

    [self callDelegateEditorTextDidChange];
}

#pragma mark - Delegate calls

/**
 *  @brief      Call's the delegate editorTextDidChange: method.
 */
- (void)callDelegateEditorTextDidChange
{
    if ([self.delegate respondsToSelector: @selector(editorTextDidChange:)]) {
        [self.delegate editorTextDidChange:self];
    }
}

/**
 *  @brief      Call's the delegate editorView:fieldCreated: method.
 */
- (void)callDelegateFieldCreated:(ZMEditorField*)field
{
    NSParameterAssert([field isKindOfClass:[ZMEditorField class]]);
    
    if ([self.delegate respondsToSelector:@selector(editorView:fieldCreated:)]) {
        [self.delegate editorView:self fieldCreated:field];
    }
}

/**
 *  @brief      Call's the delegate editorView:fieldFocused: method.
 */
- (void)callDelegateFieldFocused:(ZMEditorField*)field
{
    if ([self.delegate respondsToSelector:@selector(editorView:fieldFocused:)]) {
        [self.delegate editorView:self fieldFocused:field];
    }
}

/**
 *  @brief      Call's the delegate editorView:sourceFieldFocused: method.
 */
- (void)callDelegateSourceFieldFocused:(UIView*)view
{
    if ([self.delegate respondsToSelector:@selector(editorView:sourceFieldFocused:)]) {
        [self.delegate editorView:self sourceFieldFocused:view];
    }
}

//高度改变
- (void)callDelegateEditorViewHeightChange
{
    if ([self.delegate respondsToSelector:@selector(editorView:heightChangeField:)]) {
        [self.delegate editorView:self heightChangeField:self.contentField];
    }
}


@end
