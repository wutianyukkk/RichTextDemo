//
//  Copyright (c) 2014 Automattic Inc.
//
//  This source file is based on ZSSRichTextEditorViewController.h from ZSSRichTextEditor
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZMEditorView;
@class ZMEditorField;
@class WPImageMeta;

@protocol ZMEditorViewDelegate <UIWebViewDelegate>
@optional

- (void)editorView:(ZMEditorView*)editorView willBeginDragging:(UIScrollView *)scrollView;
/**
 *    @brief        滚动
 *
 *    @param        editorView        The editor view.
 *    @param        scrollView        The scrollView view.
 */
- (void)editorView:(ZMEditorView*)editorView didScroll:(UIScrollView *)scrollView;

/**
 *	@brief		Received when the editor text is changed.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorTextDidChange:(ZMEditorView*)editorView;

/**
 *	@brief		Received when the underlying web content's DOM is ready.
 *	@details	The content never completely loads while offline under some circumstances.
 *				This event offers an alternative to start working on the page's contents.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorViewDidFinishLoadingDOM:(ZMEditorView*)editorView;

/**
 *	@brief		Received when all of the web content is ready.
 *	@details	The content never completely loads while offline under some circumstances.
 *				This event offers an alternative to start working on the page's contents.
 *
 *	@param		editorView		The editor view.
 */
- (void)editorViewDidFinishLoading:(ZMEditorView*)editorView;

/**
 *	@brief		Received when the editor creates one of it's fields.
 *  @details    The editor fields will be nil before this method is called.  This is because editor
 *              fields are created as part of the process of loading the HTML.
 *
 *	@param		editorView		The editor view.
 *	@param		field			The new field.
 */
- (void)editorView:(ZMEditorView*)editorView fieldCreated:(ZMEditorField*)field;

/**
 *	@brief		Received when the editor focus changes on a visual mode field.
 *
 *	@param		editorView		The editor view.
 *	@param		field			The focused field.
 */
- (void)editorView:(ZMEditorView*)editorView fieldFocused:(ZMEditorField*)field;

/**
 *	@brief		Received when the editor focus changes on a HTML mode field.
 *
 *	@param		editorView		The editor view.
 *	@param		view			The focused view.
 */
- (void)editorView:(ZMEditorView*)editorView sourceFieldFocused:(UIView*)view;

/**
 *	@brief		Received when the user taps on a link in the editor.
 *
 *	@param		editorView		The editor view.
 *	@param		url				The url that should be loaded.
 *	@param		title			The title of the link that was tapped.
 *
 *	@return		YES if the tap was handled by the receiver and default handler should be supressed,
 *				NO if it wasn't.
 */
- (BOOL)editorView:(ZMEditorView*)editorView linkTapped:(NSURL*)url title:(NSString*)title;

/**
 *	@brief		Received when the user taps on a image in the editor.
 *
 *	@param		editorView	The editor view.
 *	@param		imageId		The id of image of the image that was tapped.
 *	@param		url			The url of the image that was tapped.
 *
 *	@return		YES if the tap was handled by the receiver and default handler should be supressed,
 *				NO if it wasn't.
 */
- (BOOL)editorView:(ZMEditorView*)editorView imageTapped:(NSString *)imageId url:(NSURL *)url;

/**
 * @brief		Received when the user taps on a image in the editor.
 *
 * @param		editorView	The editor view.
 * @param		imageId		The id of image of the image that was tapped.
 * @param		url			The url of the image that was tapped.
 * @param		imageMeta	The meta data associated with the image that was tapped.
 *
 */
- (void)editorView:(ZMEditorView*)editorView imageTapped:(NSString *)imageId url:(NSURL *)url imageMeta:(WPImageMeta *)imageMeta;

/**
 * @brief		Received when the user taps on a video in the editor.
 *
 * @param		editorView	The editor view.
 * @param		videoID		The id of image of the image that was tapped.
 * @param		url			The url of the image that was tapped.
 *
 */
- (void)editorView:(ZMEditorView*)editorView videoTapped:(NSString *)videoID url:(NSURL *)url;

/**
 *	@brief		Received when the selection is changed.
 *	@details	Useful to know what styles surround the current selection.
 *
 *	@param		editorView		The editor view.
 *	@param		styles			The styles that surround the current selection.
 */
- (void)editorView:(ZMEditorView*)editorView stylesForCurrentSelection:(NSArray*)styles;

/**
 * @brief		Received when a image local url is replaced by the final remote url.
 *
 * @param		editorView	The editor view.
 * @param		imageId		The id of image of the image that had the local url replaced by remote url.
 *
 */
- (void)editorView:(ZMEditorView*)editorView imageReplaced:(NSString *)imageId;

/**
 * @brief		Received when a video local url is replaced by the final remote url.
 *
 * @param		editorView	The editor view.
 * @param		videoID		The unique id of the video that had the local url replaced by remote url.
 *
 */
- (void)editorView:(ZMEditorView*)editorView videoReplaced:(NSString *)videoID;

/**
 * @brief		Received when an image is pasted into the editor.
 *
 * @param       editorView  The editor view.
 * @param       image The image that was pasted.
 *
 */
- (void)editorView:(ZMEditorView*)editorView imagePasted:(UIImage *)image;

/**
 * @brief		Received when a the editor request the url for a videopress shortcode.
 *
 * @param		editorView	 The editor view.
 * @param		videoPressID The VidePress ID that the editor needs information about.
 *
 */
- (void)editorView:(ZMEditorView *)editorView videoPressInfoRequest:(NSString *)videoPressID;

/**
 * @brief		Received when a the editor detects the removal by the user of a uploading media element.
 *
 * @param		editorView	 The editor view.
 * @param		mediaID The media ID that was removed from the editor
 *
 */
- (void)editorView:(ZMEditorView *)editorView mediaRemoved:(NSString *)mediaID;

//高度改变
- (void)editorView:(ZMEditorView *)editorView heightChangeField:(ZMEditorField*)field;

@end

@interface ZMEditorView : UIView

/**
 *	@brief		The editor's delegate.
 */
@property (nonatomic, weak, readwrite) id<ZMEditorViewDelegate> delegate;

/**
 *	@brief		Stores the current edit mode state for this view.
 */
@property (nonatomic, assign, readonly, getter = isEditing) BOOL editing;

#pragma mark - Properties: Selection
@property (nonatomic, strong, readonly) NSString *selectedLinkTitle;
@property (nonatomic, strong, readonly) NSString *selectedLinkURL;

#pragma mark - Properties: Fields
@property (nonatomic, strong, readonly) ZMEditorField* headerField;
@property (nonatomic, strong, readonly) ZMEditorField* footerField;
@property (nonatomic, strong, readonly) ZMEditorField* contentField;
@property (nonatomic, weak, readonly) ZMEditorField* focusedField;

#pragma mark - Properties: Subviews
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

#pragma mark - URL normalization

- (NSString*)normalizeURL:(NSString*)url;

#pragma mark - Interaction

- (void)insertHTML:(NSString *)html;

/**
 *	@brief		Undo the last operation.
 */
- (void)undo;

/**
 *	@brief		Redo the last operation.
 */
- (void)redo;

/**
 *    @brief        设置WEBView弹性操作.
 */
-(void)setBouncesEnable:(BOOL)enable;

#pragma mark - Text Access

/**
 *  @brief      Retrieves the content in both HTML and visual mode.
 *
 *  @returns    The content.
 */
- (NSString*)contentText;
- (NSString*)contentHtml;
- (NSString*)html;
//焦点 定位编辑内容处
- (void)focus;

#pragma mark - Selection


- (void)restoreSelection;

/**
 *	@brief		Saves the current text selection.
 *	@details	The selection is restored automatically by some insert operations when called.
 *				The only important step is to call this method before an insertion of a link or
 *				image.
 */
- (void)saveSelection;

/**
 *	@brief		Call this to retrieve the selected text.
 *
 *	@returns	The selected text.
 */
- (NSString*)selectedText;

- (void)setSelectedColor:(UIColor*)color tag:(int)tag;


/**
 获取文章中图片总数

 @return 返回图片总数
 */
- (NSInteger)imageCount;

/**
 获取本地添加的图片

 @return 返回图片地址数组
 */
- (NSArray *)localImagePaths;

/**
 替换网络本地图片

 @param urls URL数组
 */
- (void)replaceLocalImageWithUrls:(NSArray *)urls;

/**
 获取本地添加的图片
 
 @return 返回图片地址数组
 */
- (NSArray *)localFooterImagePaths;

- (void)replaceFooterLocalImageWithUrls:(NSArray *)urls;

#pragma mark - Images

/**
 *  @brief      Inserts a local image URL.  Useful for images that need to be uploaded.
 *  @details    By inserting a local image URL, we can make sure the image is shown to the user
 *              as soon as it's selected for uploading.  Once the image is successfully uploaded
 *              the application should call replaceLocalImageWithRemoteImage().
 *
 *  @param      url         The URL of the local image to display.  Please keep in mind that a
 *                          remote URL can be used here too, since this method does not check for
 *                          that.  It would be a mistake.
 *  @param      uniqueId    This is a unique ID provided by the caller.  It exists as a mechanism
 *                          to update the image node with the remote URL when
 *                          replaceLocalImageWithRemoteImage() is called.
 */
- (void)insertLocalImage:(NSString*)url uniqueId:(NSString*)uniqueId width:(CGFloat)width height:(CGFloat)height;

- (void)insertImage:(NSString *)url alt:(NSString *)alt;

/**
 *  @brief      Replaces a local image URL with a remote image URL.  Useful for images that have
 *              just finished uploading.
 *  @details    The remote image can be available after a while, when uploading images.  This method
 *              allows for the remote URL to be loaded once the upload completes.
 *
 *  @param      url         The URL of the remote image to display.
 *  @param      uniqueId    This is a unique ID provided by the caller.  It exists as a mechanism
 *                          to update the image node with the remote URL
 *                          when replaceLocalImageWithRemoteImage() is called.
 *  @param      mediaId     The mediaID of the image on the server
 */
- (void)replaceLocalImageWithRemoteImage:(NSString*)url uniqueId:(NSString*)uniqueId mediaId:(NSString *)mediaId;

- (void)updateImage:(NSString *)url alt:(NSString *)alt;

- (void)updateCurrentImageMeta:(WPImageMeta *)imageMeta;

- (void)setProgress:(double) progress onImage:(NSString*)uniqueId;

/**
 *  @brief      Marks a image that failed to upload with an overlay that has a retry image and a message.
 *              allows for the remote URL to be loaded once the upload completes.
 *
 *  @param      uniqueId    Unique Id of the image element that is going to be marked as failed
 *  @param      message     A message to display overlay on the image to explain next steps
 */
- (void)markImage:(NSString *)uniqueId failedUploadWithMessage:(NSString*) message;

/**
 *  @brief      Removes any failure overlay created by the markImage:failedUploadWithMessage
 *
 *  @param      uniqueId    Unique Id of the image element that is going to be unmarked as failed
 */
- (void)unmarkImageFailedUpload:(NSString *)uniqueId;

- (void)removeImage:(NSString*)uniqueId;

#pragma mark - Localization

/**
 *	@brief		Sets the text for the edit button on images.  Useful for localization.
 *
 *	@param		text		The text to use.  Cannot be nil.
 */
- (void)setImageEditText:(NSString *)text;

#pragma mark - Videos

/**
 *  Inserts a HTML video element using a poster image to preview it before its fully loaded.
 *
 *  @param videoURL       URL for the video file
 *  @param posterImageURL URL for the poster image to be used before the video is loaded
 *  @param alt            an alternate description for the video
 */
- (void)insertVideo:(NSString *)videoURL posterImage:(NSString *)posterImageURL alt:(NSString *)alt;

/**
 *  Inserts a HTML video element that is using a poster image to preview it before it's fully loaded
 *
 *  @param uniqueId       Unique ID to identity the video for progress report and later on to be replaced by the final video.
 *  @param posterImageURL URL for a image file to show while the video is being loaded.

 */
- (void)insertInProgressVideoWithID:(NSString *)uniqueId usingPosterImage:(NSString *)posterImageURL;

/**
 *  Sets the value of upload progress for a video
 *
 *  @param progress amount of progress being made it should be a value between 0 and 1.
 *  @param uniqueId ID of the video to be updated
 */
- (void)setProgress:(double)progress onVideo:(NSString *)uniqueId;

/**
 *  Replaces the local video url on the video with the ID specified with the final remote video url
 *
 *  @param uniqueID  ID of video to be updated
 *  @param videoURL  URL for the remote video
 *  @param posterURL URL for the remote poster image
 *  @param videoPressID ID for videoPress if applicable, nil if it isnt a videopress video
 */
- (void)replaceLocalVideoWithID:(NSString *)uniqueID forRemoteVideo:(NSString *)videoURL remotePoster:(NSString *)posterURL videoPress:(NSString *)videoPressID;

/**
 *  Sets the interface of the video with the uniqueId to a failed status with the message specified
 *
 *  @param uniqueId ID of the video to be marked as failed
 *  @param message  Details why the video has failed to upload
 */
- (void)markVideo:(NSString *)uniqueId failedUploadWithMessage:(NSString*) message;

/**
 *  Removes the failed interface on the video with the uniqueID
 *
 *  @param uniqueId ID of the video to be updated
 */
- (void)unmarkVideoFailedUpload:(NSString *)uniqueId;

/**
 *  Removed the video with the uniqueID from the HTML
 *
 *  @param uniqueId ID of video to be removed
 */
- (void)removeVideo:(NSString*)uniqueId;

/**
 *  @brief      Set video element, identified with a videoPressID, source and poster urls.
 *
 *  @param videoPressID identifier of Video Press element
 *  @param videoURL     url for videopress video source
 *  @param posterURL    url for the poster image for video
 */
- (void)setVideoPress:(NSString *)videoPressID source:(NSString *)videoURL poster:(NSString *)posterURL;

/**
 *  Pauses all the videos on the editor
 */
- (void)pauseAllVideos;

/**
 刷新头部视图占位高度
 */
- (void)refreshHeaderViewContentSize;

/**
 刷新底部视图占位高度
 */
- (void)refreshFooterViewContentSize;


#pragma mark - Links

/**
 *	@brief		Inserts a link at the last saved selection.
 *
 *	@param		url		The url that will open when the link is clicked.  Cannot be nil.
 *	@param		title	The link title.  Cannot be nil.
 */
- (void)insertLink:(NSString *)url title:(NSString*)title;

/**
 *	@brief		Call this method to know if the current selection is part of a link.
 *
 *	@return		YES if the current selection is part of a link.
 */
- (BOOL)isSelectionALink;

/**
 *	@brief		Updates the link at the last saved selection.
 *
 *	@param		url		The url that will open when the link is clicked.  Cannot be nil.
 *	@param		title	The link title.  Cannot be nil.
 */
- (void)updateLink:(NSString *)url title:(NSString*)title;

- (void)quickLink;
- (void)removeLink;

#pragma mark - Editing

/**
 *	@brief		Ends editing and forces any subview to resign first responder.
 */
- (void)endEditing;

#pragma mark - Editing lock

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing;

/**
 *	@brief		Enables editing.
 */
- (void)enableEditing;

#pragma mark - Styles

- (void)alignLeft;
- (void)alignCenter;
- (void)alignRight;
- (void)alignFull;
- (void)setBold;
- (void)setBlockQuote;
- (void)setItalic;
- (void)setSubscript;
- (void)setUnderline;
- (void)setSuperscript;
- (void)setStrikethrough;
- (void)setUnorderedList;
- (void)setOrderedList;
- (void)setHR;
- (void)setIndent;
- (void)setOutdent;
- (void)heading1;
- (void)heading2;
- (void)heading3;
- (void)heading4;
- (void)heading5;
- (void)heading6;
- (void)removeFormat;

@end
