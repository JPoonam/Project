
#import "BHGlobals.h"
#import "BHCharts.h"
#import "BHUIComponents.h"
#import <QuartzCore/QuartzCore.h>

@interface BHChart_LegendBubbleView : UIView { 
    UILabel * _label; 
    CALayer * _bubbleLayer;
}

- (void)setValue:(double)value color:(UIColor *)color;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_PieLegendView : UIView { 
    IBOutlet BHChart_LegendBubbleView * _bubbleView; 
    IBOutlet UILabel * _legendLabel; 
}

- (void)setItem:(BHChartSeriesItem *)item;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_LegendPercentBarView : UIImageView { 
    UILabel * _label; 
    UIImageView * _valueImageView;
}

- (void)setValue:(double)value name:(NSString *)string;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_LegendBarView : UIView { 
    IBOutlet BHChart_LegendPercentBarView * _percentBarView; 
    IBOutlet UILabel * _percentLabel; 
}

- (void)setItem:(BHChartSeriesItem *)item;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_GraphPieView : UIView { 
    BHChartSeries * _series;
}

@property(nonatomic, retain) BHChartSeries * series;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_BasePageView : UIView { 
    BHChartSeries * _series;
    IBOutlet BHChart_GraphPieView *_pieView;
    IBOutlet UILabel * _titleLabel;
    IBOutlet UILabel * _line2Label;
    IBOutlet UILabel *_line2dateLabel;
    IBOutlet UILabel *_line1label;
    IBOutlet UIView *_separatorView;
    IBOutlet UILabel *_noDataLabel;
}

- (BOOL)setSeries:(BHChartSeries *)series startDate:(BHStartDate)startDate;

@end 

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_PageView : BHChart_BasePageView { 
    IBOutlet UITableView * _legendTable;
    UIImageView * _backgroundImageView;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_PiePageView : BHChart_PageView { 

}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_BarPageView : BHChart_PageView { 

}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_PDFPageView : BHChart_BasePageView { 
    IBOutlet UIView * _legendPad;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_PDFPageView_Pie : BHChart_PDFPageView { 

}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHChart_PDFPageView_Bar : BHChart_PDFPageView { 

}

@end

