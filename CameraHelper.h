//
//  CameraHelper.h
//  Biando
//
//  Created by biando on 13-1-8.
//  Copyright (c) 2013年 biando. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraHelperDelegate;

@interface CameraHelper : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic,   weak) id<CameraHelperDelegate> delegate;
@property (nonatomic, strong) UIViewController *rootViewController;

- (void)startCamera;
- (void)startRecordingVideo;
- (BOOL)isFrontCameraAvailable;
- (BOOL)isRearCameraAvailable;

@end

@protocol CameraHelperDelegate <NSObject>

@optional
- (void)camera:(CameraHelper *)helper didTakePhoto:(NSData *)photoData;
- (void)camera:(CameraHelper *)helper didRecordVideo:(NSData *)videoData;
- (void)didCancelCamera:(CameraHelper *)helper;


@end
