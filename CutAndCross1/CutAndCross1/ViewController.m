//
//  ViewController.m
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "ViewController.h"
#import "GamePlay.h"
#import "PlayInstructionsViewController.h"

extern NSString * USER_GAMECENTERAUTHENTICATION_CHANGED;;

@interface ViewController () {
    NSArray *levelsInfo;
}

@end

@implementation ViewController

- (void)dealloc {
    levelsInfo = nil;
}

- (void)userAuthenticationChanged {
    if (![SharedGameCenterHelper isUserAuthenticated]) {
        [Utilities showAlertWithTitle:@"Game Center Authentication Error" andMessage:@"User is not authenticated to game center"];
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
    
    [(UITableView*)[self.view viewWithTag:1010] reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self userAuthenticationChanged];
}

- (void)viewDidLoad
{
    [NotificationCenter addObserver:self selector:@selector(userAuthenticationChanged) name:USER_GAMECENTERAUTHENTICATION_CHANGED object:nil];
    NSArray *filePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"plist" inDirectory:@"Levels Info"];
    
    NSMutableArray *info = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary *dictionary;
    for (NSString *path in filePaths) {
        dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        [info addObject:dictionary];
        dictionary = nil;
    }
    
    levelsInfo = [[NSArray alloc] initWithArray:info];
    info = nil;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [levelsInfo count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ci = @"ci";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ci];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ci];
    }
    
    cell.textLabel.text = nil;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    if (indexPath.section == 0) {
        cell.textLabel.text = levelsInfo[indexPath.row][@"Name"];
        
        if (![SharedGameCenterHelper isUserAuthenticated]) {
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            [cell setUserInteractionEnabled:NO];
        } else {
            [cell.textLabel setTextColor:[UIColor blackColor]];

            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            [cell setUserInteractionEnabled:YES];
        }
    } else {
        cell.textLabel.text = @"How to play";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if ([SharedGameCenterHelper isUserAuthenticated]) {
            GamePlay *gp = (GamePlay*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"GamePlay"];
            [gp setLevelTOPlay:indexPath.row+1];
            [gp setDictionary:levelsInfo[indexPath.row]];
            [self.navigationController pushViewController:gp animated:YES];
        } else {
            [Utilities showAlertWithTitle:@"Login Game Center!" andMessage:@"You have to login to Game Center to find opponent"];
        }
    } else {
        PlayInstructionsViewController *gp = (PlayInstructionsViewController*)[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PlayInstructionsVC"];
        [self.navigationController pushViewController:gp animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
