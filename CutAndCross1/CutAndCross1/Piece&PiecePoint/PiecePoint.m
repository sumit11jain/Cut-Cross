//
//  PiecePoint.m
//  CutAndCross1
//
//  Created by Sumit Jain on 7/29/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "PiecePoint.h"

#define REFLECTING_COLOR_1  [UIColor whiteColor]
#define REFLECTING_COLOR_2  [UIColor blackColor]

@interface PiecePoint () {
//    NSTimer *reflectTimer;
    CADisplayLink *reflectTimer;
    
    BOOL touchesMoved;
}

@end

@implementation PiecePoint

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (PiecePoint*)initWithPlayerType:(PlayerType)playerType atFrame:(CGRect)frame andTag:(NSUInteger)tag {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pointTag = tag;
        _playerType = playerType;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [[self layer] setCornerRadius:PiecePointSize/2];
    [[self layer] setMasksToBounds:YES];
}

- (void)startReflecting {
    reflectTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(reflect:)];
    [reflectTimer setFrameInterval:60];
    [reflectTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    NSInvocation *invoc = [NSInvocation new];
//    [invoc setTarget:self];
//    [invoc setSelector:@selector(reflect:)];
//    reflectTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invoc repeats:YES];
//    reflectTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(reflect:) userInfo:nil repeats:YES];
}

- (void)reflect:(id)timer {
    if ([self.backgroundColor isEqual:REFLECTING_COLOR_1]) {
        [self setBackgroundColor:REFLECTING_COLOR_2];
        return;
    }
    [self setBackgroundColor:REFLECTING_COLOR_1];
}

- (void)stopReflecting {
    if (reflectTimer) {
        [reflectTimer invalidate];
        reflectTimer = nil;
    }
    [self setBackgroundColor:PiecePointColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    touchesMoved = NO;
    [super touchesBegan:touches withEvent:event];
    [self.delegate touchBeganAtPiecePoint:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    touchesMoved = YES;
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!touchesMoved) {
        [self.delegate touchEndedAtPiecePoint:self];
    }
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

@implementation PiecePoint (KEYS_NAME)

+ (NSString*)tagKey {
    return @"Tag";
}

+ (NSString*)isOccupiedKey {
    return @"Is Occupied";
}

+ (NSString*)playerTypeKey {
    return @"Occupied Type";
}

+ (NSString*)coordinateKey {
    return @"Coordinate";
}

+ (NSString*)XCoordinateKey {
    return @"X";
}

+ (NSString*)YCoordinateKey {
    return @"Y";
}

+ (NSString*)possibleMovementKey {
    return @"Possible Movements";
}

+ (NSString*)possibleCrossKey {
    return @"Possible Crosses";
}

@end