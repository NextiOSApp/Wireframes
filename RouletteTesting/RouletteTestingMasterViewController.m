//
//  RouletteTestingMasterViewController.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/8/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "RouletteTestingMasterViewController.h"
#import "ConnectionCell.h"
#import "MessagesViewController.h"

static NSString * const KeychainItem_Service = @"FDKeychain";

@interface RouletteTestingMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RouletteTestingMasterViewController

@synthesize parseManager, connectionsListArray, connectionName, currentConnectionUUID, currentConnection;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    connectionsListArray = [[NSMutableArray alloc] init];
    parseManager = [[ParseNetworkManager alloc] init];
    parseManager.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker = [self getImagePicker:UIImagePickerControllerSourceTypeCamera];
    } else {
        self.imagePicker = [self getImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // Get documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build path to data file
    NSString *dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"data.archive"]];
    
    // Check if the file already exists
    if ([fileMgr fileExistsAtPath:dataFilePath]) {
        connectionsListArray = [NSKeyedUnarchiver unarchiveObjectWithFile:dataFilePath];
    }

    [parseManager getConnections:self.view];
}

- (void)fetchNewConnectionsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [parseManager getConnections:self.view];
    
    // Need to move this logic so completetionHandler is called once we get the objects from the server in the background
    UIBackgroundFetchResult result = UIBackgroundFetchResultNewData;
    completionHandler(result);
}

- (void)refresh {
    [parseManager getConnections:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d", [connectionsListArray count]);
    return [connectionsListArray count];
}

- (ConnectionCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionCell" forIndexPath:indexPath];
    
    if ([connectionsListArray count] <= indexPath.row)
        return cell;
    
    currentConnection = [connectionsListArray objectAtIndex:indexPath.row];
    cell.connectionNameLabel.text = currentConnection.connectionName;
    cell.connectionId = currentConnection.connectionId;
    
    // This will obvioulsy change but for now this just changes the background color of the cell to notify me there are messages, and this also tells me how many messages.
    if ([currentConnection.messagesArray count] > 0) {
        cell.backgroundColor = [UIColor greenColor];
        cell.messageCountLabel.text = [NSString stringWithFormat:@"%d Messages", [currentConnection.messagesArray count]];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.messageCountLabel.text = @"0 Messages";
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PushMessages"]) {
        MessagesViewController *messagesViewController = [segue destinationViewController];
        messagesViewController.messages = currentConnection.messagesArray;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    currentConnection = [connectionsListArray objectAtIndex:indexPath.row];
//    currentConnection.connectionId = @"hBsKsmTZCH";
//    currentConnection.connectionUUID = @"418201B4-96EA-4BB9-9D12-EC861C09E094";
    
//    if (NO) {
//    //    if ([currentConnection.messagesArray count] > 0) {
//        [self performSegueWithIdentifier:@"PushMessages" sender:self];
//
//    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [self presentViewController:[self getImagePicker:UIImagePickerControllerSourceTypeCamera] animated:YES completion:nil];
//    } else {
////        imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self presentViewController:[self getImagePicker:UIImagePickerControllerSourceTypePhotoLibrary] animated:YES completion:nil];
//        NSLog(@"No Camera On This Device");
//    }
    
    
    // This will change too but this basically either takes you to the MessagesViewController to display the Messages OR it will bring up an action sheet to allow you to send a message through a new pic or library, depending on available options on device.
    if ([currentConnection.messagesArray count] > 0) {
        [self performSegueWithIdentifier:@"PushMessages" sender:self];
    } else {
        [self showImageActions:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIImagePickerController *)getImagePicker:(UIImagePickerControllerSourceType)sourceType {
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = sourceType;
        self.imagePicker.mediaTypes = @[(NSString*) kUTTypeImage, (NSString*) kUTTypeMovie];
        self.imagePicker.videoMaximumDuration = 10;
        self.imagePicker.allowsEditing = NO;
    } else if (self.imagePicker.sourceType != sourceType) {
        self.imagePicker.sourceType = sourceType;
    }
    
    return self.imagePicker;
}

- (void)showImageActions:(id)sender {
    NSString *messageOptions = [[NSString alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *imageAction = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo", @"Take Photo", nil];
        imageAction.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [imageAction  showInView:self.view];
    } else {
        UIActionSheet *imageAction = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Photo", nil];
        imageAction.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [imageAction  showInView:self.view];
    }

    
    //    [imageAction release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self presentViewController:[self getImagePicker:UIImagePickerControllerSourceTypePhotoLibrary] animated:YES completion:nil];
    }
    else if (buttonIndex == 1){
        [self presentViewController:[self getImagePicker:UIImagePickerControllerSourceTypeCamera] animated:YES completion:nil];
    }
}

#pragma mark - Image Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        
        // Original unedited image
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        // Grab Image Data at specified quality so meet the < 1 MB requirement of the Free Parse Version
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"Image Size: %.1f MB", ([imageData length]/1048576.0));
        [parseManager uploadMessage:imageData connection:currentConnection forView:self.view];
        
        // To Save Photo to library
//        UIImageWriteToSavedPhotosAlbum(image, self,
//                                       @selector(image:finishedSavingWithError:contextInfo:),
//                                       nil);
        
        
    } else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]) {
        // Original URL of the recorded media
        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSData *videoData = [NSData dataWithContentsOfURL:url];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Parse Manager delegate methods

- (void)endRefresh {
    [self.refreshControl endRefreshing];
}

-(void)updateMessages:(NSMutableArray *)messages {
    NSFileManager *fileMgr;
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get cached hash of list of connections
    fileMgr = [NSFileManager defaultManager];
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *dataFilePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"data.archive"]];
    
    NSMutableArray *cachedConnections = [NSKeyedUnarchiver unarchiveObjectWithFile:dataFilePath];
    NSMutableArray *newMessages = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    int counter = 0;
    
    // Go through each Connection's messages array and if a new Message is found for that Connection Object then update it's messagesArray to include it.
    // This is not super slow BUT need to find a better way to do this. I really only want to loop through the Connections with new Messages
    // Maybe have to use Core Data to query a specific list of ids locally?
    for (ConnectionData *connection in cachedConnections) {
        for (ConnectionMessageData *message in messages) {
            if ([message.connectionId isEqualToString:connection.connectionId]) {
                [newMessages addObject:message];
            }
        }
        
        NSMutableArray *currMessages = [[NSMutableArray alloc] initWithArray:connection.messagesArray];
        [currMessages addObjectsFromArray:newMessages];
        
        // Had to keep a counter to know which Connection I'm looking at
        [[connectionsListArray objectAtIndex:counter] setMessagesArray:currMessages];
        
        // Want to update the row if it has changed immeditraely instead of waiting for everything. Better UX
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:counter inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        counter++;
    }
    
    // In the background, Store new Connections List Hash locally
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:connectionsListArray toFile:dataFilePath];
    });
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

@end