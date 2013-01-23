//
//  AXViewController.h
//  CaptureViewControllerDemo
//

#import <UIKit/UIKit.h>
#import "AXCaptureViewController.h"

@interface AXViewController : UIViewController <AXCaptureViewControllerDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@end
