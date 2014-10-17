//
//  GameBoard.h
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PiecePoint.h"
#import "Piece.h"

#define LeftMarginOfBoard   16.0
#define RightMarginOfBoard  16.0
#define TopMarginOfBoard    16.0
#define BottomMarginOfBoard 16.0

@protocol GameBoardDelegate;

@interface GameBoard : UIView <PieceDelegate, PiecePointDelegate>

- (id)initWithDelegate:(id <GameBoardDelegate>)deleg andMaxCoordinatePoint:(NSInteger)respectivePoint inFrame:(CGRect)rect withPlayerType:(PlayerType)player;

@property (nonatomic, strong) NSArray *points;
@property (nonatomic, readonly) PlayerType gamePlayerType;

- (void)moveOpponentWithMoveMessage:(MessageMove*)move;

- (void)rotateToDown;

@end

@protocol GameBoardDelegate <NSObject>

- (void)sendMoveFromTag:(NSUInteger)fromTag toTag:(NSUInteger)toTag;

- (void)remainingBlackPiece:(NSUInteger)blackPoints andWhitePiece:(NSUInteger)whitePoints;

@end
