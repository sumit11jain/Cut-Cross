//
//  Utilities.m
//  CutAndCross1
//
//  Created by Sumit Jain on 10/9/14.
//  Copyright (c) 2014 Impinge Solution. All rights reserved.
//

#import "Utilities.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>

@implementation Utilities

+ (UIStoryboard*)appStoryboard {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    return storyBoard;
}

+ (void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    alert = nil;
}
+ (BOOL)connectedToNetwork {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
    return ((isReachable && !needsConnection) || nonWiFi) ?
	(([[NSURLConnection alloc] initWithRequest:[NSURLRequest
												requestWithURL: [NSURL URLWithString:@"http://www.apple.com/"]
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0]
									  delegate:nil]) ? YES : NO) : NO;
}

@end
