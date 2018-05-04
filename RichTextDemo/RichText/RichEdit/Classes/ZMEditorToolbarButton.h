//
//  ZMEditorToolbarButton.h
//  zhangmen
//
//  Created by zhao on 2017/9/29.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ZMEditorViewElementTagNone = -1,
    ZMEditorViewElementTagSpaceBarButton,
    ZMEditorViewElementTagImageBarButton,
    ZMEditorViewElementTagFontBarButton,
    ZMEditorViewElementTagLinkBarButton,
    ZMEditorViewElementTagJustifyBarButton,
    ZMEditorViewElementTagColorBarButton,
    ZMEditorViewElementTagKeyBoardBarButton,
    
    
    ZMEditorViewElementTagBoldBarButton,
    ZMEditorViewElementTagItalicBarButton,
    ZMEditorViewElementTagH1BarButton,
    ZMEditorViewElementTagH2BarButton,
    ZMEditorViewElementTagH3BarButton,
    ZMEditorViewElementTagH4BarButton,
    
    
    ZMEditorViewElementTagJustifyLeftBarButton,
    ZMEditorViewElementTagJustifyCenterBarButton,
    ZMEditorViewElementTagJustifyRightBarButton,
    
    ZMEditorViewElementTagBlackColorBarButton,
    ZMEditorViewElementTagGrayColorBarButton,
    ZMEditorViewElementTagRedColorBarButton,
    ZMEditorViewElementTagYellowColorBarButton,
    ZMEditorViewElementTagGreenColorBarButton,
    ZMEditorViewElementTagBlueColorBarButton,
    ZMEditorViewElementTagPurpleColorBarButton,
    
    
    ZMEditorViewElementTagBlockQuoteBarButton,
    ZMEditorViewElementTagOrderedListBarButton,
    ZMEditorViewElementTagShowSourceBarButton,
    ZMEditorViewElementTagStrikeThroughBarButton,
    ZMEditorViewElementTagUnorderedListBarButton,
    
} ZMEditorViewElementTag;


@interface ZMEditorToolbarButton : UIButton

@property (nonatomic, strong) NSString *htmlProperty;

@property (nonatomic, assign) ZMEditorViewElementTag elementTag;

@end
