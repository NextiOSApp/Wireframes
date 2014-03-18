//
//  RouletteTestingMasterViewController.m
//  RouletteTesting
//
//  Created by Michael Parris on 2/8/14.
//  Copyright (c) 2014 Michael Parris. All rights reserved.
//

#import "RouletteTestingMasterViewController.h"

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
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UITapGestureRecognizer *dismissPhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissImageView:)];
    dismissPhotoTap.numberOfTapsRequired = 1;
    dismissPhotoTap.numberOfTouchesRequired = 1;
    [self.imageMessageView addGestureRecognizer:dismissPhotoTap];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker = [self getImagePicker];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    connectionsListArray = [[NSMutableArray alloc] init];
    
    parseManager = [[ParseNetworkManager alloc] init];
    parseManager.delegate = self;

    [parseManager getConnections:self.view];
}

- (void)refresh {
    [parseManager getConnections:self.view];
}

- (void)dismissImageView:(UITapGestureRecognizer *)recognizer {
    [self.parseManager deleteImageMessage:[[currentConnection.messagesArray objectAtIndex:0] messageId]];
    
    // Remove Cached Image Path From User Defaults AND Delete File From Documents Directory
//    NSString *cachedImagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"image_message"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"image_message"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    [fileManager removeItemAtPath:cachedImagePath error:nil];
    
    [[self.tableView cellForRowAtIndexPath:self.currentRow] setBackgroundColor:[UIColor whiteColor]];
    
//    NSArray *reloadRow = [NSArray arrayWithObject:self.currentRow];
//    [self.tableView reloadRowsAtIndexPaths:reloadRow withRowAnimation:YES];
    [self.imageMessageView setImage:nil];
    
    [self.imageMessageView setHidden:YES];
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
    return [connectionsListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectionCell" forIndexPath:indexPath];
    
    if ([connectionsListArray count] <= indexPath.row)
        return cell;
    
    currentConnection = [connectionsListArray objectAtIndex:indexPath.row];
    cell.textLabel.text = currentConnection.connectionName;
    
    if ([currentConnection.messagesArray count] > 0) {
        cell.backgroundColor = [UIColor greenColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    currentConnection = [connectionsListArray objectAtIndex:indexPath.row];
    
    if ([currentConnection.messagesArray count] > 0) {
        // Display image
        ConnectionMessageData *currentMessage = [currentConnection.messagesArray objectAtIndex:0];
        [self.imageMessageView setImage:currentMessage.imageMessage];
        
        self.imageMessageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageMessageView setHidden:NO];
        
        // *** Maybe not best solution?
        self.currentRow = indexPath;

    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // Check if device supports
        // UIImagePickerControllerSourceTypeSavedPhotosAlbum
        // UIImagePickerControllerSourceTypePhotoLibrary
        
        [self presentViewController:[self getImagePicker] animated:YES completion:nil];
    } else {
//      There is not a camera on this device so display alert instead
        NSLog(@"No Camera On This Device");
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#warning @"This could cause problems because I'm re-using the same instance of the camera. For now is good but will need testing"
- (UIImagePickerController *)getImagePicker {
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        self.imagePicker.mediaTypes = @[(NSString*) kUTTypeImage, (NSString*) kUTTypeMovie];
        self.imagePicker.videoMaximumDuration = 10;
        
#warning @"I'm sure we'll want to allow editing of taken image / video like snapchat."
        // Don't allow user to edit image (scale, move, etc. )
        self.imagePicker.allowsEditing = NO;
    }
    
    return self.imagePicker;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        [[segue destinationViewController] setDetailItem:object];
//    }
    
    
}

#pragma mark - Image Picker Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        
        // Original unedited image
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        // Grab Image Data at specified quality
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
        
        
        
//        PFFile *videoFile = [PFFile fileWithData:videoData];
        // Save in Background
//        [videoFile saveInBackground];
        
        if ([parseManager uploadVideoMessage:videoData recieverUUID:currentConnectionUUID forView:self.view]) {
            NSLog(@"Upload Success!");
            [self.tableView reloadData];
        } else {
            NSLog(@"Upload Failed!");
        }
        
        
        // Create Video Object
        
        // Request a background task to allow finish of upload even if app is sent to background
//        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication]   beginBackgroundTaskWithExpirationHandler:^{
//            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
//        }];
        
        
        // Save the Video
        
        
        
        // Write To Device
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/vid1.mp4"];
        
        // Save To Photos Album
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(NSString *videoPath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        }
        
//        BOOL success = [videoData writeToFile:tempPath atomically:NO];
        
        // Save Video
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url))
//        {
//            UISaveVideoAtPathToSavedPhotosAlbum(url,
//                                                self,
//                                                @selector(video:finishedSavingWithError:contextInfo:),
//                                                nil);
//        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Parse Manager delegate methods

- (void)updateConnections:(NSMutableArray *)cachedConnectionList {
    self.connectionsListArray = cachedConnectionList;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)updateConnection:(ConnectionData *)connection {
    NSIndexPath *number = [NSIndexPath indexPathForRow:connection.rowNumber inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[number] withRowAnimation:UITableViewRowAnimationNone];
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