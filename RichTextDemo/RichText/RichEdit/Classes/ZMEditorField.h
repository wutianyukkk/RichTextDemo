#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommentConst.h"
#import "UIView+ZM.h"
#import "CommUntil.h"

@interface ZMEditorField : NSObject

/**
 *  @brief      inputAccessoryView      The input accessory view for the field.
 */
@property (nonatomic, strong, readwrite) UIView* inputAccessoryView;

/**
 *  @brief      nodeId      The ID of the HTML node this editor field wraps.
 */
@property (nonatomic, copy, readonly) NSString* nodeId;

#pragma mark - Initializers

/**
 *  @brief      Initializes the field with the specified HTML node id.
 *
 *  @param      nodeId      The id of the html node this object will wrap.  Cannot be nil.
 *  @param      webView     The web view to use for all javascript calls.  Cannot be nil.
 *
 *  @returns    The initialized object.
 */
- (instancetype)initWithId:(NSString*)nodeId
                   webView:(UIWebView*)webView;

#pragma mark - DOM status

/**
 *  @brief      Called by the owner of this field to signal the DOM has been loaded.
 */
- (void)handleDOMLoaded;

#pragma mark - Editing lock

/**
 *	@brief		Disables editing.
 */
- (void)disableEditing;

/**
 *	@brief		Enables editing.
 */
- (void)enableEditing;

#pragma mark - HTML
/**
 设置默认字体大小  默认16号字体
 
 @param size 字体大小
 */
- (void)setFieldFontSize:(CGFloat)size;


/**
 设置默认字体间距

 @param size 间距大小
 */
- (void)setLetterSpacing:(CGFloat)size;

/**
 设置高度

 @param height 头部占用高度 不用于内容
 */
- (void)setFieldHeight:(CGFloat)height;

//设置最大高度样式
- (void)setMaxHeight;
//移除最大高度样式
- (void)removeMaxHeight;
//获取内容高度
- (double)contentHeight;

/**
 *  @brief      Retrieves the field's html contents.
 *
 *  @returns    The field's html contents.
 */
- (NSString*)html;


/**
 处理后的不带标签的

 @return html内容
 */
- (NSString*)contentHtml;

/**
 *  @brief      获取纯文本内容
 *
 *  @returns    The field's contents without HTML tags.
 */
- (NSString*)contentText;

/**
 获取指定长度的内容

 @param maxLength 长度
 @return 带html标签的字符串
 */
- (NSString*)limitHTML:(NSInteger)maxLength;

/**
 *  @brief      Sets the field's plain text contents. The param string is
 *              not interpreted as HTML.
 *
 *  @param      text     The new field's plain text contents.
 */
- (void)setText:(NSString*)text;

/**
 *  @brief      Sets the field's html contents.
 *
 *  @param      html     The new field's html contents.
 */
- (void)setHtml:(NSString*)html;

#pragma mark - Placeholder

/**
 *  @brief      Sets the placeholder text for this field.
 *
 *  @param      placeholderText     The new placeholder text.
 */
- (void)setPlaceholderText:(NSString*)placeholderText;

/**
 *  @brief      Sets the placeholder color for this field.
 *
 *  @param      placeholderColor     The new placeholder color.
 */
- (void)setPlaceholderColor:(UIColor *)placeholderColor;

#pragma mark - Focus

/**
 *	@brief		Assigns focus to the field.
 *	@todo		DRM: Replace this with becomeFirstResponder????
 */
- (void)focus;

/**
 *	@brief		Resigns focus from the field.
 *	@todo		DRM: Replace this with resignFirstResponder????
 */
- (void)blur;

#pragma mark - i18n

/**
 *  @brief      Whether the field has RTL text direction enabled
 *
 *  @returns    YES if the field is RTL, NO otherwise.
 */
- (BOOL)isRightToLeftTextEnabled;

/**
 *  @brief      Sets the field's right to left text direction.
 *
 *  @param      isRTL   Use YES if the field is RTL, NO otherwise.
 */
- (void)setRightToLeftTextEnabled:(BOOL)isRTL;

#pragma mark - Settings

/**
 *  @brief      Whether the field is single line or multiline.
 *
 *  @returns    YES if the field is multiline, NO otherwise.
 */
- (BOOL)isMultiline;

/**
 *  @brief      Sets the field's multiline configuration.
 *
 *  @param      multiline   Use YES if the field is multiline, NO otherwise.
 */
- (void)setMultiline:(BOOL)multiline;

@end
