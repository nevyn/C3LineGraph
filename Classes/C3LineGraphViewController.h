//
//  C3LineGraphViewController.h
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "C3LineGraph.h"

enum {
	EveryQuiz = 0,
	MyAverage = 1,
	WorldAverage = 2,
	GraphCount,
};

@interface C3LineGraphViewController : UIViewController
<C3LineGraphDelegate, C3LineGraphDataSource>
{
	IBOutlet C3LineGraphView *graph;
	NSArray *data[GraphCount];
}

@end

