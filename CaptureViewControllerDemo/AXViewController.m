//
//  AXViewController.m
//  CaptureViewControllerDemo
//

#import "AXViewController.h"

@interface AXViewController ()

@end

@implementation AXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	
	self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	[_imageView setContentMode:UIViewContentModeScaleAspectFill];
	
	UIButton *launchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[launchButton setTitle:@"Launch" forState:UIControlStateNormal];
	[launchButton addTarget:self action:@selector(launch:) forControlEvents:UIControlEventTouchUpInside];
	[launchButton sizeToFit];
	[launchButton setCenter:self.view.center];
	
	[self.view addSubview:_imageView];
	[self.view addSubview:launchButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)launch:(id)sender
{
	AXCaptureViewController *captureViewController = [[AXCaptureViewController alloc] init];
	[captureViewController setModalPresentationStyle:UIModalPresentationFormSheet];
	[captureViewController setDelegate:self];
	[self presentViewController:captureViewController animated:YES completion:NULL];
}

- (void)captureViewController:(AXCaptureViewController *)capture didFinishCapturingImage:(UIImage *)image
{
	[_imageView setImage:image];
	[capture dismissViewControllerAnimated:YES completion:NULL];
}

- (void)captureViewControllerDidCancel:(AXCaptureViewController *)capture
{
	[capture dismissViewControllerAnimated:YES completion:NULL];
}

@end
