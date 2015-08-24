//
//  SpotifyLoginViewController.m
//  MHDT2015
//
//  Created by Jun on 8/22/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "SpotifyLoginViewController.h"

#import "Spotify.h"

static NSString *const SpotifyLoginViewControllerDidHandleAuthNotification = @"SpotifyLoginViewControllerDidHandleAuthNotification";
static NSString *const SpotifyLoginViewControllerDidHandleAuthNotificationAuthUserInfoKey = @"auth";
static NSString *const SpotifyLoginViewControllerDidHandleAuthNotificationSessionUserInfoKey = @"session";

#pragma mark -

@interface SpotifyLoginViewController () <SPTAuthViewDelegate>

@property (nonatomic) SPTAuthViewController *authViewController;

@end

#pragma mark -

@implementation SpotifyLoginViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SpotifyLoginViewControllerDidHandleAuthNotification object:nil];
}

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SpotifyLoginViewControllerDidHandleAuthNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

+ (BOOL)isLoginNeeded {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    return (!auth.session.isValid && !auth.hasTokenRefreshService);
}

+ (BOOL)handleCallbackURL:(NSURL *)url {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            if (error) {
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyLoginViewControllerDidHandleAuthNotification object:nil userInfo:@{SpotifyLoginViewControllerDidHandleAuthNotificationAuthUserInfoKey: auth, SpotifyLoginViewControllerDidHandleAuthNotificationSessionUserInfoKey: session}];
        }];
        return YES;
    }
    
    return NO;
}

- (IBAction)login:(id)sender {
    SPTAuthViewController *authViewController = [SPTAuthViewController authenticationViewController];
    authViewController.delegate = self;
    authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.authViewController = authViewController;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:authViewController animated:NO completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self didCancel];
}

- (void)handleNotification:(NSNotification *)notification
{
    SPTAuth *auth = notification.userInfo[SpotifyLoginViewControllerDidHandleAuthNotificationAuthUserInfoKey];
    SPTSession *session = notification.userInfo[SpotifyLoginViewControllerDidHandleAuthNotificationSessionUserInfoKey];
    
    [self didLoginWithAuth:auth session:session];
}

- (void)didLoginWithAuth:(SPTAuth *)auth session:(SPTSession *)session
{
    id<SpotifyLoginViewControllerDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(spotifyLoginViewController:didLoginWithAuth:session:)]) {
        [delegate spotifyLoginViewController:self didLoginWithAuth:auth session:session];
    }
}

- (void)didCancel
{
    id<SpotifyLoginViewControllerDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(spotifyLoginViewControllerDidCancel:)]) {
        [delegate spotifyLoginViewControllerDidCancel:self];
    }
}

#pragma mark SPTAuthViewDelegate

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didFailToLogin:(NSError *)error
{
    NSLog(@"login failed with error:%@", error);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auth Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didLoginWithSession:(SPTSession *)session
{
    [self didLoginWithAuth:[SPTAuth defaultInstance] session:session];
}

- (void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController {
    [self didCancel];
}

@end
