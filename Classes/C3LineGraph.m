//
//  C3LineGraph.m
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "C3LineGraph.h"
#import "C3TextLayer.h"

@interface C3LineGraphView ()
@property (retain) CALayer *xAxis;
@property (retain) CALayer *yAxis;
@property (retain) CALayer *gridLines;
@property (retain) CALayer *dataLines;
@property (retain) CAGradientLayer *background;
@property (retain) CALayer *legend;
-(void)animateIntoPlace;
-(NSArray*)gridLines:(NSString*)axisName;
@end


@implementation C3LineGraphView
-(void)dealloc;
{
	self.gridColor = nil;
	[super dealloc];
}
@synthesize dataSource, delegate;
@synthesize xAxis, yAxis, gridLines, dataLines, background, legend;
#define layerSetter(UName, lName) \
-(void)set##UName:(id)newArg; { \
  if(lName == newArg) return; \
  [self.layer addSublayer:newArg]; \
  [lName removeFromSuperlayer]; \
   lName = newArg; \
}
layerSetter(XAxis, xAxis);
layerSetter(YAxis, yAxis);
layerSetter(GridLines, gridLines);
layerSetter(DataLines, dataLines);
layerSetter(Background, background);
layerSetter(Legend, legend);



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

@synthesize gridColor;

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
-(NSArray*)xLabels;
{
	NSMutableArray *labels = [NSMutableArray array];
	for (CALayer *l in self.xAxis.sublayers) {
		if(l == xGrad) continue;
		[labels addObject:l];
	}
	return labels;
}

static float sidebarSize = 40;
-(void)relayout;
{
	// Clear out any previous layout. Preferably, we would transition to the new
	// settings instead of just ripping out all the old an putting new stuff in
	// there, but that's for another time, when there is time to be had.
	self.legend = self.background = self.xAxis = self.yAxis = self.gridLines = self.dataLines = nil;
	
	if(!gridColor)
		self.gridColor = [UIColor colorWithHue:0.580 saturation:0.05 brightness:0.49 alpha:0.3];
	
	// Setup the container layers
	
	CGRect pen = self.frame;
	pen.origin = CGPointMake(0, 0);

	self.background = [CAGradientLayer layer];
	self.background.frame = pen;
	self.background.colors = [NSArray arrayWithObjects:
														(id)[UIColor colorWithHue:0.580 saturation:0.01 brightness:1.0 alpha:1.0].CGColor,
														(id)[UIColor colorWithHue:0.580 saturation:0.01 brightness:0.94 alpha:1.0].CGColor,
														nil];
	
	// gridLines
	self.gridLines = [CALayer layer];
	self.gridLines.frame = self.frame;
	
	// dataLines
	self.dataLines = [CALayer layer];
	pen.size.height -= sidebarSize;
	self.dataLines.frame = pen;
	self.dataLines.masksToBounds = YES;

	pen = self.frame;
	
	// xAxis
	pen.size.height = sidebarSize;
	pen.origin.y = self.frame.size.height-pen.size.height;
	self.xAxis = [CALayer layer];
	self.xAxis.opacity = 0.8;
	self.xAxis.frame = pen;
	self.xAxis.backgroundColor = [UIColor colorWithHue:0.580 saturation:0.15 brightness:0.65 alpha:1.0].CGColor;
	self.xAxis.masksToBounds = YES;
	
	// xAxis gradient
	xGrad = [CAGradientLayer layer];
	xGrad.colors = [NSArray	arrayWithObjects:
										(id)[UIColor colorWithWhite:1.0 alpha:0.55].CGColor,
										(id)[UIColor colorWithWhite:1.0 alpha:0.06].CGColor,
									nil];
	xGrad.frame = CGRectMake(0, 0, self.xAxis.frame.size.width, self.xAxis.frame.size.height);
	[self.xAxis addSublayer:xGrad];
	
	// yAxis
	self.yAxis = [CALayer layer];
	self.yAxis.masksToBounds = YES;
	self.yAxis.opacity = 0.8;
	pen = self.frame;
	pen.size.width = sidebarSize;
	pen.origin.y = 0;
	self.yAxis.frame = pen;
	self.yAxis.backgroundColor = self.xAxis.backgroundColor;
	
	// legend
	self.legend = [CALayer layer];
	CGFloat legendWidth = 130;
	self.legend.cornerRadius = 10.0;
	//self.legend.borderWidth = 2.0;
	//self.legend.backgroundColor = [UIColor colorWithHue:0.580 saturation:0.25 brightness:0.75 alpha:0.4].CGColor;
	//self.legend.borderColor = [UIColor colorWithHue:0.580 saturation:0.35 brightness:0.55 alpha:0.3].CGColor;
	self.legend.frame = CGRectMake(self.bounds.size.width-legendWidth-10, 14, legendWidth, 20);
	
	// Figure out our min and max values
	float minx, miny, maxx, maxy;
	NSRange xRange = [self xRange];
	minx = xRange.location;
	maxx = xRange.location + xRange.length;

	NSRange yRange = [self yRange];
	miny = yRange.location;
	maxy = miny + yRange.length;
	
	// Add labels and grid lines along x axis
	float stepx = (maxx-minx)/tickMarkCount[kC3Graph_Axis_X];
	BOOL doFetchLabels = [delegate respondsToSelector:@selector(twoDGraphView:labelForTickMarkIndex:forAxis:defaultLabel:)];
	
	float widthPerLabel = self.frame.size.width/tickMarkCount[kC3Graph_Axis_X];
	pen = CGRectMake(0, 0, widthPerLabel, sidebarSize);
	
	
	for(int i = 0; i < tickMarkCount[kC3Graph_Axis_X]+1; i++) {
		float val = minx + stepx*i;
		NSString *tickLabel = doFetchLabels ? [delegate twoDGraphView:self
														labelForTickMarkIndex:i
																					forAxis:kC3Graph_Axis_X
																		 defaultLabel:val] : [NSString stringWithFormat:@"%.2f", val];

		C3TextLayer *l = [C3TextLayer layerWithString:tickLabel];
		CGRect pen2 = pen;
		pen2.origin.x -= pen.size.width/2;
		l.frame = pen2;
		l.lineBreakMode = UILineBreakModeClip;
		l.alignmentMode = UITextAlignmentCenter;
		l.verticalAlignmentMode = C3VerticalTextAlignmentCenter;

		
		CGFloat x = (int)(pen.origin.x)+0.5; // Center on a pixel
		CAShapeLayer *lg = [CAShapeLayer layer];
		CGMutablePathRef pa = CGPathCreateMutable();
		CGPathMoveToPoint(pa, NULL, x, 0);
		CGPathAddLineToPoint(pa, NULL, x, self.frame.size.height);
		lg.path = pa;
		CGPathRelease(pa);
		lg.strokeColor = gridColor.CGColor;
		[lg setName:[NSString stringWithFormat:@"XAxis %f", pen.origin.x]];
		
		
		pen.origin.x += widthPerLabel;


		[self.xAxis insertSublayer:l below:xGrad];
		[self.gridLines addSublayer:lg];
	}
	
	
	// Add labels and gridlines along y axis
	float stepy = (maxy-miny)/tickMarkCount[kC3Graph_Axis_Y];
	float heightPerLabel = (self.frame.size.height - sidebarSize)/tickMarkCount[kC3Graph_Axis_Y];
	
	pen = CGRectMake(5, self.frame.size.height - sidebarSize, 30, heightPerLabel);
	
	for(int i = 0; i < tickMarkCount[kC3Graph_Axis_Y]+1; i++) {
		float val = miny + stepy*i;
		NSString *tickLabel = doFetchLabels ? [delegate twoDGraphView:self
																						labelForTickMarkIndex:i
																													forAxis:kC3Graph_Axis_Y
																										 defaultLabel:val] : [NSString stringWithFormat:@"%.2f", val];
		CGRect pen2 = pen;
		pen2.origin.y -= heightPerLabel/2.;
		C3TextLayer *l = [C3TextLayer layerWithString:tickLabel];
		l.frame = pen2;
		l.lineBreakMode = UILineBreakModeClip;
		l.alignmentMode = UITextAlignmentCenter;
		l.verticalAlignmentMode = C3VerticalTextAlignmentCenter;
		
		
		CGFloat y = (int)(pen.origin.y)+0.5; // Center on a pixel
		CAShapeLayer *lg = [CAShapeLayer layer];
		CGMutablePathRef pa = CGPathCreateMutable();
		CGPathMoveToPoint(pa, NULL, 0, y);
		CGPathAddLineToPoint(pa, NULL, self.frame.size.width, y);
		lg.path = pa;
		CGPathRelease(pa);
		lg.strokeColor = gridColor.CGColor;
		[lg setName:[NSString stringWithFormat:@"YAxis %f", pen.origin.y]];
		
		
		pen.origin.y -= heightPerLabel;
		
		// Don't add the last label as it'll be obscured anyway
		if(i != tickMarkCount[kC3Graph_Axis_Y])
			[self.yAxis addSublayer:l];
		[self.gridLines addSublayer:lg];
	}
	
	[self reloadData];
	
	
	[self animateIntoPlace];
}
#define frand() (rand()%1000)/1000.0
-(void)reloadData;
{
	BOOL wantsCustomization = [delegate respondsToSelector:@selector(twoDGraphView:customizeLine:withIndex:)];
	BOOL wantsLabel = [delegate respondsToSelector:@selector(twoDGraphView:labelForLineIndex:)];
	
	NSUInteger labelCount = self.legend.sublayers.count/2;
	NSUInteger lineCount = [dataSource numberOfLinesInTwoDGraphView:self];
	for(int i = self.dataLines.sublayers.count; i < lineCount; i++) {
		CAShapeLayer *l = [CAShapeLayer layer];
		l.fillColor = nil;
		l.strokeColor = [UIColor colorWithRed:frand() green:frand() blue:frand() alpha:1.0].CGColor;
		l.lineWidth = 4.0;
		l.lineJoin = kCALineJoinRound;
		l.lineCap = kCALineCapRound;
		[self.dataLines addSublayer:l];
		if(wantsCustomization)
			[delegate twoDGraphView:self customizeLine:l withIndex:i];
		
		NSString *labelString;
		if(wantsLabel)
			labelString = [delegate twoDGraphView:self labelForLineIndex:i];
		if(wantsLabel && labelString) {
			CGFloat atHeight = [self.legend.sublayers lastObject]?[(CALayer*)[self.legend.sublayers lastObject] frame].origin.y + 16 : 6;
			
			CAShapeLayer *plutt = [CAShapeLayer layer];
			plutt.fillColor = nil;
			plutt.strokeColor = l.strokeColor;
			plutt.lineWidth = 4.0;
			plutt.lineCap = kCALineCapRound;
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathMoveToPoint(path, NULL, 0, 7.5);
			CGPathAddLineToPoint(path, NULL, 10, 7.5);
			plutt.path = path;
			plutt.frame = CGRectMake(self.legend.frame.size.width-20, atHeight, 10, 15);

			[self.legend addSublayer:plutt];
			labelCount++;
			
			C3TextLayer *label = [C3TextLayer layerWithString:labelString];
			label.frame = CGRectMake(5, atHeight, self.legend.frame.size.width-30, 15);
			label.alignmentMode = UITextAlignmentRight;
			label.verticalAlignmentMode = C3VerticalTextAlignmentCenter;
			label.foregroundColor = [UIColor colorWithHue:0.580 saturation:0.35 brightness:0.55 alpha:1.0].CGColor;

			label.font = [UIFont systemFontOfSize:11];
			[self.legend addSublayer:label];
			
		}
	}
	
#undef frand
	
	CGRect r = self.legend.frame;
	r.size.height = 15*(labelCount) + 12;
	self.legend.frame = r;
		
	for(int i = lineCount; i < self.dataLines.sublayers.count; i++)
		[[self.dataLines.sublayers objectAtIndex:i] removeFromSuperlayer];
	
	
	
	NSRange y = [self yRange];
	NSRange x = [self xRange];
	
	for (int i = 0; i < lineCount; i++) {
		NSArray *values = [dataSource twoDGraphView:self dataForLineIndex:i];
		
		CGMutablePathRef path = CGPathCreateMutable();
		BOOL first = YES;
		for (NSValue *coordVal in values) {
			CGPoint p = coordVal.CGPointValue;
			p.x -= x.location;
			p.y -= y.location;
			p.x /= x.length;
			p.y /= y.length;
			p.y = 1.0 - p.y;
			p.x *= self.dataLines.frame.size.width;
			p.y *= self.dataLines.frame.size.height;
			if(first) {
				CGPathMoveToPoint(path, NULL, p.x, p.y);
				first = NO;
			} else {
				CGPathAddLineToPoint(path, NULL, p.x, p.y);
				CGPathAddEllipseInRect(path, NULL, CGRectMake(p.x-2, p.y-2, 4, 4));
				CGPathMoveToPoint(path, NULL, p.x, p.y);
			}
				
		}
		
		CAShapeLayer *lineLayer = [[self.dataLines sublayers] objectAtIndex:i];
		lineLayer.path = path;
	}
	
}

-(void)animateIntoPlace;
{
	for (CALayer *label in self.xLabels) {
		label.opacity = 0.0;
	}
	for (CALayer *label in self.yAxis.sublayers) {
		label.opacity = 0.0;
	}
	CGRect xAxisOldFrame = self.xAxis.frame;
	xAxisOldFrame.size.width = 0;
	self.xAxis.frame = xAxisOldFrame;
	
	CGRect dataLinesOldFrame = self.dataLines.frame;
	dataLinesOldFrame.size.width = 0;
	self.dataLines.frame = dataLinesOldFrame;
	
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
	int labelCount = self.xLabels.count;
	float labelStep = animationDuration/labelCount;
	float clock = 0.0;
	for(int i = 0; i < tickMarkCount[kC3Graph_Axis_X]; i++) {
		CALayer *label = [self.xLabels objectAtIndex:i];
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
	
	CGRect dataLinesNewFrame = self.dataLines.frame;
	dataLinesNewFrame.size.width = self.frame.size.width;
	self.dataLines.frame = dataLinesNewFrame;
	
	
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:animationDuration*0.5]
									 forKey:kCATransactionAnimationDuration];
	
	CGRect yAxisNewFrame = self.yAxis.frame;
	yAxisNewFrame.size.width = sidebarSize;
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










