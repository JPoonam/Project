

#import "BHChart_PageView.h"

@implementation BHChart_LegendBubbleView

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    _bubbleLayer = [CALayer layer];
    _bubbleLayer.frame = self.bounds; 
    _bubbleLayer.contents = (id)[UIImage imageNamed:@"legend_bubble.png"].CGImage;
    [self.layer addSublayer:_bubbleLayer];
    self.layer.cornerRadius = 9;
        
    UILabel * label = [[UILabel alloc] initWithFrame:self.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);
    [self addSubview:label];
    [label release];
    _label = label;      
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

- (void)setValue:(double)value color:(UIColor *)color { 
    _label.text = [NSString stringWithFormat:@"%.0f%%", value];
    self.backgroundColor = color;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_PieLegendView 

- (void)dealloc {
    [_bubbleView release];
    [_legendLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setItem:(BHChartSeriesItem *)item  { 
    [_bubbleView setValue:item.value color:item.color];
    _legendLabel.text = item.name;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_BasePageView

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
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
    [_series release];
    [_pieView release];
    [_titleLabel release];
    [_line2Label release];
    [_line2dateLabel release];
    [_line1label release];
    [_separatorView release];
    [_noDataLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)awakeFromNib { 
    _titleLabel.textColor = [BHReusableObjects blueLabelColor];
    _line2Label.textColor = [UIColor lightGrayColor];
    _line2dateLabel.textColor = [UIColor lightGrayColor];
    _line1label.textColor = [UIColor lightGrayColor];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)setSeries:(BHChartSeries *)series startDate:(BHStartDate)startDate {

    [_series autorelease];
    _series = [series retain];
    _pieView.series = series;
    _titleLabel.text = series.name;
    
    BOOL showChartControls = NO;
    BOOL showTitleControls = NO;
    NSString * noDataText = nil;
    
    if (series) { 
        switch (series.dataState) { 
            case BHChartSeriesHasDataState:
                showChartControls = YES;
                showTitleControls = YES;
                break;
                
            case BHChartSeriesHasNoDataState:
                noDataText = TEXT_NO_RECORDS;
                showTitleControls = YES;
                break;
                
            case BHChartSeriesHasNoFilteredDataState:
                noDataText = TEXT_BAD_FILTER;
                showTitleControls = YES;
                break;
                
            default:
                break;
        }
    }
    
    _line1label.hidden = !showTitleControls;
    _line2Label.hidden = !showTitleControls;
    _line2dateLabel.hidden = !showTitleControls;
    
    _separatorView.hidden = !showChartControls;
    _pieView.hidden = !showChartControls;
    
    if (noDataText) {
        _noDataLabel.text = noDataText;
        _noDataLabel.hidden = NO; 
    } else { 
        _noDataLabel.hidden = YES; 
    }
    
    if (showTitleControls) { 
        _line1label.text = series.line1text;
        NSString * line2text = [series.line2text stringByAppendingString:@" "];
        NSString * text = @"";
        switch (startDate.dateKind) {
            case BHStartDateAll:
                line2text = [series.line2text stringByAppendingString:@"."];
                break;
                
            case BHStartDateLast60:
                 text = @"within the past 60 days.";
                 break;

            case BHStartDateLast30:
                 text = @"within the past 30 days.";
                 break;

            case BHStartDateLast2Weeks:
                 text = @"within the past 2 weeks.";
                 break;

            case BHStartDateIndividualDate:
                 text = [NSString stringWithFormat:@"since %@.", [BHDateFromStartDate(startDate) inru_formatWithKey:BH_SHORT_DATE]];
                 break;
                 
            default:
                NSAssert(0, @"mk_ee04b605_28c8_463e_b152_a1fd377f612f");
        }
        _line2dateLabel.text = text;
        _line2Label.text = line2text;

        CGFloat line2width = [_line2Label.text sizeWithFont:_line2Label.font].width;
        CGFloat line2dateWidth = [_line2dateLabel.text sizeWithFont:_line2dateLabel.font].width;
        CGRect r = _line2Label.frame;
        if (_series.centeredText) { 
            r.origin.x = round((self.bounds.size.width - line2width - line2dateWidth) / 2);
        }
        r.size.width = line2width;
        _line2Label.frame = r;
        r.origin.x += r.size.width;
        r.size.width = line2dateWidth;
        _line2dateLabel.frame = r;
    }
    
    return showChartControls;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_PageView

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    [super internalInit];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.autoresizingMask = INFlexibleWidthHeight;
    [self insertSubview:_backgroundImageView atIndex:0];
    [_backgroundImageView release];
    _backgroundImageView.image = [[UIImage imageNamed:@"chart_bg.png"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_legendTable release];
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)setSeries:(BHChartSeries *)series startDate:(BHStartDate)startDate {
    BOOL result = [super setSeries:series startDate:startDate];
    [_legendTable reloadData];
    _legendTable.hidden =  !result;
    return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _series.chartItemCount;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(0, @"override it mk_5f0c1bc8_e7eb_48c8_ade1_b9aa1b96ce5d");
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // id item = [self itemAtPath:indexPath];
    // return item.height;
    return tableView.rowHeight;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_GraphPieView 

@synthesize series = _series;

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
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
    [_series release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------


- (void)setSeries:(BHChartSeries *)series {
    [_series autorelease];
    _series = [series retain];
    [self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)drawRect:(CGRect)rect { 
    CGRect r = self.bounds;
    CGPoint center = CGPointMake(round(r.size.width / 2), round(r.size.height / 2));
    CGFloat radius = round(MIN(r.size.height, r.size.width)/2) -1;
    BOOL drawRays = _series.chartItemCount > 1;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context,UIColor.whiteColor.CGColor);
    
    void (^DrawRay)(double) = ^(double angle) { 
        CGPoint points[2] = { 
             center,
             CGPointMake(radius * cos(angle) + center.x, center.y + radius * sin(angle))
        };
        CGContextStrokeLineSegments(context, points, 2);
    };
    
    {
        double angle = 0;
        int itemCount = _series.chartItemCount;
        for (int i = 0; i < itemCount; i++) { 
            BHChartSeriesItem * item = [_series chartItemAtIndex:i];
            double angle2 = MIN(angle + item.value * M_PI * 2 / 100.0, M_PI * 2);
            
            // NSLog(@"%d %f   %f", i, angle, angle2);
            
            CGContextSaveGState(context);
            {  
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, center.x, center.y);
                CGContextAddArc (context,
                                 center.x, center.y,
                                 radius,
                                 angle,
                                 angle2,
                                 0);
                CGContextClosePath(context);
                CGContextClip(context);
                CGContextSetFillColorWithColor(context,item.color.CGColor);
                CGContextFillRect(context, r);
            }
            CGContextRestoreGState(context);

            if (drawRays) {
                DrawRay(angle); 
            }
            
            if (angle2 >= M_PI * 2) { 
                break;
            }
            angle = angle2;
        }
        if (drawRays) {
            DrawRay(0); 
        }
    }    
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_PiePageView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        BHChart_PieLegendView * v = (id)[[INNibLoader sharedLoader] loadViewFromNib:@"BHChart_PieLegendView"];
        v.tag = 12345;
        [cell.contentView addSubview:v];
    }
    
   
    // assign data to cell controls
    BHChartSeriesItem * item = [_series chartItemAtIndex:indexPath.row];
    BHChart_PieLegendView * v = (id)[cell.contentView viewWithTag:12345];
    [v setItem:item];
    return cell;
}

@end


//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_LegendPercentBarView 

//----------------------------------------------------------------------------------------------------------------------------------

- (void)internalInit { 
    self.image = [[UIImage imageNamed:@"bar_chart_bg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];

    _valueImageView = [[UIImageView alloc] initWithImage:
         [[UIImage imageNamed:@"bar_chart_fg.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0]];
    [self addSubview:_valueImageView];
    [_valueImageView release];

     UILabel * label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds,8,0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    label.textAlignment = UITextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];     
  
  //  label.shadowColor = [UIColor blackColor];
  //  label.shadowOffset = CGSizeMake(0, -1);
    [self addSubview:label];
    [label release];
    _label = label;      
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

- (void)setValue:(double)value name:(NSString *)name { 
   _label.text = name;
   
   CGRect r = self.bounds;
   CGRect r2 = r;
   r2.size.width = MIN(MAX(27,value * r.size.width / 100.0),r.size.width); 
   _valueImageView.frame = r2;
}

@end


//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_LegendBarView

- (void)dealloc {
    [_percentBarView release];
    [_percentLabel release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setItem:(BHChartSeriesItem *)item  { 
    [_percentBarView setValue:item.value name:item.name];
    _percentLabel.text = [NSString stringWithFormat:@"%.0f%%",item.value];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_BarPageView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        BHChart_LegendBarView * v = (id)[[INNibLoader sharedLoader] loadViewFromNib:@"BHChart_LegendBarView"];
        v.tag = 12345;
        [cell.contentView addSubview:v];
    }
    
   
    // assign data to cell controls
    BHChartSeriesItem * item = [_series chartItemAtIndex:indexPath.row];
    BHChart_LegendBarView * v = (id)[cell.contentView viewWithTag:12345];
    [v setItem:item];
    return cell;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_PDFPageView 

- (void)awakeFromNib{ 
    [super awakeFromNib];
    _legendPad.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [_legendPad release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)legendView { 
    NSAssert(0, @"mk_4cee5916_a447_41b7_ae9c_445eb06fd355");
    return nil;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minLegendPadOriginY { 
    NSAssert(0, @"mk_ceb99c39_45cb_440a_b811_cf1d71c981e0");
    return 300;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minLegendPadHeight { 
    NSAssert(0, @"mk_5b17b87c_320a_40ee_aff9_e36d6b2b2276");
    return 100;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)setSeries:(BHChartSeries *)series startDate:(BHStartDate)startDate {
    BOOL result = [super setSeries:series startDate:startDate];
    _legendPad.hidden =  !result;
    
    if (result) { 
        NSAssert(series.hasItems, @"mk_65b09002_607c_4ed1_bc22_f57a4b3e9481");

        CGRect r = self.bounds;

        CGRect rLegend = self.legendView.bounds;
        int columnCount = 1;
        int itemsPerColumn = 0;
        
        CGFloat maxLegendPadHeight = r.size.height - self.minLegendPadOriginY - 10;
        int maxRowsPerColumn = maxLegendPadHeight / rLegend.size.height;
        int itemsCount = _series.chartItemCount;
        if (itemsCount > maxRowsPerColumn * 2) {
            series.limitedItemCount = maxRowsPerColumn * 2 - 1;
            itemsCount = _series.chartItemCount;
        }
        if (itemsCount <= maxRowsPerColumn) { 
            itemsPerColumn = itemsCount;
        } else { 
            itemsPerColumn = (itemsCount + 1) / 2;
            columnCount = 2;
        }
        CGRect _legendPadRect = r;
        _legendPadRect.size.height = MAX(self.minLegendPadHeight, itemsPerColumn * rLegend.size.height);
        _legendPadRect.origin.y = r.size.height - _legendPadRect.size.height;
        _legendPad.frame = _legendPadRect;
        
        [_legendPad inru_removeAllSubviews];
        int index = 0;
        for (int column = 0; column < columnCount; column++) {
             CGFloat bandWidth = _legendPadRect.size.width / columnCount;
             CGFloat x0 = column * bandWidth + round((bandWidth - rLegend.size.width)/2);
             for (int j = 0; j <  itemsPerColumn; j++) { 
                 if (index >= itemsCount) { 
                     break;
                 }
                 UIView * v = self.legendView;
                 [(id)v setItem:[_series chartItemAtIndex:index]];
                 CGRect r1 = v.frame;
                 r1.origin.x = x0;
                 r1.origin.y = j * rLegend.size.height;
                 [_legendPad addSubview:v];
                 v.frame = r1;
                 index++;
             } 
        }
        
        if (_pieView) { 
            CGRect rPie;
            rPie.origin.y = CGRectGetMaxY(_line2Label.frame) + 20;
            rPie.size.height = _legendPad.frame.origin.y - 20 - rPie.origin.y;
            rPie.size.width = r.size.width;
            rPie.origin.x =  0;
            _pieView.frame = rPie; 
        }
    }
    
    return result;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_PDFPageView_Pie

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)legendView { 
     return [[INNibLoader sharedLoader] loadViewFromNib:@"BHChart_PieLegendView"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minLegendPadOriginY { 
    return 300;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minLegendPadHeight { 
    return 100;
}


@end

//==================================================================================================================================
//==================================================================================================================================

@implementation BHChart_PDFPageView_Bar

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)legendView { 
     return [[INNibLoader sharedLoader] loadViewFromNib:@"BHChart_LegendBarView"];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minLegendPadOriginY { 
    return 100;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (CGFloat)minLegendPadHeight { 
    return 480;
}

@end
