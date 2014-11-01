//
//  GraphsViewController~iPad.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-06-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface GraphsViewController : UIViewController <CPTBarPlotDataSource, UIScrollViewDelegate>
{
    BOOL isIPad;
    int navBarHeight;
    int navBarHeight2;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl* pageControl;
    BOOL pageControlIsChangingPage;
	IBOutlet CPTGraphHostingView *scatterPlotView1, *scatterPlotView2;
	CPTXYGraph *graph;
    
    NSArray *history;
	NSMutableArray *dataForPlot1, *dataForPlot2;
}

@property (retain) IBOutlet UIToolbar *toolbar;
@property (retain) IBOutlet UILabel *label1, *label2;

@property (readwrite, retain, nonatomic) NSMutableArray *dataForPlot1, *dataForPlot2;

- (NSArray *)historyForCurrentPuzzle;

// Plot construction methods
-(void)constructScatterPlot1;
-(void)constructScatterPlot2;

@end
