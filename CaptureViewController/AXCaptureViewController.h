//
//  AXCaptureViewController.h
//  CaptureViewControllerDemo
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AXCaptureViewController;

@protocol AXCaptureViewControllerDelegate <NSObject>
@optional
- (void)captureViewController:(AXCaptureViewController *)capture didFinishCapturingImage:(UIImage *)image;
- (void)captureViewControllerDidCancel:(AXCaptureViewController *)capture;
@end

@interface AXCaptureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak) id<AXCaptureViewControllerDelegate> delegate;

@property (strong, readonly, nonatomic) UIToolbar *topToolbar;
@property (strong, readonly, nonatomic) UIToolbar *bottomToolbar;
@property (strong, readonly, nonatomic) UIImageView *previewImageView;
@end
