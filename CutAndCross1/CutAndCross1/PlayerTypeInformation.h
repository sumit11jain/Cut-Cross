//
//  PlayerTypeInformation.h
//  CutAndCross1
//
//  Created by Impinge Sumit Jain on 28/08/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

typedef enum {
    PlayerTypeNone = 0,
    PlayerTypeWhite,
    PlayerTypeBlack
}PlayerType;

typedef enum {
    GameStateSelectedPointNoneWithWhiteTurn = 0,
    GameStateSelectedPointNoneWithBlackTurn,
    GameStateSelectedPointToMove,
//    GameStateSelectedPointWhite,
//    GameStateSelectedPointBlack,
    GameStateMovingPiece
}CurrentGameState;

typedef enum {
    kNewGameStateWaitingForMatch = 0,
    kNewGameStateWaitingForRandomNumber,
    kNewGameStateWaitingForStart,
    kNewGameStateActive,
    kNewGameStateDone
}NewGameState;

typedef enum {
    kEndReasonWin,
    kEndReasonLose,
    kEndReasonDisconnected
}GameEndReasons;

#pragma mark - Message Sending Types & Formats
typedef enum {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver
}MessageType;

typedef struct {
    MessageType messageType;
}Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
}MessageRandomNumber;

typedef struct {
    Message message;
}MessageGameBegin;

typedef struct {
    Message message;
    uint fromTag;
    uint toTag;
}MessageMove;

typedef struct {
    Message message;
    PlayerType player;
    uint numberOfLeftPieces;
}MessageGameOver;