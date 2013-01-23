//
//  AXCameraButton.m
//  CaptureViewControllerDemo
//
//  Created by Hiroki Akiyama on 2013/01/23.
//  Copyright (c) 2013年 Hiroki Akiyama. All rights reserved.
//

#import "AXCameraButton.h"
#import<QuartzCore/QuartzCore.h>

@interface AXCameraButton ()
@property (strong, nonatomic) CAGradientLayer *backgroundLayer;
@end

@implementation AXCameraButton

- (id)init
{
	self = [super init];
	if (self) {
		[self prepareView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareView];
    }
    return self;
}

- (void)prepareView
{
	_backgroundLayer = [CAGradientLayer layer];
    _backgroundLayer.frame = self.bounds;
    _backgroundLayer.locations = [NSArray arrayWithObjects:
								  [NSNumber numberWithFloat:0.0],
								  [NSNumber numberWithFloat:0.5],
								  [NSNumber numberWithFloat:0.5],
								  [NSNumber numberWithFloat:1.0],
								  nil];
	_backgroundLayer.colors = [NSArray arrayWithObjects:
							   (id)[UIColor colorWithWhite:1.0 alpha:0.9].CGColor,
							   (id)[UIColor colorWithWhite:1.0 alpha:0.7].CGColor,
							   (id)[UIColor colorWithWhite:1.0 alpha:0.6].CGColor,
							   (id)[UIColor colorWithWhite:1.0 alpha:0.3].CGColor,
							   nil];
	_backgroundLayer.borderColor = [[UIColor colorWithWhite:0.3 alpha:0.8] CGColor];
	_backgroundLayer.borderWidth = 1.0;
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
	
	[self.imageView setAlpha:1.0];
	[self.imageView setHidden:NO];
}
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	CGRect bounds = self.bounds;
	[_backgroundLayer setFrame:bounds];
	[_backgroundLayer setCornerRadius:CGRectGetHeight(bounds) / 2.0];
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	if (highlighted) {
		_backgroundLayer.locations = [NSArray arrayWithObjects:
									  [NSNumber numberWithFloat:0.0],
									  [NSNumber numberWithFloat:0.6],
									  [NSNumber numberWithFloat:0.6],
									  [NSNumber numberWithFloat:1.0],
									  nil];
		_backgroundLayer.colors = [NSArray arrayWithObjects:
								   (id)[UIColor colorWithWhite:0.3 alpha:0.9].CGColor,
								   (id)[UIColor colorWithWhite:0.5 alpha:0.9].CGColor,
								   (id)[UIColor colorWithWhite:0.4 alpha:0.9].CGColor,
								   (id)[UIColor colorWithWhite:0.7 alpha:0.9].CGColor,
								   nil];
	} else {
		_backgroundLayer.locations = [NSArray arrayWithObjects:
									  [NSNumber numberWithFloat:0.0],
									  [NSNumber numberWithFloat:0.5],
									  [NSNumber numberWithFloat:0.5],
									  [NSNumber numberWithFloat:1.0],
									  nil];
		_backgroundLayer.colors = [NSArray arrayWithObjects:
								   (id)[UIColor colorWithWhite:1.0 alpha:0.9].CGColor,
								   (id)[UIColor colorWithWhite:0.8 alpha:0.9].CGColor,
								   (id)[UIColor colorWithWhite:0.7 alpha:0.9].CGColor,
								   (id)[UIColor colorWithWhite:0.6 alpha:0.9].CGColor,
								   nil];
	}
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
