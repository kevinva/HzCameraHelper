//
//  CameraHelper.m
//  Biando
//
//  Created by biando on 13-1-8.
//  Copyright (c) 2013年 biando. All rights reserved.
//

#import "CameraHelper.h"
#import "UIImage+fixOrientation.h"
#import <AVFoundation/AVFoundation.h>

#define KevinDebug

@interface CameraHelper ()

- (BOOL)isCameraAvailable;
- (BOOL)doesCameraSupportTakingPhotos;
- (BOOL)doesCameraSupportRecordingVideos;
- (BOOL)cameraSupportsMedia:(NSString *)paramMeidaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;

@end

@implementation CameraHelper


#pragma mark - Public Methods

- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (void)startCamera{
    if(_rootViewController){
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else if(authStatus == AVAuthorizationStatusAuthorized){
            if([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]){
                UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                pickerController.allowsEditing = NO;
                pickerController.showsCameraControls = YES;
                pickerController.delegate = self;
                [_rootViewController presentViewController:pickerController animated:YES completion:nil];
            }else{
                
#ifdef DEBUG
                NSLog(@"Camera is not available.");
#endif
                
            }
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                
                if(granted){
                    if([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]){
                        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                        pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                        pickerController.allowsEditing = NO;
                        pickerController.showsCameraControls = YES;
                        pickerController.delegate = self;
                        [_rootViewController presentViewController:pickerController animated:YES completion:nil];
                    }else{
                        
#ifdef DEBUG
                        NSLog(@"Camera is not available.");
#endif
                        
                    }
                }
                
            }];
            
        }
    }
}

- (void)startRecordingVideo{
    if(_rootViewController){
        if([self isCameraAvailable] && [self doesCameraSupportRecordingVideos]){
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            pickerController.allowsEditing = NO;
            pickerController.showsCameraControls = YES;
            pickerController.delegate = self;
            [_rootViewController presentViewController:pickerController animated:YES completion:nil];
        }else{
            
#ifdef KevinDebug
            NSLog(@"Camera is not available.");
#endif
            
        }
    }
}

#pragma mark - Private Methods

- (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)doesCameraSupportTakingPhotos{
    return [self cameraSupportsMedia:(NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)doesCameraSupportRecordingVideos{
    return [self cameraSupportsMedia:(NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMeidaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if(paramMeidaType.length == 0){
        return NO;
    }
    
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *mediaType = (NSString *)obj;
        if([mediaType isEqualToString:paramMeidaType]){
            result = YES;
            *stop = YES;
        }
        
    }];
    
    return result;
}

#pragma mark - UIImagePickerControllerDelegate delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if(_rootViewController){
        [_rootViewController dismissViewControllerAnimated:YES completion:^{
            
#ifdef KevinDebug
            NSLog(@"%s, info: %@", __FUNCTION__, info);
#endif
            
            NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
            if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                if(_delegate && [_delegate respondsToSelector:@selector(camera:didTakePhoto:)]){
                    UIImage *resultImage = [image fixOrientation];
                    //            NSData *photoData = UIImagePNGRepresentation(resultImage);
                    NSData *photoData = UIImageJPEGRepresentation(resultImage, 1.0f);
                    [_delegate camera:self didTakePhoto:photoData];
                }
            }
            else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
                NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
                if(_delegate && [_delegate respondsToSelector:@selector(camera:didRecordVideo:)]){
                    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
                    [_delegate camera:self didRecordVideo:videoData];
                }
            }
            
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if(_rootViewController){
        [_rootViewController dismissViewControllerAnimated:YES completion:^{
            
            if([_delegate respondsToSelector:@selector(didCancelCamera:)]){
                [_delegate didCancelCamera:self];
            }
            
        }];
    }
}

@end
