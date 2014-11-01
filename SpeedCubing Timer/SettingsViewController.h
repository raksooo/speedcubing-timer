//
//  SettingsViewController.h
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate
- (void)SettingsViewControllerDidFinish:(SettingsViewController *)controller;
- (void)SettingsViewControllerDidChangeColor;
@end

@interface SettingsViewController : UITableViewController {
    NSUserDefaults *defaults;
    BOOL isIPad;
    
    UISegmentedControl *inspectionsTime;
    UIView *colorPicker1;
    UIView *colorPicker2;
    
    NSArray *items;
    NSArray *colors1;
    NSArray *colors2;
}

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;

- (void)changeInspectionTime;
- (void)changeColor:(id)sender;
- (void)changeHideTimer:(id)sender;
- (void)changeSounds:(id)sender;

@end
