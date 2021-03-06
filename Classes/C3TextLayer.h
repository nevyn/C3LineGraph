//
//  CATextLayer.h
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-03.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
	C3VerticalTextAlignmentTop = 0,
	C3VerticalTextAlignmentCenter,
	C3VerticalTextAlignmentBottom,
} C3VerticalTextAlignment;

@interface C3TextLayer : CALayer {
	NSString *string;
	UIFont *font;
	CGColorRef foregroundColor;
	UILineBreakMode lineBreakMode;
	UITextAlignment alignmentMode;
	C3VerticalTextAlignment verticalAlignmentMode;
}
+(id)layerWithString:(NSString*)string_;
-(id)initWithString:(NSString*)string_;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) CGColorRef foregroundColor;
@property (nonatomic, assign) UILineBreakMode lineBreakMode;
@property (nonatomic, assign) UITextAlignment alignmentMode;
@property (nonatomic, assign) C3VerticalTextAlignment verticalAlignmentMode;
@end
