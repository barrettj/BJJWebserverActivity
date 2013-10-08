//
//  BJJWebserverActivity.m
//  BJJWebserverActivityTest
//
//  Created by Barrett Jacobsen on 10/8/13.
//  Copyright (c) 2013 Barrett Jacobsen. All rights reserved.
//

#import "BJJWebserverActivity.h"
#import "HTTPServer.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface BJJWebserverActivity ()

@property (copy, nonatomic) NSArray *activityItems;
@property (copy, nonatomic) NSURL *urlActivityItem;

@end

@implementation BJJWebserverActivity {
    HTTPServer *_httpServer;
}


- (instancetype)init {
    self = [super init];
    
    if (self) {
        _activityTitle = NSLocalizedStringWithDefaultValue(@"SHAVE_VIA_WEBSERVER_DEFAULT_TITLE", nil, [NSBundle mainBundle], @"Share via Webserver", @"");
    }
    
    return self;
}

- (NSString *)activityType {
    return @"com.barrettj.webserveractivity";
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSURL class]]) {
            NSURL *url = item;
            
            if (url.isFileURL) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.activityItems = activityItems;
    
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSURL class]]) {
            NSURL *url = item;
            
            if (url.isFileURL) {
                self.urlActivityItem = url;
                return;
            }
        }
    }
}

- (void)performActivity {
    _httpServer = [[HTTPServer alloc] init];
    
    [_httpServer setType:@"_http._tcp."];
    
    NSString *filePath = self.urlActivityItem.path;
    NSString *fileName = [filePath lastPathComponent];
    NSString *docRoot = [filePath stringByDeletingLastPathComponent];
    
    [_httpServer setDocumentRoot:docRoot];
    
    BJJFinishedUsingWebserverBlock onFinished = ^{
        [_httpServer stop];
        
        [self activityDidFinish:YES];
    };
    
    NSError *error = nil;
    if(![_httpServer start:&error]) {
        if (self.onError) {
            self.onError(error);
        }
        
        [self activityDidFinish:NO];
    }
    else {
        NSString *ipAddress = [BJJWebserverActivity localWifiIPAddress];
        
        if (ipAddress.length == 0) {
            if (self.onError) {
                error = [NSError errorWithDomain:@"com.barrettj.webserveractivity" code:100 userInfo:@{NSLocalizedDescriptionKey : @"Could not get local wifi ip address."}];
                self.onError(nil);
            }
        }
        else {
            if (self.onStart) {
                NSString *urlString = [NSString stringWithFormat:@"http://%@:%i/%@", ipAddress, _httpServer.port, fileName];
                self.onStart([NSURL URLWithString:urlString], onFinished);
            }
            else {
                NSLog(@"Activity is not fully configured!");
                onFinished();
            }
        }
    }
}

#pragma mark - Helpers

+ (NSString *)localWifiIPAddress {
	NSString *address = @"";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0) {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL) {
			if(temp_addr->ifa_addr->sa_family == AF_INET) {
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}
			
			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
	freeifaddrs(interfaces);
	
	return address;
}


@end
