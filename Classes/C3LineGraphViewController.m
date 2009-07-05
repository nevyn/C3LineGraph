//
//  C3LineGraphViewController.m
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "C3LineGraphViewController.h"

@implementation C3LineGraphViewController



/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

#define score(i) i
#define daysfromnow(i) [[NSDate dateWithTimeIntervalSinceNow:-i*60*60*24] timeIntervalSinceReferenceDate]
#define pv(x, y) [NSValue valueWithCGPoint:CGPointMake(x, y)]

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
	
	data = [[NSArray alloc] initWithObjects:
					pv(daysfromnow(30), score(4)),
					pv(daysfromnow(26), score(6)),
					pv(daysfromnow(20), score(9)),
					pv(daysfromnow(16), score(2)),
					pv(daysfromnow(15), score(12)),
					pv(daysfromnow(14), score(16)),
					pv(daysfromnow(8), score(9)),
					pv(daysfromnow(1), score(10)),
					pv(daysfromnow(0), score(9)),
					nil
				];
	
	myAverage = [[NSArray alloc] initWithObjects:
							 pv(daysfromnow(30), score(8.55)),
							 pv(daysfromnow(0), score(8.55)),
							 nil];
	
	worldAverage = [[NSArray alloc] initWithObjects:
									pv(daysfromnow(30), score(7.2)),
									pv(daysfromnow(0), score(7.2)),
									nil];
	
	[graph setNumberOfTickMarks:5 forAxis:kC3Graph_Axis_X];
	[graph setNumberOfTickMarks:9 forAxis:kC3Graph_Axis_Y];
	
	[graph relayout];
	
}
#undef score
#undef daysfromnow
#undef pv


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
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
	if(inLineIndex == 0) return data;
	if(inLineIndex == 1) return myAverage;
	return worldAverage;
}

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView
maximumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
{
	if(inAxis == kC3Graph_Axis_X)
		return [(NSValue*)[data lastObject] CGPointValue].x;
	return 18;
}

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView
minimumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
{
	if(inAxis == kC3Graph_Axis_X)
		return [(NSValue*)[data objectAtIndex:0] CGPointValue].x;
	

	return 0;
}

- (NSString *)twoDGraphView:(C3LineGraphView *)inGraphView
			labelForTickMarkIndex:(NSUInteger)inTickMarkIndex
										forAxis:(C3GraphAxisEnum)inAxis
							 defaultLabel:(float)inVal;
{
	if(inAxis == kC3Graph_Axis_X) {
		NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:inVal];
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
	if(inLineIndex == 0) return nil;
	if(inLineIndex == 1) return @"Ditt medel";
	return @"Sveriges medel";
}

@end
