//
//  CameraViewController.h
//  Next
//
//  Created by Chris Hayes on 5/17/14.
//  Copyright (c) 2014 CAV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ParseManager.h"

@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                                        UIActionSheetDelegate, ParseManagerProtocol>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *recipients;
@property (nonatomic) ParseManager *parseManager;

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

- (void)uploadMessage;
- (void)setupImagePicker;
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;

@end

