//
//  GamePlay.m
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "GamePlay.h"

#import "GameBoard.h"

@interface GamePlay () {
    GameBoard *gameBoard;
    
    IBOutlet UILabel *gameStatusLabel;
    
    IBOutlet UILabel *turnLabel;
    
    IBOutlet UILabel *whiteUserNameLabel;
    IBOutlet UILabel *blackUserNameLabel;
    
    IBOutlet UILabel *whiteRemaining;
    IBOutlet UILabel *blackRemaining;
    
    PlayerType selfPlayerType;
    
    uint32_t ourRandom;
    BOOL receivedRandom;
    __strong NSString *otherPlayerId;
}

@property (nonatomic, readwrite) NewGameState gameState;
@property (nonatomic, readwrite) BOOL yourTurn;

- (IBAction)dismissGameButtonPressed:(id)sender;

@end

@implementation GamePlay

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    gameBoard = nil;
}

- (IBAction)dismissGameButtonPressed:(id)sender {
//    [[SharedGameCenterHelper currentMatch] disconnect];
    [self matchEnded];
}

- (void)setYourTurn:(BOOL)yourTurn {
    _yourTurn = yourTurn;
    if (yourTurn) {
        [turnLabel setText:@"YOUR TURN"];
    } else {
        GKPlayer *otherPlayer = [[SharedGameCenterHelper playersInfoDictionary] objectForKey:otherPlayerId];

        [turnLabel setText:[NSString stringWithFormat:@"%@'s TURN", [otherPlayer alias]]];
    }
}

- (void)viewDidLoad
{
    receivedRandom = NO;
    _yourTurn = NO;
    selfPlayerType = PlayerTypeNone;

    ourRandom = arc4random();
    [self setGameState:kNewGameStateWaitingForMatch];
    
    [SharedGameCenterHelper findMatchInViewController:self forLevel:self.levelTOPlay withDelegate:self];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)setUpPlayerNames {
    if (selfPlayerType == PlayerTypeWhite)
    {
        [whiteUserNameLabel setText:[[GKLocalPlayer localPlayer] alias]];
        
        GKPlayer *otherPlayer = [[SharedGameCenterHelper playersInfoDictionary] objectForKey:otherPlayerId];
        [blackUserNameLabel setText:[otherPlayer alias]];
    }
    else
    {
        [blackUserNameLabel setText:[[GKLocalPlayer localPlayer] alias]];
        
        GKPlayer *otherPlayer = [[SharedGameCenterHelper playersInfoDictionary] objectForKey:otherPlayerId];
        [whiteUserNameLabel setText:[otherPlayer alias]];
    }
}

#pragma mark - send messages
- (void)sendData:(NSData*)data {
    NSError *error = nil;
    
    BOOL success = [[SharedGameCenterHelper currentMatch] sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        NSLog(@"error sending message to player == %@", [error localizedDescription]);
        [Utilities showAlertWithTitle:@"Error while exchanging data!" andMessage:[error localizedDescription]];

        [self matchEnded];
    }
}

- (void)sendRandomNumber {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    MessageRandomNumber randNomessage;
    randNomessage.message.messageType = kMessageTypeRandomNumber;
    randNomessage.randomNumber = ourRandom;
    
    NSData *data = [NSData dataWithBytes:&randNomessage length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

- (void)sendGameBegin {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    MessageGameBegin beginmessage;
    beginmessage.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&beginmessage length:sizeof(MessageGameBegin)];
    [self sendData:data];
    
    [self getGameBoard];

}

- (void)sendMoveMessageFromTag:(NSUInteger)fromTag toTag:(NSUInteger)toTag {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    MessageMove sendMoveMessage;
    sendMoveMessage.message.messageType = kMessageTypeMove;
    sendMoveMessage.fromTag = [[NSNumber numberWithInteger:fromTag] unsignedIntValue];
    sendMoveMessage.toTag = [[NSNumber numberWithInteger:toTag] unsignedIntValue];
    
    NSData *data = [NSData dataWithBytes:&sendMoveMessage length:sizeof(MessageMove)];
    [self sendData:data];
}

- (void)sendGameOverMessageWithRemainingPieces:(NSUInteger)remaingPieces {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    MessageGameOver gameOverMessage;
    gameOverMessage.message.messageType = kMessageTypeGameOver;
    gameOverMessage.player = selfPlayerType;
    gameOverMessage.numberOfLeftPieces = [[NSNumber numberWithInteger:remaingPieces] unsignedIntValue];
    
    NSData *data = [NSData dataWithBytes:&gameOverMessage length:sizeof(MessageGameOver)];
    [self sendData:data];
}

#pragma mark - GameBoard Delegates
- (void)sendMoveFromTag:(NSUInteger)fromTag toTag:(NSUInteger)toTag {
    [self sendMoveMessageFromTag:fromTag toTag:toTag];
    [self setYourTurn:NO];
}

- (void)remainingBlackPiece:(NSUInteger)blackPoints andWhitePiece:(NSUInteger)whitePoints {
    
    [whiteRemaining setText:[NSString stringWithFormat:@"Remaining : %lu", (unsigned long)whitePoints]];
    [blackRemaining setText:[NSString stringWithFormat:@"Remaining : %lu", (unsigned long)blackPoints]];
    
    if (blackPoints == 0) {
        [self playerWithPlayerType:PlayerTypeWhite winWithRemainingCounts:whitePoints];
    } else if (whitePoints == 0) {
        [self playerWithPlayerType:PlayerTypeBlack winWithRemainingCounts:blackPoints];
    }
}

- (void)playerWithPlayerType:(PlayerType)playerType winWithRemainingCounts:(NSUInteger)remaingPoints {
    if (playerType == selfPlayerType) {
        [self sendGameOverMessageWithRemainingPieces:remaingPoints];

        [gameStatusLabel setText:@"YOU WON/n(Tap to go back)"];
        
        [self.view bringSubviewToFront:gameStatusLabel];
        
        [gameBoard setUserInteractionEnabled:NO];
        
        [gameStatusLabel setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(matchEnded)];
        [gameStatusLabel addGestureRecognizer:tap];
    }
}

#pragma mark - GameCenter Receivers
- (void)matchStarted {
    if (receivedRandom) {
        [self setGameState:kNewGameStateWaitingForStart];
    } else {
        [self setGameState:kNewGameStateWaitingForRandomNumber];
    }
    
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)matchEnded {
    [[SharedGameCenterHelper currentMatch] disconnect];
    [SharedGameCenterHelper setCurrentMatch:nil];
    
    otherPlayerId = nil;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)match:(GKMatch*)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    // Store away other player ID for later
    if (otherPlayerId == nil) {
        otherPlayerId = playerID;
    }
    
    Message *message = (Message *) [data bytes];
    switch (message->messageType) {
        case kMessageTypeRandomNumber:
        {
            MessageRandomNumber *messageInit = (MessageRandomNumber *)message;
            NSLog(@"Received random number: %ud, ours %ud", messageInit->randomNumber, ourRandom);
            bool tie = false;
            
            if (messageInit->randomNumber == ourRandom) {
                NSLog(@"TIE!");
                tie = true;
                ourRandom = arc4random();
                [self sendRandomNumber];
            } else if (ourRandom > messageInit->randomNumber) {
                NSLog(@"We are white players");
                selfPlayerType = PlayerTypeWhite;
                
                self.yourTurn = YES;
                
                [Utilities showAlertWithTitle:@"White" andMessage:@"You have white pieces. First turn belongs to you"];
            } else {
                NSLog(@"We are black players");
                selfPlayerType = PlayerTypeBlack;

                self.yourTurn = NO;
                
                [Utilities showAlertWithTitle:@"Black" andMessage:@"You have black pieces. First turn belongs to opponent"];
            }
            
            if (!tie) {
                receivedRandom = YES;
                if (self.gameState == kNewGameStateWaitingForRandomNumber) {
                    [self setGameState:kNewGameStateWaitingForStart];
                }
                [self tryStartGame];        
            }
        }
            break;
            
        case kMessageTypeGameBegin:
        {
            [self setUpPlayerNames];
            [self setGameState:kNewGameStateActive];
            [self getGameBoard];
            if (selfPlayerType == PlayerTypeWhite)
            {
                self.yourTurn = YES;
            }
            else
            {
                self.yourTurn = NO;
            }

        }
            break;
            
        case kMessageTypeMove:
        {
            [gameBoard moveOpponentWithMoveMessage:(MessageMove *)message];
            [self setYourTurn:YES];
        }
            
            break;
            
        case kMessageTypeGameOver:
        {
            [gameStatusLabel setText:@"YOU LOOSE/n(Tap to go back)"];
            
            [self.view bringSubviewToFront:gameStatusLabel];
            
            [gameBoard setUserInteractionEnabled:NO];
            
            [gameStatusLabel setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(matchEnded)];
            [gameStatusLabel addGestureRecognizer:tap];
        }
            
            break;
    }
}

- (void)tryStartGame {
    
    if (self.gameState == kNewGameStateWaitingForStart) {
        [self setUpPlayerNames];
        [self setGameState:kNewGameStateActive];
        [self sendGameBegin];
    }
}

- (void)getGameBoard {
    gameBoard = nil;
    
    gameBoard = [[GameBoard alloc] initWithDelegate:self andMaxCoordinatePoint:[[self.dictionary objectForKey:@"Max Point"] integerValue] inFrame:CGRectMake(10, 10, 300, 300) withPlayerType:selfPlayerType];
    [gameBoard setBackgroundColor:[UIColor yellowColor]];
    [gameBoard setPoints:[self.dictionary objectForKey:@"Points"]];
    [self.view addSubview:gameBoard];
}

- (void)setGameState:(NewGameState)state {
    
    _gameState = state;
    if (_gameState == kNewGameStateWaitingForMatch) {
        [gameStatusLabel setText:@"Waiting for match"];
    } else if (_gameState == kNewGameStateWaitingForRandomNumber) {
        [gameStatusLabel setText:@"Waiting for rand #"];
    } else if (_gameState == kNewGameStateWaitingForStart) {
        [gameStatusLabel setText:@"Waiting for start"];
    } else if (_gameState == kNewGameStateActive) {
        [gameStatusLabel setText:@"Active"];
    } else if (_gameState == kNewGameStateDone) {
        [gameStatusLabel setText:@"Done"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
