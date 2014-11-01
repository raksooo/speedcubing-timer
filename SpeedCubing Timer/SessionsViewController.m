//
//  SessionsViewController.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SessionsViewController.h"

@implementation SessionsViewController

@synthesize  overview, chosenSession;

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
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    defaults = [NSUserDefaults standardUserDefaults];
    
    [super viewDidLoad];
    
    if(overview)
        self.title = @"Previous sessions";
    else{
        NSMutableArray *session = [[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        if([[formatter stringFromDate:(NSDate *)[[session objectAtIndex:0] objectAtIndex:1]] isEqualToString:[formatter stringFromDate:(NSDate *)[[session lastObject] objectAtIndex:1]]])
            self.title = [formatter stringFromDate:(NSDate *)[[session objectAtIndex:0] objectAtIndex:1]];
        else
            self.title = [NSString stringWithFormat:@"%@ -- %@", [formatter stringFromDate:(NSDate *)[[session objectAtIndex:0] objectAtIndex:1]], [formatter stringFromDate:(NSDate *)[[session lastObject] objectAtIndex:1]]];
    }
    
    if (overview)
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    puzzles = [NSArray arrayWithObjects:@"Rubik's Cube 3x3", @"Rubik's 2x2", @"Rubik's 4x4", @"Rubik's/Vcube 5x5", @"Vcube 6x6", @"Vcube 7x7", @"MegaMinx", @"Pyraminx", @"Rubik's 3x3 Blindfold", nil];
    
    if(!overview){
        PBs = [NSMutableArray array];
        for(NSInteger i=0; i<puzzles.count; i++){
            NSArray *history = [self historyForPuzzle:i inSession:[[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession]];
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
    
    recycleSound = [SessionsViewController createSoundID:@"recycle.wav"];

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

- (NSArray *)historyForPuzzle:(NSInteger)puzzle inSession:(NSMutableArray *)session{
    NSMutableArray *history = session;
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
    if(overview && ((NSMutableArray *)[defaults objectForKey:@"sessions"]).count != 0)
        return 1;
    else if(overview)
        return 0;
    
    NSInteger sections = 0;
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i inSession:[[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession]].count > 0)
            sections++;
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(overview)
        return ((NSMutableArray *)[defaults objectForKey:@"sessions"]).count;
    
    
    NSMutableArray *sectionNumbers = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i inSession:[[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession]].count > 0)
            [sectionNumbers addObject:[NSNumber numberWithInt:i]];
    return [self historyForPuzzle:((NSNumber *)[sectionNumbers objectAtIndex:section]).intValue inSession:[[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellAt:%d,%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     
        if(overview){
            NSMutableArray *session = [[defaults objectForKey:@"sessions"] objectAtIndex:indexPath.row];
        
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if([[formatter stringFromDate:(NSDate *)[[session objectAtIndex:0] objectAtIndex:1]] isEqualToString:[formatter stringFromDate:(NSDate *)[[session lastObject] objectAtIndex:1]]])
                cell.textLabel.text = [formatter stringFromDate:(NSDate *)[[session objectAtIndex:0] objectAtIndex:1]];
            else
                cell.textLabel.text = [NSString stringWithFormat:@"%@ -- %@", [formatter stringFromDate:(NSDate *)[[session objectAtIndex:0] objectAtIndex:1]], [formatter stringFromDate:(NSDate *)[[session lastObject] objectAtIndex:1]]];
        }
        else{
            NSMutableArray *session = [[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession];
            
            int section = indexPath.section;
            
            NSMutableArray *sectionNumbers = [NSMutableArray array];
            for(NSInteger i=0; i<puzzles.count; i++)
                if([self historyForPuzzle:i inSession:session].count > 0)
                    [sectionNumbers addObject:[NSNumber numberWithInt:i]];
            indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:((NSNumber *)[sectionNumbers objectAtIndex:indexPath.section]).intValue];
            
            NSArray *info = [[self historyForPuzzle:indexPath.section inSession:session] objectAtIndex:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSTimeInterval deltaTime = ((NSNumber *)[info objectAtIndex:0]).floatValue;
            
            if([[NSString stringWithFormat:@"%.3f", ((NSNumber *)[PBs objectAtIndex:section]).floatValue] isEqualToString:[NSString stringWithFormat:@"%.3f", deltaTime]])
                cell.imageView.image = [UIImage imageNamed:@"star"];
            
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
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@:%@:%@", minutesString, secondsString, milliSecondsString];
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(overview)
        return nil;
    
    NSMutableArray *sectionTitles = [NSMutableArray array];
    for(NSInteger i=0; i<puzzles.count; i++)
        if([self historyForPuzzle:i inSession:[[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession]].count > 0)
            [sectionTitles addObject:[puzzles objectAtIndex:i]];
    
    return [sectionTitles objectAtIndex:section];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!overview)
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AudioServicesPlaySystemSound(recycleSound);
        
        NSMutableArray *sessions = [NSMutableArray arrayWithArray:[defaults objectForKey:@"sessions"]];
        [sessions removeObjectAtIndex:indexPath.row];
        [defaults setObject:sessions forKey:@"sessions"];
        [defaults synchronize];
        
        if(sessions.count == 0)
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        else
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(overview){
        SessionsViewController *sessionVC = [[SessionsViewController alloc] initWithStyle:UITableViewStylePlain];
        sessionVC.overview = NO;
        sessionVC.chosenSession = indexPath.row;
        [self.navigationController pushViewController:sessionVC animated:YES];
    }
    else{
        NSMutableArray *history = [[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession];
        
        NSMutableArray *sectionNumbers = [NSMutableArray array];
        for(NSInteger i=0; i<puzzles.count; i++)
            if([self historyForPuzzle:i inSession:[[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession]].count > 0)
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
        detailedVC.session = [[defaults objectForKey:@"sessions"] objectAtIndex:chosenSession];
        detailedVC.oldSession = YES;
        detailedVC.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
        [self.navigationController pushViewController:detailedVC animated:YES];
    }
}


+ (SystemSoundID)createSoundID:(NSString*)name{
    NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], name];
    NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    return soundID;
}

@end
