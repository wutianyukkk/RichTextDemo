//
//  ZMEditorToolBarView.m
//  zhangmen
//
//  Created by zhao on 2017/9/29.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import "ZMEditorToolBarView.h"

@interface ZMEditorToolBarView ()

@property (strong, nonatomic) UIView *toolbarView;

@property (strong, nonatomic) UIView *topbarView;

@property (strong, nonatomic) NSMutableArray *toolBarArray;

@property (strong, nonatomic) NSMutableArray *fontArray;

@property (strong, nonatomic) NSMutableArray *justifyArray;

@property (strong, nonatomic) NSMutableArray *colorArray;

@property (strong, nonatomic) UIImageView *topSignView;  //底部箭头

@property (assign, nonatomic) CGFloat itemWidth;
    
@property (nonatomic, assign) ZMEditorViewElementTag topElementTag;

@end

@implementation ZMEditorToolBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

//重写点击处理
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.bounds,point) || CGRectContainsPoint(self.topbarView.frame, point)) {
        return YES;
    }
    return NO;
}


- (void)initSubViews {
    self.backgroundColor = [UIColor whiteColor];
    self.topElementTag = ZMEditorViewElementTagNone;
    
    [self initMenusBar];
    
    self.toolbarView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:self.toolbarView];
    
    [self setToolBarWithButtons:self.toolBarArray];
    
    self.topbarView = [[UIView alloc]initWithFrame:CGRectZero];
    self.topbarView.backgroundColor = [CommUntil colorWithHexString:@"ffffff"];
    self.topbarView.layer.cornerRadius = 5;
    self.topbarView.layer.borderColor = [CommUntil colorWithHexString:@"dbdbdb"].CGColor;
    self.topbarView.layer.borderWidth = 1.0/ScreenScale * 2;
    self.topbarView.layer.masksToBounds = YES;
    [self addSubview:self.topbarView];
    
    self.topSignView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 10)];
    self.topSignView.image = [self topSignImage:self.topSignView.frame.size];
    self.topSignView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.topSignView];
    self.topSignView.hidden = YES;
}

- (void)initMenusBar {
    [self initToolBarButtons];
    [self initFontBarButtons];
    [self initJustifyBarButtons];
    [self initColorBarButtons];
}

- (void)initToolBarButtons {
    
    self.toolBarArray = [NSMutableArray array];
    
    NSArray *array = @[
                       @{@"htmlProperty":@"image",   @"imageName":@"article_image",      @"selector":@"insertImage:",   @"type":@(ZMEditorViewElementTagImageBarButton)},
                       @{@"htmlProperty":@"font",    @"imageName":@"article_font",       @"selector":@"setFontBar:",    @"type":@(ZMEditorViewElementTagFontBarButton)},
                       @{@"htmlProperty":@"link",    @"imageName":@"article_link",       @"selector":@"insertLink:",    @"type":@(ZMEditorViewElementTagLinkBarButton)},
                       @{@"htmlProperty":@"justify", @"imageName":@"article_left",       @"selector":@"setJustifyBar:", @"type":@(ZMEditorViewElementTagJustifyBarButton)},
                       @{@"htmlProperty":@"color",   @"imageName":@"article_color",      @"selector":@"setColorBar:",   @"type":@(ZMEditorViewElementTagColorBarButton)},
                       @{@"htmlProperty":@"space",   @"imageName":@"",                                                  @"type":@(ZMEditorViewElementTagSpaceBarButton)},
                       @{@"htmlProperty":@"keyboard",@"imageName":@"article_keyboard",   @"selector":@"setKeyBoard:",   @"type":@(ZMEditorViewElementTagKeyBoardBarButton)}
                       ];
    _itemWidth  = CGRectGetWidth(self.bounds)/array.count;
    for(NSDictionary *dict in array) {
        ZMEditorToolbarButton *button = [self createToolBarButton:dict padding:0];
        button.zm_width = _itemWidth;
        [self.toolBarArray addObject:button];
    }
}


- (void)initFontBarButtons {
    
    self.fontArray = [NSMutableArray array];
    
    NSArray *array = @[
                       @{@"htmlProperty":@"bold",   @"imageName":@"article_bold_normal",   @"selectImageName":@"article_bold_select",   @"selector":@"setBold:",   @"type":@(ZMEditorViewElementTagBoldBarButton)},
                       @{@"htmlProperty":@"italic", @"imageName":@"article_italic_normal", @"selectImageName":@"article_italic_select", @"selector":@"setItalic:", @"type":@(ZMEditorViewElementTagItalicBarButton)},
                       @{@"htmlProperty":@"h1",     @"imageName":@"article_h1_normal",     @"selectImageName":@"article_h1_select",     @"selector":@"setH1:",     @"type":@(ZMEditorViewElementTagH1BarButton)},
                       @{@"htmlProperty":@"h2",     @"imageName":@"article_h2_normal",     @"selectImageName":@"article_h2_select",     @"selector":@"setH2:",     @"type":@(ZMEditorViewElementTagH2BarButton)},
                       @{@"htmlProperty":@"h3",     @"imageName":@"article_h3_normal",     @"selectImageName":@"article_h3_select",     @"selector":@"setH3:",     @"type":@(ZMEditorViewElementTagH3BarButton)},
                       @{@"htmlProperty":@"h4",     @"imageName":@"article_h4_normal",     @"selectImageName":@"article_h4_select",     @"selector":@"setH4:",     @"type":@(ZMEditorViewElementTagH4BarButton)}
                       ];
    for(NSDictionary *dict in array) {
        ZMEditorToolbarButton *button = [self createToolBarButton:dict padding:23];
        [self.fontArray addObject:button];
    }
}


- (void)initJustifyBarButtons {
    
    self.justifyArray = [NSMutableArray array];
    
    NSArray *array = @[
                       @{@"htmlProperty":@"justifyLeft",   @"imageName":@"article_left_normal",    @"selectImageName":@"article_left_select",   @"selector":@"setJustifyLeft:",   @"type":@(ZMEditorViewElementTagJustifyLeftBarButton)},
                       @{@"htmlProperty":@"justifyCenter", @"imageName":@"article_center_normal",  @"selectImageName":@"article_center_select", @"selector":@"setJustifyCenter:", @"type":@(ZMEditorViewElementTagJustifyCenterBarButton)},
                       @{@"htmlProperty":@"justifyRight",  @"imageName":@"article_right_normal",    @"selectImageName":@"article_right_select",  @"selector":@"setJustifyRight:",  @"type":@(ZMEditorViewElementTagJustifyRightBarButton)}
                       ];
    for(NSDictionary *dict in array) {
        ZMEditorToolbarButton *button = [self createToolBarButton:dict padding:33];
        [self.justifyArray addObject:button];
    }
}

- (void)initColorBarButtons {
    
    self.colorArray = [NSMutableArray array];
    
    NSArray *array = @[
                       @{@"htmlProperty":@"textColor:323232", @"imageName":@"article_black_normal",   @"selectImageName":@"article_black_select",  @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagBlackColorBarButton)},
                       @{@"htmlProperty":@"textColor:a0a0a0", @"imageName":@"article_gray_normal",    @"selectImageName":@"article_gray_select",   @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagGrayColorBarButton)},
                       @{@"htmlProperty":@"textColor:ff4a2d", @"imageName":@"article_red_normal",     @"selectImageName":@"article_red_select",    @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagRedColorBarButton)},
                       @{@"htmlProperty":@"textColor:fdaa25", @"imageName":@"article_yellow_normal",  @"selectImageName":@"article_yellow_select", @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagYellowColorBarButton)},
                       @{@"htmlProperty":@"textColor:44c67b", @"imageName":@"article_green_normal",   @"selectImageName":@"article_green_select",  @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagGreenColorBarButton)},
                       @{@"htmlProperty":@"textColor:14b2e0", @"imageName":@"article_blue_normal",    @"selectImageName":@"article_blue_select",   @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagBlueColorBarButton)},
                       @{@"htmlProperty":@"textColor:b064e2", @"imageName":@"article_purple_normal",  @"selectImageName":@"article_purple_select", @"selector":@"setTextColor:",    @"type":@(ZMEditorViewElementTagPurpleColorBarButton)}
                       ];
    for(NSDictionary *dict in array) {
        ZMEditorToolbarButton *button = [self createToolBarButton:dict padding:12];
        [self.colorArray addObject:button];
    }
}
- (ZMEditorToolbarButton *)createToolBarButton:(NSDictionary *)dict padding:(CGFloat)padding {
    
    UIImage *image = [UIImage imageNamed:dict[@"imageName"]];
    
    ZMEditorToolbarButton *button = [[ZMEditorToolbarButton alloc]initWithFrame:CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds))];
    button.elementTag = (ZMEditorViewElementTag)[dict[@"type"] integerValue];
    button.htmlProperty = dict[@"htmlProperty"];
    [button setImage:image forState:UIControlStateNormal];
    
    if(dict[@"selectImageName"]){
        [button setImage:[UIImage imageNamed:dict[@"selectImageName"]] forState:UIControlStateSelected];
    }
    button.zm_width = image.size.width + padding;
    if(dict[@"selector"]){
        SEL selector = NSSelectorFromString(dict[@"selector"]);
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

-(void) setToolBarWithButtons:(NSMutableArray *)array {
    CGFloat startX = 0;
    for(ZMEditorToolbarButton *button in array){
        button.frame = CGRectMake(startX, 0, button.zm_width, CGRectGetHeight(self.bounds));
        startX += button.zm_width;
        [self.toolbarView addSubview:button];
    }
}

-(void) setTopBarWithButtons:(NSMutableArray *)array margin:(CGFloat)margin {
    [self.topbarView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat startX = margin;
    for(ZMEditorToolbarButton *button in array){
        button.frame = CGRectMake(startX, 0, button.zm_width, CGRectGetHeight(self.bounds));
        startX += button.zm_width;
        [self.topbarView addSubview:button];
    }
    startX += margin;
    self.topbarView.frame = CGRectMake(20, 0, startX, CGRectGetHeight(self.bounds));
}

- (void)clearTopBarView {
    self.topElementTag = ZMEditorViewElementTagNone;
    [self setTopBarWithButtons:@[] margin:0];
    self.topbarView.layer.transform = CATransform3DIdentity;
    self.topbarView.hidden = YES;
    self.topSignView.hidden = YES;
}

#pragma mark - 控件点击显示
- (void)setFontBar:(ZMEditorToolbarButton *)barButtonItem {
    
    if(barButtonItem.elementTag == self.topElementTag){
        [self clearTopBarView];
        return;
    }
    
    self.topElementTag = barButtonItem.elementTag;
    [self setTopBarWithButtons:self.fontArray margin:9.5];
    [self showTopBarView:barButtonItem];
}

- (void)setJustifyBar:(ZMEditorToolbarButton *)barButtonItem {
    if(barButtonItem.elementTag == self.topElementTag){
        [self clearTopBarView];
        return;
    }
    
    self.topElementTag = barButtonItem.elementTag;
    [self setTopBarWithButtons:self.justifyArray margin:4];
    [self showTopBarView:barButtonItem];
}

- (void)setColorBar:(ZMEditorToolbarButton *)barButtonItem {
    if(barButtonItem.elementTag == self.topElementTag){
        [self clearTopBarView];
        return;
    }
    
    self.topElementTag = barButtonItem.elementTag;
    [self setTopBarWithButtons:self.colorArray margin:8];
    [self showTopBarView:barButtonItem];
}

- (void)showTopBarView:(ZMEditorToolbarButton *)barButtonItem {
    
    CGPoint point = barButtonItem.center;
    CGFloat width = self.topbarView.zm_width;

    if(width/2 + 20 > point.x){
        point.x = width/2 + 20;
    }
    
    if(point.x + width/2 + 20 > CGRectGetWidth(self.bounds)){
        point.x = CGRectGetWidth(self.bounds) - 20 - width/2;
    }
    
    self.topbarView.center = point;
    self.topbarView.hidden = NO;
    self.topbarView.layer.transform = CATransform3DMakeTranslation(0, -43.5, 0);
    
    self.topSignView.center = CGPointMake(barButtonItem.center.x,4);
    self.topSignView.hidden = NO;
}



#pragma mark - Required Delegate Calls

- (void)insertImage:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self insertImage:barButtonItem];
}

- (void)setBold:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setBold:barButtonItem];
}

- (void)setItalic:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setItalic:barButtonItem];
}

- (void)setBlockquote:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setBlockquote:barButtonItem];
}

- (void)setUnorderedList:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setUnorderedList:barButtonItem];
}

- (void)setOrderedList:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setOrderedList:barButtonItem];
}

- (void)insertLink:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self insertLink:barButtonItem];
}

- (void)setStrikeThrough:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setStrikeThrough:barButtonItem];
}

- (void)setH1:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setH1:barButtonItem];
}

- (void)setH2:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setH2:barButtonItem];
}

- (void)setH3:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setH3:barButtonItem];
}

- (void)setH4:(ZMEditorToolbarButton *)barButtonItem
{
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setH4:barButtonItem];
}

- (void)setJustifyLeft:(ZMEditorToolbarButton *)barButtonItem {
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setJustifyLeft:barButtonItem];
}

- (void)setJustifyCenter:(ZMEditorToolbarButton *)barButtonItem {
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setJustifyCenter:barButtonItem];
}

- (void)setJustifyRight:(ZMEditorToolbarButton *)barButtonItem {
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setJustifyRight:barButtonItem];
}

- (void)setTextColor:(ZMEditorToolbarButton *)barButtonItem {
    [self clearTopBarView];
    
    NSArray *array = [barButtonItem.htmlProperty componentsSeparatedByString:@":"];
    NSString *colorString = array.lastObject;
    UIColor *color =  [CommUntil colorWithHexString:colorString];
    [self.delegate editorToolbarView:self setTextColor:barButtonItem color:color];
}

- (void)setKeyBoard:(ZMEditorToolbarButton *)barButtonItem {
    [self clearTopBarView];
    [self.delegate editorToolbarView:self setKeyBoard:barButtonItem];
}


//暴漏方法处理
- (ZMEditorToolbarButton *)toolBarItemWithTag:(ZMEditorViewElementTag)tag {
    
    for(ZMEditorToolbarButton *button in self.toolBarArray){
        if(button.elementTag == tag){
            return button;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.fontArray){
        if(button.elementTag == tag){
            return button;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.justifyArray){
        if(button.elementTag == tag){
            return button;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.colorArray){
        if(button.elementTag == tag){
            return button;
        }
    }

    return nil;
}

- (void)toolBarItemWithTag:(ZMEditorViewElementTag)tag setVisible:(BOOL)visible {
    for(ZMEditorToolbarButton *button in self.toolBarArray){
        if(button.elementTag == tag){
            button.hidden = !visible;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.fontArray){
        if(button.elementTag == tag){
            button.hidden = !visible;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.justifyArray){
        if(button.elementTag == tag){
            button.hidden = !visible;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.colorArray){
        if(button.elementTag == tag){
            button.hidden = !visible;
            return;
        }
    }
}

- (void)toolBarItemWithTag:(ZMEditorViewElementTag)tag setSelected:(BOOL)selected {
    for(ZMEditorToolbarButton *button in self.toolBarArray){
        if(button.elementTag == tag){
            button.selected = selected;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.fontArray){
        if(button.elementTag == tag){
            button.selected = selected;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.justifyArray){
        if(button.elementTag == tag){
            button.selected = selected;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.colorArray){
        if(button.elementTag == tag){
            button.selected = selected;
            return;
        }
    }
}
- (void)toggleSelectionForToolBarItemWithTag:(ZMEditorViewElementTag)tag {
    for(ZMEditorToolbarButton *button in self.toolBarArray){
        if(button.elementTag == tag){
            button.selected = !button.selected;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.fontArray){
        if(button.elementTag == tag){
            button.selected = !button.selected;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.justifyArray){
        if(button.elementTag == tag){
            button.selected = !button.selected;
            return;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.colorArray){
        if(button.elementTag == tag){
            button.selected = !button.selected;
            return;
        }
    }
}
- (void)enableToolbarItems:(BOOL)enable shouldShowSourceButton:(BOOL)showSource {
    for (ZMEditorToolbarButton *button in self.toolBarArray) {
        if(button.elementTag == ZMEditorViewElementTagShowSourceBarButton){
            button.enabled = showSource;
            return;
        } else {
            button.enabled = enable;
        }
        
        if(!enable){
            button.selected = NO;
        }
    }
}

- (void)clearSelectedToolbarItems {
    for(ZMEditorToolbarButton *button in self.toolBarArray){
         button.selected = NO;
    }
    
    for(ZMEditorToolbarButton *button in self.fontArray){
         button.selected = NO;
    }
    
    for(ZMEditorToolbarButton *button in self.justifyArray){
         button.selected = NO;
    }
    
    for(ZMEditorToolbarButton *button in self.colorArray){
         button.selected = NO;
    }
}

- (void)selectToolbarItemsForStyles:(NSArray*)styles {
    
    for(ZMEditorToolbarButton *button in self.toolBarArray){
        if([styles containsObject:button.htmlProperty]) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.fontArray){
        if([styles containsObject:button.htmlProperty]) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.justifyArray){
        if([styles containsObject:button.htmlProperty]) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
    
    for(ZMEditorToolbarButton *button in self.colorArray){
        if([styles containsObject:button.htmlProperty]) {
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
}


- (UIImage *)topSignImage:(CGSize)size {
    CGFloat lineWidth = 1.0/ScreenScale * 2;
    
    UIImage *resultImage = nil;
    UIColor *backgroundColor = self.topbarView.backgroundColor;
    UIColor *borderColor = [UIColor colorWithCGColor:self.topbarView.layer.borderColor];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = lineWidth;
    [path moveToPoint:CGPointMake(0 , lineWidth)];
    [path addLineToPoint:CGPointMake(size.width/2 - 2, size.height - 2)];
    
    // 添加二次曲线
    [path addQuadCurveToPoint:CGPointMake(size.width/2 + 2, size.height - 2) controlPoint:CGPointMake(size.width/2, size.height)];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;

    [path addLineToPoint:CGPointMake(size.width, lineWidth)];
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    [path fill];
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    [path stroke];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}



@end
