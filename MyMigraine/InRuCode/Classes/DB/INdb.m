//!
//! @file INdb.m
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

#import "INdb.h"

#define DEBUG_INIT 0

static BOOL TESTING_ENVIRONMENT = NO;

//==================================================================================================================================
//==================================================================================================================================

@interface INSQLResultRow (Private)

- (id)initWithStatement:(sqlite3_stmt*)aStatement;
- (void)updateColumnNames;

@end

//==================================================================================================================================

@implementation INSQLResultRow (Private)

- (id)initWithStatement:(sqlite3_stmt*)aStatement {
	self = [super init];
	
	if (self) {
		_statement = aStatement;
		_columnsCount = -1;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)updateColumnNames {
	_columnsCount = sqlite3_column_count(_statement);
	
	if (_columnNames) {
		[_columnNames release];
	}
	_columnNames = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < _columnsCount; i++) {
		[_columnNames addObject:[NSString stringWithCString:sqlite3_column_name(_statement, i) encoding:NSUTF8StringEncoding]];
	}
}

- (void) dealloc {
	[_columnNames release];
	[super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INSQLResultRow

- (id)autoValueForColumnIndexed:(int)aColumnIndex {
	if (aColumnIndex < 0) {
		return nil;
	}

	NSInteger type = sqlite3_column_type(_statement, aColumnIndex);
	if (type == SQLITE_INTEGER) {
		return [NSNumber numberWithInt:[self intValueForColumnIndexed:aColumnIndex]];
	} else if (type == SQLITE_FLOAT) {
		return [NSNumber numberWithDouble:[self doubleValueForColumnIndexed:aColumnIndex]];
	} else if (type == SQLITE_TEXT) {
		return [self stringValueForColumnIndexed:aColumnIndex];
	} else if (type == SQLITE_BLOB) {
		return [self blobValueForColumnIndexed:aColumnIndex];
	} else {
		return nil;
	}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString*)stringValueForColumnIndexed:(unsigned int)aColumnIndex {
	if ((int)aColumnIndex < 0) {
		return nil;
	}
	
	const char *text = (const char *)sqlite3_column_text(_statement, (int) aColumnIndex);
	return text == NULL ? @"" : [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (int)intValueForColumnIndexed:(unsigned int)aColumnIndex {
	if ((int)aColumnIndex < 0) {
		return 0;
	}
	
	return sqlite3_column_int(_statement, (int) aColumnIndex);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (double)doubleValueForColumnIndexed:(unsigned int)aColumnIndex {
	if ((int)aColumnIndex < 0) {
		return 0;
	}
	
	return sqlite3_column_double(_statement, (int) aColumnIndex);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)boolValueForColumnIndexed:(unsigned int)aColumnIndex {
	if ((int)aColumnIndex < 0) {
		return NO;
	}
	
	return sqlite3_column_int(_statement, (int) aColumnIndex) ? YES : NO;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSData*)blobValueForColumnIndexed:(unsigned int)aColumnIndex {
	if ((int)aColumnIndex < 0) {
		return nil;
	}
	
	return [NSData dataWithBytes:sqlite3_column_blob(_statement, (int) aColumnIndex) length:sqlite3_column_bytes(_statement, (int) aColumnIndex)];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString*)stringValueForColumnNamed:(NSString*)aColumnName {
	if (_columnsCount == -1) {
		[self updateColumnNames];
	}
	
	return [self stringValueForColumnIndexed:[_columnNames indexOfObject:aColumnName]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (int)intValueForColumnNamed:(NSString*)aColumnName {
	if (_columnsCount == -1) {
		[self updateColumnNames];
	}
	
	return [self intValueForColumnIndexed:[_columnNames indexOfObject:aColumnName]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (double)doubleValueForColumnNamed:(NSString*)aColumnName {
	if (_columnsCount == -1) {
		[self updateColumnNames];
	}
	
	return [self doubleValueForColumnIndexed:[_columnNames indexOfObject:aColumnName]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)boolValueForColumnNamed:(NSString*)aColumnName {
	if (_columnsCount == -1) {
		[self updateColumnNames];
	}
	
	return [self boolValueForColumnIndexed:[_columnNames indexOfObject:aColumnName]];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSData*)blobValueForColumnNamed:(NSString*)aColumnName {
	if (_columnsCount == -1) {
		[self updateColumnNames];
	}
	
	return [self blobValueForColumnIndexed:[_columnNames indexOfObject:aColumnName]];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INSQLParameter (Private)

- (id)initWithIntParameter:(__int64_t)aInt;
- (id)initWithDoubleParameter:(double)aDouble;
- (id)initWithBoolParameter:(BOOL)aBool;
- (id)initWithStringParameter:(NSString*)aString;

- (void)setToStatement:(sqlite3_stmt*)aStatement forIndex:(int)aParameterIndex;

@end

//==================================================================================================================================

@implementation INSQLParameter (Private)

- (id)initWithIntParameter:(__int64_t)aInt {
	self = [super init];
	if (self) {
		_stringValue = NULL;
		_stringAndBlobSize = 0;
		_value._intValue = aInt;
		_type = SQLTypeInteger;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithDoubleParameter:(double)aDouble {
	self = [super init];
	if (self) {
		_stringValue = NULL;
		_stringAndBlobSize = 0;
		_value._doubleValue = aDouble;
		_type = SQLTypeDouble;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithBoolParameter:(BOOL)aBool {
	self = [super init];
	if (self) {
		_stringValue = NULL;
		_stringAndBlobSize = 0;
		_value._boolValue = aBool;
		_type = SQLTypeBool;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithStringParameter:(NSString*)aString {
	self = [super init];
	if (self) {
		_stringAndBlobSize = [aString lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
		_stringValue = malloc(_stringAndBlobSize);
		[aString getCString:_stringValue maxLength:_stringAndBlobSize encoding:NSUTF8StringEncoding];
		_type = SQLTypeString;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)setToStatement:(sqlite3_stmt*)aStatement forIndex:(int)aParameterIndex {
	int result = SQLITE_OK;
	
	if (_type == SQLTypeInteger) {
		result = sqlite3_bind_int64(aStatement, aParameterIndex, _value._intValue);
	} else if (_type == SQLTypeDouble) {
		result = sqlite3_bind_double(aStatement, aParameterIndex, _value._doubleValue);
	} else if (_type == SQLTypeBool) {
		result = sqlite3_bind_int(aStatement, aParameterIndex, _value._boolValue);
	} else if (_type == SQLTypeString) {
		result = sqlite3_bind_text(aStatement, aParameterIndex, _stringValue, (int) _stringAndBlobSize, SQLITE_STATIC);
	}
	
	if (result != SQLITE_OK) {
		NSLog(@"Error in binding parameter indexed %d: %d", aParameterIndex, result);
	}
}

@end

//==================================================================================================================================
//==================================================================================================================================

@implementation INSQLParameter

- (NSString*)description {
	switch (_type) {
		case SQLTypeInteger:
			return [NSString stringWithFormat:@"SQL Integer parameter: %d", _value._intValue];	
		case SQLTypeDouble:
			return [NSString stringWithFormat:@"SQL Double parameter: %f", _value._doubleValue];	
		case SQLTypeBool:
			return [NSString stringWithFormat:@"SQL BOOL parameter: %@", (_value._boolValue ? @"YES" : @"NO")];	
		case SQLTypeString:
			return [NSString stringWithFormat:@"SQL String parameter: %@", _stringValue];	
		case SQLTypeDate:
			return [NSString stringWithFormat:@"SQL Date parameter: %f", _value._doubleValue];	
		case SQLTypeBLOB:
			return [NSString stringWithFormat:@"SQL BLOB parameter"];	
		default:
			return [NSString stringWithFormat:@"Unknown type"];	
	}
}

+ (id)intParameter:(__int64_t)aInt {
	return [[[INSQLParameter alloc] initWithIntParameter:aInt] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)doubleParameter:(double)aDouble {
	return [[[INSQLParameter alloc] initWithDoubleParameter:aDouble] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)boolParameter:(BOOL)aBool {
	return [[[INSQLParameter alloc] initWithBoolParameter:aBool] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)stringParameter:(NSString*)aString {
	return [[[INSQLParameter alloc] initWithStringParameter:aString] autorelease];
}

//----------------------------------------------------------------------------------------------------------------------------------

+ (id)dateParameter:(NSDate*)aDate {
	return [[[INSQLParameter alloc] initWithDoubleParameter:[aDate timeIntervalSince1970]] autorelease];
}

- (void)dealloc {
	if (_stringValue != NULL) {
		free(_stringValue);
	}
	
	[super dealloc];
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface INdb (Private) 

- (sqlite3_stmt*)getStatementForSQL:(NSString*)aSQL;
- (void)applyParameters:(NSArray*)aParameters toStatement:(sqlite3_stmt*)aStatement;

@end

//==================================================================================================================================

@implementation INdb (Private)

- (sqlite3_stmt*)getStatementForSQL:(NSString*)aSQL {
	sqlite3_stmt *statement;
	int result = sqlite3_prepare_v2(_dbConnection, 
									[aSQL cStringUsingEncoding:NSUTF8StringEncoding], 
									(int) [aSQL lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
									&statement, 
									NULL);
	
	if (result != SQLITE_OK) {
		NSLog(@"Error in compiling statement %@: %d", aSQL, result);
		statement = NULL;
	}
	
	return statement;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)applyParameters:(NSArray*)aParameters toStatement:(sqlite3_stmt*)aStatement {
	if (aParameters == nil) {
		return;
	}
	
	int index = 1;
	for (INSQLParameter *parameter in aParameters) {
		[parameter setToStatement:aStatement forIndex:index];
		index++;
	}
}

@end

//==================================================================================================================================

@implementation INdb

+ (void)initTestingEnvironment {
	TESTING_ENVIRONMENT = YES;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithDBFileName:(NSString*)aDBFileName {
	NSString *path;
	if (TESTING_ENVIRONMENT) {
		NSLog(@"(Warning) Running in test environment, using ./test/ as DB path.");
		path = @"./test/";
	} else {
		path = [[NSBundle mainBundle] resourcePath];
		if (![[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:aDBFileName]]) {
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			path = [paths objectAtIndex:0];
		}
	}
	
	return [self initWithDBFileName:aDBFileName inDirectory:path];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)initWithDBFileName:(NSString*)aDBFileName inDirectory:(NSString*)aDirectory {
	self = [super init];
	
	if (self) {
		NSString *path = [aDirectory stringByAppendingPathComponent:aDBFileName];
		
		int openResult = sqlite3_open([path UTF8String], &_dbConnection);
		
		if (openResult == SQLITE_OK) {
#if DEBUG_INIT == 1
			NSLog(@"Database Successfully Opened");
#endif			
		} else {
			NSLog(@"Error in opening database: %d (path: %@)", openResult, path);
		}
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)getRowsForSQL:(NSString*)aSQL andParameters:(NSArray*)aParameters target:(id)aLineCallbackTarget selector:(SEL)aSelector {
	sqlite3_stmt *statement = [self getStatementForSQL:aSQL];
	if (statement == NULL) {
		return;
	}
	
//	sqlite3_reset(statement);
//	sqlite3_clear_bindings(statement);
	
	[self applyParameters:aParameters toStatement:statement];
	
	INSQLResultRow *resultRow = [[INSQLResultRow alloc] initWithStatement:statement];
	
	int rowIndex = 0;
	int stepResult = SQLITE_ROW;
	while ((stepResult = sqlite3_step(statement)) == SQLITE_ROW) {
		rowIndex++;
		[aLineCallbackTarget performSelector:aSelector withObject:resultRow];
	}
	
	if (stepResult != SQLITE_DONE) {
		NSLog(@"Error in executing statement (at row %d) %@: %d", rowIndex, aSQL, stepResult);
	}
	
	sqlite3_finalize(statement);

	[resultRow release];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (id)getSimpleResult:(NSString*)aSQL andParameters:(NSArray*)aParameters {
	sqlite3_stmt *statement = [self getStatementForSQL:aSQL];
	if (statement == NULL) {
		return nil;
	}
	
//	sqlite3_reset(statement);
//	sqlite3_clear_bindings(statement);

	[self applyParameters:aParameters toStatement:statement];

	INSQLResultRow *resultRow = [[INSQLResultRow alloc] initWithStatement:statement];
	
	id result = nil;
	
	if (sqlite3_step(statement) == SQLITE_ROW) {
		result = [resultRow autoValueForColumnIndexed:0];
	}
	
	sqlite3_finalize(statement);
	
	[resultRow release];

	return result;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)executeSQL:(NSString*)aSQL withParameters:(NSArray*)aParameters {
	sqlite3_stmt *statement = [self getStatementForSQL:aSQL];

//	sqlite3_reset(statement);
//	sqlite3_clear_bindings(statement);
	
	[self applyParameters:aParameters toStatement:statement];
	
	int result = sqlite3_step(statement);
	sqlite3_finalize(statement);

	if (result != SQLITE_DONE) {
		@throw [NSException exceptionWithName:@"SQL failed" 
									   reason:[NSString stringWithFormat:@"SQL execution failed (%d). SQL: %@\nParameters:\n%@", result, aSQL, aParameters] 
									 userInfo:nil];
	}
}

//----------------------------------------------------------------------------------------------------------------------------------

- (int64_t)lastInsertedId {
	return sqlite3_last_insert_rowid(_dbConnection);
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)beginTransaction {
	[self executeSQL:@"BEGIN TRANSACTION" withParameters:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)commitTransaction {
	[self executeSQL:@"COMMIT TRANSACTION" withParameters:nil];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
	sqlite3_close(_dbConnection);
	
	if (TESTING_ENVIRONMENT) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		NSDirectoryEnumerator *testFiles = [fileManager enumeratorAtPath:@"./test/"];
		
		NSString *file;
		BOOL isDir;
		while (file = [testFiles nextObject]) {
			NSString *fileName = [@"./test/" stringByAppendingPathComponent:file];
			[fileManager fileExistsAtPath:fileName isDirectory:&isDir];
			if (!isDir) {
				NSLog(@"Removing test file: %@", fileName);
				[fileManager removeItemAtPath:fileName error:NULL];
			}
		}
	}
	
	[super dealloc];
}

@end
