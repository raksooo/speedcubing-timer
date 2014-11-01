//
//  SessionsViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DetailedHistoryViewController.h"

@interface SessionsViewController : UITableViewController {
    NSUserDefaults *defaults;
    NSArray *puzzles;
    NSMutableArray *PBs;
    
    SystemSoundID recycleSound;
}

@property (readwrite) BOOL overview;
@property (readwrite) NSInteger chosenSession;

- (NSArray *)historyForPuzzle:(NSInteger)puzzle inSession:(NSMutableArray *)session;

+ (SystemSoundID)createSoundID:(NSString*)name;

@end
