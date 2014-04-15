
#import "BHGlobals.h"
#import "BHClasses.h"

@interface BHTexturedView : UIView {
    
}

+ (id)view;

@end

#define COMMON_CELL_HEIGHT 40

//==================================================================================================================================

#pragma mark -
#pragma mark Labels 

@interface BHRedLabel : UILabel { 

}

@end

//==================================================================================================================================

@interface BHBlueLabel : UILabel { 
    
}

@end

#pragma mark -
#pragma mark Buttons

@interface BHBlueButton : INButton {

}

@end

//==================================================================================================================================

@interface BHPainIntenseButton : BHBlueButton {
    // UIColor * _originalBackgroundColor;
    IBOutlet UILabel * _mainLabel;
    IBOutlet UILabel * _detailLabel;
    BHPainIntense _intense;
    UIView * _colorBand;
}

@property(nonatomic) BHPainIntense intense;

@end

//==================================================================================================================================

@interface BHGreenButton : UIButton { 
    
}

@end

//==================================================================================================================================

#pragma mark -
#pragma mark Views 

typedef enum { 
    BHControlFrameSquare,
    BHControlFrameRounded,
    BHControlFrameTopRounded,
    BHControlFrameBottomRounded,
    BHControlFrameStyleLast,
} BHControlFrameStyle;

@interface BHControlFrame : UIImageView { 
    BHControlFrameStyle _frameStyle; 
    BOOL _myHighlighted;
}

@property(nonatomic) BHControlFrameStyle frameStyle;

@end

//==================================================================================================================================

@interface BHDoubleStripView : UIImageView { 

}

@end

//==================================================================================================================================

#pragma mark -
#pragma mark Table Cells 

@interface BHTitleCell : UITableViewCell { 
    IBOutlet UILabel * _captionLabel;
}

@property (nonatomic, readonly) UILabel * captionLabel;

+ (CGFloat)heightForTitle:(NSString *)title condensed:(BOOL)condensed; 
+ (id)cellWithTitle:(NSString *)title tableView:(UITableView *)tableView condensed:(BOOL)condensed; 

@end

//==================================================================================================================================

@interface BHSeparatorCell : UITableViewCell { 

}

+ (id)cellWithDivider:(BOOL)divider tableView:(UITableView *)tableView;

@end

//==================================================================================================================================

@interface BHFramedCell : UITableViewCell { 
    BHControlFrame * _frameControl;
    BOOL _highlightEnabled;
    IBOutlet UILabel * _captionLabel;
}

@property (nonatomic,readonly) UILabel * captionLabel;
@property (nonatomic) BOOL highlightEnabled;
@property (nonatomic,readonly) BHControlFrame * frameControl;

- (void)setRow:(NSInteger)row ofTotal:(NSInteger)rowCount;

@end

//==================================================================================================================================

@interface BHHistoryCell : BHFramedCell { 
    IBOutlet UILabel * _timeCellLabel;
    IBOutlet UIView * _intencityIndicator;
}

@property (nonatomic,readonly) UILabel * timeCellLabel;
@property (nonatomic,readonly) UIView * intencityIndicator;

@end

//==================================================================================================================================

typedef enum { 
    BHItemButtonDelete,
    BHItemButtonCheckbox,
    BHItemButtonHelp,
    BHItemButtonLast
} BHItemButtonStyle;

@interface BHCellItemButton : INButton {
    BHItemButtonStyle _style;
}

@property (nonatomic) BHItemButtonStyle style;

@end

//==================================================================================================================================

@protocol BHButtonedCellDelegate 

- (void)bhcellWithTag:(NSInteger)cellTag didPressButton:(UIButton *)button forObject:(id)object;

@end

//==================================================================================================================================

@interface BHButtonedCell : BHFramedCell { 
    BHCellItemButton * _itemButton;
    BHCellItemButton * _itemRightButton;
    id<BHButtonedCellDelegate> _delegate;
    id object;
    NSInteger _cellTag;
}

@property (nonatomic,retain) IBOutlet BHCellItemButton * itemButton;
@property (nonatomic,retain) IBOutlet BHCellItemButton * itemRightButton;
@property (nonatomic,retain) id object;
@property (nonatomic) NSInteger cellTag;
@property (nonatomic,assign) id<BHButtonedCellDelegate> delegate;

- (IBAction)buttonPressed:(id)sender;
- (void)hideRightButton;
- (void)showRightButtonWithStyle:(BHItemButtonStyle)style;

@end 

#pragma mark -
#pragma mark Navigation bars 

@interface BHModalNavigationBar : INCustomNavigationBar { 

}

@end

#pragma mark -
#pragma mark View controllers 

@protocol BHViewControllerLookAndFeelInformalProtocol 

- (BOOL)bh_style_shouldHideHeader;
- (BOOL)bh_style_setupHeader;
- (BOOL)bh_style_shouldShowSideShadows;
- (void)bh_becomeActiveTab:(BOOL)firstTime;
- (void)bh_reselectActiveTab;

@end 

@interface UIViewController (BlippHeadache) 

+ (id)bh_tabPageControllerWithTitle:(NSString *)title imageName:(NSString *)imageName;

- (void)bh_setStandardCaptionForNavItem;
- (void)bh_setCaptionWithStep:(NSInteger)step ofTotal:(NSInteger)totalSteps;
- (void)bh_setStyleWithCoolBackground:(BOOL)doBackground topShadow:(BOOL)addTopShadow havingOwnNavBar:(BOOL)hasOwnNavbar; 
- (void)bh_setCaption:(NSString *)caption;
- (void)bh_setNavBarBackground;

@property(nonatomic) BOOL bh_tabFirstTimeOpened;

@end

#pragma mark -
#pragma mark Bar Button Items 

@interface BHBarButtonItem : UIBarButtonItem { 
    UIButton * _btn;
}

@end

//==================================================================================================================================

@interface BHBarButtonItem_Done : BHBarButtonItem { 

}

@end

//==================================================================================================================================

@interface BHBarButtonItem_Help : BHBarButtonItem { 
    
}

@end

//==================================================================================================================================

@interface BHBarButtonItem_Filter : BHBarButtonItem { 
    
}

@end

//==================================================================================================================================

@interface BHBarButtonItem_Cancel : BHBarButtonItem { 

}

@end

//==================================================================================================================================

@interface BHBarButtonItem_Action : UIBarButtonItem { 
    
}

@end


//==================================================================================================================================

@interface BHBarButtonItem_Back : BHBarButtonItem { 

}

@end

//==================================================================================================================================

@interface BHBarButtonItem_Next : BHBarButtonItem { 

}

@end

#pragma mark -
#pragma mark Table Views 

@interface BHTableView : UITableView {  
   UIView * _bottomTexture;

}
- (void)scrollToLastRowOfSection:(NSUInteger)section;
- (void)enableTexturedBackground;
- (void)enableExtraScrollingSpace;
- (void)enableExtraScrollingSpace2;

@end

