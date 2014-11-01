//
//  DetailedHistoryViewController.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-05-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailedHistoryViewController.h"

@implementation DetailedHistoryViewController

@synthesize info, index;
@synthesize session, oldSession;

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
    [super viewDidLoad];

    puzzles = [NSArray arrayWithObjects:@"Rubik's Cube 3x3", @"Rubik's 2x2", @"Rubik's 4x4", @"Rubik's/Vcube 5x5", @"Vcube 6x6", @"Vcube 7x7", @"Megaminx", @"Pyraminx", @"Rubik's 3x3 Blindfold", nil];
    
    if(!oldSession){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        session = [defaults objectForKey:@"history"];
    }

    NSArray *history = [self historyForPuzzle:((NSNumber *)[info objectAtIndex:2]).intValue];
    NSTimeInterval currentBestTime = NSIntegerMax;
    for(NSArray *arr in history)
        if(((NSNumber *)[arr objectAtIndex:0]).floatValue < currentBestTime)
            currentBestTime = ((NSNumber *)[arr objectAtIndex:0]).floatValue;
    if([[NSString stringWithFormat:@"%.3f", ((NSNumber *)[info objectAtIndex:0]).floatValue] isEqualToString:[NSString stringWithFormat:@"%.3f", currentBestTime]]){
        UIImageView *star = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        star.frame = CGRectMake(0, 0, 30, 30);
        self.navigationItem.titleView = star;
    }
    
    recycleSound = [DetailedHistoryViewController createSoundID:@"recycle.wav"];
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

- (NSArray *)historyForPuzzle:(NSInteger)puzzle{
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
    // Return the number of sections.
    if(oldSession)
        return 2;
    else
        return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch(section){
        case 0:
            return 4;
            break;
        case 1:
            return 2;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell:%d,%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:(indexPath.section == 0 ? UITableViewCellStyleValue1 : UITableViewCellStyleDefault) reuseIdentifier:CellIdentifier];
    else
        return cell;
    
    if(indexPath.section == 0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.row == 0){
            cell.textLabel.text = @"Time";
            cell.detailTextLabel.text = [self formatHumanReadableTime];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Puzzle";
            cell.detailTextLabel.text = [puzzles objectAtIndex:((NSNumber *)[info objectAtIndex:2]).intValue];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"Date";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd  HH:mm"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:(NSDate *)[info objectAtIndex:1]]];
        }else{
            cell.textLabel.text = @"Scramble";
            cell.detailTextLabel.text = [info objectAtIndex:3];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Share on Twitter";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = @"Share on Facebook";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }else{
        if(!oldSession){
            [[cell textLabel] setTextAlignment: NSTextAlignmentCenter];
            cell.textLabel.text = @"Delete";
        
            UIImageView* upImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deleteButtonBgUp"]];
            UIImageView* downImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deleteButtonBgDown"]];
            
            [cell setBackgroundView: upImage];
            [cell setSelectedBackgroundView: downImage];
        
            [[upImage layer] setCornerRadius:8.0f];
            [[upImage layer] setMasksToBounds:YES];
            [[upImage layer] setBorderWidth:1.0f];
            [[upImage layer] setBorderColor: [[UIColor grayColor] CGColor]];
            
            [[downImage layer] setCornerRadius:8.0f];
            [[downImage layer] setMasksToBounds:YES];
            [[downImage layer] setBorderWidth:1.0f];
            [[downImage layer] setBorderColor: [[UIColor grayColor] CGColor]];
        
            [[cell textLabel] setTextColor: [UIColor whiteColor]];
            [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
            [cell  setBackgroundColor:[UIColor clearColor]]; // needed for 3.2 (not needed for later iOS versions)
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:20.0]];
        
            [cell.textLabel setShadowColor:[UIColor blackColor]];
            [cell.textLabel setShadowOffset:CGSizeMake(0, -1)];
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0 && indexPath.row == 3){
        NSArray *history = session;
        [[[UIAlertView alloc] initWithTitle:@"Scramble" message:[[history objectAtIndex:index] objectAtIndex:3] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            SLComposeViewController *tweetView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetView setInitialText:[NSString stringWithFormat:@"I solved %@ in %@ with SpeedCubing Timer for iOS", [puzzles objectAtIndex:((NSNumber *)[info objectAtIndex:2]).intValue], [self formatHumanReadableTime]]];
            [tweetView addURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/speedcubing-timer/id529120484?mt=8"]];
            [self presentViewController:tweetView animated:YES completion:NULL];
        } else {
            SLComposeViewController *tweetView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [tweetView setInitialText:[NSString stringWithFormat:@"I solved %@ in %@ with SpeedCubing Timer for iOS", [puzzles objectAtIndex:((NSNumber *)[info objectAtIndex:2]).intValue], [self formatHumanReadableTime]]];
            [tweetView addURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/speedcubing-timer/id529120484?mt=8"]];
            [self presentViewController:tweetView animated:YES completion:NULL];
        }
    }else if(indexPath.section == 2){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        AudioServicesPlaySystemSound(recycleSound);
        
        NSMutableArray *history = [NSMutableArray arrayWithArray:[defaults objectForKey:@"history"]];
        [history removeObjectAtIndex:index];
        [defaults setObject:history forKey:@"history"];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)formatHumanReadableTime {
    NSTimeInterval deltaTime = ((NSNumber *)[info objectAtIndex:0]).floatValue;
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
    
    return [NSString stringWithFormat:@"%@:%@:%@", minutesString, secondsString, milliSecondsString];
}

+ (SystemSoundID)createSoundID:(NSString*)name{
    NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], name];
    NSURL* filePath = [NSURL fileURLWithPath: path isDirectory: NO];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    return soundID;
}

@end
