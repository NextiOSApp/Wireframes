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

//@class ParseNetworkManager;
//@class RouletteTestingDetailViewController;

#import <CoreData/CoreData.h>

@interface RouletteTestingMasterViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ParseManagerProtocol, UIGestureRecognizerDelegate>

//@property (strong, nonatomic) RouletteTestingDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Camera View
@property (nonatomic) UIImagePickerController *imagePicker;

-(UIImagePickerController *)imagePicker;

// Keep Current Connection Context
@property (nonatomic) ConnectionData *currentConnection;

// List of connections. Use Connection Model? Or too small?
@property (strong, nonatomic) NSMutableArray *connectionsListArray;
@property (strong, nonatomic) NSMutableArray *messagesListArray;

// Need to know who you are sending message too
@property (nonatomic) NSString *currentConnectionUUID;

//@property (nonatomic) ParseNetworkManager *parseManager;
@property (nonatomic) ParseNetworkManager *parseManager;

@property (nonatomic) NSIndexPath *currentRow;

@property (nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic) IBOutlet UILabel *connectionName;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIImageView *imageMessageView;
//@property (nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;



@end
