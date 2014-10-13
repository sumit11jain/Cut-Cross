//
//  Piece.h
//  CutAndCross1
//
//  Created by Sumit Jain on 21/09/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerTypeInformation.h"
#import "PiecePointDelegate.h"

#define PIECEMOVEMENT_DURATION_PERSTEP  1.5

@class PiecePoint;

@interface Piece : UIImageView

- (id)initWithPieceType:(PlayerType)playerType andInitialCenterPoint:(CGPoint)center andTagValue:(NSUInteger)tagV;

@property (nonatomic, assign) id <PieceDelegate> delegate;

@property (nonatomic, readonly) NSUInteger tagValue;

- (void)reflect;
- (void)unreflect;

- (void)moveFromPiecePoint:(PiecePoint*)fromPp ToPiecePoint:(PiecePoint*)toPp inSteps:(NSUInteger)steps;

- (void)cutToRemoveFromPiecePoint:(PiecePoint*)pp;

@end
