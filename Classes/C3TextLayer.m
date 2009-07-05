//
//  CATextLayer.m
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-03.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "C3TextLayer.h"


@implementation C3TextLayer
@synthesize string, font, foregroundColor, alignmentMode, lineBreakMode, verticalAlignmentMode;
-(void)setString:(NSString *)string_;
{
	[string release];
	string = [string_ copy];
	[self setNeedsDisplay];
}
-(void)setFont:(UIFont *)font_;
{
	[font_ retain];
	[font release];
	font = font_;
	[self setNeedsDisplay];
}
-(void)setForegroundColor:(CGColorRef)foregroundColor_;
{
	CGColorRetain(foregroundColor_);
	CGColorRelease(foregroundColor);
	foregroundColor = foregroundColor_;
	[self setNeedsDisplay];
}
-(void)setAlignmentMode:(UITextAlignment)alignmentMode_;
{
	alignmentMode = alignmentMode_;
	[self setNeedsDisplay];
}
-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode_;
{
	lineBreakMode = lineBreakMode_;
	[self setNeedsDisplay];
}
-(void)setVerticalAlignmentMode:(C3VerticalTextAlignment)verticalAlignmentMode_;
{
	verticalAlignmentMode = verticalAlignmentMode_;
	[self setNeedsDisplay];
}


+(id)layerWithString:(NSString*)string_;
{
	return [[[[self class] alloc] initWithString:string_] autorelease];
}
-(id)initWithString:(NSString*)string_;
{
	if( ! [super init] ) return nil;
	self.string = string_;
	
	self.font = [UIFont systemFontOfSize:12];
	self.foregroundColor = [UIColor whiteColor].CGColor;
	
	return self;
}
-(void)dealloc;
{
	self.string = self.font = self.foregroundColor = nil;
	[super dealloc];
}
- (void)drawInContext:(CGContextRef)ctx;
{
	UIGraphicsPushContext(ctx);
	
	CGContextSetFillColorWithColor(ctx, self.foregroundColor);
	
	CGRect pen = self.bounds;
	if(verticalAlignmentMode == C3VerticalTextAlignmentTop) {
		pen.origin = CGPointMake(0, 0);		
	} else if (verticalAlignmentMode == C3VerticalTextAlignmentCenter) {
		CGSize size = [string sizeWithFont:self.font forWidth:pen.size.width lineBreakMode:self.lineBreakMode];
		pen.origin.x = 0;
		pen.origin.y = pen.size.height/2 - size.height/2;
	} else {
		[NSException raise:@"NSNotImplementedException" format:@"C3VerticalTextAlignmentBottom not implemented"];
	}

		
	[string drawInRect:pen withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.alignmentMode ];
	UIGraphicsPopContext();
}
@end
