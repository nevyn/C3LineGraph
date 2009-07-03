//
//  CATextLayer.m
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-03.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "CATextLayer.h"


@implementation CATextLayer
@synthesize string, font, foregroundColor, alignmentMode, lineBreakMode;
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
	pen.origin = CGPointMake(0, 0);
		
	[string drawInRect:pen withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.alignmentMode ];
	UIGraphicsPopContext();
}
@end
