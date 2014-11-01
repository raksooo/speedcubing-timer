//
//  HistoryViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DetailedHistoryViewController.h"
#import "SessionsViewController.h"

@class HistoryViewController;

@protocol HistoryViewControllerDelegate
- (void)HistoryViewControllerDidFinish:(HistoryViewController *)controller;
@end

@interface HistoryViewController : UITableViewController <UIAlertViewDelegate> {
    NSUserDefaults *defaults;
    BOOL isIPad;
    
    NSArray *puzzles;
    NSMutableArray *PBs;
    
    SystemSoundID recycleSound;
}

@property (weak, nonatomic) id <HistoryViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

- (NSArray *)historyForPuzzle:(NSInteger)puzzle;

- (void)askForClearAll;
- (void)clearAll;
- (void)changeEditMode;

- (NSString *) formatHumanReadableTimeForTimeStamp:(float)timeStamp;
- (void)calculatePersonalBests;

+ (SystemSoundID)createSoundID:(NSString*)name;

@end
