//
//  InruCodeAppDelegate.m
//  InruCode
//
//  Created by Alexander Babaev on 3/15/10.
//  Copyright Igrolain 2010. All rights reserved.
//

#import "InruCodeAppDelegate.h"
#import "INCommonTypes.h"


// main root view controller. Intended for IPad mostly (supports interface rotation).

@interface RotableViewController : UIViewController { 

}

@end

//==================================================================================================================================

@implementation RotableViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end

//==================================================================================================================================
//==================================================================================================================================

@interface CatalogObject : NSObject {
@package
   NSString * _name;
   NSString * _viewName;
   NSArray * _items;
}

@end

//==================================================================================================================================

@implementation CatalogObject

+ (id)objWithName:(NSString *)name viewName:(NSString *)viewName items:(NSArray *)items { 
    CatalogObject * obj = [[CatalogObject new] autorelease];
    obj->_name = [name retain];
    obj->_viewName = [viewName retain];
    obj->_items = [items retain];
    
    return obj;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSArray *)items { 
    return _items;  
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)name { 
    return _name;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)viewName { 
    return _viewName;
}


//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [_name release];
    [_viewName release];
    [_items release];
    [super dealloc];
}

@end




//==================================================================================================================================
//==================================================================================================================================

@implementation InruCodeAppDelegate

@synthesize window;

- (void)selectItem:(CatalogObject *)obj { 
    assert(obj.name);
    assert(obj.viewName);
    UINavigationBar * bar = (id)[_detailPageController.view viewWithTag:92374623];
    bar.topItem.title = obj.name; 
    
    if (_detailContentController) { 
       [_detailContentController.view removeFromSuperview];
       [_detailContentController release];
    }
    
    Class c = NSClassFromString(obj.viewName);
    NSAssert1(c != nil, @"Class %@ is not defined", obj.viewName);

    _detailContentController = [c new];
    NSAssert1([_detailContentController isKindOfClass:UIViewController.class], @"Class %@ is not UIViewController descendant!", obj.viewName);

    CGRect r = INRectInset(_detailPageController.view.bounds,0,44,0,0);
    _detailContentController.view.frame = r;
    [_detailPageController.view addSubview:_detailContentController.view];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    CatalogObject * startObject = nil;
    
    _catalogItems = [[NSArray arrayWithObjects: 
         // ui
         [CatalogObject objWithName:@"UI" viewName:nil items:[NSArray arrayWithObjects: 
             [CatalogObject objWithName:@"INLabel" viewName:@"INLabelTestViewController" items:nil],               
             [CatalogObject objWithName:@"INCalendarView" viewName:@"INCalendarViewTestViewController" items:nil],               
             startObject = [CatalogObject objWithName:@"INCountPicker" viewName:@"INCountPickerTestViewController" items:nil],               
             nil]],
         
         // ORM
         [CatalogObject objWithName:@"ORM" viewName:nil items:[NSArray arrayWithObjects: 
                        
            nil]],
    
         nil] retain];

    _splitController = [UISplitViewController new];
   
    _categoryController = [[RotableViewController new] autorelease]; //
    UITableViewController * tv = [[[UITableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease]; 
    tv.view.frame = _categoryController.view.bounds;
    tv.tableView.delegate = self;
    tv.tableView.dataSource = self;
    [_categoryController.view addSubview:tv.view];
    
    _detailPageController = [[RotableViewController new] autorelease];
    _detailPageController.view.backgroundColor = [UIColor whiteColor];
    UINavigationBar * navBar = [[UINavigationBar new] autorelease];
    CGRect r = _detailPageController.view.bounds; 
    r.size.height = 44;
    navBar.tag = 92374623;
    [navBar pushNavigationItem:[[UINavigationItem new] autorelease] animated:NO]; 
    navBar.frame = r;
    [_detailPageController.view addSubview:navBar];
          
    _splitController.viewControllers = [NSArray arrayWithObjects:_categoryController,_detailPageController,nil];
     [window addSubview:_splitController.view];
	
    [window makeKeyAndVisible];
    
    if (startObject) { 
        [self selectItem:startObject];
    }

	return YES;
}



//----------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
    [window release];
    [_catalogItems release];
    [_splitController release];
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_catalogItems objectAtIndex:section] items] count];

}

//----------------------------------------------------------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCustomCellID = @"MyCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID] autorelease];
    }

    cell.textLabel.text = [[[[_catalogItems objectAtIndex:indexPath.section] items] objectAtIndex:indexPath.row] name];
    return cell;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return _catalogItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    return [[_catalogItems objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CatalogObject * obj =  [[[_catalogItems objectAtIndex:indexPath.section] items] objectAtIndex:indexPath.row];
    [self selectItem:obj];
}


@end
