//
//  MainViewController.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize historyPopoverController = _historyPopoverController;
@synthesize puzzlesPopoverController = _puzzlesPopoverController;
@synthesize settingsPopoverController = _settingsPopoverController;
@synthesize navBar;
@synthesize stopLight;
@synthesize puzzles;
@synthesize puzzlesButton, settingsButton, historyButton, statisticsButton;
@synthesize timerLabel, scrambleLabel, dontSaveButton, startInspectionButton, stopButton, leftStarterButton, rightStarterButton;
@synthesize PBLabel, averageLabel, averageOfFiveLabel, threeOfFiveLabel, tenOfTwelveLabel;
@synthesize PBTitleLabel, averageTitleLabel, averageOfFiveTitleLabel, threeOfFiveTitleLabel, tenOfTwelveTitleLabel;

- (void)viewDidLoad
{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    if(!isIPad)
        self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    lastStop = [[NSDate date] timeIntervalSince1970];
    
    puzzles = [NSArray arrayWithObjects:@"Rubik's Cube 3x3", @"Rubik's 2x2", @"Rubik's 4x4", @"Rubik's/Vcube 5x5", @"Vcube 6x6", @"Vcube 7x7", @"Megaminx", @"Pyraminx", @"Rubik's 3x3 Blindfold", nil];
    self.puzzlesButton.title = [NSString stringWithFormat:@"Puzzle: %@", [puzzles objectAtIndex:[defaults integerForKey:@"selectedPuzzle"]]];
    
    self.dontSaveButton.hidden = YES;
    
    
    UIImageView* upImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deleteButtonBgUp"]];
    UIImageView* downImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deleteButtonBgDown"]];
    
    [self.dontSaveButton setBackgroundImage:upImage.image forState:UIControlStateNormal];
    [self.dontSaveButton setBackgroundImage:downImage.image forState:UIControlStateSelected];
    
    [self.dontSaveButton.layer setCornerRadius:8.0f];
    [self.dontSaveButton.layer setMasksToBounds:YES];
    [self.dontSaveButton.layer setBorderWidth:1.0f];
    [self.dontSaveButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    
    [self.dontSaveButton.layer setCornerRadius:8.0f];
    [self.dontSaveButton.layer setMasksToBounds:YES];
    [self.dontSaveButton.layer setBorderWidth:1.0f];
    [self.dontSaveButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    
    self.dontSaveButton.titleLabel.textColor = [UIColor whiteColor];
    [self.dontSaveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:(isIPad ? 20.0 : 17.0)]];
    
    [self.dontSaveButton.titleLabel setShadowColor:[UIColor blackColor]];
    [self.dontSaveButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    upImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenButtonBgUp"]];
    downImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenButtonBgDown"]];
    
    [self.startInspectionButton setBackgroundImage:upImage.image forState:UIControlStateNormal];
    [self.startInspectionButton setBackgroundImage:downImage.image forState:UIControlStateSelected];
    
    [self.startInspectionButton.layer setCornerRadius:8.0f];
    [self.startInspectionButton.layer setMasksToBounds:YES];
    [self.startInspectionButton.layer setBorderWidth:1.0f];
    [self.startInspectionButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    
    [self.startInspectionButton.layer setCornerRadius:8.0f];
    [self.startInspectionButton.layer setMasksToBounds:YES];
    [self.startInspectionButton.layer setBorderWidth:1.0f];
    [self.startInspectionButton.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    
    self.startInspectionButton.titleLabel.textColor = [UIColor whiteColor];
    [self.startInspectionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:(isIPad ? 20.0 : 17.0)]];
    
    [self.startInspectionButton.titleLabel setShadowColor:[UIColor blackColor]];
    [self.startInspectionButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    
    upSound = [MainViewController createSoundID:@"upSound.wav"];
    downSound = [MainViewController createSoundID:@"downSound.wav"];
    recycleSound = [MainViewController createSoundID:@"recycle.wav"];
    lowBeep = [MainViewController createSoundID:@"lowBeep.wav"];
    highBeep = [MainViewController createSoundID:@"highBeep.wav"];
    fanfareSound = [MainViewController createSoundID:@"fanfare.wav"];
    
    [self updateColors];
    [self printAllStatistics];
}

- (void)viewWillAppear:(BOOL)animated{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    if(!isIPad){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self updateColors];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.puzzlesPopoverController dismissPopoverAnimated:YES];
    self.puzzlesPopoverController = nil;
    [self.historyPopoverController dismissPopoverAnimated:YES];
    self.historyPopoverController = nil;
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
}
- (void)viewDidAppear:(BOOL)animated{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    [self generateScramble];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    return isIPad || (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

#pragma mark - Flipside View Controller

- (void)HistoryViewControllerDidFinish:(HistoryViewController *)controller
{
    [self.historyPopoverController dismissPopoverAnimated:YES];
    self.historyPopoverController = nil;
    [self printAllStatistics];
}

- (void)PuzzlePickerViewControllerDidFinish:(PuzzlePickerViewController *)controller
{
    [self.puzzlesPopoverController dismissPopoverAnimated:YES];
    self.puzzlesPopoverController = nil;
}
- (void)PuzzlePickerViewControllerDidSelectPuzzle:(Puzzle)puzzle{
    self.puzzlesButton.title = [NSString stringWithFormat:@"Puzzle: %@", [puzzles objectAtIndex:puzzle]];
    [self generateScramble];
    [self printAllStatistics];
}

- (void)SettingsViewControllerDidFinish:(SettingsViewController *)controller{
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
}
- (void)SettingsViewControllerDidChangeColor{
    [self updateColors];
}
- (void)updateColors{
    NSArray *colors1 = [NSArray arrayWithObjects:   [UIColor blackColor], 
                                                    [UIColor whiteColor], 
                                                    [UIColor lightGrayColor], 
                                                    [UIColor darkGrayColor], 
                                                    [UIColor colorWithRed:72.0/255.0 green:93.0/255.0 blue:104.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:85.0/255.0 green:161.0/255.0 blue:92.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:217.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:169.0/255.0 green:42.0/255.0 blue:159.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:113.0/255.0 alpha:1.0], 
                                                    nil];
    NSArray *colors2 = [NSArray arrayWithObjects:   [UIColor colorWithRed:72.0/255.0 green:93.0/255.0 blue:104.0/255.0 alpha:1.0], 
                                                    [UIColor whiteColor], 
                                                    [UIColor lightGrayColor], 
                                                    [UIColor darkGrayColor], 
                                                    [UIColor blackColor], 
                                                    [UIColor colorWithRed:85.0/255.0 green:161.0/255.0 blue:92.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:217.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:169.0/255.0 green:42.0/255.0 blue:159.0/255.0 alpha:1.0], 
                                                    [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:113.0/255.0 alpha:1.0], 
                                                    nil];
    
    self.view.backgroundColor = [colors2 objectAtIndex:[defaults integerForKey:@"backgroundColor"]];
    timerLabel.textColor = scrambleLabel.textColor = [colors1 objectAtIndex:[defaults integerForKey:@"textColor"]];
    if(isIPad)
        PBLabel.textColor = averageLabel.textColor = averageOfFiveLabel.textColor = threeOfFiveLabel.textColor = tenOfTwelveLabel.textColor = PBTitleLabel.textColor = averageTitleLabel.textColor = averageOfFiveTitleLabel.textColor = threeOfFiveTitleLabel.textColor = tenOfTwelveTitleLabel.textColor = [colors1 objectAtIndex:[defaults integerForKey:@"textColor"]];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(popoverController == self.historyPopoverController)
        self.historyPopoverController = nil;
    else if(popoverController == self.puzzlesPopoverController)
        self.puzzlesPopoverController = nil;
    else if(popoverController == self.settingsPopoverController)
        self.settingsPopoverController = nil;
    [self printAllStatistics];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showHistory"]) {
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        ((HistoryViewController *)segue.destinationViewController).delegate = self;
        self.historyPopoverController = popoverController;
        self.historyPopoverController.delegate = self;
    }
    else if([[segue identifier] isEqualToString:@"showPuzzles"]){
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        ((PuzzlePickerViewController *)segue.destinationViewController).delegate = self;
        self.puzzlesPopoverController = popoverController;
        self.puzzlesPopoverController.delegate = self;
    }
    else if([[segue identifier] isEqualToString:@"showSettings"]){
        UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
        ((SettingsViewController *)segue.destinationViewController).delegate = self;
        self.settingsPopoverController = popoverController;
        self.settingsPopoverController.delegate = self;
    }
}

- (IBAction)togglePopover:(id)sender
{
    if([((UIBarButtonItem *)sender).title rangeOfString:@"Puzzle"].location != NSNotFound){
        if (self.puzzlesPopoverController) {
            [self.puzzlesPopoverController dismissPopoverAnimated:YES];
            self.puzzlesPopoverController = nil;
            [self printAllStatistics];
        } else {
            [self performSegueWithIdentifier:@"showPuzzles" sender:sender];
        }
    }else if([((UIBarButtonItem *)sender).title rangeOfString:@"Session"].location != NSNotFound){
        if (self.historyPopoverController) {
            [self.historyPopoverController dismissPopoverAnimated:YES];
            self.historyPopoverController = nil;
            [self printAllStatistics];
        } else {
            [self performSegueWithIdentifier:@"showHistory" sender:sender];
        }
    }else{
        if (self.settingsPopoverController) {
            [self.settingsPopoverController dismissPopoverAnimated:YES];
            self.settingsPopoverController = nil;
        } else {
            [self performSegueWithIdentifier:@"showSettings" sender:sender];
        }
    }
}


- (NSArray *)historyForPuzzle:(NSInteger)puzzle{
    NSMutableArray *history = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
    if(history == nil)
        history = [NSMutableArray array];
    
    NSMutableArray *historyForPuzzle = [NSMutableArray array];
    for(NSArray *arr in history)
        if(arr.count > 2)
            if(((NSNumber *)[arr objectAtIndex:2]).intValue == puzzle)
                [historyForPuzzle addObject:arr];
    
    return historyForPuzzle;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval{
    NSTimeInterval deltaTime = timeInterval;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    NSInteger milliSeconds = 0;
    
    while(deltaTime >= 60){
        minutes++;
        deltaTime -= 60;
    }
    seconds = floor(deltaTime);
    milliSeconds = round((deltaTime-floor(deltaTime))*1000);
    
    NSString *minutesString = [NSString stringWithFormat:@"%d", minutes];
    NSString *secondsString = [NSString stringWithFormat:@"%d", seconds];
    NSString *milliSecondsString = [NSString stringWithFormat:@"%.0d", milliSeconds];
    
    if(minutesString.length == 1)
        minutesString = [@"0" stringByAppendingString:minutesString];
    if(secondsString.length == 1)
        secondsString = [@"0" stringByAppendingString:secondsString];
    if(milliSecondsString.length == 0)
        milliSecondsString = [@"000" stringByAppendingString:milliSecondsString];
    else if(milliSecondsString.length == 1)
        milliSecondsString = [@"00" stringByAppendingString:milliSecondsString];
    else if(milliSecondsString.length == 2)
        milliSecondsString = [@"0" stringByAppendingString:milliSecondsString];
    else if(milliSecondsString.length == 4)
        milliSecondsString = [milliSecondsString substringToIndex:3];
    
    return [NSString stringWithFormat:@"%@:%@:%@", minutesString, secondsString, milliSecondsString];
}

- (void)generateScramble{
    NSInteger puzzle = [defaults integerForKey:@"selectedPuzzle"];
    NSString *scrambleString = [NSString string];
    NSArray *availableMoves;
    NSInteger lastIndex = -1;
    NSInteger length = -1;
    
    switch(puzzle){
        case 0:
        case 1:
        case 8:
            availableMoves = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"R", @"L", nil], [NSArray arrayWithObjects:@"F", @"B", nil], [NSArray arrayWithObjects:@"U", @"D", nil], nil];
            length = 25;
            break;
        case 2:
        case 3:
            length = puzzle == 2 ? 40 : 60;
            availableMoves = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"R", @"r", @"L", @"l", nil], [NSArray arrayWithObjects:@"F", @"f", @"B", @"b", nil], [NSArray arrayWithObjects:@"U", @"u", @"D", @"d", nil], nil];
            break;
        case 4:
        case 5:
            length = puzzle == 4 ? 80 : 100;
            availableMoves = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"R", @"2R", @"3R", @"L", @"2L", @"3L", nil], [NSArray arrayWithObjects:@"F", @"2F", @"3F", @"B", @"2B", @"3B", nil], [NSArray arrayWithObjects:@"U", @"2U", @"3U", @"D", @"2D", @"3D", nil], nil];
            break;
        case 6:
            break;
        case 7:
            length = 20;
            availableMoves = [NSArray arrayWithObjects:[NSArray arrayWithObject:@"F"], [NSArray arrayWithObject:@"BR"], [NSArray arrayWithObject:@"BL"], [NSArray arrayWithObject:@"D"], nil];
            break;
        default:
            scrambleLabel.text = @"";
            return;
            break;
    }
    
    for(int currentLength=0; currentLength < length; currentLength++){
        NSInteger random = rand() % availableMoves.count;
        while (random == lastIndex)
            random = rand() % availableMoves.count;
        lastIndex = random;
        NSString *currentMove = [[availableMoves objectAtIndex:random] objectAtIndex:(rand()%((NSArray *)[availableMoves objectAtIndex:0]).count)];
        
        if(rand()%3 == 0)
            currentMove = [currentMove stringByAppendingString:@"2"];
        else if(rand()%3 == 0)
            currentMove = [currentMove stringByAppendingString:@"'"];
        
        scrambleString = [NSString stringWithFormat:@"%@ %@", scrambleString, currentMove];
    }
    
    scrambleString = [scrambleString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if(isIPad)
        scrambleLabel.frame = CGRectMake(scrambleLabel.frame.origin.x, scrambleLabel.frame.origin.y, scrambleLabel.frame.size.width, [scrambleString sizeWithFont:scrambleLabel.font constrainedToSize:CGSizeMake(scrambleLabel.frame.size.width, 1024)].height);
    else{
        if([defaults integerForKey:@"selectedPuzzle"] < 3 || [defaults integerForKey:@"selectedPuzzle"] > 5)
            scrambleLabel.font = [scrambleLabel.font fontWithSize:17];
        else
            scrambleLabel.font = [scrambleLabel.font fontWithSize:12];
    }
    scrambleLabel.text = scrambleString;
}


- (void)printAllStatistics{
    [self printPB];
    [self printAverage];
    if(isIPad){
        [self printAverageOfFive];
        [self printThreeOfFive];
        [self printTenOfTwelve];
    }
}
- (void)printPB{
    NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
    if(history == nil || history.count <= 0){
        lastPB = INT_MAX;
        PBLabel.text = @"";
        return;
    }
    
    NSArray *currentBest;
    NSTimeInterval currentBestTime = NSIntegerMax;
    for(NSArray *arr in history){
        if(((NSNumber *)[arr objectAtIndex:0]).floatValue < currentBestTime){
            currentBestTime = ((NSNumber *)[arr objectAtIndex:0]).floatValue;
            currentBest = arr;
        }
    }
    
    lastPB = ((NSNumber *)[currentBest objectAtIndex:0]).floatValue;
    
    if(isIPad)
        PBLabel.text = [self stringFromTimeInterval:((NSNumber *)[currentBest objectAtIndex:0]).floatValue];
}
- (void)printAverage{
    NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
    if(history == nil || history.count <= 0){
        lastAverage = INT_MAX;
        averageLabel.text = @"";
        return;
    }
    
    NSTimeInterval time = 0;
    NSInteger times = 0;
    for(NSArray *arr in history){
        time += ((NSNumber *)[arr objectAtIndex:0]).floatValue;
        times++;
    }
    
    lastAverage = time/times;
    
    if(isIPad)
        averageLabel.text = [self stringFromTimeInterval:lastAverage];
}
- (void)printAverageOfFive{
    NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
    if(history == nil || history.count <= 0){
        averageOfFiveLabel.text = @"";
        return;
    }
    if(history.count < 5){
        averageOfFiveLabel.text = @"";
        return;
    }
    
    NSTimeInterval time = 0;
    for(NSInteger i=(history.count-1); i>=(history.count-5) && i>=0; i--)
        time += ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
    
    averageOfFiveLabel.text = [self stringFromTimeInterval:time/5];
}
- (void)printThreeOfFive{
    NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
    if(history == nil || history.count <= 0){
        threeOfFiveLabel.text = @"";
        return;
    }
    if(history.count < 5){
        threeOfFiveLabel.text = @"";
        return;
    }
    
    NSTimeInterval max = NSIntegerMin;
    NSTimeInterval min = NSIntegerMax;
    NSTimeInterval time = 0;
    for(NSInteger i=(history.count-1); i>=(history.count-5) && i>=0; i--){
        time += ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
        if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue > max)
            max = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
        else if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue < min)
            min = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
    }
    time -= max + min;
    
    threeOfFiveLabel.text = [self stringFromTimeInterval:time/3];
}
- (void)printTenOfTwelve{
    NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
    if(history == nil || history.count <= 0){
        tenOfTwelveLabel.text = @"";
        return;
    }
    if(history.count < 12){
        tenOfTwelveLabel.text = @"";
        return;
    }
    
    NSTimeInterval max = NSIntegerMin;
    NSTimeInterval min = NSIntegerMax;
    NSTimeInterval time = 0;
    for(NSInteger i=(history.count-1); i>=(history.count-12) && i>=0; i--){
        time += ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
        if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue > max)
            max = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
        else if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue < min)
            min = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
    }
    time -= max + min;
    
    tenOfTwelveLabel.text = [self stringFromTimeInterval:time/10];
}




- (IBAction)startInspectionTimer{
    [self performSelector:@selector(updateInspectionTimer) withObject:nil afterDelay:1.0];
    
    if([defaults boolForKey:@"sounds"])
        AudioServicesPlaySystemSound(lowBeep);
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    firstPressed = NO;
    readyToStart = NO;
    
    startInspectionButton.hidden = YES;
    dontSaveButton.hidden = YES;
    
    puzzlesButton.enabled = NO;
    historyButton.enabled = NO;
    settingsButton.enabled = NO;
    statisticsButton.enabled = NO;
    
    startFromInspection = NO;
    inspecting = YES;
    
    NSString *inspectionTime = [defaults objectForKey:@"inspectionTime"];
    if(inspectionTime == nil)
        inspectionTime = @"15";
    timerLabel.text = inspectionTime;
    stopLight.image = [UIImage imageNamed:@"redLight"];
    
}
- (void)updateInspectionTimer{
    NSInteger newValue = timerLabel.text.integerValue - 1;
    if(newValue == -1){
        if([defaults boolForKey:@"sounds"] && ![timer isValid])
            AudioServicesPlaySystemSound(highBeep);
        inspecting = NO;
        startFromInspection = YES;
        [self startTimer];
        stopLight.image = [UIImage imageNamed:@"greenLight"];
    }else if(inspecting){
        [self performSelector:@selector(updateInspectionTimer) withObject:nil afterDelay:1.0];
        if([defaults boolForKey:@"sounds"])
            AudioServicesPlaySystemSound(lowBeep);
        timerLabel.text = [NSString stringWithFormat:@"%d", newValue];
    }
}

- (IBAction)gettingReadyForStart{
    if(!firstPressed){
        firstPressed = YES;
        stopLight.image = [UIImage imageNamed:@"redYellowLight"];
    }else if(firstPressed){
        readyToStart = YES;
        stopLight.image = [UIImage imageNamed:@"greenLight"];
    }
}
- (IBAction)startTimer{
    if([timer isValid] || timer != nil || timerIsAboutToStart)
        return;

    timerIsAboutToStart = YES;
    
    if((!readyToStart && !startFromInspection) || [[NSDate date] timeIntervalSince1970]-lastStop<=1){
        firstPressed = NO;
        stopLight.image = [UIImage imageNamed:@"redLight"];
        
        timerIsAboutToStart = NO;
        return;
    }
    
    if([NSThread isMainThread]){
        start = [[NSDate date] timeIntervalSince1970];
        timerIsAboutToStart = NO;
        [NSThread detachNewThreadSelector:@selector(startTimer) toTarget:self withObject:nil];
    }else{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [self.view bringSubviewToFront:stopButton];
        startInspectionButton.hidden = YES;
        self.dontSaveButton.hidden = YES;
        
        if([defaults boolForKey:@"hideTimer"])
            timerLabel.hidden = YES;
        
        puzzlesButton.enabled = NO;
        historyButton.enabled = NO;
        settingsButton.enabled = NO;
        statisticsButton.enabled = NO;
        
        startFromInspection = NO;
        inspecting = NO;
        firstPressed = NO;
        readyToStart = NO;
        
        timer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(updateTimerDisplay) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        timerIsAboutToStart = NO;
    }
}
- (void)updateTimerDisplay{
    lastResult = [[NSDate date] timeIntervalSince1970]-start;
    timerLabel.text = [self stringFromTimeInterval:lastResult];
}
- (IBAction)stopTimer{
    if(![timer isValid] || inspecting)
        return;
    
    [timer invalidate];
    timer = nil;
    
    if([defaults boolForKey:@"sounds"]){
        if(lastResult < lastPB && lastPB != INT_MAX)
            AudioServicesPlaySystemSound(fanfareSound);
        else if(lastResult < lastAverage && lastAverage != INT_MAX)
            AudioServicesPlaySystemSound(upSound);
        else if(lastResult > lastAverage && lastAverage != INT_MAX)
            AudioServicesPlaySystemSound(downSound);
    }
    
    [self addToHistory:lastResult date:[NSDate date] puzzle:[defaults integerForKey:@"selectedPuzzle"] scramble:scrambleLabel.text];
    
    self.dontSaveButton.hidden = NO;
    startInspectionButton.hidden = NO;
    
    timerLabel.hidden = NO;
    
    startFromInspection = NO;
    inspecting = NO;
    firstPressed = NO;
    readyToStart = NO;
    
    stopLight.image = [UIImage imageNamed:@"redLight"];
    
    [self generateScramble];
    [self printAllStatistics];
    
    puzzlesButton.enabled = YES;
    historyButton.enabled = YES;
    settingsButton.enabled = YES;
    statisticsButton.enabled = YES;
    
    lastStop = [[NSDate date] timeIntervalSince1970];
    
    [self.view bringSubviewToFront:leftStarterButton];
    [self.view bringSubviewToFront:rightStarterButton];
    [self.view bringSubviewToFront:startInspectionButton];
    [self.view bringSubviewToFront:dontSaveButton];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (IBAction)discardTime:(id)sender{
    AudioServicesPlaySystemSound(recycleSound);
    
    self.dontSaveButton.hidden = YES;
    
    NSMutableArray *history = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
    [history removeLastObject];
    [defaults setObject:history forKey:@"history"];
    
    [self printAllStatistics];
}


- (void)addToHistory:(NSTimeInterval)time date:(NSDate *)date puzzle:(NSInteger)puzzle scramble:(NSString *)scramble{
    NSMutableArray *history = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
    if(history == nil)
        history = [NSMutableArray array];
    
    [history addObject:[NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:time], date, [NSNumber numberWithInt:puzzle], scramble, nil]];
    
    [defaults setObject:history forKey:@"history"];
    [defaults synchronize];
}

+ (SystemSoundID)createSoundID:(NSString*)name{
    NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], name];
    NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    return soundID;
}

@end













