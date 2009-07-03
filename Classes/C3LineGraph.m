//
//  C3LineGraph.m
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "C3LineGraph.h"
#import "CATextLayer.h"

@interface C3LineGraphView ()
@property (retain) CALayer *xAxis;
@property (retain) CALayer *yAxis;
@property (retain) CALayer *gridLines;
@property (retain) CALayer *dataLines;
-(void)animateIntoPlace;
-(NSArray*)gridLines:(NSString*)axisName;
@end


@implementation C3LineGraphView
-(void)awakeFromNib
{

}
@synthesize dataSource, delegate;
@synthesize xAxis, yAxis, gridLines, dataLines;
-(void)setXAxis:(CALayer*)xAxis_; {
	if(xAxis == xAxis_) return;
	[self.layer addSublayer:xAxis_];
	[xAxis removeFromSuperlayer];
	xAxis = xAxis_;
}
-(void)setYAxis:(CALayer*)yAxis_; {
	if(yAxis == yAxis_) return;
	[self.layer addSublayer:yAxis_];
	[yAxis removeFromSuperlayer];
	yAxis = yAxis_;
}
-(void)setGridLines:(CALayer*)gridLines_; {
	if(gridLines == gridLines_) return;
	[self.layer addSublayer:gridLines_];
	[gridLines removeFromSuperlayer];
	gridLines = gridLines_;
}
-(void)setDataLines:(CALayer*)dataLines_; {
	if(dataLines == dataLines_) return;
	[self.layer addSublayer:dataLines_];
	[dataLines removeFromSuperlayer];
	dataLines = dataLines_;
}


- (void)setNumberOfTickMarks:(NSInteger)count forAxis:(C3GraphAxisEnum)inAxis;
{
	tickMarkCount[inAxis] = count;
}
- (NSInteger)numberOfTickMarksForAxis:(C3GraphAxisEnum)inAxis;
{
	return tickMarkCount[inAxis];
}
- (void)setNumberOfMinorTickMarks:(NSInteger)count forAxis:(C3GraphAxisEnum)inAxis;
{
	minorTickMarkCount[inAxis] = count;
}
- (NSInteger)numberOfMinorTickMarksForAxis:(C3GraphAxisEnum)inAxis;
{
	return minorTickMarkCount[inAxis];
}


-(NSRange)xRange:(int)i;
{
	CGFloat minx, maxx;
	minx = [dataSource twoDGraphView:self minimumValueForLineIndex:i forAxis:kC3Graph_Axis_X];
	maxx = [dataSource twoDGraphView:self maximumValueForLineIndex:i forAxis:kC3Graph_Axis_X];
	return NSMakeRange(minx, maxx-minx);
}
-(NSRange)xRange;
{
	int lineCount = [dataSource numberOfLinesInTwoDGraphView:self];
	CGFloat minx = INT_MAX, maxx = INT_MIN;
	
	for(int i = 0; i < lineCount; i++)
		minx = MIN(minx, [dataSource twoDGraphView:self minimumValueForLineIndex:i forAxis:kC3Graph_Axis_X]);
	for(int i = 0; i < lineCount; i++)
		maxx = MAX(maxx, [dataSource twoDGraphView:self maximumValueForLineIndex:i forAxis:kC3Graph_Axis_X]);
	
	return NSMakeRange(minx, maxx-minx);
}
-(NSRange)yRange;
{
	int lineCount = [dataSource numberOfLinesInTwoDGraphView:self];
	CGFloat miny = INT_MAX, maxy = INT_MIN;
	
	for(int i = 0; i < lineCount; i++)
		miny = MIN(miny, [dataSource twoDGraphView:self minimumValueForLineIndex:i forAxis:kC3Graph_Axis_Y]);
	for(int i = 0; i < lineCount; i++)
		maxy = MAX(maxy, [dataSource twoDGraphView:self maximumValueForLineIndex:i forAxis:kC3Graph_Axis_Y]);
	return NSMakeRange(miny, maxy-miny);
}

-(void)relayout;
{
	// Clear out any previous layout. Preferably, we would transition to the new
	// settings instead of just ripping out all the old an putting new stuff in
	// there, but that's for another time, when there is time to be had.
	self.xAxis = self.yAxis = self.gridLines = self.dataLines = nil;
	
	
	// Setup the container layers
	
	// gridLines
	CGRect pen = self.frame;
	self.gridLines = [CALayer layer];
	pen.origin = CGPointMake(0, 0);
	self.gridLines.frame = self.frame;
	
	// dataLines
	self.dataLines = [CALayer layer];
	self.gridLines.frame = self.frame;

	
	// xAxis
	pen.size.height = 40;
	pen.origin.y = self.frame.size.height-pen.size.height;
	self.xAxis = [CALayer layer];
	self.xAxis.opacity = 0.8;
	self.xAxis.frame = pen;
	self.xAxis.backgroundColor = [UIColor redColor].CGColor;
	
	// yAxis
	self.yAxis = [CALayer layer];
	self.yAxis.masksToBounds = YES;
	self.yAxis.opacity = 0.6;
	pen = self.frame;
	pen.size.width = 40;
	pen.origin.y = 0;
	self.yAxis.frame = pen;
	self.yAxis.backgroundColor = [UIColor greenColor].CGColor;
	
	
	
	// Figure out our min and max values
	int lineCount = [dataSource numberOfLinesInTwoDGraphView:self];
	float minx = INT_MAX, miny = INT_MAX, maxx = INT_MIN, maxy = INT_MIN;
	NSRange xRange = [self xRange];
	minx = xRange.location;
	maxx = xRange.location + xRange.length;

	NSRange yRange = [self yRange];
	miny = yRange.location;
	maxy = miny + yRange.length;
	
	// Add labels and grid lines along x axis
	float stepx = (maxx-minx)/tickMarkCount[kC3Graph_Axis_X];
	BOOL doFetchLabels = [delegate respondsToSelector:@selector(twoDGraphView:labelForTickMarkIndex:forAxis:defaultLabel:)];
	
	float margin = 5;
	float widthPerLabel = (self.frame.size.width - margin*2)/tickMarkCount[kC3Graph_Axis_X] - margin;
	pen = CGRectMake(10, 10, widthPerLabel, 20);
	
	
	for(int i = 0; i < tickMarkCount[kC3Graph_Axis_X]; i++) {
		float val = minx + stepx*i;
		NSString *tickLabel = doFetchLabels ? [delegate twoDGraphView:self
														labelForTickMarkIndex:i
																					forAxis:kC3Graph_Axis_X
																		 defaultLabel:val] : [NSString stringWithFormat:@"%.2f", val];

		CATextLayer *l = [CATextLayer layerWithString:tickLabel];
		l.frame = pen;
		l.lineBreakMode = UILineBreakModeClip;
		l.alignmentMode = UITextAlignmentCenter;
		
		pen.origin.x += widthPerLabel + margin;
		
		CGFloat lineO = pen.origin.x;
		lineO -= pen.size.width/2;
		CAShapeLayer *lg = [CAShapeLayer layer];
		CGMutablePathRef pa = CGPathCreateMutable();
		CGPathMoveToPoint(pa, NULL, lineO, 0);
		CGPathAddLineToPoint(pa, NULL, lineO, self.frame.size.height);
		lg.path = pa;
		CGPathRelease(pa);
		lg.strokeColor = [UIColor colorWithHue:0 saturation:0 brightness:0.8 alpha:1.0].CGColor;
		[lg setName:[NSString stringWithFormat:@"XAxis %f", lineO]];
		
		[self.xAxis addSublayer:l];
		[self.gridLines addSublayer:lg];
	}
	
	
	// Add labels and gridlines along y axis
	float stepy = (maxy-miny)/tickMarkCount[kC3Graph_Axis_Y];
	float heightPerLabel = (self.frame.size.height - 40 - margin*2)/tickMarkCount[kC3Graph_Axis_Y] - margin;
	
	pen = CGRectMake(5, self.frame.size.height-30 - 40, 30, 20);
	
	for(int i = 0; i < tickMarkCount[kC3Graph_Axis_Y]; i++) {
		float val = miny + stepy*i;
		NSString *tickLabel = doFetchLabels ? [delegate twoDGraphView:self
																						labelForTickMarkIndex:i
																													forAxis:kC3Graph_Axis_Y
																										 defaultLabel:val] : [NSString stringWithFormat:@"%.2f", val];
		
		CATextLayer *l = [CATextLayer layerWithString:tickLabel];
		l.frame = pen;
		l.lineBreakMode = UILineBreakModeClip;
		l.alignmentMode = UITextAlignmentCenter;
		l.foregroundColor = [UIColor blackColor].CGColor;
		
		
		CGFloat lineO = pen.origin.y;
		lineO += pen.size.height/2 + 0.5 - 2;
		CAShapeLayer *lg = [CAShapeLayer layer];
		CGMutablePathRef pa = CGPathCreateMutable();
		CGPathMoveToPoint(pa, NULL, 0, lineO);
		CGPathAddLineToPoint(pa, NULL, self.frame.size.width, lineO);
		lg.path = pa;
		CGPathRelease(pa);
		lg.strokeColor = [UIColor colorWithHue:0 saturation:0 brightness:0.9 alpha:1.0].CGColor;
		[lg setName:[NSString stringWithFormat:@"YAxis %f", lineO]];
		
		
		pen.origin.y -= heightPerLabel + margin;
		
		[self.yAxis addSublayer:l];
		[self.gridLines addSublayer:lg];
	}
	
	[self reloadData];
	
	
	[self animateIntoPlace];
}
-(void)reloadData;
{
	BOOL wantsCustomization = [delegate respondsToSelector:@selector(twoDGraphView:customizeLine:withIndex:)];
	
	NSUInteger lineCount = [dataSource numberOfLinesInTwoDGraphView:self];
	for(int i = self.dataLines.sublayers.count; i < lineCount; i++) {
		CAShapeLayer *l = [CAShapeLayer layer];
		[self.dataLines addSublayer:l];
		if(wantsCustomization)
			[delegate twoDGraphView:self customizeLine:l withIndex:i];
	}
		
	for(int i = lineCount; i < self.dataLines.sublayers.count; i++)
		[[self.dataLines.sublayers objectAtIndex:i] removeFromSuperlayer];
	
	NSRange y = [self yRange];
	NSRange x = [self xRange];
	
	for (int i = 0; i < lineCount; i++) {
		NSArray *values = [dataSource twoDGraphView:self dataForLineIndex:i];
		
		CGPathRef path = CGPathCreateMutable();
		BOOL first = YES;
		for (NSValue *coordVal in values) {
			CGPoint p = coordVal.CGPointValue;
			p.x += x.location;
			p.y += y.location;
			p.x /= x.length;
			p.y /= y.length;
			p.x *= self.dataLines.frame.size.width;
			p.y *= self.dataLines.frame.size.height;
			if(first) {
				CGPathMoveToPoint(path, NULL, p.x, p.y);
				first = NO;
			} else
				CGPathAddLineToPoint(path, NULL, p.x, p.y);
		}
		
		CAShapeLayer *lineLayer = [[self.dataLines sublayers] objectAtIndex:i];
		lineLayer.path = path;
	}
	
}

-(void)animateIntoPlace;
{
	for (CALayer *label in self.xAxis.sublayers) {
		label.opacity = 0.0;
	}
	for (CALayer *label in self.yAxis.sublayers) {
		label.opacity = 0.0;
	}
	CGRect xAxisOldFrame = self.xAxis.frame;
	xAxisOldFrame.size.width = 0;
	self.xAxis.frame = xAxisOldFrame;
	
	CGRect yAxisOldFrame = self.yAxis.frame;
	yAxisOldFrame.size.width = 0;
	self.yAxis.frame = yAxisOldFrame;
	
	for(CALayer *line in self.gridLines.sublayers) {
		line.opacity = 0.0;
	}
	
	[self performSelector:@selector(animate2) withObject:nil afterDelay:0.0];
}
-(void)animate2;
{
	float animationDuration = 1.0;
	int labelCount = self.xAxis.sublayers.count;
	float labelStep = animationDuration/labelCount;
	float clock = 0.0;
	for(int i = 0; i < tickMarkCount[kC3Graph_Axis_X]; i++) {
		CALayer *label = [self.xAxis.sublayers objectAtIndex:i];
		CALayer *line = [[self gridLines:@"XAxis"] objectAtIndex:i];
		
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.beginTime = CACurrentMediaTime()+clock;
		anim.duration = labelStep + 0.3;
		anim.fromValue = [NSNumber numberWithFloat:0.0];
		anim.toValue = [NSNumber numberWithFloat:1.0];
		anim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];

		[self performSelector:@selector(labelAnimEnd:) withObject:label afterDelay:clock + anim.duration -0.02];
		[self performSelector:@selector(labelAnimEnd:) withObject:line  afterDelay:clock + anim.duration -0.02];
		
		clock += labelStep;
		[label addAnimation:anim forKey:@"fadeIn"];
		[line addAnimation:anim forKey:@"fadeIn"];
	}
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:animationDuration]
									 forKey:kCATransactionAnimationDuration];
	
	CGRect xAxisNewFrame = self.xAxis.frame;
	xAxisNewFrame.size.width = self.frame.size.width;
	self.xAxis.frame = xAxisNewFrame;
	
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:animationDuration*0.5]
									 forKey:kCATransactionAnimationDuration];
	
	CGRect yAxisNewFrame = self.yAxis.frame;
	yAxisNewFrame.size.width = 40;
	self.yAxis.frame = yAxisNewFrame;
	
	for (CALayer *label in self.yAxis.sublayers) {
		label.opacity = 1.0;
	}
	
	
	[CATransaction commit];

	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:animationDuration]
									 forKey:kCATransactionAnimationDuration];
	
	for (CALayer *line in [self gridLines:@"YAxis"]) {
		line.opacity = 1.0;
	}	

	[CATransaction commit];

}
-(void)labelAnimEnd:(CALayer*)lay;
{
	lay.opacity = 1.0;
}


-(NSArray*)gridLines:(NSString*)axisName;
{
	NSMutableArray *lines = [NSMutableArray array];
	for (CALayer *lay in gridLines.sublayers) {
		if(lay.name && [lay.name hasPrefix:axisName])
			[lines addObject:lay];
	}
	return lines;
}

@end










