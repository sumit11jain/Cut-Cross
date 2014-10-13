//
//  GamePlay.h
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameBoard.h"
#import "GameCenterHelper.h"

@interface GamePlay : UIViewController <GameCenterHelperDelegate, GameBoardDelegate>

@property (nonatomic, strong) NSDictionary *dictionary;

@property (nonatomic, readwrite) NSInteger levelTOPlay;

@end
