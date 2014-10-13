//
//  GameBoard+FindPiecePoint.h
//  CutAndCross1
//
//  Created by Sumit Jain on 21/09/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "GameBoard.h"

@interface GameBoard (FindPiecePoint)

- (Piece*)pieceWithTag:(NSUInteger)tag withError:(NSError**)err;
- (PiecePoint*)piecePointWithTag:(NSUInteger)tag withError:(NSError**)err;

@end
