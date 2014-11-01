//
//  StatsViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UITableViewController {
    NSUserDefaults *defaults;
}

- (NSArray *)historyForPuzzle:(NSInteger)puzzle;
- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval;

@end
