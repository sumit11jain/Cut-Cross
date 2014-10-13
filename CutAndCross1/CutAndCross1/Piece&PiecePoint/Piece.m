//
//  Piece.m
//  CutAndCross1
//
//  Created by Sumit Jain on 21/09/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "Piece.h"
#import "PiecePoint.h"

#define BLACKPIECE_IMAGENAME    @"Black_Piece"
#define WHITEPIECE_IMAGENAME    @"White_Piece"

@implementation Piece

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithPieceType:(PlayerType)playerType andInitialCenterPoint:(CGPoint)center andTagValue:(NSUInteger)tagV{
    self = [super initWithFrame:CGRectMake(0, 0, PiecePointSize, PiecePointSize)];
    if (self) {
        _tagValue = tagV;
        self.center = center;
        self.image = [UIImage imageNamed:WHITEPIECE_IMAGENAME];
        if (playerType == PlayerTypeBlack) {
            self.image = [UIImage imageNamed:BLACKPIECE_IMAGENAME];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.layer setCornerRadius:PiecePointSize/2];
    [self.layer setMasksToBounds:YES];
}

- (void)moveFromPiecePoint:(PiecePoint*)fromPp ToPiecePoint:(PiecePoint*)toPp inSteps:(NSUInteger)steps {
    [UIView animateWithDuration:PIECEMOVEMENT_DURATION_PERSTEP*steps animations:^ {
        self.center = toPp.center;
    } completion:^(BOOL finished) {
        _tagValue = toPp.pointTag;
        [self.delegate piece:self movedFromPiecePoint:fromPp toPoint:toPp];
    }];
}

- (void)reflect {
    [self.layer setBorderColor:[[UIColor redColor] CGColor]];
    [self.layer setBorderWidth:2.0];
}

- (void)unreflect {
    [self.layer setBorderColor:nil];
    [self.layer setBorderWidth:0];
}

- (void)cutToRemoveFromPiecePoint:(PiecePoint*)pp {
    [UIView animateWithDuration:PIECEMOVEMENT_DURATION_PERSTEP animations:^ {
        self.alpha = 0.2;
    } completion:^(BOOL finished) {
        [self.delegate piece:self cutFromPiecePoint:pp];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
