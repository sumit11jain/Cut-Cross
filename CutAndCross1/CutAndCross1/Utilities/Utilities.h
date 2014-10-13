//
//  Utilities.h
//  CutAndCross1
//
//  Created by Sumit Jain on 10/9/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SharedApplication   [UIApplication sharedApplication]
#define CurrentDevice       [UIDevice currentDevice]
#define UserDefault         [NSUserDefaults standardUserDefaults]
#define NotificationCenter  [NSNotificationCenter defaultCenter]
#define GameCenterPlayer    [GKLocalPlayer localPlayer]

@interface Utilities : NSObject

+ (UIStoryboard*)appStoryboard;

+ (void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message;
+ (BOOL)connectedToNetwork;

@end
