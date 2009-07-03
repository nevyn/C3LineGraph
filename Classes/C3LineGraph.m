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
-(void)animateIntoPlace;
@end


@implementation C3LineGraphView
-(void)awakeFromNib
{

}
@synthesize dataSource, delegate;
@synthesize xAxis, yAxis;
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


-(void)relayout;
{
	CGRect pen = self.frame;
	pen.size.height = 40;
	pen.origin.y = self.frame.size.height-pen.size.height;
	self.xAxis = [CALayer layer];
	self.xAxis.frame = pen;
	self.xAxis.backgroundColor = [UIColor redColor].CGColor;
	
	
	self.yAxis = [CALayer layer];
	self.yAxis.opacity = 0.6;
	pen = self.frame;
	pen.size.width = 40;
	pen.origin.y = 0;
	self.yAxis.frame = pen;
	self.yAxis.backgroundColor = [UIColor greenColor].CGColor;
	
	int lineCount = [dataSource numberOfLinesInTwoDGraphView:self];
	float minx = INT_MAX, miny = INT_MAX, maxx = INT_MIN, maxy = INT_MIN;
	for(int i = 0; i < lineCount; i++)
		minx = MIN(minx, [dataSource twoDGraphView:self minimumValueForLineIndex:i forAxis:kC3Graph_Axis_X]);
	for(int i = 0; i < lineCount; i++)
		maxx = MAX(maxx, [dataSource twoDGraphView:self maximumValueForLineIndex:i forAxis:kC3Graph_Axis_X]);
	for(int i = 0; i < lineCount; i++)
		miny = MIN(miny, [dataSource twoDGraphView:self minimumValueForLineIndex:i forAxis:kC3Graph_Axis_Y]);
	for(int i = 0; i < lineCount; i++)
		maxy = MAX(maxy, [dataSource twoDGraphView:self maximumValueForLineIndex:i forAxis:kC3Graph_Axis_Y]);
	
	
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
		[self.xAxis addSublayer:l];
	}
	if(!hasAnimated)
		[self animateIntoPlace];
}
-(void)reloadData;
{
	
}

-(void)animateIntoPlace;
{
	for (CALayer *label in self.xAxis.sublayers) {
		label.opacity = 0.0;
	}
	CGRect xAxisOldFrame = self.xAxis.frame;
	xAxisOldFrame.size.width = 0;
	self.xAxis.frame = xAxisOldFrame;
	
	CGRect yAxisOldFrame = self.yAxis.frame;
	yAxisOldFrame.size.width = 0;
	self.yAxis.frame = yAxisOldFrame;
	
	
	
	[self performSelector:@selector(animate2) withObject:nil afterDelay:0.0];
}
-(void)animate2;
{
	float animationDuration = 1.0;
	int labelCount = self.xAxis.sublayers.count;
	float labelStep = animationDuration/labelCount;
	float clock = 0.0;
	for (CALayer *label in self.xAxis.sublayers) {
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		anim.beginTime = CACurrentMediaTime()+clock;
		anim.duration = labelStep + 0.3;
		anim.fromValue = [NSNumber numberWithFloat:0.0];
		anim.toValue = [NSNumber numberWithFloat:1.0];
		anim.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
		[self performSelector:@selector(labelAnimEnd:) withObject:label afterDelay:clock + anim.duration -0.02];
		clock += labelStep;
		[label addAnimation:anim forKey:@"fadeIn"];
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
	
	
	[CATransaction commit];


}
-(void)labelAnimEnd:(CALayer*)lay;
{
	lay.opacity = 1.0;
}

@end
