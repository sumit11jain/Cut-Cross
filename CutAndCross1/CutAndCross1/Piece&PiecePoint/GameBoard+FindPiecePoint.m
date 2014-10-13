//
//  GameBoard+FindPiecePoint.m
//  CutAndCross1
//
//  Created by Sumit Jain on 21/09/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "GameBoard+FindPiecePoint.h"

@implementation GameBoard (FindPiecePoint)

- (Piece*)pieceWithTag:(NSUInteger)tag withError:(NSError *__autoreleasing *)err {
    for (Piece *pc in [self subviews]) {
        if ([pc isKindOfClass:[Piece class]]) {
            if ([pc tagValue] == tag) {
//                break;
                return pc;
            }
            continue;
        }
        continue;
    }
    if (err) {
        *err = [NSError errorWithDomain:@"Piece with given tag not available" code:-1 userInfo:nil];
    }
    return nil;
}
- (PiecePoint*)piecePointWithTag:(NSUInteger)tag withError:(NSError *__autoreleasing *)err {
    for (PiecePoint *pc in [self subviews]) {
        if ([pc isKindOfClass:[PiecePoint class]]) {
            if ([pc pointTag] == tag) {
//                break;
                return pc;
            }
            continue;
        }
        continue;
    }
    if (err) {
        *err = [NSError errorWithDomain:@"PiecePoint with given tag not available" code:-1 userInfo:nil];
    }
    return nil;
}

@end
