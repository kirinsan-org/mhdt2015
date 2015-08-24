//
//  SpotifyLoginViewController.h
//  MHDT2015
//
//  Created by Jun on 8/22/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@protocol SpotifyLoginViewControllerDelegate;

@interface SpotifyLoginViewController : UIViewController

+ (BOOL)isLoginNeeded;

+ (BOOL)handleCallbackURL:(NSURL *)url;

@property (nonatomic, weak) id<SpotifyLoginViewControllerDelegate> delegate;

@end

@protocol SpotifyLoginViewControllerDelegate <NSObject>

- (void)spotifyLoginViewController:(SpotifyLoginViewController *)controller didLoginWithAuth:(SPTAuth *)auth session:(SPTSession *)session;
- (void)spotifyLoginViewControllerDidCancel:(SpotifyLoginViewController *)controller;

@end