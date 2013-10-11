//
//  BJJWebserverActivity.h
//  BJJWebserverActivityTest
//
//  Created by Barrett Jacobsen on 10/8/13.
//  Copyright (c) 2013 Barrett Jacobsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPConnection.h"

@class BJJWebserverActivity;

typedef void (^BJJErrorStartingWebserverBlock)(NSError *error);

typedef void (^BJJFinishedUsingWebserverBlock)(void);

typedef void (^BJJWebserverStartedBlock)(NSURL *url, BJJFinishedUsingWebserverBlock finished);

@class HTTPServer;

@interface BJJWebserverActivity : UIActivity

@property (nonatomic, readonly) HTTPServer *httpServer;

@property (nonatomic, assign) BOOL redirectToSpecifiedFile;

@property (nonatomic, strong) UIImage *activityImage;
@property (nonatomic, strong) NSString *activityTitle;

@property (nonatomic, copy) BJJErrorStartingWebserverBlock onError;
@property (nonatomic, copy) BJJWebserverStartedBlock onStart;

+ (NSString *)localWifiIPAddress;

@end

@interface RedirectingHTTPConnection : HTTPConnection
+ (void)setRedirectPath:(NSString*)path;
@end