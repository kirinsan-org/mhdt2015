//
//  AppDelegate.m
//  MHDT2015
//
//  Created by Jun on 8/22/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "AWSCore.h"
#import "AWSSNS.h"
#import "AmazonCredentials.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tokenString = [deviceToken description];
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    AWSStaticCredentialsProvider *provider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:AmazonAccessKey secretKey:AmazonSecretKey];
    
    AWSServiceConfiguration *defaultConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:provider];
    
    [[AWSServiceManager defaultServiceManager] setDefaultServiceConfiguration:defaultConfiguration];
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    
    AWSSNSCreatePlatformEndpointInput *createEndpointInput = [[AWSSNSCreatePlatformEndpointInput alloc] init];
    createEndpointInput.customUserData = [[NSUUID UUID] UUIDString];
    createEndpointInput.platformApplicationArn = AmazonSNSPlatformApplicationArn;
    createEndpointInput.token = tokenString;
    
    [[[sns createPlatformEndpoint:createEndpointInput] continueWithSuccessBlock:^id(AWSTask *task) {
        AWSSNSCreateEndpointResponse *endpointResponse = task.result;
        AWSSNSSubscribeInput *subscribeInput = [[AWSSNSSubscribeInput alloc] init];
        subscribeInput.endpoint = endpointResponse.endpointArn;
        subscribeInput.topicArn = AmazonSNSGlobalTopicArn;
        subscribeInput.protocols = @"application";
        return [sns subscribe:subscribeInput];
    }] continueWithBlock:^id(AWSTask *task) {
        if (!task.error) {
            NSLog(@"Subscribed SNS topic!");
        }
        return nil;
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    PlayerViewController *controller = (PlayerViewController *)self.window.rootViewController;
    
    [controller handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register for remote notifications with error: %@", error);
}

@end
