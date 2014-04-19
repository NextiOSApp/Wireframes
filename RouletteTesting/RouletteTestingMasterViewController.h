//
//  RouletteTestingMasterViewController.h
//  RouletteTesting
//
//  Created by Michael Parris on 2/8/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import "ConnectionData.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ParseNetworkManager.h"
#import <CoreData/CoreData.h>

@interface RouletteTestingMasterViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ParseManagerProtocol, UIGestureRecognizerDelegate, UIActionSheetDelegate>

- (void)fetchNewConnectionsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

-(UIImagePickerController *)imagePicker;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) ConnectionData *currentConnection;
@property (nonatomic) ParseNetworkManager *parseManager;

@property (strong, nonatomic) NSMutableArray *connectionsListArray;
@property (strong, nonatomic) NSMutableArray *messagesListArray;

@property (nonatomic) NSString *currentConnectionUUID;
@property (nonatomic) NSIndexPath *currentRow;

@property (nonatomic) IBOutlet UILabel *connectionName;
@property (nonatomic) IBOutlet UITableView *tableView;

@end
