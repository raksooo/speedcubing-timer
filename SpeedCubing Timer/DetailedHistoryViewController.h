//
//  DetailedHistoryViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <AudioToolbox/AudioToolbox.h>

@interface DetailedHistoryViewController : UITableViewController {
    NSArray *puzzles;
    
    SystemSoundID recycleSound;
}

@property (retain) NSArray *info;
@property (readwrite) NSInteger index;

@property (retain) NSMutableArray *session;
@property (readwrite) BOOL oldSession;

- (NSString *)formatHumanReadableTime;

- (NSArray *)historyForPuzzle:(NSInteger)puzzle;

+ (SystemSoundID)createSoundID:(NSString*)name;

@end
