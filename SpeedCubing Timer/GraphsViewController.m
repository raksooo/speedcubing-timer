//
//  GraphsViewController~iPad.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-06-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphsViewController.h"

@implementation GraphsViewController

@synthesize toolbar;
@synthesize label1, label2;
@synthesize dataForPlot1, dataForPlot2;

#pragma mark -
#pragma mark Initialization and teardown

-(void)viewDidLoad
{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    navBarHeight = isIPad ? 44 : 0;
    navBarHeight2 = isIPad ? 44 : 34;
    
	[super viewDidLoad];
    
    if(isIPad){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *puzzles = [NSArray arrayWithObjects:@"Rubik's Cube 3x3", @"Rubik's 2x2", @"Rubik's 4x4", @"Rubik's/Vcube 5x5", @"Vcube 6x6", @"Vcube 7x7", @"Megaminx", @"Pyraminx", @"Rubik's 3x3 Blindfold", nil];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Statistics for %@", [puzzles objectAtIndex:[defaults integerForKey:@"selectedPuzzle"]]] style:UIBarButtonItemStylePlain target:nil action:nil];
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:toolbar.items];
        [items insertObject:item atIndex:2];
        [toolbar setItems:items];
    }else{
        self.title = @"Progress graphs";
    }
    
    history = [self historyForCurrentPuzzle];
    
    pageControl.numberOfPages = 2;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
	[self performSelector:@selector(constructScatterPlot1) withObject:nil afterDelay:0.01];
	[self performSelector:@selector(constructScatterPlot2) withObject:nil afterDelay:0.01];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
	return UIInterfaceOrientationIsLandscape(interfaceOrientation) || isIPad;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    scatterPlotView1.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    scatterPlotView2.frame = CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    label1.frame = CGRectMake(0, (isIPad ? 10 : 1), scrollView.frame.size.width, (isIPad ? 40 : 20));
    label2.frame = CGRectMake(scrollView.frame.size.width, (isIPad ? 10 : 1), scrollView.frame.size.width, (isIPad ? 40 : 20));
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
    scrollView.contentOffset = CGPointMake(0, 0);
}

-(void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
    
	// Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSArray *)historyForCurrentPuzzle{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger puzzle = [defaults integerForKey:@"selectedPuzzle"];
    
    
    NSMutableArray *historyy = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
    if(historyy == nil)
        historyy = [NSMutableArray array];
    
    NSMutableArray *historyForPuzzle = [NSMutableArray array];
    for(NSArray *arr in historyy)
        if(arr.count > 2)
            if(((NSNumber *)[arr objectAtIndex:2]).intValue == puzzle)
                [historyForPuzzle addObject:arr];
    
    return historyForPuzzle;
}

#pragma mark -
#pragma mark Plot construction methods

-(void)constructScatterPlot1
{
    NSTimeInterval worstTime;
    for(NSMutableArray *arr in history)
        if([(NSNumber *)[arr objectAtIndex:0] compare:[NSNumber numberWithDouble:worstTime]] == NSOrderedDescending)
            worstTime = [(NSNumber *)[arr objectAtIndex:0] doubleValue];
    
	// Create graph from theme
	graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTStocksTheme];
	[graph applyTheme:theme];
    scatterPlotView1 = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
	scatterPlotView1.hostedGraph = graph;
    [scrollView addSubview:scatterPlotView1];
    
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, (isIPad ? 10 : 1), scrollView.frame.size.width, (isIPad ? 40 : 20))];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"Progress";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont fontWithName:@"Helvetica-Bold" size:(isIPad ? 35 : 17)];
    [scrollView addSubview:label1];
    
	graph.paddingLeft	= 0;
	graph.paddingTop	= 0;
	graph.paddingRight	= 0;
	graph.paddingBottom = 0;
    graph.plotAreaFrame.paddingBottom = 25;
    graph.plotAreaFrame.paddingLeft = 35;
    
	// Setup plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
	plotSpace.xRange				= [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1) length:CPTDecimalFromFloat((history.count-1)*1.05)];
	plotSpace.yRange				= [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat((ceil(ceil(worstTime)/10)*10+0.5)*1.05)];
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    
	// Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
	x.majorIntervalLength		  = CPTDecimalFromString([NSString stringWithFormat:@"%d", history.count]);
	x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	x.minorTicksPerInterval		  = 0;
    x.labelFormatter              = formatter;
    
	CPTXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength		  = CPTDecimalFromString(isIPad ? (worstTime < 200 ? @"10" : @"120") : (worstTime < 100 ? @"10" : (worstTime < 1000 ? @"60" : @"600")));
	y.minorTicksPerInterval		  = 1;
	y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1");
    y.labelFormatter              = formatter;
    
	// Create a green plot area
	CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
	dataSourceLinePlot.identifier = @"Plot1";
    
	CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
	lineStyle.lineWidth				 = 3.f;
	lineStyle.lineColor				 = [CPTColor whiteColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;
    
	dataSourceLinePlot.dataSource = self;
    
	/*// Put an area gradient under the plot above
	CPTColor *areaColor		  = [CPTColor colorWithComponentRed:1 green:1 blue:1 alpha:0.7];
	CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
	areaGradient.angle = -90.0f;
	CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
	dataSourceLinePlot.areaFill		 = areaGradientFill;
	dataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"1.75");*/
    
	// Animate in the new plot, as an example
	dataSourceLinePlot.opacity		  = 0.0f;
	dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDecimal;
	[graph addPlot:dataSourceLinePlot];
    
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration			= 1.0f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode			= kCAFillModeForwards;
	fadeInAnimation.toValue				= [NSNumber numberWithFloat:1.0];
	[dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
	
    
    
	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	NSUInteger i = 1;
	for (NSMutableArray *arr in history)
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i++], @"x", [arr objectAtIndex:0], @"y", nil]];
    
	self.dataForPlot1 = contentArray;
    
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
}

-(void)constructScatterPlot2
{
    double highest = 0;
	NSUInteger i = 1;
	for (NSMutableArray *arr in history){
        double average = 0;
        for(int j=0; j<i; j++)
            average += [[[history objectAtIndex:j] objectAtIndex:0] doubleValue];
        average /= i;
        highest = MAX(highest, average);
        i++;
    }
    
	// Create graph from theme
	graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	CPTTheme *theme = [CPTTheme themeNamed:kCPTStocksTheme];
	[graph applyTheme:theme];
    scatterPlotView2 = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
	scatterPlotView2.hostedGraph = graph;
    [scrollView addSubview:scatterPlotView2];
    
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(scrollView.frame.size.width, (isIPad ? 10 : 1), scrollView.frame.size.width, (isIPad ? 40 : 20))];
    label2.backgroundColor = [UIColor clearColor];
    label2.text = @"Average progress";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor whiteColor];
    label2.font = [UIFont fontWithName:@"Helvetica-Bold" size:(isIPad ? 35 : 17)];
    [scrollView addSubview:label2];
    
	graph.paddingLeft	= 0;
	graph.paddingTop	= 0;
	graph.paddingRight	= 0;
	graph.paddingBottom = 0;
    graph.plotAreaFrame.paddingBottom = 25;
    graph.plotAreaFrame.paddingLeft = 35;
    
	// Setup plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = NO;
	plotSpace.xRange				= [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1) length:CPTDecimalFromFloat((history.count-1)*1.05)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat((ceil(ceil(highest)/10)*10+0.5)*1.05)];
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    
	// Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
	x.majorIntervalLength		  = CPTDecimalFromString([NSString stringWithFormat:@"%d", history.count]);
	x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
	x.minorTicksPerInterval		  = 0;
    x.labelFormatter              = formatter;
    
	CPTXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength		  = CPTDecimalFromString(isIPad ? (highest < 200 ? @"10" : @"120") : (highest < 100 ? @"10" : (highest < 1000 ? @"60" : @"600")));
	y.minorTicksPerInterval		  = 1;
	y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1");
    y.labelFormatter              = formatter;
    
	// Create a green plot area
	CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
	dataSourceLinePlot.identifier = @"Plot2";
    
	CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
	lineStyle.lineWidth				 = 3.f;
	lineStyle.lineColor				 = [CPTColor whiteColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;
    
	dataSourceLinePlot.dataSource = self;
    
	/*// Put an area gradient under the plot above
     CPTColor *areaColor		  = [CPTColor colorWithComponentRed:1 green:1 blue:1 alpha:0.7];
     CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
     areaGradient.angle = -90.0f;
     CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
     dataSourceLinePlot.areaFill		 = areaGradientFill;
     dataSourceLinePlot.areaBaseValue = CPTDecimalFromString(@"1.75");*/
    
	// Animate in the new plot, as an example
	dataSourceLinePlot.opacity		  = 0.0f;
	dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDecimal;
	[graph addPlot:dataSourceLinePlot];
    
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.duration			= 1.0f;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.fillMode			= kCAFillModeForwards;
	fadeInAnimation.toValue				= [NSNumber numberWithFloat:1.0];
	[dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
	
    
    
	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
	i = 1;
	for (NSMutableArray *arr in history){
        double average = 0;
        for(int j=0; j<i; j++)
            average += [[[history objectAtIndex:j] objectAtIndex:0] doubleValue];
        average /= i;
        
        highest = MAX(highest, average);
        
		[contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i++], @"x", [NSNumber numberWithDouble:average], @"y", nil]];
    }
    
	self.dataForPlot2 = contentArray;
    
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSMutableArray *plotData;
    if([plot.identifier isEqual:@"Plot1"])
        plotData = dataForPlot1;
    else
        plotData = dataForPlot2;
        
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSMutableArray *plotData;
    if([plot.identifier isEqual:@"Plot1"])
        plotData = dataForPlot1;
    else
        plotData = dataForPlot2;
    
	NSDecimalNumber *num = nil;
    
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    num = [[plotData objectAtIndex:index] valueForKey:key];
    if ( fieldEnum == CPTScatterPlotFieldY )
        num = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[num doubleValue]];
    
	return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    NSMutableArray *plotData;
    if([plot.identifier isEqual:@"Plot1"])
        plotData = dataForPlot1;
    else
        plotData = dataForPlot2;
    
	static CPTMutableTextStyle *whiteText = nil;
    
	if ( !whiteText ) {
		whiteText		= [[CPTMutableTextStyle alloc] init];
		whiteText.color = [CPTColor whiteColor];
	}
    
	CPTTextLayer *newLayer = nil;
    
    int twenties = 0;
    int count = plotData.count;
    for(;count>0; twenties++)
        count -= 20;
    
    if(index % (isIPad ? (int)round(twenties/2.0) : twenties) == 0)
        newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.1f", [[[plotData objectAtIndex:index] valueForKey:@"y"] doubleValue]] style:whiteText];
    else
        newLayer = [[CPTTextLayer alloc] initWithText:@"" style:whiteText];
    
	return newLayer;
}




- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)changePage:(id)sender 
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:YES];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}

@end
