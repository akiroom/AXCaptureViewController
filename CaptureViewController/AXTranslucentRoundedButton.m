//
//  AXTranslucentRoundedButton.m
//  CaptureViewControllerDemo
//
//  Created by Hiroki Akiyama on 2013/01/23.
//  Copyright (c) 2013年 Hiroki Akiyama. All rights reserved.
//

#import "AXTranslucentRoundedButton.h"
#import <QuartzCore/QuartzCore.h>

@interface AXTranslucentRoundedButton ()

@property (strong, nonatomic) CALayer *backgroundLayer;

@end

@implementation AXTranslucentRoundedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self prepareView];
    }
    return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"titleLabel.text"];
	[self removeObserver:self forKeyPath:@"imageView.image"];
}

- (void)prepareView
{
	[self addObserver:self forKeyPath:@"titleLabel.text" options:NSKeyValueObservingOptionNew context:NULL];
	[self addObserver:self forKeyPath:@"imageView.image" options:NSKeyValueObservingOptionNew context:NULL];
	[self.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
	[self setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.8] forState:UIControlStateNormal];
	
	_backgroundLayer = [CALayer layer];
	[_backgroundLayer setBorderColor:[[UIColor colorWithWhite:0.3 alpha:0.8] CGColor]];
	[_backgroundLayer setBorderWidth:1.0];
	[_backgroundLayer setCornerRadius:20.0];
	[_backgroundLayer setBackgroundColor:[[UIColor colorWithWhite:0.8 alpha:0.5] CGColor]];
	[_backgroundLayer setFrame:self.bounds];
	[self.layer insertSublayer:_backgroundLayer atIndex:0];
	
	[self.imageView setAlpha:0.8];
	[self.imageView setHidden:NO];
}

- (void)prepareInsets
{
	BOOL hasText = ((self.titleLabel.text != nil) && ([self.titleLabel.text isEqualToString:@""] == NO));
	BOOL hasImage = (self.imageView.image != nil);
	if (hasImage && hasText) {
		[self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 0.0)];
		[self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 8.0)];
	} else {
		[self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
		[self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
	}
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	CGRect bounds = self.bounds;
	[_backgroundLayer setFrame:bounds];
	[_backgroundLayer setCornerRadius:CGRectGetHeight(bounds) / 2.0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[_backgroundLayer setBackgroundColor:[[UIColor colorWithWhite:(highlighted ? 1.0 : 0.8) alpha:0.5] CGColor]];
}
- (void)drawRect:(CGRect)rect
{
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == self) {
		if ([keyPath isEqualToString:@"titleLabel.text"]) {
			[self prepareInsets];
		} else if ([keyPath isEqualToString:@"imageView.image"]) {
			[self prepareInsets];
		}
	}
}

@end
