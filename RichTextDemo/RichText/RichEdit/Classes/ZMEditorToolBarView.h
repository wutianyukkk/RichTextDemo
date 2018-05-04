//
//  ZMEditorToolBarView.h
//  zhangmen
//
//  Created by zhao on 2017/9/29.
//  Copyright © 2017年 该亚中国 • 开发团队. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZMEditorToolbarButton.h"
#import "CommentConst.h"
#import "CommUntil.h"
#import "UIView+ZM.h"

@class ZMEditorToolBarView;

@protocol ZMEditorToolbarViewDelegate <NSObject>
@required

/**
 *  @brief      Tell the delegate the insert image button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView*)editorToolbarView insertImage:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the bold button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView*)editorToolbarView setBold:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the italic button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setItalic:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the blockquote button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setBlockquote:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the unordered list button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setUnorderedList:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the ordered list button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setOrderedList:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the insert link button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView insertLink:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the strikethrough button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setStrikeThrough:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the H1 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH1:(ZMEditorToolbarButton *)barButtonItem;
/**
 *  @brief      Tell the delegate the H2 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH2:(ZMEditorToolbarButton *)barButtonItem;
/**
 *  @brief      Tell the delegate the H3 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH3:(ZMEditorToolbarButton *)barButtonItem;
/**
 *  @brief      Tell the delegate the H4 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setH4:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the H4 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setJustifyLeft:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the H4 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setJustifyCenter:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the H4 button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setJustifyRight:(ZMEditorToolbarButton *)barButtonItem;

/**
 *  @brief      Tell the delegate the textColor button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setTextColor:(ZMEditorToolbarButton *)barButtonItem color:(UIColor *)color;

/**
 *  @brief      Tell the delegate the KeyBoard button was pressed.
 *
 *  @param      editorToolbarView       The toolbar view calling this method.  Will never be nil.
 *  @param      barButtonItem           The pressed bar button item.  Will never be nil.
 */
- (void)editorToolbarView:(ZMEditorToolBarView *)editorToolbarView setKeyBoard:(ZMEditorToolbarButton *)barButtonItem;

@end



@interface ZMEditorToolBarView : UIView

#pragma mark - Properties: delegate

/**
 *  @brief      The toolbar delegate.
 */
@property (nonatomic, weak, readwrite) id<ZMEditorToolbarViewDelegate> delegate;

#pragma mark - Properties: colors

/**
 *    @brief        The border color for the toolbar.
 */
@property (nonatomic, copy, readwrite) UIColor* borderColor UI_APPEARANCE_SELECTOR;

/**
 *  Color to tint the toolbar items
 */
@property (nonatomic, strong) UIColor *itemTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Color to tint the toolbar items when the toolbar is disabled
 */
@property (nonatomic, strong) UIColor *disabledItemTintColor UI_APPEARANCE_SELECTOR;

/**
 *  Color to tint selected items
 */
@property (nonatomic, strong) UIColor *selectedItemTintColor UI_APPEARANCE_SELECTOR;


#pragma mark - Toolbar items

/**
 *  @brief      Returns a toolbar item (if any) matching the specified tag.
 *
 *  @param      tag     ZMEditorViewControllerElementTag of the item to return.
 *  @return     A toolbar item with the specified tag.
 */
- (UIBarButtonItem *)toolBarItemWithTag:(ZMEditorViewElementTag)tag;

/**
 *  @brief      Makes a toolbar item visible or hidden
 *
 *  @param      tag     ZMEditorViewControllerElementTag of the item to alter.
 *  @param      visible YES to make the item visible, NO to hide it.
 */
- (void)toolBarItemWithTag:(ZMEditorViewElementTag)tag setVisible:(BOOL)visible;

/**
 *  @brief      Selects or deselects a toolbar item
 *
 *  @param      tag      ZMEditorViewControllerElementTag of the item to alter.
 *  @param      selected YES to make the item selected, NO to deselect it.
 */
- (void)toolBarItemWithTag:(ZMEditorViewElementTag)tag setSelected:(BOOL)selected;

/**
 *  @brief      Toggles the on / off selection state for a toolbar item
 *
 *  @param      tag      ZMEditorViewControllerElementTag of the item to alter.
 */
- (void)toggleSelectionForToolBarItemWithTag:(ZMEditorViewElementTag)tag;

/**
 *  @brief      Enables and disables the toolbar items.
 *
 *  @param      enable       YES to enable the toolbar buttons; NO to disable them.
 *  @param      showSource   YES to enable the HTML mode button; NO to disable it.
 */
- (void)enableToolbarItems:(BOOL)enable shouldShowSourceButton:(BOOL)showSource;

/**
 *  @brief      Clears all selected toolbar items.
 */
- (void)clearSelectedToolbarItems;

- (void)selectToolbarItemsForStyles:(NSArray*)styles;

@end
