//
//  C3LineGraph.h
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
	kC3Graph_Axis_Y = 0,
	kC3Graph_Axis_X = 1,
	
	kC3Graph_Axis_Y_Right = 2, // not used
	kC3Graph_Axis_Y_Left = kC3Graph_Axis_Y,
	kC3Graph_AxisCount
} C3GraphAxisEnum;


@protocol C3LineGraphDelegate;
@protocol C3LineGraphDataSource;

@interface C3LineGraphView : UIView {
	id<NSObject, C3LineGraphDataSource> dataSource;
	id<NSObject, C3LineGraphDelegate> delegate;
	
	NSInteger tickMarkCount[kC3Graph_AxisCount];
	NSInteger minorTickMarkCount[kC3Graph_AxisCount];
	
	CALayer *xAxis;
	CALayer *yAxis;
	CALayer *gridLines;
	BOOL hasAnimated;	
}

#pragma mark 
#pragma mark Callbacks

@property (nonatomic, retain) id<NSObject, C3LineGraphDataSource> dataSource;
@property (nonatomic, retain) id<NSObject, C3LineGraphDelegate> delegate;

#pragma mark 
#pragma mark Looks



/*!	@method	setNumberOfTickMarks:forAxis:
 @discussion Sets the number of major tick marks for an axis.  The default is no tick marks.
 @param	count		The number of major tick marks.  Should not be one.
 @param	inAxis		The axis to change.
 */
- (void)setNumberOfTickMarks:(NSInteger)count forAxis:(C3GraphAxisEnum)inAxis;
- (NSInteger)numberOfTickMarksForAxis:(C3GraphAxisEnum)inAxis;
- (void)setNumberOfMinorTickMarks:(NSInteger)count forAxis:(C3GraphAxisEnum)inAxis;
- (NSInteger)numberOfMinorTickMarksForAxis:(C3GraphAxisEnum)inAxis;

-(void)relayout;
-(void)reloadData;

/*!	@method	convertPoint:fromView:toLineIndex:
 @discussion Converts a point from a given window/view coordinate system to a point in the coordinate system
 of a given line on the graph.  For example, if the x range values for a line are from -10.0 to +10.0
 the returned point will be in this range.
 
 This is very useful when calling it from the -twoDGraphView:didClickPoint: delegate method.
 @param	inPoint		The point to be converted.
 @param	inView		The inPoint parameter is in this view's coordinate system.
 A value of nil means the window's coordinate system.
 @param	inLineIndex	Zero based index of a line displayed on the graph.
 @result	The point after conversion to the appropriate line's scale.
 */
- (CGPoint)convertPoint:(CGPoint)inPoint fromView:(UIView *)inView toLineIndex:(NSUInteger)inLineIndex;


@end

#pragma mark 

@protocol C3LineGraphDataSource

/*!	@method	numberOfLinesInTwoDGraphView:
 @discussion Asks the datasource to report the number of data lines to be drawn in a particular graph view.
 @param	inGraphView	The graph view making the call.
 @result	Should return the number of data lines to graph.
 */
- (NSUInteger)numberOfLinesInTwoDGraphView:(C3LineGraphView *)inGraphView;

/*!	@method	twoDGraphView:dataForLineIndex:
 @discussion <b>This method must be implemented.</b>
 
 Asks the datasource to report the actual data points for a particular line.  The points should
 be returned as an NSArray of CGPoints as NSValues
 @param	inGraphView	The graph view making the call.
 @param	inLineIndex	The zero based data line index to return.
 @result	An NSArray (or NSMutableArray) of CGPoints as NSValues.
 */
- (NSArray *)twoDGraphView:(C3LineGraphView *)inGraphView dataForLineIndex:(NSUInteger)inLineIndex;


/*!	@method	twoDGraphView:maximumValueForLineIndex:forAxis:
 @discussion Asks the datasource to report the maximum axis value to use for a particular line.  For example, if
 your line data points y value ranges from 1 to 9, you may want to graph from 0 to 10; in that case,
 you would return 10 as a maximum.
 
 This sets the scale to be used to display the line.
 @param	inGraphView	The graph view making the call.
 @param	inLineIndex	The zero based data line index to return.
 @param	inAxis		The axis requested.
 @result	A number to use for the maximum value of the scale.
 */

- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView maximumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;

/*!	@method	twoDGraphView:minimumValueForLineIndex:forAxis:
 @discussion Asks the datasource to report the minimum axis value to use for a particular line.  For example, if
 your line data points y value ranges from 1 to 9, you may want to graph from 0 to 10; in that case,
 you would return 0 as a minimum.
 
 This sets the scale to be used to display the line.
 @param	inGraphView	The graph view making the call.
 @param	inLineIndex	The zero based data line index to return.
 @param	inAxis		The axis requested.
 @result	A number to use for the minimum value of the scale.
 */
- (CGFloat)twoDGraphView:(C3LineGraphView *)inGraphView minimumValueForLineIndex:(NSUInteger)inLineIndex
								 forAxis:(C3GraphAxisEnum)inAxis;
@end

/*!	@category	NSObject(C3LineGraphDelegate)
 @discussion	An object can implement any of the optional methods in this category to gain greater control over a
 particular graph view.
 */
@protocol C3LineGraphDelegate
@optional
/*!	@method	twoDGraphView:labelForTickMarkIndex:forAxis:defaultLabel:
 @discussion <b>Implementing this method is optional.</b>  The delegate has a chance to change the tick mark
 labels drawn on each axis of the graph.  If the delegate does not respond to this message the
 default label is used.  If nil is returned, no label is drawn.
 
 The default label is a number based on the position of the tick mark and the scale reported by the
 datasource for the first data line.
 @param	inGraphView		The graph view making the call.
 @param	inTickMarkIndex	The zero based data line index to return.
 @param	inAxis			The axis the tick mark is on.
 @param	inDefault		The default value of the label; will always be a number based on the position of the
 tick mark and the scale of the first line.
 @result	A string to draw at the tick mark location; can return nil if no label is wanted.
 */
- (NSString *)twoDGraphView:(C3LineGraphView *)inGraphView
			labelForTickMarkIndex:(NSUInteger)inTickMarkIndex
										forAxis:(C3GraphAxisEnum)inAxis
							 defaultLabel:(float)inDefault;


/*!	@method	twoDGraphView:didClickPoint:
 @discussion <b>Implementing this method is optional.</b>  The delegate has a chance to respond to the user
 clicking the mouse in the graph paper area of the view.
 
 You may want to use -convertPoint:fromView:toLineIndex: to get the point into the coordinate
 system of a particular data line.
 @param	inGraphView		The graph view making the call.
 @param	inPoint			The clicked position in the graph view coordinate system.
 */
- (void)twoDGraphView:(C3LineGraphView *)inGraphView didClickPoint:(CGPoint)inPoint;

@end
