//
//  BJJViewController.m
//  BJJWebserverActivityTest
//
//  Created by Barrett Jacobsen on 10/8/13.
//  Copyright (c) 2013 Barrett Jacobsen. All rights reserved.
//

#import "BJJViewController.h"
#import "BJJWebserverActivity.h"

@interface BJJViewController ()

@end

@implementation BJJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)didPressShare:(id)sender {
    NSURL *testFileURL = [[NSBundle mainBundle] URLForResource:@"Test" withExtension:@"html"];
    
    NSArray *activityItems = @[testFileURL];
    
    BJJWebserverActivity *webserverActivity = [BJJWebserverActivity new];
    
    UIImage *activityImage = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? [UIImage imageNamed:@"activity"] : [UIImage imageNamed:@"activity-ipad"];
    
    webserverActivity.activityImage = activityImage;
    
    webserverActivity.onError = ^(NSError *error) {
        NSLog(@"Error with webserver: %@", error);
    };
    
    webserverActivity.onStart = ^(NSURL *url, BJJFinishedUsingWebserverBlock finished) {
        
        NSLog(@"Get the file at: %@", url);
        
        // normally you'd display a UI here saying where to download the file and then have a done button
        
        // wait 30 seconds and then cleanup
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:30]];
        finished();
    };
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[webserverActivity]];
    
    avc.completionHandler = ^(NSString *activityType, BOOL completed){
        NSLog(@"Activity Type selected: %@", activityType);
        if (completed) {
            NSLog(@"Selected activity was performed.");
        }
        else {
            if (activityType == NULL) {
                NSLog(@"User dismissed the view controller without making a selection.");
            }
            else {
                NSLog(@"Activity was not performed.");
            }
        }
    };
    
    avc.excludedActivityTypes = [NSArray arrayWithObjects:UIActivityTypeAssignToContact, nil];
    
    [self presentViewController:avc animated:YES completion:nil];
}

@end
