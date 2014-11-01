//
//  PuzzlePickerViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PuzzlePickerViewController;

typedef NSInteger Puzzle;

@protocol PuzzlePickerViewControllerDelegate
- (void)PuzzlePickerViewControllerDidFinish:(PuzzlePickerViewController *)controller;
- (void)PuzzlePickerViewControllerDidSelectPuzzle:(Puzzle)puzzle;
@end

@interface PuzzlePickerViewController : UITableViewController {
    NSUserDefaults *defaults;
    BOOL isIPad;
    
    NSArray *puzzles;
    Puzzle selectedPuzzle;
}

@property (weak, nonatomic) id <PuzzlePickerViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
