//
//  HistoryViewController.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"

@implementation HistoryViewController

@synthesize delegate = _delegate;

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
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    if(!isIPad)
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = @"Session";
    
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(changeEditMode)];
    if(isIPad){
        if(((NSMutableArray *)[defaults objectForKey:@"history"]).count > 0)
            self.navigationItem.leftBarButtonItem = editButton;
    }else{
        if(((NSMutableArray *)[defaults objectForKey:@"history"]).count > 0)
            self.navigationItem.rightBarButtonItem = editButton;
    }
    
    if(isIPad){
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"End session" style:UIBarButtonItemStyleBordered target:self action:@selector(askForClearAll)];
        if(((NSMutableArray *)[defaults objectForKey:@"history"]).count > 0)
            self.navigationItem.rightBarButtonItem = clearButton;
    }
    
    
    puzzles = [NSArray arrayWithObjects:@"Rubik's Cube 3x3", @"Rubik's 2x2", @"Rubik's 4x4", @"Rubik's/Vcube 5x5", @"Vcube 6x6", @"Vcube 7x7", @"MegaMinx", @"Pyraminx", @"Rubik's 3x3 Blindfold", nil];
    
    recycleSound = [HistoryViewController createSoundID:@"recycle.wav"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [self calculatePersonalBests];
    [self.tableView reloadData];
    if(((NSMutableArray *)[defaults objectForKey:@"history"]).count < 1){
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
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
    [self.delegate HistoryViewControllerDidFinish:self];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger sections = 1;
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i].count > 0)
            sections++;
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
        return 1;
    section--;
    
    NSMutableArray *sectionNumbers = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i].count > 0)
            [sectionNumbers addObject:[NSNumber numberWithInt:i]];
    return [self historyForPuzzle:((NSNumber *)[sectionNumbers objectAtIndex:section]).intValue].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellAt:%d,%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    if(section == 0){
        cell.textLabel.text = @"Previous sessions";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    NSMutableArray *sectionNumbers = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i].count > 0)
            [sectionNumbers addObject:[NSNumber numberWithInt:i]];
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:((NSNumber *)[sectionNumbers objectAtIndex:indexPath.section]).intValue];
    
    NSArray *info = [[self historyForPuzzle:indexPath.section] objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:(NSDate *)[info objectAtIndex:1]]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSTimeInterval deltaTime = ((NSNumber *)[info objectAtIndex:0]).floatValue;
    
    if([[NSString stringWithFormat:@"%.3f", ((NSNumber *)[PBs objectAtIndex:section-1]).floatValue] isEqualToString:[NSString stringWithFormat:@"%.3f", deltaTime]])
        cell.imageView.image = [UIImage imageNamed:@"star"];
    else
        cell.imageView.image = nil;
    
    cell.textLabel.text = [self formatHumanReadableTimeForTimeStamp:((NSNumber *)[info objectAtIndex:0]).floatValue];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return nil;
    section--;
    
    NSMutableArray *sectionTitles = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i].count > 0)
            [sectionTitles addObject:[puzzles objectAtIndex:i]];

    return [sectionTitles objectAtIndex:section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)
        return NO;
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *oldIndexPath = indexPath;
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        AudioServicesPlaySystemSound(recycleSound);
        
        NSMutableArray *history = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
        
        NSMutableArray *sectionNumbers = [NSMutableArray array];
        for(NSInteger i=0; i<puzzles.count; i++)
            if([self historyForPuzzle:i].count > 0)
                [sectionNumbers addObject:[NSNumber numberWithInt:i]];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:((NSNumber *)[sectionNumbers objectAtIndex:indexPath.section]).intValue];
        
        NSInteger row = 0;
        NSInteger i;
        for(i=0; i<history.count; i++){
            if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:2]).intValue == newIndexPath.section){
                if(row == newIndexPath.row)
                    break;
                row++;
            }
        }
        
        [history removeObjectAtIndex:i];
        
        [defaults setObject:history forKey:@"history"];
        [defaults synchronize];
        
        if([self historyForPuzzle:newIndexPath.section].count == 0)
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:oldIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        else
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oldIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(history.count == 0){
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.leftBarButtonItem = nil;
            [self changeEditMode];
        }
        
        [self calculatePersonalBests];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        SessionsViewController *sessionsVC = [[SessionsViewController alloc] initWithStyle:UITableViewStylePlain];
        sessionsVC.overview = YES;
        [self.navigationController pushViewController:sessionsVC animated:YES];
        return;
    }
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    NSMutableArray *history = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
    
    NSMutableArray *sectionNumbers = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i].count > 0)
            [sectionNumbers addObject:[NSNumber numberWithInt:i]];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:((NSNumber *)[sectionNumbers objectAtIndex:indexPath.section]).intValue];
    
    NSInteger row = 0;
    NSInteger i;
    for(i=0; i<history.count; i++){
        if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:2]).intValue == newIndexPath.section){
            if(row == newIndexPath.row)
                break;
            row++;
        }
    }
    
    DetailedHistoryViewController *detailedVC = [[DetailedHistoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailedVC.info = [history objectAtIndex:i];
    detailedVC.index = i;
    detailedVC.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
    [self.navigationController pushViewController:detailedVC animated:YES];
}



- (void)askForClearAll{
    [[[UIAlertView alloc] initWithTitle:@"End session" message:@"Are you sure you would like to end this session?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"End session", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self clearAll];
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        if(self.tableView.isEditing)
            [self changeEditMode];
    }
}

- (void)clearAll{
    NSMutableArray *sessions = [NSMutableArray arrayWithArray:[defaults objectForKey:@"sessions"]];
    if(sessions == nil)
        sessions = [NSMutableArray array];
    [sessions addObject:[defaults objectForKey:@"history"]];
    [defaults setObject:sessions forKey:@"sessions"];
    
    [defaults setObject:nil forKey:@"history"];
    
    [self.tableView reloadData];
}

- (void)changeEditMode{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(changeEditMode)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(changeEditMode)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"End session" style:UIBarButtonItemStyleBordered target:self action:@selector(askForClearAll)];
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if(((NSMutableArray *)[defaults objectForKey:@"history"]).count < 1)
        return;
    
    if(self.tableView.editing){
        if(isIPad){
            self.navigationItem.leftBarButtonItem = doneButton;
        }else{
            self.navigationItem.rightBarButtonItem = doneButton;
            self.navigationItem.leftBarButtonItem = clearButton;
        }
    }else{
        if(isIPad){
            self.navigationItem.leftBarButtonItem = editButton;
        }else{
            self.navigationItem.rightBarButtonItem = editButton;
            self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
        }
    }
}


+ (SystemSoundID)createSoundID:(NSString*)name{
    NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], name];
    NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    return soundID;
}

- (NSString *) formatHumanReadableTimeForTimeStamp:(float)timeStamp{
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    NSInteger milliSeconds = 0;
    
    while(timeStamp >= 60){
        minutes++;
        timeStamp -= 60;
    }
    seconds = floor(timeStamp);
    milliSeconds = round((timeStamp-floor(timeStamp))*1000);
    
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

- (void)calculatePersonalBests {
    PBs = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++){
        NSArray *history = [self historyForPuzzle:i];
        if(history == nil || history.count <= 0)
            continue;
        NSArray *currentBest;
        NSTimeInterval currentBestTime = NSIntegerMax;
        for(NSArray *arr in history){
            if(((NSNumber *)[arr objectAtIndex:0]).floatValue < currentBestTime){
                currentBestTime = ((NSNumber *)[arr objectAtIndex:0]).floatValue;
                currentBest = arr;
            }
        }
        [PBs addObject:[currentBest objectAtIndex:0]];
    }
}

@end
