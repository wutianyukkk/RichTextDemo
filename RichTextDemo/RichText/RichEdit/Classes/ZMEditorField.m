#import "ZMEditorField.h"

static NSString* const kZMEditorFieldJavascriptFalse = @"false";
static NSString* const kZMEditorFieldJavascriptTrue = @"true";

@interface ZMEditorField ()

/**
 *  @brief      A flag to indicate wether the DOM has been loaded or not.
 */
@property (nonatomic, assign, readwrite) BOOL domLoaded;

/**
 *  @brief      The web view to use for all javascript calls.
 */
@property (nonatomic, strong, readonly) UIWebView* webView;

#pragma mark - Properties: preloaded values

/**
 *  @brief      Serves as a temporary buffer to store any value set to the HTML of this field before
 *              the DOM is loaded.
 */
@property (nonatomic, copy, readwrite) NSString* preloadedHTML;

/**
 *  @brief      Serves as a temporary buffer to store any value set to the placeholderText of this
 *              field before the DOM is loaded.
 */
@property (nonatomic, copy, readwrite) UIColor* preloadedPlaceholderColor;

/**
 *  @brief      Serves as a temporary buffer to store any value set to the placeholderColor of this
 *              field before the DOM is loaded.
 */
@property (nonatomic, copy, readwrite) NSString* preloadedPlaceholderText;

@end

@implementation ZMEditorField

#pragma mark - Initializers

/**
 *  @brief      We're disabling this initializer.  The correct one is initWithId:
 * 
 *  @returns    nil
 */
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    self = nil;
    return self;
}

- (instancetype)initWithId:(NSString*)nodeId
                   webView:(UIWebView*)webView
{
    NSAssert([nodeId isKindOfClass:[NSString class]],
             @"We're expecting a non-nil NSString object here.");
    
    self = [super init];
    
    if (self) {
        _nodeId = nodeId;
        _webView = webView;
    }
    
    return self;
}

#pragma mark - DOM status

- (void)handleDOMLoaded
{
    NSAssert(!_domLoaded,
             @"This method should only be called once.");
    
    self.domLoaded = YES;
    
    [self setupInitialHTML];
    [self setupInitialPlaceholderText];
    [self setupInitialPlaceholderColor];
}

- (void)setupInitialHTML
{
    [self setHtml:self.preloadedHTML];
    self.preloadedHTML = nil;
}

- (void)setupInitialPlaceholderText
{
    [self setPlaceholderText:self.preloadedPlaceholderText];
    self.preloadedPlaceholderText = nil;
}

- (void)setupInitialPlaceholderColor
{
    [self setPlaceholderColor:self.preloadedPlaceholderColor];
    self.preloadedPlaceholderColor = nil;
}

#pragma mark - Node access

/**
 *  @brief      Returns the javascript string to obtain the wrapped node.
 */
- (NSString*)wrappedNodeJavascriptAccessor
{
    static NSString* const kWrappedNodeByIdFormat = @"ZSSEditor.getField(\"%@\")";
    
    NSString* wrappedNode = [NSString stringWithFormat:kWrappedNodeByIdFormat, self.nodeId];
    
    return wrappedNode;
}

#pragma mark - Editing lock

- (void)disableEditing
{
    NSString* javascript = [NSString stringWithFormat:@"%@.disableEditing();", [self wrappedNodeJavascriptAccessor]];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)enableEditing
{
    NSString* javascript = [NSString stringWithFormat:@"%@.enableEditing();", [self wrappedNodeJavascriptAccessor]];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - font-size
- (void)setFieldFontSize:(CGFloat)size
{
    NSString* javascript = [NSString stringWithFormat:@"%@.setFontSize(\"%@\");", [self wrappedNodeJavascriptAccessor], @(size)];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setLetterSpacing:(CGFloat)size
{
    size = size * 2 * 1.0/ScreenScale;
    NSString* javascript = [NSString stringWithFormat:@"%@.setLetterSpacing(\"%@\");", [self wrappedNodeJavascriptAccessor], @(size)];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}



#pragma mark - Height
- (void)setFieldHeight:(CGFloat)height
{
    NSString* javascript = [NSString stringWithFormat:@"%@.setFieldHeight(\"%@\");", [self wrappedNodeJavascriptAccessor], @(height)];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setMaxHeight{
    NSString* javascript = [NSString stringWithFormat:@"%@.setMaxHeight();", [self wrappedNodeJavascriptAccessor]];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)removeMaxHeight {
    NSString* javascript = [NSString stringWithFormat:@"%@.removeMaxHeight();", [self wrappedNodeJavascriptAccessor]];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (double)contentHeight {
    NSString* javascript = [NSString stringWithFormat:@"%@.contentHeight();", [self wrappedNodeJavascriptAccessor]];
    NSString *heightString = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    return heightString.doubleValue;
}

#pragma mark - HTML

- (NSString*)html
{
    NSString* html = nil;
    
    if (!self.domLoaded) {
        html = self.preloadedHTML;
    } else {
        NSString* javascript = [NSString stringWithFormat:@"%@.getInnerHTML();", [self wrappedNodeJavascriptAccessor]];
        
        html = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
    
    return html;
}

- (NSString*)contentHtml
{
    NSString* html = nil;
    
    if (!self.domLoaded) {
        html = self.preloadedHTML;
    } else {
        NSString* javascript = [NSString stringWithFormat:@"%@.getHTML();", [self wrappedNodeJavascriptAccessor]];
        
        html = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
    
    return html;
}

- (NSString*)contentText
{
    NSString* strippedHtml = nil;
    
    if (!self.domLoaded) {
        strippedHtml = self.preloadedHTML;
    } else {
        NSString* javascript = [NSString stringWithFormat:@"%@.strippedHTML();", [self wrappedNodeJavascriptAccessor]];        
        strippedHtml = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
    
    return strippedHtml;
}

- (NSString*)limitHTML:(NSInteger)maxLength
{
    NSString* javascript = [NSString stringWithFormat:@"%@.limitHTML(%@);", [self wrappedNodeJavascriptAccessor],@(maxLength)];
    NSString* limitString = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    return limitString;
}



- (void)setText:(NSString*)text
{
    if (!self.domLoaded) {
        self.preloadedHTML = text;
    } else {
        
        if (text) {
            text = [self sanitizeHTML:text];
        } else {
            text = @"";
        }
        
        NSString* javascript = [NSString stringWithFormat:@"%@.setPlainText(\"%@\");", [self wrappedNodeJavascriptAccessor], text];
        
        [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
}

- (void)setHtml:(NSString*)html
{
    if (!self.domLoaded) {
        self.preloadedHTML = html;
    } else {
        
        if (html) {
            html = [self sanitizeHTML:html];
        } else {
            html = @"";
        }
        
        NSString* javascript = [NSString stringWithFormat:@"%@.setHTML(\"%@\");", [self wrappedNodeJavascriptAccessor], html];
        
        [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
}

#pragma mark - Placeholder

- (void)setPlaceholderText:(NSString*)placeholderText
{
    if (!self.domLoaded) {
        self.preloadedPlaceholderText = placeholderText;
    } else {
        placeholderText = [self sanitizeHTML:placeholderText];
        NSString* javascript = [NSString stringWithFormat:@"%@.setPlaceholderText(\"%@\");", [self wrappedNodeJavascriptAccessor], placeholderText?:@""];
        
        [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    if (placeholderColor == nil) {
        return;
    }
    if (!self.domLoaded) {
        self.preloadedPlaceholderColor = placeholderColor;
    } else {        
        NSString *hexColorStr = [CommUntil hexStringFromColor:placeholderColor];
        
        NSString* javascript = [NSString stringWithFormat:@"%@.setPlaceholderColor(\"#%@\");", [self wrappedNodeJavascriptAccessor], hexColorStr];
        
        [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    }
}

#pragma mark - URL & HTML utilities

/**
 *  @brief      Adds slashes and removes script tags from the specified HTML string, to prevent injections when calling JS
 *              code.
 *
 *  @param      html    The HTML string to sanitize.  Cannot be nil.
 *
 *  @returns    The sanitized HTML string.
 */
- (NSString *)sanitizeHTML:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];

    // Invisible line separator and paragraph separator characters.
    // Fixes https://github.com/wordpress-mobile/WordPress-iOS/issues/5496 and
    // https://github.com/wordpress-mobile/WordPress-Editor-iOS/issues/830
    html = [html stringByReplacingOccurrencesOfString:@"\u2028"  withString:@"\\u2028"];
    html = [html stringByReplacingOccurrencesOfString:@"\u2029"  withString:@"\\u2029"];

    html = [html stringByReplacingOccurrencesOfString:@"<script>" withString:@"&lt;script&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
    html = [html stringByReplacingOccurrencesOfString:@"</script>" withString:@"&lt;/script&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];

    return html;
}

#pragma mark - Focus

- (void)focus
{
    NSString* javascript = [NSString stringWithFormat:@"%@.focus();", [self wrappedNodeJavascriptAccessor]];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)blur
{
    NSString* javascript = [NSString stringWithFormat:@"%@.blur();", [self wrappedNodeJavascriptAccessor]];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - i18n

- (BOOL)isRightToLeftTextEnabled
{
    NSString* javascript = [NSString stringWithFormat:@"%@.isRightToLeftTextEnabled();", [self wrappedNodeJavascriptAccessor]];
    NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    
    return [result boolValue];
}

- (void)setRightToLeftTextEnabled:(BOOL)isRTL
{
    NSString* rtlString = nil;
    
    if (isRTL) {
        rtlString = kZMEditorFieldJavascriptTrue;
    } else {
        rtlString = kZMEditorFieldJavascriptFalse;
    }
    
    NSAssert([rtlString isKindOfClass:[NSString class]], @"Expected a non-nil NSString object here.");
    
    NSString* javascript = [NSString stringWithFormat:@"%@.enableRightToLeftText(%@);", [self wrappedNodeJavascriptAccessor], rtlString];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - Settings

- (BOOL)isMultiline
{
    NSString* javascript = [NSString stringWithFormat:@"%@.isMultiline();", [self wrappedNodeJavascriptAccessor]];
    NSString* result = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    
    return [result boolValue];
}

- (void)setMultiline:(BOOL)multiline
{
    NSString* multilineString = nil;
    
    if (multiline) {
        multilineString = kZMEditorFieldJavascriptTrue;
    } else {
        multilineString = kZMEditorFieldJavascriptFalse;
    }
    
    NSAssert([multilineString isKindOfClass:[NSString class]],
             @"Expected a non-nil NSString object here.");
    
    NSString* javascript = [NSString stringWithFormat:@"%@.setMultiline(%@);", [self wrappedNodeJavascriptAccessor], multilineString];
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

@end
