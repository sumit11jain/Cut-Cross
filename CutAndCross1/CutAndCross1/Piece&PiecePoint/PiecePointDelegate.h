//
//  PiecePointDelegate.h
//  CutAndCross1
//
//  Created by Sumit Jain on 21/09/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PiecePoint;
@class Piece;

@protocol PiecePointDelegate <NSObject>

- (void)touchBeganAtPiecePoint:(PiecePoint*)pp;
- (void)touchEndedAtPiecePoint:(PiecePoint*)pp;

@end

@protocol PieceDelegate <NSObject>

- (void)piece:(Piece*)pc movedFromPiecePoint:(PiecePoint*)fromPp toPoint:(PiecePoint*)toPp;
- (void)piece:(Piece*)pc cutFromPiecePoint:(PiecePoint*)pp;

@end
