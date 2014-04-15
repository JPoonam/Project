

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "INCommonTypes.h"
#import "INLocalization.h"
#import "INGraphics.h"
#import "INObject.h"
#import "INView.h"
#import "INFormat.h"

// #define DEBUG_ALWAYS_SHOW_TERMS_OF_USE 
// #define DEBUG_ALWAYS_FIRST_TAB_SWITCHING 
// #define DEBUG_RECREATE_WITH_FAKE_RECORDS 
// #define DEBUG_FAKE_RECORD_COUNT               100 
// #define DEBUG_DB_LOG
// #define DEBUG_LOG
// #define DEBUG_BRIGHT_BACKGROUND
// #define DEBUG_MARK_CUSTOM_ITEMS         

// 
#define TEXT_NO_PRINTING            @"Sorry, your device does not support printing"

#define TEXT_NO_EMAIL               @"Sorry, mail is not available or not configured properly on this device"
#define TEXT_EMAIL_FAILED           @"Failed to send e-mail"
#define TEXT_SHARE_NOTHING_TO_PDF   @"There is no information to include into PDF document for given filter settings"  

// DIARY TAB
#define TEXT_NO_RECORDS             @"There are no migraine records in the diary"
#define TEXT_BAD_FILTER             @"No records found. Please change filter settings and try again."

// ----

//==================================================================================================================================
//==================================================================================================================================

#define PDF_HEADER                @"My Migraine Triggers"
#define PDF_FILENAME              @"My Migraine Triggers.pdf"
#define PDF_EMAIL_SUBJ            @"My Migraine Triggers Information"

#define CELL_TITLE_HAS_HA         @"Did you have a headache?"
#define CELL_TITLE_CHOOSE_DATE    @"New entry"
#define CELL_TITLE_EDIT_HIST      @"Edit a previous entry"

#define CELL_TITLE_LOCATION       @"Location of pain:"
#define CELL_TITLE_ADD_LOCATION   @"Add your own location"

#define CELL_TITLE_SHARE_CHOOSE_START_DATE     @"Choose a start date"
#define CELL_TITLE_SHARE                       @"Share with Your Doctor by Printing or Emailing Your Data" 

#define CELL_TITLE_SYMPTOM         @"Did you experience any of these symptoms?"
#define CELL_TITLE_ADD_SYMPTOM     @"Add your own symptom"

#define CELL_TITLE_WARNING         @"Did you experience any warning signs?"
#define CELL_TITLE_ADD_WARNING     @"Add your own warning sign"

#define CELL_TITLE_TREATMENT       @"Did you take any medication and/or try any other therapy?"
#define CELL_TITLE_ADD_TREATMENT   @"Add your own migraine treatment"

#define CELL_TITLE_RELIEF          @"Did you get relief from the medication and/or therapy?"
#define CELL_TITLE_ADD_RELIEF      @"Add your own relief description"

#define CELL_TITLE_FOOD            @"Did you consume any of the following?"
#define CELL_TITLE_ADD_FOOD        @"Add your own food item"

#define CELL_TITLE_LIFESTYLE       @"Did you experience any of the following?"
#define CELL_TITLE_ADD_LIFESTYLE   @"Add your own item"

#define CELL_TITLE_ENVIRONMENT     @"Were you exposed to any of the following?"
#define CELL_TITLE_ADD_ENVIRONMENT @"Add your own item"

#define CELL_TITLE_NOTES          @"Notes"
#define CELL_TITLE_NOTES_VIEW     @"View your own notes"
#define CELL_TITLE_NOTES_ADD      @"Add your own notes"

#define CELL_TITLE_DATE           @"The date on entry"

//==================================================================================================================================
//==================================================================================================================================

#define BH_SIMPLE_DATE                            @"BH_SIMPLE_DATE"
#define BH_LONG_DATE                              @"BH_LONG_DATE"
#define BH_DAY                                    @"BH_DAY"
#define BH_HOURS                                  @"BH_HOURS"
#define BH_SHORT_DATE                             @"BH_SHORT_DATE"
#define BH_MONTH                                  @"BH_MONTH"
#define BH_MONTH_YEAR                             @"BH_MONTH_YEAR"
#define BH_RECORD_SAVED_IN_CONTEXT_NOTIFICATION   @"BH_RECORD_SAVED_IN_CONTEXT_NOTIFICATION"
#define BH_SHARED_START_DATE_CHANGED_NOTIFICATION @"BH_SHARED_START_DATE_CHANGED_NOTIFICATION"
#define BH_SHARED_SETTINGCHANGED_NOTIFICATION     @"BH_SHARED_SETTINGCHANGED_NOTIFICATION"
#define BH_WIZARD_TOTAL_STEPS_HAS_HA              6
#define BH_WIZARD_TOTAL_STEPS_HAS_NO_HA           3
#define BH_MAX_DAYS_AGO                           60
#define BH_MIN_CHART_VALUE_ALLOWED                1.0  
#define BH_CHART_PIE_ITEMS_ALLOWED                10  

//==================================================================================================================================
//==================================================================================================================================

#define USERNAME                                   @"testfordmi@gmail.com"
#define PASSWORD                                   @"password#01"
#define SMTP                                       @"smtp.gmail.com"
#define  SENDMAILURL        @"https://www.novartis-otc.com/webservices/sendNonTemplateEmail?"
#define SERVERSTATUS @"https://www.novartis-otc.com/webservices/adminmonitoring/status.jsp"


/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)




@interface BHReusableObjects : NSObject {

} 

+ (UIFont *)blueLabelFont;
+ (UIFont *)redLabelFont;
+ (UIColor *)texturedColor;
+ (UIColor *)blueLabelColor;

@end
