//
//  StatsViewController.m
//  SpeedCubing Timer
//
//  Created by Oskar Nyberg on 2012-06-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StatsViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *puzzles = [NSArray arrayWithObjects:@"Rubik's Cube 3x3", @"Rubik's 2x2", @"Rubik's 4x4", @"Rubik's/Vcube 5x5", @"Vcube 6x6", @"Vcube 7x7", @"Megaminx", @"Pyraminx", @"Rubik's 3x3 Blindfold", nil];
    self.title = [NSString stringWithFormat:@"Statistics for %@", [puzzles objectAtIndex:[defaults integerForKey:@"selectedPuzzle"]]];
    
    [super viewDidLoad];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellAt:%d,%d", indexPath.section, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:(indexPath.row == 5 ? UITableViewCellStyleDefault : UITableViewCellStyleValue1) reuseIdentifier:CellIdentifier];
    else
        return cell;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row == 0){
        cell.textLabel.text = @"Personal Best";
        
        NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
        if(history == nil || history.count <= 0){
            cell.detailTextLabel.text = @"-";
        }
        else{
            NSArray *currentBest;
            NSTimeInterval currentBestTime = NSIntegerMax;
            for(NSArray *arr in history){
                if(((NSNumber *)[arr objectAtIndex:0]).floatValue < currentBestTime){
                    currentBestTime = ((NSNumber *)[arr objectAtIndex:0]).floatValue;
                    currentBest = arr;
                }
            }
        
            cell.detailTextLabel.text = [self stringFromTimeInterval:((NSNumber *)[currentBest objectAtIndex:0]).floatValue];
        }
    }
    else if(indexPath.row == 1){
        cell.textLabel.text = @"Average";
        
        NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
        if(history == nil || history.count <= 0){
            cell.detailTextLabel.text = @"-";
        }
        else{
            NSTimeInterval time = 0;
            NSInteger times = 0;
            for(NSArray *arr in history){
                time += ((NSNumber *)[arr objectAtIndex:0]).floatValue;
                times++;
            }
        
            cell.detailTextLabel.text = [self stringFromTimeInterval:time/times];
        }
    }
    else if(indexPath.row == 2){
        cell.textLabel.text = @"Average of 5";
        
        NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
        if(history == nil || history.count <= 0){
            cell.detailTextLabel.text = @"-";
        }
        else if(history.count < 5){
            cell.detailTextLabel.text = @"-";
        }
        else{
            NSTimeInterval time = 0;
            for(NSInteger i=(history.count-1); i>=(history.count-5) && i>=0; i--)
                time += ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
        
            cell.detailTextLabel.text = [self stringFromTimeInterval:time/5];
        }
    }
    else if(indexPath.row == 3){
        cell.textLabel.text = @"3 of 5";
        
        NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
        if(history == nil || history.count <= 0){
            cell.detailTextLabel.text = @"-";
        }
        else if(history.count < 5){
            cell.detailTextLabel.text = @"-";
        }
        else{
            NSTimeInterval max = NSIntegerMin;
            NSTimeInterval min = NSIntegerMax;
            NSTimeInterval time = 0;
            for(NSInteger i=(history.count-1); i>=(history.count-5) && i>=0; i--){
                time += ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
                if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue > max)
                    max = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
                else if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue < min)
                    min = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
            }
            time -= max + min;
        
            cell.detailTextLabel.text = [self stringFromTimeInterval:time/3];
        }
    }
    else if(indexPath.row == 4){
        cell.textLabel.text = @"10 of 12";
        
        NSArray *history = [self historyForPuzzle:[defaults integerForKey:@"selectedPuzzle"]];
        if(history == nil || history.count <= 0){
            cell.detailTextLabel.text = @"-";
        }
        else if(history.count < 12){
            cell.detailTextLabel.text = @"-";
        }
        else{
            NSTimeInterval max = NSIntegerMin;
            NSTimeInterval min = NSIntegerMax;
            NSTimeInterval time = 0;
            for(NSInteger i=(history.count-1); i>=(history.count-12) && i>=0; i--){
                time += ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
                if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue > max)
                    max = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
                else if(((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue < min)
                    min = ((NSNumber *)[[history objectAtIndex:i] objectAtIndex:0]).floatValue;
            }
            time -= max + min;
        
            cell.detailTextLabel.text = [self stringFromTimeInterval:time/10];
        }
    }
    else if(indexPath.row == 5){
        cell.textLabel.text = @"Progress Graphs";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
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
- (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval{
    NSTimeInterval deltaTime = timeInterval;
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
    if(indexPath.row == 5){
        [self performSegueWithIdentifier:@"GoToGraphs" sender:self];
    }
}

@end
