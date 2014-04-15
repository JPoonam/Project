
#import "BHGlobals.h"
#import "BHClasses.h"
#import "BHShareViewController.h"

@interface BHMigrainEventScreenReportBandView : UIView {
    UILabel * _headerLabel;
    UILabel * _row0Label;
}


@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHMigrainEventScreenReportView : UIView { 
    BHMigrainEvent * _event;
    IBOutlet UILabel * _timeStampLabel;
    IBOutlet UIImageView * _verticalGradient;
    BHMigrainEventScreenReportBandView * _bands[BHReportFilterLast]; 
    UIView * _headacheBand;
    UILabel * _headacheHourLabel;
    UILabel * _headacheLastedLabel;
    UILabel * _headacheHour2Label;
} 

@property(nonatomic,retain) BHMigrainEvent * event;

+ (CGFloat)heightForEvent:(BHMigrainEvent *)event;

+ (BOOL)testForEvent:(BHMigrainEvent *)event;

@end

//==================================================================================================================================
//==================================================================================================================================

@interface BHReportGenerator : INObject {
    NSFetchedResultsController * _fetchedResults;
    NSInteger _pageNumber;
    BOOL _pageOpened;
    CGRect _pageRestSpace;
    UIColor * _grayColor;
    UIColor * _grayBorderColor;
    BHShareOptions _options;
}

- (NSData *)createReportWithOptions:(BHShareOptions)options;
+ (BOOL)canPrint;

@end




