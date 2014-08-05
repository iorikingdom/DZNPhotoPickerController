//
//  RootViewController.m
//  Sample
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2013 DZN Labs. All rights reserved.
//

#import "RootViewController.h"

#import "DZNPhotoPickerController.h"
#import "UIImagePickerControllerExtended.h"
#import "DZNPhotoMetadata.h"

#import "Private.h"
#import <MWPhotoBrowser.h>

@interface RootViewController ()<MWPhotoBrowserDelegate> {
    UIPopoverController *_popoverController;
    NSDictionary *_photoPayload;
}

@property(nonatomic,strong) NSMutableArray *arrayPhotoMetas;
@end

@implementation RootViewController

+ (void)initialize
{
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerService500px
                                  consumerKey:k500pxConsumerKey
                               consumerSecret:k500pxConsumerSecret
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceFlickr
                                  consumerKey:kFlickrConsumerKey
                               consumerSecret:kFlickrConsumerSecret
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceInstagram
                                  consumerKey:kInstagramConsumerKey
                               consumerSecret:kInstagramConsumerSecret
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceGoogleImages
                                  consumerKey:kGoogleImagesConsumerKey
                               consumerSecret:kGoogleImagesSearchEngineID
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    //Bing does not require a secret. Rather just an "Account Key" 
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceBingImages
                                  consumerKey:kBingImagesAccountKey
                               consumerSecret:nil
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startupConfig];
}


#pragma mark - ViewController methods

- (IBAction)pressButton:(UIButton *)button
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose Photo", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Search Photo", nil)];
    
    if (_imageView.image) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Edit Photo", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Delete Photo", nil)];
    }
    
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)]];
    [actionSheet setDelegate:self];
    
    CGRect rect = button.frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rect.origin = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height/2);
    }
    
    [actionSheet showFromRect:rect inView:self.view animated:YES];
}

- (void)presentPhotoPicker
{
    [self presentPhotoPickerWithImage:nil];
}

- (void)presentPhotoEditor
{
    UIImage *image = [_photoPayload objectForKey:UIImagePickerControllerOriginalImage];
    [self presentPhotoPickerWithImage:image];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [_arrayPhotoMetas count];
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{

    DZNPhotoMetadata *metadata = [_arrayPhotoMetas objectAtIndex:index];
//    NSURL *url = [NSURL URLWithString:strUrl];
    
    MWPhoto *photo = [[MWPhoto alloc]initWithURL:metadata.sourceURL];
//    photo.caption = [_arrayPhotoMetas firstObject][DZNPhotoPickerControllerPhotoMetadata][@"source_name"];

    return photo;
}
- (void)presentPhotoPickerWithImage:(UIImage *)image
{
    DZNPhotoPickerController *picker = nil;
    
    if (image && _photoPayload) {
        picker = [[DZNPhotoPickerController alloc] initWithEditableImage:image];
        picker.cropMode = [[_photoPayload objectForKey:DZNPhotoPickerControllerCropMode] integerValue];
    }
    else {
        picker = [DZNPhotoPickerController new];
        picker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceInstagram|DZNPhotoPickerControllerServiceGoogleImages|DZNPhotoPickerControllerServiceBingImages;
        picker.allowsEditing = NO;
        picker.cropMode = DZNPhotoEditorViewControllerCropModeNone;
        picker.initialSearchTerm = @"California";
        picker.enablePhotoDownload = YES;
        picker.allowAutoCompletedSearch = YES;
    }
    
    self.arrayPhotoMetas = [NSMutableArray array];
    
    picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {

        [self.arrayPhotoMetas removeAllObjects];
        [self.arrayPhotoMetas addObjectsFromArray:[picker getMetadataList]];

       dispatch_async(dispatch_get_main_queue(), ^{
            MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc]initWithDelegate:self];
            photoBrowser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
            photoBrowser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
            photoBrowser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
            photoBrowser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
            photoBrowser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
            photoBrowser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
            photoBrowser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
//            photoBrowser.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
           
           

           
           
           // Optionally set the current visible photo before displaying
           [photoBrowser setCurrentPhotoIndex:[info[DZNPhotoPickerControllerPhotoMetadata][@"index"] integerValue]];
           
//            UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:photoBrowser];
//            [self presentViewController:navigationController animated:TRUE completion:nil];
            [picker pushViewController:photoBrowser animated:YES];
        });


    };
    
    picker.failureBlock = ^(DZNPhotoPickerController *picker, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
        [self dismissController:picker];
    };
    
    [self presentController:picker];
}

- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        [self handleImagePicker:picker withMediaInfo:info];
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {
        [self dismissController:picker];
    };
    
    [self presentController:picker];
}

- (void)handleImagePicker:(UIImagePickerController *)picker withMediaInfo:(NSDictionary *)info
{
    if (picker.cropMode != DZNPhotoEditorViewControllerCropModeNone) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

        DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image cropMode:picker.cropMode];
        [picker pushViewController:editor animated:YES];
    }
    else {
        [self updateImageWithPayload:info];
        [self dismissController:picker];
    }
}

- (void)updateImageWithPayload:(NSDictionary *)payload
{
    _photoPayload = payload;
    
    NSLog(@"OriginalImage : %@",[payload objectForKey:UIImagePickerControllerOriginalImage]);
    NSLog(@"EditedImage : %@",[payload objectForKey:UIImagePickerControllerEditedImage]);
    NSLog(@"MediaType : %@",[payload objectForKey:UIImagePickerControllerMediaType]);
    NSLog(@"CropRect : %@", NSStringFromCGRect([[payload objectForKey:UIImagePickerControllerCropRect] CGRectValue]));
    NSLog(@"ZoomScale : %f", [[payload objectForKey:DZNPhotoPickerControllerCropZoomScale] floatValue]);

    NSLog(@"CropMode : %@", [payload objectForKey:DZNPhotoPickerControllerCropMode]);
    NSLog(@"PhotoAttributes : %@",[payload objectForKey:DZNPhotoPickerControllerPhotoMetadata]);
    
    UIImage *image = [payload objectForKey:UIImagePickerControllerEditedImage];
    if (!image) image = [payload objectForKey:UIImagePickerControllerOriginalImage];
    
    [self setButtonImage:image];
    [self saveImage:image];
}

- (void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)startupConfig
{
    [_button setTitle:@"Tap Here to Start" forState:UIControlStateNormal];
    [_button setBackgroundImage:nil forState:UIControlStateHighlighted];

    _imageView.image = nil;
    _photoPayload = nil;
}

- (void)setButtonImage:(UIImage *)image
{
    _imageView.image = image;
    [_button setTitle:nil forState:UIControlStateNormal];
    
    
    UIGraphicsBeginImageContextWithOptions(_button.frame.size, NO, 0);
    
    CGSize imageSize = CGSizeMake(self.view.frame.size.width, (image.size.height*self.view.frame.size.width)/image.size.width);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, (_button.frame.size.height-imageSize.height)/2, imageSize.width, imageSize.height)];
    [[UIColor colorWithWhite:0 alpha:0.75] setFill];
    [clipPath fill];
    
    [_button setBackgroundImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateHighlighted];
    
    UIGraphicsEndImageContext();
}

- (void)presentController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        _popoverController.popoverContentSize = CGSizeMake(320.0, 548.0);
        
        [_popoverController presentPopoverFromRect:_button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)dismissController:(UIViewController *)controller
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [_popoverController dismissPopoverAnimated:YES];
    }
    else {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Choose Photo", nil)]) {
        [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Search Photo",nil)]) {
        [self presentPhotoPicker];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Edit Photo",nil)]) {
        [self presentPhotoEditor];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"Delete Photo",nil)]) {
        [self startupConfig];
    }
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


@end
