
#import "BHUIComponents.h"
#import "BHAppDelegate.h"
#import "BH.h"

@implementation BHTexturedView

+ (id)view {
    return [[[BHTexturedView alloc] initWithFrame:CGRectMake(0,0,10,10)] autorelease]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.backgroundColor = [BHReusableObjects texturedColor];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBlueButton 

- (void)updateState { 
    NSInteger state1 = (self.selected) ? UIControlStateNormal : UIControlStateHighlighted; 
    NSInteger state2 = (self.selected) ? UIControlStateHighlighted : UIControlStateNormal;
     
    [self setTitleColor:[UIColor whiteColor] forState:state1];
    [self setBackgroundImage:[[UIImage imageNamed:@"blue_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:state1];
    
    [self setTitleColor:[UIColor darkGrayColor] forState:state2];
    [self setBackgroundImage:[[UIImage imageNamed:@"cream_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:state2];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelected:(BOOL)value { 
    [super setSelected:value];
    [self updateState];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.adjustsImageWhenHighlighted = NO;
    [self updateState];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHPainIntenseButton 

@synthesize intense = _intense;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    // _originalBackgroundColor = [self.backgroundColor retain];
    // self.adjustsImageWhenHighlighted = NO;
    [super internalInit];
    self.backgroundColor = [UIColor whiteColor];
    CGRect r = self.bounds;
    _colorBand = [[UIView alloc] initWithFrame:INRectInset(r, 0, r.size.height - 8, 0, 0)];
    _colorBand.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_colorBand];
    [_colorBand release]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    // _caption1.textColor =     
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_mainLabel release];
    [_detailLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateLabels { 
    _mainLabel.textColor = self.currentTitleColor;
    _detailLabel.textColor = self.currentTitleColor;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateState { 
    [super updateState];
    [self updateLabels]; 
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHighlighted:(BOOL)highlighted { 
    [super setHighlighted:highlighted];
    [self updateLabels];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setIntense:(BHPainIntense)intense { 
    _intense = intense;
    _colorBand.backgroundColor = BHColorForPainIntense(intense);
}


/* 
 - (void)updateState { 
 NSInteger state1 = (self.selected) ? UIControlStateNormal : UIControlStateHighlighted; 
 NSInteger state2 = (self.selected) ? UIControlStateHighlighted : UIControlStateNormal;
 
 [self setBackgroundImage:[[UIImage imageNamed:@"blue_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:state1];
 [self setBackgroundImage:nil forState:state2];
 }
 
 //----------------------------------------------------------------------------------------------------------------------------------
 
 - (void)setSelected:(BOOL)value { 
 [super setSelected:value];
 [self updateState];
 }
 
 //----------------------------------------------------------------------------------------------------------------------------------
 
 - (void)internalInit { 
 _originalBackgroundColor = [self.backgroundColor retain];
 self.adjustsImageWhenHighlighted = NO;
 [self updateState];    
 }
 
 //----------------------------------------------------------------------------------------------------------------------------------
 
 - (id)initWithCoder:(NSCoder *)aDecoder {
 self = [super initWithCoder:aDecoder];
 if (self != nil) {
 [self internalInit];
 }
 return self;
 }
 
 //----------------------------------------------------------------------------------------------------------------------------------
 
 - (id)initWithFrame:(CGRect)frame {
 self = [super initWithFrame:frame];
 if (self != nil) {
 [self internalInit];
 }
 return self;
 }
 
 //----------------------------------------------------------------------------------------------------------------------------------
 
 - (void)dealloc {
 [_originalBackgroundColor release];
 [super dealloc];
 }
 
 */

@end

//==================================================================================================================================
//==================================================================================================================================
/* 
@implementation BHNavButton 

@synthesize bhbuttonType = _bhbuttonType;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit {
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.backgroundColor = [UIColor greenColor];

}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)bhbuttonWithType:(BHNavButtonType)buttonType { 
    BHNavButton * btn = [self buttonWithType:UIButtonTypeCustom];
    btn->_bhbuttonType = buttonType;
    switch (buttonType) {
        case BHNavButtonCancel:
            [btn setTitle:@"Cancel" forState:UIControlStateNormal];    
            break;

        case BHNavButtonDone:
            [btn setTitle:@"Done" forState:UIControlStateNormal];    
            break;

        case BHNavButtonNext:
            [btn setTitle:@"Next" forState:UIControlStateNormal];    
            break;

        case BHNavButtonBack:
            [btn setTitle:@"Back" forState:UIControlStateNormal];    
            break;
            
        default:
            NSAssert(0,@"mk_eaace2c2_8623_4145_8376_75cf0af999cd");
    } 
    return btn;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHNavigationBar 

@synthesize delegate = _delegate;

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)title {
    return _captionLabel.text;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setTitle:(NSString *)value { 
    _captionLabel.text = value;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setLeftButtonType:(BHNavButtonType)buttonType { 
    [_leftButton removeFromSuperview];
    _leftButton = [BHNavButton bhbuttonWithType:buttonType];
    _leftButton.frame = CGRectMake(8,7,72,31);
    [self addSubview:_leftButton];
    [_leftButton addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setRightButtonType:(BHNavButtonType)buttonType { 
    [_rightButton removeFromSuperview];
    _rightButton = [BHNavButton bhbuttonWithType:buttonType];
    _rightButton.frame = CGRectMake(240,7,72,31);
    [self addSubview:_rightButton];
    [_rightButton addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)btnPressed:(BHNavButton *)button { 
   NSAssert(!_delegate || [_delegate respondsToSelector:@selector(bhnavigationBar:didPressButton:)],@"mk_5ea107ea_4fe0_4cb7_bbaa_d49016b184c0");
    [_delegate bhnavigationBar:self didPressButton:button.bhbuttonType];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setStandardCaption { 
    self.title = @"MIGRAINE";
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.backgroundColor = [UIColor lightGrayColor];  
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds,81,0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.textAlignment = UITextAlignmentCenter;
    // label.numberOfLines = 0;
    // label.lineBreakMode = UILineBreakModeTailTruncation;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont italicSystemFontOfSize:14] ;
    label.textColor = [UIColor inru_colorFromRGBA:0x007F00FF];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    [self addSubview:label];
    [label release];
    _captionLabel = label;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {

    [super dealloc];
}

@end


*/
//==================================================================================================================================
//==================================================================================================================================

@implementation BHRedLabel

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.textColor = [UIColor inru_colorFromRGBA:0xc80000FF];
    self.font = [BHReusableObjects redLabelFont];
    // CGFloat f = [@"!" sizeWithFont:self.font].height;
    self.numberOfLines = 0;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {

    [super dealloc];
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBlueLabel

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.textColor = [BHReusableObjects blueLabelColor];
    self.font = [BHReusableObjects blueLabelFont];
    // CGFloat f = [@"!" sizeWithFont:self.font].height;
    self.numberOfLines = 0;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    
    [super dealloc];
}


@end


//==================================================================================================================================
//==================================================================================================================================

@implementation BHControlFrame

@synthesize frameStyle = _frameStyle;
@synthesize highlighted = _highlighted;

/* 
//----------------------------------------------------------------------------------------------------------------------------------

- (BHControlFrameStyle)frameStyle {
     return _frameControl.frameStyle;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrameStyle:(BHControlFrameStyle)value { 
    _frameControl.frameStyle = valuel
}
*/
//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateState {
    static struct { 
        NSString * imageName[2];    
        UIImage * image[2];
    } images[BHControlFrameStyleLast] = {
        {
           { @"table_square.png", @"table_squared_selected.png"}
        }, 
        {
           { @"table_rounded_full.png", @"table_rounded_full_selected.png"}
        }, 
        {
           { @"table_rounded_top.png", @"table_rounded_top_selected.png"}
        }, 
        {
           { @"table_rounded_bottom.png", @"table_rounded_bottom_selected.png"}
        }
    };
    
    if (!images[_frameStyle].image[NO]) { 
        images[_frameStyle].image[NO] = [[[UIImage imageNamed:images[_frameStyle].imageName[NO]]
                                                      stretchableImageWithLeftCapWidth:10 topCapHeight:5] retain];
        images[_frameStyle].image[YES] = [[[UIImage imageNamed:images[_frameStyle].imageName[YES]]
                                                      stretchableImageWithLeftCapWidth:10 topCapHeight:5] retain];
    }
    // NSLog(@"%@ %d",images[_frameStyle].imageName[self.highlighted], self.highlighted);
    self.image = images[_frameStyle].image[_myHighlighted];
    
    
    // self.highlightedImage = images[_frameStyle].image[YES];
    // self.backgroundColor = [UIColor redColor];
    // self.opaque = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setFrameStyle:(BHControlFrameStyle)newStyle {
    NSParameterAssert(newStyle < BHControlFrameStyleLast);   
    _frameStyle = newStyle;  
   [self updateState];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHighlighted:(BOOL)value { 
    [super setHighlighted:value];
    _myHighlighted = value;
    [self updateState];
} 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    //self.backgroundColor = [UIColor whiteColor];
    //self.layer.borderWidth = 1;
    //self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.frameStyle = BHControlFrameSquare;    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHCellItemButton

@synthesize style = _style;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.backgroundColor = [UIColor whiteColor]; //yellowColor] colorWithAlphaComponent:0.3];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {

    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setStyle:(BHItemButtonStyle)newStyle { 
    _style = newStyle;
    switch (_style) { 
        case BHItemButtonDelete:
            [self setImage:[UIImage imageNamed:@"delete_btn.png"] forState:UIControlStateNormal];
            [self setImage:nil forState:UIControlStateSelected];
            [self setImage:nil forState:UIControlStateHighlighted];
            break;     

        case BHItemButtonHelp:
            [self setImage:[UIImage imageNamed:@"question.png"] forState:UIControlStateNormal];
            [self setImage:nil forState:UIControlStateSelected];
            [self setImage:nil forState:UIControlStateHighlighted];
            break;     

        case BHItemButtonCheckbox:
            //[self setImage:[UIImage imageNamed:@"btn_checkbox.png"] forState:UIControlStateNormal];
            // [self setImage:[UIImage imageNamed:@"btn_checkbox_checked.png"] forState:UIControlStateSelected];
            if (self.selected) { 
                [self setImage:[UIImage imageNamed:@"btn_checkbox_checked.png"] forState:UIControlStateNormal];            
            } else { 
                [self setImage:[UIImage imageNamed:@"btn_checkbox.png"] forState:UIControlStateNormal];
            }
            break;     
        
        default:
            NSAssert(0,@"mk_aa23e95d_4421_47a2_ab64_d803d351507c");
    }  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setSelected:(BOOL)value { 
    [super setSelected:value];
    [self setStyle:_style];  
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHTitleCell

@synthesize captionLabel = _captionLabel;

- (void)awakeFromNib { 
    _captionLabel.backgroundColor = [BHReusableObjects texturedColor];
    _captionLabel.opaque = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_captionLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (CGFloat)heightForTitle:(NSString *)title condensed:(BOOL)condensed { 
     CGSize sz = [title sizeWithFont:[BHReusableObjects redLabelFont] constrainedToSize:CGSizeMake(320 - 15 * 2, 1000)];
     return condensed ? (6 + 2 + sz.height + 2) : (20 + 2 + sz.height + 10);
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)cellWithTitle:(NSString *)title tableView:(UITableView *)tableView  condensed:(BOOL)condensed  { 
    BOOL justLoaded;
    BHTitleCell * cell = nil;
    if (condensed) { 
        cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView 
                    nibFile:@"BHTitleCellCondensed" reuseIdentifier:@"condensedTitleCell" justLoaded:&justLoaded];
    } else { 
        cell = (id)[[INNibLoader sharedLoader] reusableCellForTable:tableView 
                                                            nibFile:@"BHTitleCell" reuseIdentifier:@"titleCell" justLoaded:&justLoaded];
    }
    cell->_captionLabel.text = title;
    return cell;
}

@end

//==================================================================================================================================

@implementation BHHistoryCell

@synthesize timeCellLabel = _timeCellLabel;
@synthesize intencityIndicator = _intencityIndicator;

- (void)dealloc {
    [_timeCellLabel release];
    [_intencityIndicator release];
    [super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHSeparatorCell
    
+ (id)cellWithDivider:(BOOL)divider tableView:(UITableView *)tableView { 
    NSString * reuseIdentifier = divider ?  @"divider1" : @"divider2";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[BHSeparatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        if (divider) { 
            CGRect r = CGRectInset(cell.contentView.bounds,15,0);
            r.origin.y = round(r.size.height / 2 - 1);
            r.size.height = 1;
            UIView * v = [[UIView alloc] initWithFrame:r];
            [cell.contentView addSubview:v];
            v.backgroundColor = [UIColor lightGrayColor];
            [v release];
            v.autoresizingMask  = UIViewAutoresizingFlexibleBottomMargin | 
                                  UIViewAutoresizingFlexibleTopMargin | 
                                  UIViewAutoresizingFlexibleLeftMargin | 
                                  UIViewAutoresizingFlexibleRightMargin;
            // cell.backgroundView = [[UIView alloc] initWithFrame:r];
            // cell.backgroundView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2];
        }
        cell.backgroundView = [BHTexturedView view];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHFramedCell 

@synthesize captionLabel = _captionLabel;
@synthesize highlightEnabled = _highlightEnabled;
@synthesize frameControl = _frameControl;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
         _highlightEnabled = YES;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib { 
    [super awakeFromNib];
    UIView * cv = self.contentView;
    
    _frameControl = [[BHControlFrame alloc] initWithFrame:INRectInset(self.bounds, 15,0, 15,0)];
    [cv insertSubview:_frameControl atIndex:0];
    [_frameControl release];
    _frameControl.autoresizingMask = INFlexibleWidthHeight;
    
    /* 
    
    CGRect r = INRectInset(self.bounds, 15,0, 15,-1);     
    CGRect r1 = r;
    r1.size.width = 1;
    UIView * left = [[BHLineView alloc] initWithFrame:r1];
    [cv addSubview:left];
    [left release];
    left.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;

    r1 = r;
    r1.size.width = 1;
    r1.origin.x += r.size.width-1;
    UIView * right = [[BHLineView alloc] initWithFrame:r1];
    [cv addSubview:right];
    [right release];
    right.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;

    r1 = r;
    r1.size.height = 1;
    UIView * top = [[BHLineView alloc] initWithFrame:r1];
    [cv addSubview:top];
    [top release];
    top.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;

    r1 = r;
    r1.size.height = 1;
    r1.origin.y += r.size.height-1;
    UIView * bottom = [[BHLineView alloc] initWithFrame:r1];
    [cv addSubview:bottom];
    [bottom release];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    */
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setRow:(NSInteger)row ofTotal:(NSInteger)rowCount { 
    CGRect r = self.bounds;
    if (row == rowCount-1) { 
        r = INRectInset(r, 15,0, 15, 0);
    } else {
        r = INRectInset(r, 15, 0, 15, -1); // -1);
    }
   _frameControl.frame = r;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)doHighlightingForChildrenOfView:(UIView *)v  highlight:(BOOL)highlight { 
    for (UIView * v1 in v.subviews) { 
        if ([v1 respondsToSelector:@selector(setHighlighted:)]) { 
            [(id)v1 setHighlighted:highlight];
        }
        [self doHighlightingForChildrenOfView:v1 highlight:highlight];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated { 
    [super setHighlighted:highlighted animated:animated];
    if (_highlightEnabled) { 
        [self doHighlightingForChildrenOfView:self.contentView highlight:highlighted];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_captionLabel release];
    [super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHButtonedCell

@synthesize itemButton = _itemButton;
@synthesize delegate = _delegate;
@synthesize object = _object;
@synthesize cellTag = _cellTag;
@synthesize itemRightButton = _itemRightButton;

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
         self.highlightEnabled = NO;
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_itemButton release];
    [_object release];
    [_itemRightButton release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (IBAction)buttonPressed:(id)sender {
    if (sender == _itemRightButton && _itemRightButton.style == BHItemButtonHelp && 
        [_object isKindOfClass:BHCollectionItem.class]) 
    { 
        [g_BH showHelpTopic:((BHCollectionItem *)_object).tag.intValue];    
    } else { 
        [_delegate bhcellWithTag:_cellTag didPressButton:sender forObject:_object];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)hideRightButton { 
    CGRect r1 = _captionLabel.frame;   
    CGRect r2 = self.bounds;
    _itemRightButton.hidden = YES;
    r1.size.width = CGRectGetMaxX(r2) - r1.origin.x - 15 - 8;
    _captionLabel.frame = r1;
    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)showRightButtonWithStyle:(BHItemButtonStyle)style { 
    CGRect r1 = _captionLabel.frame;   
    CGRect r2 = self.bounds;
    CGRect r3 = _itemRightButton.frame;
    r1.size.width = CGRectGetMaxX(r2) - r1.origin.x - 15 - 8 - r3.size.width;
    CGFloat w = [_captionLabel.text sizeWithFont:_captionLabel.font].width;
    r1.size.width = MIN(w,r1.size.width);
    _captionLabel.frame = r1;
    // _captionLabel.backgroundColor = [UIColor redColor];
    r3.origin.x = CGRectGetMaxX(r1) + 4;
    _itemRightButton.hidden = NO;
    _itemRightButton.style = style;
    _itemRightButton.frame = r3;
} 

@end 

//==================================================================================================================================
//==================================================================================================================================

@implementation BHModalNavigationBar


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        
        //DMI ios7 Change
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            self.backgroundStyle = INNavigationBarBGStyleImage;
            self.backgroundImage = [UIImage imageNamed:@"nav_bar_bg.png"]; //    @"modal_nav_bar_bg.png"];
        }
    }
    return self;
}


@end


//==================================================================================================================================
//==================================================================================================================================

/* 
@implementation RTBackNavButton

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit {
    [super internalInit]; 
    if (!self.titleLabel.text.length) { 
        [self setTitle:InruLoc(@"BTN_BACK") forState:UIControlStateNormal];
    }
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [self setBackgroundImage:[[UIImage imageNamed:@"navbar_back_btn.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]  forState:UIControlStateNormal];
}


@end 
*/

//==================================================================================================================================
//==================================================================================================================================

@implementation BHGreenButton

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.titleLabel.shadowOffset = CGSizeMake(0,-1);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self setBackgroundImage:[[UIImage imageNamed:@"bar_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] 
                               forState:UIControlStateNormal];
    self.reversesTitleShadowWhenHighlighted = YES;
    self.adjustsImageWhenDisabled = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem 

- (UIImage *)backgroundImage { 
    return [[UIImage imageNamed:@"bar_button.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minWidth { 
   return 60;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setTitleEx:(NSString *)value { 
    UIButton * btn = _btn;
    
    [btn setTitle:value forState:UIControlStateNormal];
    CGFloat width = MAX(self.minWidth, [value sizeWithFont:btn.titleLabel.font].width + 2 * 8);
    self.customView.frame = CGRectMake(0, 0, width, 31);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.shadowOffset = CGSizeMake(0,-1);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self setTitleEx:self.title];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [btn setBackgroundImage:self.backgroundImage  forState:UIControlStateNormal];
    btn.reversesTitleShadowWhenHighlighted = YES;
    btn.adjustsImageWhenDisabled = YES;
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIView * v = [[[UIView alloc] initWithFrame:CGRectMake(0,0,30,31)] autorelease];
    [v addSubview:btn];
    btn.frame = CGRectMake(0,2,30,30);
    btn.autoresizingMask = INFlexibleWidthHeight;
    _btn = btn;
    self.customView = v;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)btnPressed:(id)sender { 
    [self.target performSelector:self.action withObject:self];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setEnabled:(BOOL)enabled { 
    [super setEnabled:enabled];
    _btn.enabled = enabled;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Done

- (void)internalInit { 
    [super internalInit];
    [self setTitleEx:@"Done"];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Filter

- (void)internalInit { 
    [super internalInit];
    [self setTitleEx:@"Filter"];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Help

- (void)internalInit { 
    [super internalInit];
    [self setTitleEx:@"Help"];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Cancel

- (void)internalInit { 
    [super internalInit];
    [self setTitleEx:@"Cancel"];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Action


- (void)internalInit { 
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIView * v = [[[UIView alloc] initWithFrame:CGRectMake(0,0,50,31)] autorelease];
    [v addSubview:btn];
    btn.frame = CGRectMake(0,2,50,30);
    btn.autoresizingMask = INFlexibleWidthHeight;
    self.customView = v;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)btnPressed:(id)sender { 
    [self.target performSelector:self.action withObject:self];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Back

- (void)internalInit { 
    [super internalInit];
    [self setTitleEx:@"Back"];
    _btn.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)backgroundImage { 
    return [UIImage imageNamed:@"back_button.png"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minWidth { 
   return 50;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHBarButtonItem_Next

- (void)internalInit { 
    [super internalInit];
    [self setTitleEx:@"Next"];
    _btn.contentEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIImage *)backgroundImage { 
    return [UIImage imageNamed:@"next_button.png"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minWidth { 
   return 50;
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation UIViewController (BlippHeadache) 

+ (id)bh_tabPageControllerWithTitle:(NSString *)title imageName:(NSString *)imageName { 
    UIViewController * result = [self new];
    UINavigationController * navController = [[[UINavigationController alloc] initWithRootViewController:result] autorelease];
    [result bh_setNavBarBackground];
    navController.delegate = g_AppDelegate;
    [result release];
    result.title = title;
    result.tabBarItem.image = [UIImage imageNamed:imageName];
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_setNavBarBackground {
    
    //DMI ios7 Change
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self.navigationController inru_setNavBarBackgroundImage:[UIImage imageNamed:@"nav_bar_bg.png"]];
    }

    
    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_setStandardCaptionForNavItem {
    UIImageView * iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bar_title.png"]]autorelease];
    iv.contentMode = UIViewContentModeCenter; 
    self.navigationItem.titleView = iv;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_setCaptionWithStep:(NSInteger)step ofTotal:(NSInteger)totalSteps {
    [self bh_setCaption:[NSString stringWithFormat:@"Step %d of %d", step, totalSteps]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_setCaption:(NSString *)caption { 
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,180,44)];
    // label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor blackColor];
    //label.shadowColor = [UIColor blackColor];
    //label.shadowOffset = CGSizeMake(0, 1);
    //[self addSubview:label];
    label.text = caption;
    self.navigationItem.titleView = label;
    [label release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)bh_setStyleWithCoolBackground:(BOOL)doBackground topShadow:(BOOL)addTopShadow havingOwnNavBar:(BOOL)hasOwnNavbar { 
    // top shadow 
    if (addTopShadow) { 
        UIImageView * iv = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_shadow.png"]]autorelease];
        iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;        
        
        CGRect r = self.view.bounds;
        r.size.height = iv.bounds.size.height;
        if (hasOwnNavbar) { 
            r.origin.y = INNavBarHeight;
        }
        iv.frame = r;
        [self.view addSubview:iv];
    }
    
    if (doBackground) { 
        BHTableView * tv = (id)[self.view inru_viewWithClass:BHTableView.class];
        if (tv) { 
            [tv enableTexturedBackground];
        } else {
            self.view.backgroundColor = BHReusableObjects.texturedColor;
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)bh_tabFirstTimeOpened {
    #ifdef DEBUG_ALWAYS_FIRST_TAB_SWITCHING
         return YES;
    #endif 
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    UIViewController * rootVC = [self.navigationController.viewControllers objectAtIndex:0];
    NSString * vcClass = NSStringFromClass([rootVC class]);
    return ![[[defaults dictionaryForKey:@"AlreadyOpenedTabs"] objectForKey:vcClass] boolValue];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setBh_tabFirstTimeOpened:(BOOL)bh_tabFirstTimeOpened { 
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"AlreadyOpenedTabs"]];
    UIViewController * rootVC = [self.navigationController.viewControllers objectAtIndex:0];
    NSString * vcClass = NSStringFromClass([rootVC class]);
    [dict setObject:[NSNumber numberWithBool:!bh_tabFirstTimeOpened] forKey:vcClass];
    [defaults setObject:dict forKey:@"AlreadyOpenedTabs"]; 
}
    
@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHDoubleStripView 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.image = [UIImage imageNamed:@"red_line.png"];
    self.backgroundColor = [UIColor clearColor];    
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self internalInit];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {

    [super dealloc];
}

@end

//==================================================================================================================================
//                                                   TABLE VIEWS
//==================================================================================================================================

@implementation BHTableView

- (void)scrollToLastRowOfSection:(NSUInteger)section {
    NSUInteger sectionCount = [self.dataSource numberOfSectionsInTableView:self];
    if (section < sectionCount) { 
        NSUInteger rowCount = [self.dataSource tableView:self numberOfRowsInSection:section];
        if (rowCount) { 
             [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowCount-1 inSection:section] 
                 atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGRect)bottomTextureFrame { 
    CGRect r = self.frame;
    if (self.contentSize.height >= r.size.height) { 
        return CGRectMake(0,self.contentSize.height,320,200);  
    } else { 
        return CGRectMake(0,self.contentSize.height,320,200 + r.size.height - self.contentSize.height);  
    }
}
        
//----------------------------------------------------------------------------------------------------------------------------------

- (void)enableTexturedBackground { 
    if (!_bottomTexture) { 
        UIView * v = [BHTexturedView view];
        v.frame = CGRectMake(0,-200,320,200);
        [self insertSubview:v atIndex:0]; 
        // v.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];

        v = [BHTexturedView view];
        v.frame = self.bottomTextureFrame;
        v.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self insertSubview:v atIndex:0]; 
        _bottomTexture = v;
        // v.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2];
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    _bottomTexture.frame = self.bottomTextureFrame;
}

//----------------------------------------------------------------------------------------------------------------------------------

#define BOTTOM_TABLE_EXTRA_SCROLL_SPACE  30

- (void)enableExtraScrollingSpace { 
    self.contentInset = UIEdgeInsetsMake(0, 0, BOTTOM_TABLE_EXTRA_SCROLL_SPACE, 0);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)enableExtraScrollingSpace2 { 
    self.contentInset = UIEdgeInsetsMake(8, 0, BOTTOM_TABLE_EXTRA_SCROLL_SPACE, 0);
}

@end

