//
//  SettingsViewController.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    self.contentSizeForViewInPopover = CGSizeMake(400, 480);
    if(!isIPad){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.title = @"Settings";
    }
    
    [super viewDidLoad];

    defaults = [NSUserDefaults standardUserDefaults];
    
    items = [NSArray arrayWithObjects:@"3", @"5", @"10", @"15", @"30", nil];
    colors1 = [NSArray arrayWithObjects:[UIColor blackColor], 
                                        [UIColor whiteColor], 
                                        [UIColor lightGrayColor], 
                                        [UIColor darkGrayColor], 
                                        [UIColor colorWithRed:72.0/255.0 green:93.0/255.0 blue:104.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:85.0/255.0 green:161.0/255.0 blue:92.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:217.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:169.0/255.0 green:42.0/255.0 blue:159.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:113.0/255.0 alpha:1.0], 
                                        nil];
    colors2 = [NSArray arrayWithObjects:[UIColor colorWithRed:72.0/255.0 green:93.0/255.0 blue:104.0/255.0 alpha:1.0], 
                                        [UIColor whiteColor], 
                                        [UIColor lightGrayColor], 
                                        [UIColor darkGrayColor], 
                                        [UIColor blackColor], 
                                        [UIColor colorWithRed:85.0/255.0 green:161.0/255.0 blue:92.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:217.0/255.0 green:97.0/255.0 blue:97.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:169.0/255.0 green:42.0/255.0 blue:159.0/255.0 alpha:1.0], 
                                        [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:113.0/255.0 alpha:1.0], 
                                        nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)done:(id)sender
{
    [self.delegate SettingsViewControllerDidFinish:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
        return 3;
    else
        return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    else
        return cell;
    
    NSInteger leftAddition = isIPad ? -80 : (!([[UIScreen mainScreen] bounds].size.height-568) ? 88 : 0);
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Inspection duration";
            
            inspectionsTime = [[UISegmentedControl alloc] initWithItems:items];
            inspectionsTime.segmentedControlStyle = UISegmentedControlStyleBar;
            inspectionsTime.frame = CGRectMake(260+leftAddition, 8, 200, 30);
            inspectionsTime.selectedSegmentIndex = [items indexOfObject:[defaults objectForKey:@"inspectionTime"]];
            if(inspectionsTime.selectedSegmentIndex == -1)
                inspectionsTime.selectedSegmentIndex = 3;
            
            [inspectionsTime addTarget:self action:@selector(changeInspectionTime) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:inspectionsTime];
        }
        else if(indexPath.row == 1){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Hide timer when active";
            
            UISwitch *hideTimerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(380+leftAddition, 9, 0, 0)];
            hideTimerSwitch.on = [defaults boolForKey:@"hideTimer"];
            [hideTimerSwitch addTarget:self action:@selector(changeHideTimer:) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:hideTimerSwitch];
        }
        else if(indexPath.row == 2){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Play sounds";
            
            UISwitch *soundsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(380+leftAddition, 9, 0, 0)];
            soundsSwitch.on = [defaults boolForKey:@"sounds"];
            [soundsSwitch addTarget:self action:@selector(changeSounds:) forControlEvents:UIControlEventValueChanged];
            
            [cell addSubview:soundsSwitch];
        }
    }
    else if(indexPath.section == 1){
        if(indexPath.row == 0){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Text color";
            
            colorPicker1 = [[UIView alloc] initWithFrame:CGRectMake(215+leftAddition, 13, 245, 30)];
            int width = 20, i=-1;
            for(UIColor *color in colors1){i++;
                UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                btn1.frame = CGRectMake((width+8)*i, 0, width, 20);
                btn1.backgroundColor = [UIColor whiteColor];
                if([defaults integerForKey:@"textColor"] == i)
                    [btn1 setBackgroundImage:[UIImage imageNamed:@"colorPickerSelectedBackground"] forState:UIControlStateNormal];
                btn1.tag = i;
                [btn1 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
                
                [btn1.layer setMasksToBounds:YES];
                [btn1.layer setCornerRadius:0];
                [btn1.layer setBorderWidth:1.0];
                [btn1.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
                
                
                UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                btn2.frame = CGRectMake(3, 3, 14, 14);
                btn2.backgroundColor = color;
                btn2.tag = i;
                [btn2 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
                
                [btn2.layer setMasksToBounds:YES];
                [btn2.layer setCornerRadius:0];
                [btn2.layer setBorderWidth:1.0];
                [btn2.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
                
                [btn1 addSubview:btn2];
                
                
                [colorPicker1 addSubview:btn1];
            }
            [cell addSubview:colorPicker1];
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"Background";
            
            colorPicker2 = [[UIView alloc] initWithFrame:CGRectMake(215+leftAddition, 13, 245, 30)];
            int width = 20, i=-1;
            for(UIColor *color in colors2){i++;
                UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                btn1.frame = CGRectMake((width+8)*i, 0, width, 20);
                btn1.backgroundColor = [UIColor whiteColor];
                if([defaults integerForKey:@"backgroundColor"] == i)
                    [btn1 setBackgroundImage:[UIImage imageNamed:@"colorPickerSelectedBackground"] forState:UIControlStateNormal];
                btn1.tag = i;
                [btn1 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
                
                [btn1.layer setMasksToBounds:YES];
                [btn1.layer setCornerRadius:0];
                [btn1.layer setBorderWidth:1.0];
                [btn1.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
                
                
                UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                btn2.frame = CGRectMake(3, 3, 14, 14);
                btn2.backgroundColor = color;
                btn2.tag = i;
                [btn2 addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
                
                [btn2.layer setMasksToBounds:YES];
                [btn2.layer setCornerRadius:0];
                [btn2.layer setBorderWidth:1.0];
                [btn2.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
                
                [btn1 addSubview:btn2];
                
                
                [colorPicker2 addSubview:btn1];
            }
            [cell addSubview:colorPicker2];
        }
    }
    
    return cell;
}



- (void)changeInspectionTime{
    [defaults setObject:[items objectAtIndex:inspectionsTime.selectedSegmentIndex] forKey:@"inspectionTime"];
    [defaults synchronize];
}

- (void)changeColor:(id)sender{
    UIView *picker;
    if(((UIButton *)sender).superview == colorPicker1 || ((UIButton *)sender).superview == colorPicker2)
        picker = ((UIButton *)sender).superview;
    else
        picker = ((UIButton *)sender).superview.superview;
    
    for(UIButton *btn in picker.subviews){
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        if(((UIButton *)sender).tag == btn.tag)
            [btn setBackgroundImage:[UIImage imageNamed:@"colorPickerSelectedBackground"] forState:UIControlStateNormal];
    }
    
    [defaults setInteger:((UIButton *)sender).tag forKey:(picker == colorPicker1 ? @"textColor" : @"backgroundColor")];
    [defaults synchronize];
    if(isIPad)
        [delegate SettingsViewControllerDidChangeColor];
}

- (void)changeHideTimer:(id)sender{
    [defaults setBool:((UISwitch *)sender).on forKey:@"hideTimer"];
    [defaults synchronize];
}

- (void)changeSounds:(id)sender{
    [defaults setBool:((UISwitch *)sender).on forKey:@"sounds"];
    [defaults synchronize];
}

@end
