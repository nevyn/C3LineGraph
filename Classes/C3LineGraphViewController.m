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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
	
	[graph setNumberOfTickMarks:5 forAxis:kC3Graph_Axis_X];
	
	[graph relayout];
	
}



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
	return 1;
}
- (NSArray *)twoDGraphView:(C3LineGraphView *)inGraphView dataForLineIndex:(NSUInteger)inLineIndex;
{
	return nil;
}

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView
maximumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
{
	if(inAxis == kC3Graph_Axis_X)
		return [[NSDate date] timeIntervalSinceReferenceDate];
	return 16;
}

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView
minimumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
{
	if(inAxis == kC3Graph_Axis_X) {
		NSDate *date = [NSDate date];
		date = [date addTimeInterval:-60*60*24*30];
		return [date timeIntervalSinceReferenceDate];
	}

	return 0;
}

- (NSString *)twoDGraphView:(C3LineGraphView *)inGraphView
			labelForTickMarkIndex:(NSUInteger)inTickMarkIndex
										forAxis:(C3GraphAxisEnum)inAxis
							 defaultLabel:(float)timeInterval;
{
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"d MMMM"];
	
	return [formatter stringFromDate:date];
}

@end
