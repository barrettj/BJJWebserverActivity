//
//  BJJWebserverActivity.h
//  BJJWebserverActivityTest
//
//  Created by Barrett Jacobsen on 10/8/13.
//  Copyright (c) 2013 Barrett Jacobsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BJJWebserverActivity;

typedef void (^BJJErrorStartingWebserverBlock)(NSError *error);

typedef void (^BJJFinishedUsingWebserverBlock)(void);

typedef void (^BJJWebserverStartedBlock)(NSURL *url, BJJFinishedUsingWebserverBlock finished);



@interface BJJWebserverActivity : UIActivity

@property (nonatomic, strong) UIImage *activityImage;
@property (nonatomic, strong) NSString *activityTitle;

@property (nonatomic, copy) BJJErrorStartingWebserverBlock onError;
@property (nonatomic, copy) BJJWebserverStartedBlock onStart;

+ (NSString *)localWifiIPAddress;

@end
