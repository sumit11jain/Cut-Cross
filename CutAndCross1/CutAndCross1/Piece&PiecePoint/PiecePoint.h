//
//  PiecePoint.h
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerTypeInformation.h"
#import "PiecePointDelegate.h"

#define PiecePointSize  32.0f
#define PiecePointColor [UIColor grayColor]

@interface PiecePoint : UIView

- (PiecePoint*)initWithPlayerType:(PlayerType)playerType atFrame:(CGRect)frame andTag:(NSUInteger)tag;

@property (nonatomic, assign) id <PiecePointDelegate> delegate;

@property (nonatomic, readonly) NSUInteger pointTag;

@property (nonatomic, readwrite) PlayerType playerType;

@property (nonatomic, strong) NSArray *possibleMovements;
@property (nonatomic, strong) NSArray *possibleCrosses;

- (void)startReflecting;
- (void)stopReflecting;

@end

@interface PiecePoint (KEYS_NAME)

+ (NSString*)tagKey;
+ (NSString*)isOccupiedKey;
+ (NSString*)playerTypeKey;
+ (NSString*)coordinateKey;
+ (NSString*)XCoordinateKey;
+ (NSString*)YCoordinateKey;
+ (NSString*)possibleMovementKey;
+ (NSString*)possibleCrossKey;

@end