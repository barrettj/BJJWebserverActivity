//
//  BJJWebserverActivity.m
//  BJJWebserverActivityTest
//
//  Created by Barrett Jacobsen on 10/8/13.
//  Copyright (c) 2013 Barrett Jacobsen. All rights reserved.
//

#import "BJJWebserverActivity.h"
#import "HTTPServer.h"
#import "HTTPRedirectResponse.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface BJJWebserverActivity ()

@property (copy, nonatomic) NSArray *activityItems;
@property (copy, nonatomic) NSURL *urlActivityItem;

@end

@implementation BJJWebserverActivity


- (instancetype)init {
    self = [super init];
    
    if (self) {
        _activityTitle = NSLocalizedStringWithDefaultValue(@"SHAVE_VIA_WEBSERVER_DEFAULT_TITLE", nil, [NSBundle mainBundle], @"Share via Webserver", @"");
        
        _httpServer = [[HTTPServer alloc] init];
        
        _redirectToSpecifiedFile = YES;
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
    NSString *filePath = self.urlActivityItem.path;
    NSString *fileName = [[filePath lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *docRoot = [filePath stringByDeletingLastPathComponent];
    
    [self.httpServer setDocumentRoot:docRoot];
    
    if (self.redirectToSpecifiedFile) {
        if (self.httpServer.connectionClass != [HTTPConnection class] && self.httpServer.connectionClass != [RedirectingHTTPConnection class]) {
            NSLog(@"Custom HTTPConnection is being overwritten by redirectToSpecifiedFile");
        }
        
        [self.httpServer setConnectionClass:[RedirectingHTTPConnection class]];
        
        [RedirectingHTTPConnection setRedirectPath:fileName];
    }
    else if (self.httpServer.connectionClass != [HTTPConnection class]) {
        if (self.httpServer.connectionClass == [RedirectingHTTPConnection class]) {
            [self.httpServer setConnectionClass:[HTTPConnection class]];
        }
        else {
            NSLog(@"Already using custom connection class!");
        }
    }
    
    BJJFinishedUsingWebserverBlock onFinished = ^{
        [self.httpServer stop];
        
        [self activityDidFinish:YES];
    };
    
    NSError *error = nil;
    if(![self.httpServer start:&error]) {
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
                self.onError(error);
            }
        }
        else {
            if (self.onStart) {
                NSString *urlString = [NSString stringWithFormat:@"http://%@:%i/%@", ipAddress, self.httpServer.listeningPort, fileName];
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


@implementation RedirectingHTTPConnection

static NSString *sharedRedirectPath;

+ (NSString*)redirectPath {
    return sharedRedirectPath;
}

+ (void)setRedirectPath:(NSString*)path {
    sharedRedirectPath = [path copy];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    //NSLog(@"uri: %@", path);
    
	NSString *filePath = [self filePathForURI:path];
	
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if ([path isEqualToString:@"/favicon.ico"]) {
            // Don't redirect the favicon
            return nil;
        }

        HTTPRedirectResponse *redirect = [[HTTPRedirectResponse alloc] initWithPath:[RedirectingHTTPConnection redirectPath]];
        return redirect;
    }
	
	return [super httpResponseForMethod:method URI:path];
}


@end
