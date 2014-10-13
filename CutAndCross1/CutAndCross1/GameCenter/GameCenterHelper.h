//
//  GameCenterHelper.h
//  CutAndCross1
//
//  Created by Sumit Jain on 10/9/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define SharedGameCenterHelper    [GameCenterHelper sharedInstance]

extern NSString const *USER_GAMECENTERAUTHENTICATION_CHANGED;;

@protocol GameCenterHelperDelegate;     //declaring the protocol

@interface GameCenterHelper : NSObject {
    
    BOOL matchStarted;
    
    GKInvite *pendingInvite;
    NSArray *pendingPlayersToInvite;
}

@property (nonatomic, readonly) BOOL isUserAuthenticated;;
@property (retain) UIViewController *presentViewController;
@property (retain) GKMatch *currentMatch;
@property (assign) id <GameCenterHelperDelegate> gcDelegate;
@property (nonatomic, strong) NSMutableDictionary *playersInfoDictionary;

+ (GameCenterHelper*)sharedInstance;    //singleton instance of class
- (void)authenticateDeviceUser;         //this method will be called by instance variable of class to authenticate user. this will be called when app starts up

- (void)findMatchInViewController:(UIViewController*)controller forLevel:(NSInteger)level withDelegate:(id<GameCenterHelperDelegate>)delegate;

@end


@protocol GameCenterHelperDelegate <NSObject>

- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch*)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;

@end

//http://www.raywenderlich.com/3276/game-center-tutorial-for-ios-how-to-make-a-simple-multiplayer-game-part-12
//http://www.raywenderlich.com/3325/game-center-tutorial-for-ios-how-to-make-a-simple-multiplayer-game-part-22