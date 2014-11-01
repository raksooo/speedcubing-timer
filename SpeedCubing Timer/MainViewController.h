//
//  MainViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HistoryViewController.h"
#import "PuzzlePickerViewController.h"
#import "SettingsViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface MainViewController : UIViewController <HistoryViewControllerDelegate, PuzzlePickerViewControllerDelegate, SettingsViewControllerDelegate, UIPopoverControllerDelegate> {
    NSUserDefaults *defaults;
    BOOL isIPad;
    
    NSArray *puzzles;
    
    BOOL inspecting;
    BOOL startFromInspection;
    BOOL firstPressed;
    BOOL readyToStart;
    UILabel *timerLabel;
    NSTimeInterval start;
    NSTimer *timer;
    NSTimeInterval lastAverage, lastPB;
    NSTimeInterval lastResult;
    
    NSTimeInterval lastStop;
    
    SystemSoundID upSound, downSound, recycleSound, lowBeep, highBeep, fanfareSound;
    
    BOOL timerIsAboutToStart;
}

@property (strong, nonatomic) UIPopoverController *historyPopoverController;
@property (strong, nonatomic) UIPopoverController *puzzlesPopoverController;
@property (strong, nonatomic) UIPopoverController *settingsPopoverController;

@property (readwrite) NSArray *puzzles;

@property (retain) IBOutlet UIToolbar *navBar;

@property (retain) IBOutlet UIImageView *stopLight;

@property (retain) IBOutlet UIButton *stopButton;
@property (retain) IBOutlet UIButton *leftStarterButton;
@property (retain) IBOutlet UIButton *rightStarterButton;
@property (retain) IBOutlet UILabel *timerLabel;
@property (retain) IBOutlet UILabel *scrambleLabel;
@property (retain) IBOutlet UIButton *dontSaveButton;
@property (retain) IBOutlet UIButton *startInspectionButton;

@property (retain) IBOutlet UIBarButtonItem *puzzlesButton;
@property (retain) IBOutlet UIBarButtonItem *settingsButton;
@property (retain) IBOutlet UIBarButtonItem *historyButton;
@property (retain) IBOutlet UIBarButtonItem *statisticsButton;

@property (retain) IBOutlet UILabel *PBLabel;
@property (retain) IBOutlet UILabel *averageLabel;
@property (retain) IBOutlet UILabel *averageOfFiveLabel;
@property (retain) IBOutlet UILabel *threeOfFiveLabel;
@property (retain) IBOutlet UILabel *tenOfTwelveLabel;

@property (retain) IBOutlet UILabel *PBTitleLabel;
@property (retain) IBOutlet UILabel *averageTitleLabel;
@property (retain) IBOutlet UILabel *averageOfFiveTitleLabel;
@property (retain) IBOutlet UILabel *threeOfFiveTitleLabel;
@property (retain) IBOutlet UILabel *tenOfTwelveTitleLabel;

- (NSArray *)historyForPuzzle:(NSInteger)puzzle;
- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval;

- (void)generateScramble;

- (void)updateColors;

- (void)printAllStatistics;
- (void)printPB;
- (void)printAverage;
- (void)printAverageOfFive;
- (void)printThreeOfFive;
- (void)printTenOfTwelve;

- (IBAction)startInspectionTimer;
- (void)updateInspectionTimer;

- (IBAction)gettingReadyForStart;
- (IBAction)startTimer;
- (void)updateTimerDisplay;
- (IBAction)stopTimer;

- (IBAction)discardTime:(id)sender;

- (void)addToHistory:(NSTimeInterval)time date:(NSDate *)date puzzle:(NSInteger)puzzle scramble:(NSString *)scramble;

+ (SystemSoundID)createSoundID:(NSString*)name;

@end
