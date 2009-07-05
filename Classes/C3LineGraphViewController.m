//
//  C3LineGraphViewController.m
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "C3LineGraphViewController.h"

@interface DataPoint : NSObject
{
	NSDate *when;
	int ident;
	int score;
}
+:when_ :(int)score_ :(int)ident;
@property (retain) NSDate *when;
@property (assign) int ident;
@property (assign) int score;
@end
@implementation DataPoint
@synthesize when, ident, score;
+:when_ :(int)score_ :(int)ident_;
{
	DataPoint *p = [[[DataPoint alloc] init] autorelease];
	p.when = when_; p.ident = ident_; p.score = score_;
	return p;
}
-(void)dealloc; {
	self.when = nil;
	[super dealloc];
}
@end


@implementation C3LineGraphViewController

#define daysfromnow(i) [NSDate dateWithTimeIntervalSinceNow:-i*60*60*24]

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

	data[EveryQuiz] = [[NSArray alloc] initWithObjects:
										 [DataPoint :daysfromnow(30) :4 :0],
										 [DataPoint :daysfromnow(30) :6 :1],
										 [DataPoint :daysfromnow(30) :9 :2],
										 [DataPoint :daysfromnow(30) :2 :3],
										 [DataPoint :daysfromnow(15) :12 :4],
										 [DataPoint :daysfromnow(14) :16 :5],
										 [DataPoint :daysfromnow(8) :9 :6],
										 [DataPoint :daysfromnow(1) :10 :7],
										 [DataPoint :daysfromnow(0) :9 :8],
										nil];
	data[MyAverage] = [[NSArray alloc] initWithObjects:
										 [DataPoint :[NSDate distantPast] :8.55 :-1],
										 [DataPoint :[NSDate distantFuture]  :8.55 :9],
										nil];
	data[WorldAverage] = [[NSArray alloc] initWithObjects:
												[DataPoint :[NSDate distantPast] :7.2 :-1],
												[DataPoint :[NSDate distantFuture] :7.2 :9],
											nil];

	[graph setNumberOfTickMarks:5 forAxis:kC3Graph_Axis_X];
	[graph setNumberOfTickMarks:9 forAxis:kC3Graph_Axis_Y];
	
	[graph relayout];
	
}
#undef daysfromnow
-(void)dealloc;
{
	[data[EveryQuiz] release];
	[data[MyAverage] release];
	[data[WorldAverage] release];
	[super dealloc];
}


#pragma mark
#pragma mark Graph callbacks
- (NSUInteger)numberOfLinesInTwoDGraphView:(C3LineGraphView *)inGraphView;
{
	return 3;
}
- (NSArray *)twoDGraphView:(C3LineGraphView *)inGraphView dataForLineIndex:(NSUInteger)inLineIndex;
{
	NSMutableArray *ma = [NSMutableArray array];
	for (DataPoint *p in data[inLineIndex])
		[ma addObject:[NSValue valueWithCGPoint:CGPointMake(p.ident, p.score)]];
	
	return ma;
}

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView
maximumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
{
	if(inAxis == kC3Graph_Axis_X)
		return [[data[EveryQuiz] lastObject] ident];
	return 18;
}

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView
minimumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
{
	if(inAxis == kC3Graph_Axis_X)
		return [[data[EveryQuiz] objectAtIndex:0] ident];
	return 0;
}

- (NSString *)twoDGraphView:(C3LineGraphView *)inGraphView
			labelForTickMarkIndex:(NSUInteger)inTickMarkIndex
										forAxis:(C3GraphAxisEnum)inAxis
							 defaultLabel:(float)inVal;
{
	if(inAxis == kC3Graph_Axis_X) {
		// This won't work if the DataPoint doesn't have the same ident as its index
		// in the data array.
		
		DataPoint *p = [data[EveryQuiz] objectAtIndex:inVal];
		NSDate *date = p.when;
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateFormat:@"d MMMM"];
	
		return [formatter stringFromDate:date];
	} else {
		return [NSString stringWithFormat:@"%d", (int)inVal];
	}

}
-(void)twoDGraphView:(C3LineGraphView *)inGraphView
			 customizeLine: (CAShapeLayer*)lineLayer
					 withIndex:(NSUInteger)inLineIndex;
{
	if(inLineIndex == 0) lineLayer.strokeColor = [UIColor colorWithHue:0.300 saturation:0.15 brightness:0.65 alpha:1.0].CGColor;
	if(inLineIndex == 1) lineLayer.strokeColor = [UIColor colorWithHue:0.300 saturation:0.35 brightness:0.65 alpha:0.4].CGColor;
	if(inLineIndex == 2) lineLayer.strokeColor = [UIColor colorWithHue:0.650 saturation:0.85 brightness:0.65 alpha:0.4].CGColor;
}
-(NSString*)twoDGraphView:(C3LineGraphView *)inGraphView
				labelForLineIndex:(NSUInteger)inLineIndex;
{
	if(inLineIndex == 2) return @"Sveriges medel";
	if(inLineIndex == 1) return @"Ditt medel";
	return nil;
}

@end
