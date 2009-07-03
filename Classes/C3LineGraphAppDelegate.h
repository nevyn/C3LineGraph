//
//  C3LineGraphAppDelegate.h
//  C3LineGraph
//
//  Created by Joachim Bengtsson on 2009-07-02.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class C3LineGraphViewController;

@interface C3LineGraphAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    C3LineGraphViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet C3LineGraphViewController *viewController;

@end

