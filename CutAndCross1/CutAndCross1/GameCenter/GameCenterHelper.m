//
//  GameCenterHelper.m
//  CutAndCross1
//
//  Created by Sumit Jain on 10/9/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "GameCenterHelper.h"

NSString *USER_GAMECENTERAUTHENTICATION_CHANGED = @"USER_GAMECENTERAUTHENTICATION_CHANGED";

static GameCenterHelper *gchelperSingObj = nil;

@interface GameCenterHelper () <UINavigationControllerDelegate, GKMatchDelegate, GKMatchmakerViewControllerDelegate>

- (void)lookForPlayers;

@end

@implementation GameCenterHelper

#pragma mark - Contructors and Objects

+ (id)alloc {
    
//    if (gchelperSingObj) {
        NSAssert((gchelperSingObj == nil), @"Try to create another object of GameCenterHelper class"); //so no 2 objects are created
//    }
    gchelperSingObj = [super alloc]; //if reach to this step than allocates the memory to instance
    
    return gchelperSingObj;
}

+ (GameCenterHelper*)sharedInstance {
    if (!gchelperSingObj) {
        gchelperSingObj = [[GameCenterHelper alloc] init];
    }
    return gchelperSingObj;
}

- (id)init {
    if ((self = [super init])) {
        [NotificationCenter addObserver:self selector:@selector(authenticationDidChange) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];      //register for authentication change notification
    }
    return self;
}

#pragma mark - Authentication Methods

- (void)authenticationDidChange {
    if ([GameCenterPlayer isAuthenticated] && !_isUserAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        _isUserAuthenticated = YES;
        [NotificationCenter postNotificationName:USER_GAMECENTERAUTHENTICATION_CHANGED object:nil];
    } else if (![GameCenterPlayer isAuthenticated] && _isUserAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated.");
        _isUserAuthenticated = NO;
        [NotificationCenter postNotificationName:USER_GAMECENTERAUTHENTICATION_CHANGED object:nil];
    }
}

- (void)authenticateDeviceUser {
    if ([GameCenterPlayer isAuthenticated] == NO) { //check if user is authenticated or not
        [GameCenterPlayer setAuthenticateHandler:^(UIViewController *viewController, NSError *error) { //authenticate if user is not authenticated
            if (viewController) {
                [self presentViewController:viewController];
            } else if (error) {
                [Utilities showAlertWithTitle:@"Game Center Error!" andMessage:[error localizedDescription]];
            }
        }];
    }
}

#pragma mark authentication VCs

- (UIViewController*) getRootViewController {
    return [[SharedApplication keyWindow] rootViewController];  //getting the most root view controller of the windows
}

- (void)presentViewController:(UIViewController*)vc {
    [[self getRootViewController] presentViewController:vc animated:YES completion:NULL];
}

#pragma mark -
- (void)findMatchInViewController:(UIViewController*)controller forLevel:(NSInteger)level withDelegate:(id<GameCenterHelperDelegate>)delegate {
    
    //initial settings
    _playersInfoDictionary = nil;
    matchStarted = NO;
    self.currentMatch = nil;
    self.presentViewController = controller;    //object given for future use
    self.gcDelegate = delegate;                 //delegate assignment
    
    [_presentViewController dismissViewControllerAnimated:NO completion:NULL];  //dismiss any previously existing modal view controllers
    
    //match request
    GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
    [matchRequest setMinPlayers:2];             // Minimum number of players for the match
    [matchRequest setMaxPlayers:2];             // Maximum number of players for the match
    [matchRequest setPlayerGroup:level];        // to find match only with these players
    
    GKMatchmakerViewController *matchMakerVc = [[GKMatchmakerViewController alloc] initWithMatchRequest:matchRequest];  // Initialize with a matchmaking request, allowing the user to send invites and/or start matchmaking
    [matchMakerVc setDelegate:self];
    [matchMakerVc setMatchmakerDelegate:self];
    
    [_presentViewController presentViewController:matchMakerVc animated:YES completion:NULL];
}

#pragma mark - GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [_presentViewController dismissViewControllerAnimated:YES completion:NULL];
    
    [self.gcDelegate matchEnded];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [_presentViewController dismissViewControllerAnimated:YES completion:NULL];
    
    NSLog(@"%@\nerror finding match == %@", NSStringFromSelector(_cmd), [error localizedDescription]);

    [Utilities showAlertWithTitle:@"ERROR" andMessage:[error localizedDescription]];
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
    [_presentViewController dismissViewControllerAnimated:YES completion:NULL];
    
    self.currentMatch = match;
    [match setDelegate:self];
    if ((!matchStarted) && ([match expectedPlayerCount] == 0)) {
        NSLog(@"Ready to start match");
        
        [self lookForPlayers];
    }
}

//- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didReceiveAcceptFromHostedPlayer:(NSString *)playerID {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//}

#pragma mark - GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (match != _currentMatch) return;         // return if data of some other match is received
    
    [self.gcDelegate match:match didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (match != _currentMatch) return;         //return id data of some other match is received
    
    switch (state) {
        case GKPlayerStateUnknown:          // initial player state
            
            break;

        case GKPlayerStateConnected:        // connected to the match
        {
            NSLog(@"Player connected");
            if ((!matchStarted) && ([match expectedPlayerCount] == 0)) {

                [self lookForPlayers];
            }
        }
            break;

        case GKPlayerStateDisconnected:     // disconnected from the match
        {
            NSLog(@"Player disconnected");
            matchStarted = NO;
            [Utilities showAlertWithTitle:@"Game Center Error!" andMessage:@"Player Disconnected"];

            [self.gcDelegate matchEnded];

        }
            break;

    }
    
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    if (match != _currentMatch) return;         //return id data of some other match is received
    
    NSLog(@"%@\nfailed to connect to player == %@", NSStringFromSelector(_cmd), [error localizedDescription]);
    
    matchStarted = NO;
    
    [Utilities showAlertWithTitle:@"Match Error!" andMessage:[error localizedDescription]];

    [self.gcDelegate matchEnded];
}

- (void)lookForPlayers {
    NSLog(@"Looking for %lu players", (unsigned long)[self.currentMatch.playerIDs count]);
    
    [GKPlayer loadPlayersForIdentifiers:self.currentMatch.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error) {
            NSLog(@"Error Retrieving Player info == %@", [error localizedDescription]);
            matchStarted = NO;
            [Utilities showAlertWithTitle:@"Error while looking for player!" andMessage:[error localizedDescription]];
            [self.gcDelegate matchEnded];
        } else {
            //populate players dictionary
            _playersInfoDictionary = [[NSMutableDictionary alloc] initWithCapacity:[players count]];
            
            for (GKPlayer *player in players) {
                NSLog(@"Found Player == %@", player.alias);
                [_playersInfoDictionary setObject:player forKey:player.playerID];
            }
            
            //now match can begin
            matchStarted = YES;
            [self.gcDelegate matchStarted];
        }
    }];
}

@end
