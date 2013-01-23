//
//  AXCaptureViewController.m
//  CaptureViewControllerDemo
//

#import "AXCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AXTranslucentRoundedButton.h"
#import "AXCameraButton.h"

@interface AXCaptureViewController ()
@property (strong, readonly, nonatomic) AVCaptureSession *captureSession;
@property (strong, readonly, nonatomic) AVCaptureStillImageOutput *imageOutput;
@property (strong, readonly, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, readonly, nonatomic) UIButton *toggleFlashButton;
@end

@implementation AXCaptureViewController

static CGFloat const TOP_TOOLBAR_BUTTON_MARGIN = 10.0;
static CGFloat const TOP_TOOLBAR_BUTTON_WIDTH = 68.0;
static CGFloat const TOP_TOOLBAR_BUTTON_HEIGHT = 35.0;
static CGFloat const BOTTOM_TOOLBAR_HEIGHT = 64.0;

- (id)init
{
	self = [super init];
	if (self) {
		_previewImageView = [[UIImageView alloc] init];
		_topToolbar = [[UIToolbar alloc] init];
		_bottomToolbar = [[UIToolbar alloc] init];
		
		
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// 上部ツールバーにボタンを追加
	UIBarButtonItem *__flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
	UIBarButtonItem *__fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
	[__fixedSpaceItem setWidth:TOP_TOOLBAR_BUTTON_MARGIN];
	
	UIButton *closeButton = [[AXTranslucentRoundedButton alloc] init];
	[closeButton setBounds:(CGRect){CGPointZero, TOP_TOOLBAR_BUTTON_WIDTH, TOP_TOOLBAR_BUTTON_HEIGHT}];
	[closeButton setImage:[UIImage imageNamed:@"ax-icon-camera-close"] forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
	
	UIButton *toggleFlashButton = [[AXTranslucentRoundedButton alloc] init];
	[toggleFlashButton setBounds:(CGRect){CGPointZero, 96.0, TOP_TOOLBAR_BUTTON_HEIGHT}];
	[toggleFlashButton setTitle:@"Auto" forState:UIControlStateNormal];
	[toggleFlashButton setImage:[UIImage imageNamed:@"ax-icon-camera-flash"] forState:UIControlStateNormal];
	UIBarButtonItem *toggleFlashBarButton = [[UIBarButtonItem alloc] initWithCustomView:toggleFlashButton];
	[toggleFlashButton addTarget:self action:@selector(toggleFlash:) forControlEvents:UIControlEventTouchUpInside];
	_toggleFlashButton = toggleFlashButton;
	
	UIButton *flipCameraButton = [[AXTranslucentRoundedButton alloc] init];
	[flipCameraButton setBounds:(CGRect){CGPointZero, TOP_TOOLBAR_BUTTON_WIDTH, TOP_TOOLBAR_BUTTON_HEIGHT}];
	[flipCameraButton setTitle:@"" forState:UIControlStateNormal];
	[flipCameraButton setImage:[UIImage imageNamed:@"ax-icon-camera-flip"] forState:UIControlStateNormal];
	[flipCameraButton addTarget:self action:@selector(flipCamera:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *flipCameraBarButton = [[UIBarButtonItem alloc] initWithCustomView:flipCameraButton];
	
	[_topToolbar setItems:[NSArray arrayWithObjects:
						   __fixedSpaceItem,
						   closeBarButton,
						   __flexibleSpaceItem,
						   toggleFlashBarButton,
						   __flexibleSpaceItem,
						   flipCameraBarButton,
						   __fixedSpaceItem,
						   nil]];
	
	// 下部ツールバーにボタンを追加
	UIButton *pickPhotoButton = [[UIButton alloc] init];
	[pickPhotoButton setBounds:(CGRect){CGPointZero, BOTTOM_TOOLBAR_HEIGHT - TOP_TOOLBAR_BUTTON_MARGIN * 2, BOTTOM_TOOLBAR_HEIGHT - TOP_TOOLBAR_BUTTON_MARGIN}];
	[pickPhotoButton setImage:[UIImage imageNamed:@"ax-icon-camera-picker"] forState:UIControlStateNormal];
	[pickPhotoButton addTarget:self action:@selector(pickPhoto:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *pickPhotoBarButton = [[UIBarButtonItem alloc] initWithCustomView:pickPhotoButton];
	AXCameraButton *capturePhotoButton = [[AXCameraButton alloc] init];
	[capturePhotoButton setBounds:(CGRect){CGPointZero, TOP_TOOLBAR_BUTTON_WIDTH, BOTTOM_TOOLBAR_HEIGHT - TOP_TOOLBAR_BUTTON_MARGIN}];
	[capturePhotoButton setImage:[UIImage imageNamed:@"ax-icon-camera"] forState:UIControlStateNormal];
	[capturePhotoButton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *capturePhotoBarButton = [[UIBarButtonItem alloc] initWithCustomView:capturePhotoButton];
	[_bottomToolbar setItems:[NSArray arrayWithObjects:
							  pickPhotoBarButton,
							  __flexibleSpaceItem,
							  capturePhotoBarButton,
							  __flexibleSpaceItem,
							  nil]];
	
	// 他のビューの計算に使うのでself.viewのサイズを取得
	CGSize viewSize = self.view.bounds.size;
	
	// プレビューの設定
	[_previewImageView setFrame:self.view.bounds];
	[_previewImageView setBackgroundColor:[UIColor blackColor]];
	[_previewImageView setContentMode:UIViewContentModeScaleAspectFill];
	
	// 上部ツールバーの設定
	[_topToolbar setFrame:(CGRect){CGPointZero, viewSize.width, TOP_TOOLBAR_BUTTON_HEIGHT + TOP_TOOLBAR_BUTTON_MARGIN * 2}];
	[_topToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

	// 下部ツールバーの設定
	[_bottomToolbar setFrame:(CGRect){0.0, viewSize.height - BOTTOM_TOOLBAR_HEIGHT, viewSize.width, BOTTOM_TOOLBAR_HEIGHT}];
	[_bottomToolbar setBarStyle:UIBarStyleBlack];
	
	// ビューを追加
	[self.view addSubview:_previewImageView];
	[self.view addSubview:_topToolbar];
	[self.view addSubview:_bottomToolbar];
	
	// カメラを用意
	[self prepareCamera];
}

- (void)prepareCamera
{
	NSError *error = nil;
	
	// デバイスを取得
	_captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
	if (!captureInput) {
		NSLog(@"ERROR:%@", error);
		return;
	}
	[_captureDevice lockForConfiguration:Nil];
	[_captureDevice setFlashMode:AVCaptureFlashModeOff];
	[_toggleFlashButton setTitle:@"Off" forState:UIControlStateNormal];
	[_captureDevice unlockForConfiguration];
	
	// セッションの初期化
	_captureSession = [[AVCaptureSession alloc] init];
	[_captureSession addInput:captureInput];
	[_captureSession beginConfiguration];
	[_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
	[_captureSession commitConfiguration];
	
	// プレビューの初期化と追加
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[previewLayer setFrame:self.view.bounds];
	[self.view.layer insertSublayer:previewLayer atIndex:0];
	
	// 出力の初期化と設定
	_imageOutput = [[AVCaptureStillImageOutput alloc] init];
	[_captureSession addOutput:_imageOutput];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// ナビゲーションコントローラの中にいたら、ナビゲーションバーを隠す
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	
	// プレビュー開始を監視しながら撮影開始
	[_captureSession addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:NULL];
	[_captureSession performSelectorInBackground:@selector(startRunning) withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	// 撮影停止して監視を終了
	[_captureSession stopRunning];
	[_captureSession removeObserver:self forKeyPath:@"running"];
	[super viewDidDisappear:animated];
}

- (void)dealloc
{
	_toggleFlashButton = nil;
}

- (void)fadeInPreviewLayer
{
	// プレビューレイヤーをフェードインする
	[_previewImageView setImage:nil];
	[_previewImageView setBackgroundColor:[UIColor blackColor]];
	[_previewImageView setAlpha:1.0];
	[UIView animateWithDuration:0.3 animations:^{
		[_previewImageView setAlpha:0.0];
	} completion:^(BOOL finished) {
		[_previewImageView setHidden:YES];
	}];
}

#pragma mark - Action

// 閉じる
- (void)close:(id)sender
{
	if ([_delegate respondsToSelector:@selector(captureViewControllerDidCancel:)]) {
		[_delegate captureViewControllerDidCancel:self];
	}
}

// ライブラリから写真を選ぶ
- (void)pickPhoto:(id)sender
{
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	[imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[imagePickerController setDelegate:self];
	[self presentViewController:imagePickerController animated:YES completion:NULL];
}

// カメラで写真を取得
- (void)capturePhoto:(id)sender
{
	AVCaptureConnection *connection = [[_imageOutput connections] lastObject];
    [_imageOutput
	 captureStillImageAsynchronouslyFromConnection:connection
	 completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		 NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
		 UIImage *image = [UIImage imageWithData:data];
		 // 前面カメラなら画像を左右反転する
		 if (_captureDevice.position == AVCaptureDevicePositionFront) {
			 CGSize size = image.size;
			 UIGraphicsBeginImageContext(size);
			 CGContextRef context = UIGraphicsGetCurrentContext();
			 CGContextTranslateCTM(context, size.width,0);
			 CGContextScaleCTM(context, -1.0, 1.0);
			 [image drawAtPoint:CGPointZero];
			 image = UIGraphicsGetImageFromCurrentImageContext();
			 UIGraphicsEndImageContext();
		 }
		 [_previewImageView setImage:image];
		 [_previewImageView setAlpha:1.0];
		 [_previewImageView setHidden:NO];
		 if ([_delegate respondsToSelector:@selector(captureViewController:didFinishCapturingImage:)]) {
			 [_delegate captureViewController:self didFinishCapturingImage:image];
		 }
	 }];
}

// フラッシュの切り替え
- (void)toggleFlash:(id)sender
{
	NSError *error;
	[_captureDevice lockForConfiguration:&error];
	if (!error) {
		switch (_captureDevice.flashMode) {
			case AVCaptureFlashModeAuto:
				[_captureDevice setFlashMode:AVCaptureFlashModeOn];
				[_toggleFlashButton setTitle:@"On" forState:UIControlStateNormal];
				break;
			case AVCaptureFlashModeOn:
				[_captureDevice setFlashMode:AVCaptureFlashModeOff];
				[_toggleFlashButton setTitle:@"Off" forState:UIControlStateNormal];
				break;
			case AVCaptureFlashModeOff:
				[_captureDevice setFlashMode:AVCaptureFlashModeAuto];
				[_toggleFlashButton setTitle:@"Auto" forState:UIControlStateNormal];
				break;
			default:
				break;
		}
	}
	[_captureDevice unlockForConfiguration];
}

// 前面背面カメラの切り替え
- (void)flipCamera:(id)sender
{
	NSError *error;
	AVCaptureDevice *toDevice;
	AVCaptureDevicePosition toDevicePosition;
	if (_captureDevice.position == AVCaptureDevicePositionFront) {
		toDevicePosition = AVCaptureDevicePositionBack;
	} else {
		toDevicePosition = AVCaptureDevicePositionFront;
	}
	
	NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in videoDevices) {
		if (device.position == toDevicePosition) {
			toDevice = device;
			break;
		}
	}
	
	if (toDevice) {
		_captureDevice = toDevice;
		[_captureSession removeInput:[[_captureSession inputs] lastObject]];
		AVCaptureInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:toDevice error:&error];
		if (!captureInput) {
			NSLog(@"ERROR:%@", error);
			return;
		}
		[_captureSession addInput:captureInput];
	}
}

#pragma mark - Image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	
	[[picker presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
	if ([_delegate respondsToSelector:@selector(captureViewController:didFinishCapturingImage:)]) {
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
		[_delegate captureViewController:self didFinishCapturingImage:image];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[[picker presentingViewController] dismissViewControllerAnimated:YES completion:NO];
}

#pragma mark - Key value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == _captureSession) {
		if ([keyPath isEqualToString:@"running"]) {
			if (_captureSession.running) {
				// カメラの状態が稼働中に変わったので、フェードインする
				[self performSelectorOnMainThread:@selector(fadeInPreviewLayer) withObject:nil waitUntilDone:NO];
			}
		}
	}
}

@end
