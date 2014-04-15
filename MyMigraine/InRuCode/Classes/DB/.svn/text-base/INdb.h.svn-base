//!
//! @file INdb.h
//!
//! @author Alexander Babaev (alex.babaev@me.com)
//! @version 1.0
//! @date 2010
//! 
//! Copyright 2010 InRu
//! 
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//! 
//!     http://www.apache.org/licenses/LICENSE-2.0
//! 
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.
//!

#import <Foundation/Foundation.h>
#import <sqlite3.h>

/**
 @brief Result row. It helps to get specific values for columns by index or by column name.
 @todo: We can also store column types as well as column names for type-checking.
 */
@interface INSQLResultRow : NSObject {
	sqlite3_stmt *_statement; //!< Statement to get row information from.
	int _columnsCount; //!< Total number of columns (cached value for index checking)
	NSMutableArray *_columnNames; //!< Cache of column names, filled as needed 
}

/**
 @brief Returns Objective-C value, based on the SQLite type of the column. 
 
 Resulting types are defined by \c sqlite3_column_type
   - SQLITE_INTEGER -> NSNumber with int inside.
   - SQLITE_FLOAT -> NSNumber with double inside.
   - SQLITE_TEXT -> NSString
   - SQLITE_BLOB -> NSData
 */
- (id)autoValueForColumnIndexed:(int)aColumnIndex;


//! @brief Returns NSString for a column with index \c aColumnIndex.
- (NSString*)stringValueForColumnIndexed:(unsigned int)aColumnIndex;
//! @brief Returns NSString for a column with name \c aColumnName.
- (NSString*)stringValueForColumnNamed:(NSString*)aColumnName;

//! @brief Returns int for a column with index \c aColumnIndex.
- (int)intValueForColumnIndexed:(unsigned int)aColumnIndex;
//! @brief Returns int for a column with name \c aColumnName.
- (int)intValueForColumnNamed:(NSString*)aColumnName;

//! @brief Returns double for a column with index \c aColumnIndex.
- (double)doubleValueForColumnIndexed:(unsigned int)aColumnIndex;
//! @brief Returns double for a column with name \c aColumnName.
- (double)doubleValueForColumnNamed:(NSString*)aColumnName;

//! @brief Returns BOOL (converted from int) for a column with index \c aColumnIndex.
- (BOOL)boolValueForColumnIndexed:(unsigned int)aColumnIndex;
//! @brief Returns double for a column with name \c aColumnName.
- (BOOL)boolValueForColumnNamed:(NSString*)aColumnName;

//! @brief Returns NSData for a column with index \c aColumnIndex.
- (NSData*)blobValueForColumnIndexed:(unsigned int)aColumnIndex;
//! @brief Returns double for a column with name \c aColumnName.
- (NSData*)blobValueForColumnNamed:(NSString*)aColumnName;

@end

// -------------------------------------------------

/**
 @brief Parameter for SQL requests.
 */
@interface INSQLParameter : NSObject {
	//! @brief SQL types. 
	//!
	//! Supported types are: Integer, Double, Bool, String, BLOB
	//! @todo: add Date support
	enum {
		SQLTypeInteger,
		SQLTypeString,
		SQLTypeDate,
		SQLTypeDouble,
		SQLTypeBool,
		SQLTypeBLOB
	} _type;

@private	
	union {
		__int64_t _intValue; //!< intValue
		double _doubleValue; //!< doubleValue
		BOOL _boolValue; //!< boolValue
	} _value;
	
	char *_stringValue;
//	const void *_blobValue;
	
	unsigned int _stringAndBlobSize;
}

//! @brief get parameter with int value inside.
+ (id)intParameter:(__int64_t)aInt;
//! @brief get parameter with double inside.
+ (id)doubleParameter:(double)aDouble;
//! @brief get parameter with BOOL value inside.
+ (id)boolParameter:(BOOL)aBool;
//! @brief get parameter with NSString value inside.
+ (id)stringParameter:(NSString*)aString;
//! @brief get parameter with NSDate (in fact, double NSTimeInterval from 1970 is there) value inside.
+ (id)dateParameter:(NSDate*)aDate;

@end


// -------------------------------------------------

//! @defgroup Init Initialization
//! @defgroup SELECT SELECTs
//! @defgroup INSERT INSERTs/DELETEs/UPDATEs
//! @defgroup Transactions Transactions

/**
 @brief Class, that hides SQLite usage details.
 
 INdb is supported to be used in simple cases. No automatic ORM mapping here, only light SQLite frontend.
 */
@interface INdb : NSObject {
@private 
	sqlite3 *_dbConnection;
}

//! @ingroup Init
//! @brief Used for unit-testing, creates all DB files in subdirectory "test" of current directory.
+ (void)initTestingEnvironment;

//! @ingroup Init
//! Method tries to search for a DB file in Application bundle directory, if it's not found — then looks for it in Documents directory.
//! If no DB file was found, it is created in Documentation directory
- (id)initWithDBFileName:(NSString*)aDBFileName;

//! @ingroup Init
//! Method tries to search for a DB file in Application bundle directory, if it's not found — then looks for it in Documents directory.
//! If no DB file was found, it is created in Documentation directory
- (id)initWithDBFileName:(NSString*)aDBFileName inDirectory:(NSString*)aDirectory;

/**
 @ingroup SELECT
 @brief Executes an SQL query, calling delegate for every row.
 
 SQL can contain parameters, that are marked with "?". aParameters array must contain INSQLParameter objects.
 */
- (void)getRowsForSQL:(NSString*)aSQL andParameters:(NSArray*)aParameters target:(id)aLineCallbackTarget selector:(SEL)aSelector;

/**
 @ingroup SELECT
 @brief Executes an SQL query, returning result from first column of frst row.
 
 SQL can contain parameters, that are marked with "?". aParameters array must contain INSQLParameter objects.
 - (id)autoValueForColumnIndexed:(int)aColumnIndex; of INSQLResultRow is used to determine type and create return value.
 */
- (id)getSimpleResult:(NSString*)aSQL andParameters:(NSArray*)aParameters;

/**
 @ingroup INSERT
 @brief Executes an SQL query without result (not a SELECT one).
 */
- (void)executeSQL:(NSString*)aSQL withParameters:(NSArray*)aParameters;

/**
 @ingroup INSERT
 @brief Returns last succesfully created ROWID in SQLite.
 */
- (int64_t)lastInsertedId;

/**
 @ingroup Transactions
 @brief Starts transaction.
 */
- (void)beginTransaction;

/**
 @ingroup Transactions
 @brief Commits transaction.
 */
- (void)commitTransaction;

@end
