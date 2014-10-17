//
//  GameBoard.m
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "GameBoard.h"
#import <QuartzCore/QuartzCore.h>
#import "GameBoard+FindPiecePoint.h"

@interface GameBoard () {
    id <GameBoardDelegate> delegate;
    NSInteger respectiveMaxPoint;
    
//    GameState currentGameState;
    
    NSUInteger selectedPieceTag;
    
    NSInteger blackPlayersRemainingCount, whitePlayersRemainingCount;
}

@property (nonatomic, readwrite) CurrentGameState currentGameState;

- (float)getXPointFromXCoordinate:(float)cordinate;
- (float)getYPointFromYCoordinate:(float)cordinate;

@end

@implementation GameBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)rotateToDown {
    [self setTransform:CGAffineTransformMakeRotation(M_PI)];
    
    for (Piece *piece in [self subviews]) {
        if ([piece isKindOfClass:[Piece class]]) {
            [piece setTransform:CGAffineTransformMakeRotation(M_PI)];
        }
    }
//    self.transform = CGAffineTransformMakeScale(1.0, -1.0);
}

- (id)initWithDelegate:(id<GameBoardDelegate>)deleg andMaxCoordinatePoint:(NSInteger)respectivePoint inFrame:(CGRect)rect withPlayerType:(PlayerType)player {
    self = [super initWithFrame:rect];
    if (self) {
        respectiveMaxPoint = respectivePoint;
        delegate = deleg;
        self.currentGameState = GameStateSelectedPointNoneWithWhiteTurn;
        _gamePlayerType = player;
        UIImageView *iv = [[UIImageView alloc] initWithFrame:self.bounds];
        [iv setTag:1010101];
        [self addSubview:iv];
        iv = nil;
    }
    return self;
}

- (void)setPoints:(NSArray *)points {
    blackPlayersRemainingCount = 0;
    whitePlayersRemainingCount = 0;
    _points = points;
    [self drawBoard];
}

- (void)drawBoard {
    for (NSDictionary *point in self.points) {
        NSDictionary *coordinates = [point objectForKey:[PiecePoint coordinateKey]];
        float xPoint = [self getXPointFromXCoordinate:[[coordinates objectForKey:[PiecePoint XCoordinateKey]] floatValue]];
        float yPoint = [self getYPointFromYCoordinate:[[coordinates objectForKey:[PiecePoint YCoordinateKey]] floatValue]];
        
        NSInteger ptdb = [[point objectForKey:[PiecePoint playerTypeKey]] integerValue];
        PlayerType playerT = (PlayerType)ptdb;
        NSInteger pointTag = [[point objectForKey:[PiecePoint tagKey]] integerValue];
        CGPoint pointCenter = CGPointMake(xPoint, yPoint);
        
//        PiecePoint *pp = [[PiecePoint alloc] initWithPlayerType:playerT atFrame:CGRectMake(xPoint-PiecePointSize/2, yPoint-PiecePointSize/2, PiecePointSize, PiecePointSize) andTag:pointTag];
        PiecePoint *pp = [[PiecePoint alloc] initWithPlayerType:playerT atFrame:CGRectMake(0, 0, PiecePointSize, PiecePointSize) andTag:pointTag];
        pp.center = pointCenter;
        pp.delegate = self;
        [pp setBackgroundColor:PiecePointColor];
        pp.possibleCrosses = (NSArray*)[point objectForKey:[PiecePoint possibleCrossKey]];
        pp.possibleMovements = (NSArray*)[point objectForKey:[PiecePoint possibleMovementKey]];
        [self addSubview:pp];
        [self drawLinesForPiecePoint:pp];
        pp = nil;
        
        if (ptdb > 0) {
            if (playerT == PlayerTypeBlack) {
                blackPlayersRemainingCount = blackPlayersRemainingCount + 1;
            } else if (playerT == PlayerTypeWhite) {
                whitePlayersRemainingCount = whitePlayersRemainingCount + 1;
            }
            Piece *pc = [[Piece alloc] initWithPieceType:playerT andInitialCenterPoint:pointCenter andTagValue:pointTag];
            pc.delegate = self;
            [self addSubview:pc];
            pc = nil;
        }
    }
    
    [delegate remainingBlackPiece:blackPlayersRemainingCount andWhitePiece:whitePlayersRemainingCount];
    
    for (Piece *pc in [self subviews]) {
        if ([pc isKindOfClass:[Piece class]]) {
            [self bringSubviewToFront:pc];
        }
    }
}


- (void)drawLinesForPiecePoint:(PiecePoint*)point {
    for (NSNumber *tagValue in point.possibleMovements) {
        PiecePoint *pp = [self piecePointWithTag:[tagValue integerValue] withError:nil];
        if (pp) {
            [self drawLineFromPoint:point.center toPoint:pp.center];
//            Piece *pc = [self pieceWithTag:[tagValue integerValue] withError:nil];
//            if (pc) {
//                [self bringSubviewToFront:pc];
//            }
        }
    }
}

- (void)drawLineFromPoint:(CGPoint)fromPt toPoint:(CGPoint)toPt {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, fromPt.x, fromPt.y);
    CGPathAddLineToPoint(path, NULL, toPt.x, toPt.y);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path;
    layer.strokeColor = [PiecePointColor CGColor];
    layer.lineWidth = 0.7f;
    [self.layer addSublayer:layer];

//    UIGraphicsBeginImageContext(self.frame.size);
//    [[(UIImageView*)[self viewWithTag:1010101] image] drawInRect:self.bounds];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
//    CGContextSetLineWidth(context, 1.0);
//    CGContextMoveToPoint(context, fromPt.x, fromPt.y);
//    CGContextAddLineToPoint(context, toPt.x, toPt.y);
//    CGContextStrokePath(context);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    [(UIImageView*)[self viewWithTag:1010101] setImage:image];
//    UIGraphicsEndImageContext();
}

- (float)getXPointFromXCoordinate:(float)cordinate {
    float width = self.frame.size.width - RightMarginOfBoard - LeftMarginOfBoard;
    float xPt = (cordinate*width)/respectiveMaxPoint;
    
    return (xPt+LeftMarginOfBoard);
}

- (float)getYPointFromYCoordinate:(float)cordinate {
    float height = self.frame.size.height - TopMarginOfBoard - BottomMarginOfBoard;
    float xPt = (cordinate*height)/respectiveMaxPoint;
    
    return (xPt+TopMarginOfBoard);
}

#pragma mark PiecePointDelegate
- (void)touchBeganAtPiecePoint:(PiecePoint *)pp {
    
}

- (void)touchEndedAtPiecePoint:(PiecePoint *)pp {
    switch (self.currentGameState) {
        case GameStateSelectedPointNoneWithWhiteTurn:
        {
            if (pp.playerType == PlayerTypeWhite && self.gamePlayerType == PlayerTypeWhite) {
                [self selectPiecePoint:pp];
                selectedPieceTag = pp.pointTag;
                self.currentGameState = GameStateSelectedPointToMove;
            }
        }
            break;

        case GameStateSelectedPointNoneWithBlackTurn:
        {
            if (pp.playerType == PlayerTypeBlack && self.gamePlayerType == PlayerTypeBlack) {
                [self selectPiecePoint:pp];
                selectedPieceTag = pp.pointTag;
                self.currentGameState = GameStateSelectedPointToMove;
            }
        }
            break;

        case GameStateSelectedPointToMove:
        {
            NSError *er = nil;
            Piece *selectedPiece = [self pieceWithTag:selectedPieceTag withError:&er];
            if (selectedPieceTag == pp.pointTag) { //in case selected point is again clicked
                //unselect selected point
                if (selectedPiece) {
                    [selectedPiece unreflect];
                }
                [self stopReflectingPiecePointRelatedToPoint:pp];
                
                //change state
                self.currentGameState = GameStateSelectedPointNoneWithWhiteTurn;
                if (pp.playerType == PlayerTypeBlack) {
                    self.currentGameState = GameStateSelectedPointNoneWithBlackTurn;
                }
                return; //return to finish task
            }
            
            PiecePoint *selectedPoint = [self piecePointWithTag:selectedPieceTag withError:&er];
            if (!er) {
                if (selectedPoint) {
                    if ([[selectedPoint possibleMovements] containsObject:[NSNumber numberWithInteger:pp.pointTag]]) {  //check for movement only
                        if (selectedPiece) {
                            if (pp.playerType == PlayerTypeNone) {  //if the point doesn't contain any player than only it will move
                                self.currentGameState = GameStateMovingPiece;   //change game state

                                if (selectedPoint.playerType == self.gamePlayerType) {
                                    [delegate sendMoveFromTag:selectedPieceTag toTag:pp.pointTag];
                                }
                                
                                [selectedPiece moveFromPiecePoint:selectedPoint ToPiecePoint:pp inSteps:1]; //to move piece from one position to another
                                [self bringSubviewToFront:selectedPiece]; //to bring the piece in front in view
                                [self stopReflectingPiecePointRelatedToPoint:selectedPoint];
                                [pp startReflecting];   //only selected point will reflect
                                
                                return; //return to finish task
                            }
                        }
                    }
                    if ([[selectedPoint possibleCrosses] containsObject:[NSNumber numberWithUnsignedInteger:pp.pointTag]]) {    //check for crossing and cutting
                        if (selectedPiece) {
                            if (pp.playerType == PlayerTypeNone) {  //if the point doesn't contain any player than only it will move
                                NSUInteger cutPointTag = (pp.pointTag+selectedPoint.pointTag)/2;
                                PiecePoint *cutPoint = [self piecePointWithTag:cutPointTag withError:&er];
                                if (!er && cutPoint) {
                                    if ((cutPoint.playerType != selectedPoint.playerType) && (cutPoint.playerType != PlayerTypeNone)) { //if cut point has only opponent player
                                        self.currentGameState = GameStateMovingPiece;   //change game state
                                        
                                        if (selectedPoint.playerType == self.gamePlayerType) {
                                            [delegate sendMoveFromTag:selectedPieceTag toTag:pp.pointTag];
                                        }
                                        
                                        [selectedPiece moveFromPiecePoint:selectedPoint ToPiecePoint:pp inSteps:2];
                                        Piece *cutPiece = [self pieceWithTag:cutPointTag withError:&er];
                                        if (!er && cutPiece) {
                                            [cutPiece cutToRemoveFromPiecePoint:cutPoint];
                                        }
                                        
                                        [self bringSubviewToFront:selectedPiece]; //to bring the piece in front in view
                                        [self stopReflectingPiecePointRelatedToPoint:selectedPoint];
                                        [pp startReflecting];   //only selected point will reflect
                                        
                                        return; //return to finish task
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
            break;

        case GameStateMovingPiece:
        {
            
        }
            break;

    }
}

- (void)stopReflectingPiecePointRelatedToPoint:(PiecePoint*)pp {
    for (NSNumber *possibleTag in [pp possibleMovements]) {
        PiecePoint *pointToUnreflect = [self piecePointWithTag:[possibleTag integerValue] withError:nil];
        if (pointToUnreflect) {
            [pointToUnreflect stopReflecting];
        }
    }
    for (NSNumber *possibleTag in [pp possibleCrosses]) {
        PiecePoint *pointToUnreflect = [self piecePointWithTag:[possibleTag integerValue] withError:nil];
        if (pointToUnreflect) {
            [pointToUnreflect stopReflecting];
        }
    }
}

- (void)selectPiecePoint:(PiecePoint*)pp {
    for (NSNumber *tg in [pp possibleMovements]) {
        NSError *ppEr = nil;
        PiecePoint *piecePoint = [self piecePointWithTag:[tg integerValue] withError:&ppEr];
        if (!ppEr) {
            if (piecePoint) {
                if (piecePoint.playerType == PlayerTypeNone) {
                    [piecePoint startReflecting];
                }
            }
        }
    }
    for (NSNumber *tg in [pp possibleCrosses]) {
        NSError *ppEr = nil;
        PiecePoint *piecePoint = [self piecePointWithTag:[tg integerValue] withError:&ppEr];
        if (!ppEr) {
            if (piecePoint) {
                if (piecePoint.playerType == PlayerTypeNone) {
                    NSUInteger cutPointTag = (pp.pointTag+piecePoint.pointTag)/2;
                    PiecePoint *cutPoint = [self piecePointWithTag:cutPointTag withError:nil];
                    if (cutPoint) {
                        if ((cutPoint.playerType != pp.playerType) && (cutPoint.playerType != PlayerTypeNone)) {
                            [piecePoint startReflecting];
                        }
                    }
                }
            }
        }
    }
    NSError *pcEr;
    Piece *pc = [self pieceWithTag:[pp pointTag] withError:&pcEr];
    if (!pcEr) {
        if (pc) {
            [pc reflect];
        }
    }
}

- (void)moveOpponentWithMoveMessage:(MessageMove*)move {
    uint fromTag = move->fromTag;
    uint toTag = move->toTag;
    
    selectedPieceTag = fromTag;
    self.currentGameState = GameStateSelectedPointToMove;
    
    PiecePoint *pp = [self piecePointWithTag:toTag withError:nil];
    if (pp) {
        [self touchEndedAtPiecePoint:pp];
    }
}

#pragma mark PieceDelegate
- (void)piece:(Piece *)pc movedFromPiecePoint:(PiecePoint *)fromPp toPoint:(PiecePoint *)toPp {
    toPp.playerType = fromPp.playerType;
    fromPp.playerType = PlayerTypeNone;
    [pc unreflect];
    [toPp stopReflecting];
    if (toPp.playerType == PlayerTypeWhite) {
        self.currentGameState = GameStateSelectedPointNoneWithBlackTurn;
    } else {
        self.currentGameState = GameStateSelectedPointNoneWithWhiteTurn;
    }
}

- (void)piece:(Piece *)pc cutFromPiecePoint:(PiecePoint *)pp {
    [pc removeFromSuperview];
    
    if (pp.playerType == PlayerTypeBlack) {
        blackPlayersRemainingCount = blackPlayersRemainingCount - 1;
    } else if (pp.playerType == PlayerTypeWhite) {
        whitePlayersRemainingCount = whitePlayersRemainingCount - 1;
    }
    
    pp.playerType = PlayerTypeNone;
    
    [delegate remainingBlackPiece:blackPlayersRemainingCount andWhitePiece:whitePlayersRemainingCount];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

- (void)setCurrentGameState:(CurrentGameState)currentGameState {
    [self setUserInteractionEnabled:YES];
    if ((currentGameState == GameStateSelectedPointNoneWithBlackTurn) || (currentGameState == GameStateSelectedPointNoneWithWhiteTurn)) {
        selectedPieceTag = 0;
    } else if (currentGameState == GameStateMovingPiece) {
        [self setUserInteractionEnabled:NO];
    }
    
    _currentGameState = currentGameState;
}

@end
