//
//  PlayerViewController.m
//  MHDT2015
//
//  Created by Jun on 8/22/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "PlayerViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AWSSNS/AWSSNS.h>
#import "AmazonCredentials.h"
#import "CircleButton.h"
#import "TrackSearchViewController.h"
#import "TrackCell.h"
#import "Track.h"
#import "TrackDetail.h"
#import "UserCell.h"
#import "User.h"

static NSString *const PresentTrackSearchViewControllerSegue = @"PresentTrackSearchViewController";

#pragma mark -

@interface PlayerViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, TrackSearchViewControllerDelegate>

@property (nonatomic, weak) IBOutlet PlayPauseButton *playPauseButton;
@property (nonatomic, weak) IBOutlet CircleButton *rewindButton;
@property (nonatomic, weak) IBOutlet CircleButton *forwardButton;

@property (nonatomic, weak) IBOutlet UIImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, weak) IBOutlet UIProgressView *playbackProgressView;
@property (nonatomic, weak) IBOutlet UILabel *playbackElapsedTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *playbackRemainingTimeLabel;

@property (nonatomic, weak) IBOutlet ToggleCircleButton *trackListToggleButton;
@property (nonatomic, weak) IBOutlet CircleButton *addMusicButton;
@property (nonatomic, weak) IBOutlet UIView *trackListContainerView;
@property (nonatomic, weak) IBOutlet UITableView *trackTableView;

@property (nonatomic, weak) IBOutlet UICollectionView *userListView;

@property (nonatomic) Track *currentTrack;
@property (nonatomic) AVQueuePlayer *player;
@property (nonatomic) NSMutableDictionary *tracksByURL;
@property (nonatomic) NSArray *users;
@property (nonatomic) NSMutableDictionary *detailsByTrack;
@property (nonatomic) CADisplayLink *displayLink;

@end

#pragma mark -

@implementation PlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configurePlayer];
    
//    [self insertDummyTracks];
    [self insertDummyUsers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:PresentTrackSearchViewControllerSegue]) {
        TrackSearchViewController *controller = segue.destinationViewController;
        controller.delegate = self;
    }
}

- (void)configurePlayer
{
    AVQueuePlayer *player = [[AVQueuePlayer alloc] init];
    self.player = player;
    
    self.tracksByURL = [[NSMutableDictionary alloc] init];
    self.users = [[NSMutableArray alloc] init];
    self.detailsByTrack = [[NSMutableDictionary alloc] init];
    
    CADisplayLink *displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(updateUI:)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = displayLink;
}

- (void)insertDummyTracks
{
    NSURL *url = [NSURL URLWithString:@"http://172.16.200.170:8888/search?q=foo"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Failed to fetch results with error: %@", error);
        }
        else {
            NSMutableArray *results = [[NSMutableArray alloc] init];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (id object in [json[@"results"] reverseObjectEnumerator]) {
                Track *track = [[Track alloc] initWithJSON:object];
                [results addObject:track];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                for (Track *track in results) {
                    [self insertNextTrack:track];
                }
            });
        }
    }];
    [task resume];
}

- (void)insertDummyUsers
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"users" withExtension:@"json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Failed to fetch dummy users with error: %@", error);
        }
        else {
            NSError *error;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                NSLog(@"Failed to parse fummy users with error: %@", error);
            }
            NSMutableArray *users = [[NSMutableArray alloc] init];
            for (NSDictionary *obj in json[@"users"]) {
                User *user = [[User alloc] initWithJSON:obj];
                [users addObject:user];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.users = users;
            });
        }
    }];
    [task resume];
}

- (void)updateUI:(CADisplayLink *)displayLink
{
    AVPlayerItem *item = self.player.currentItem;
    
    if (item && CMTIME_IS_NUMERIC(item.duration)) {
        NSTimeInterval duration = CMTimeGetSeconds(item.duration);
        NSTimeInterval elapsedTime = CMTimeGetSeconds(item.currentTime);
        NSTimeInterval remainingTime = duration - elapsedTime;
        
        NSString *elapsedTimeString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)elapsedTime / 60, (unsigned long)elapsedTime % 60];
        NSString *remainingTimeString = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)remainingTime / 60, (unsigned long)remainingTime % 60];
        
        self.playbackElapsedTimeLabel.text = elapsedTimeString;
        self.playbackRemainingTimeLabel.text = remainingTimeString;
        self.playbackProgressView.progress = (float)elapsedTime / (float)duration;
        
        Track *track = [self trackForPlayerItem:item];
        if (track && ![track isEqual:self.currentTrack]) {
            self.currentTrack = track;
        }
    }
    else {
        self.playbackElapsedTimeLabel.text = @"";
        self.playbackRemainingTimeLabel.text = @"";
        self.playbackProgressView.progress = 0;
        self.artworkImageView.image = nil;
    }
    
    BOOL isPlaying = self.player.rate != 0;
    self.playPauseButton.selected = isPlaying;
}

- (void)setCurrentTrack:(Track *)track
{
    _currentTrack = track;
    
    NSURL *imageURL = track.imageURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Failed to fetch image at: %@", response.URL);
        }
        else {
            UIImage *image = [[UIImage alloc] initWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView transitionWithView:self.artworkImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.artworkImageView.image = image;
                    self.backgroundImageView.image = image;
                } completion:nil];
            });
        }
    }];
    [task resume];
    
    [self getDetailOfTrack:track completion:^(TrackDetail *detail, NSError *error) {
        if (error) {
            NSLog(@"Failed to fetch track detail with error: %@", error);
        }
        else if (self.currentTrack == track) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.playPauseButton.satelliteRingView.bpm = detail.tempo;
                self.playPauseButton.satelliteRingView.color = detail.mood.color;
            });
        }
    }];
    
    [self.trackTableView reloadData];
}

- (void)insertNextTrack:(Track *)track
{
    AVPlayerItem *nextItem = [AVPlayerItem playerItemWithURL:track.audioURL];
    AVPlayerItem *currentItem = self.player.currentItem;
    
    Track *currentTrack = [self trackForPlayerItem:currentItem];
    if ([currentTrack isEqual:track]) {
        return;
    }
    
    if ([self.player canInsertItem:nextItem afterItem:currentItem]) {
        [self.player insertItem:nextItem afterItem:currentItem];
    }
    else {
        return;
    }
    
    [self setTrack:track forPlayerItem:nextItem];
    
    NSUInteger index = [self.player.items indexOfObject:nextItem];
    [self.trackTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (!currentItem) {
        [self.player play];
    }
    else if (track.force) {
        [self forward:nil];
    }
}

- (Track *)trackForPlayerItem:(AVPlayerItem *)item
{
    NSURL *url = [(AVURLAsset *)item.asset URL];
    
    return [self.tracksByURL objectForKey:url];
}

- (void)setTrack:(Track *)track forPlayerItem:(AVPlayerItem *)item
{
    NSURL *url = [(AVURLAsset *)item.asset URL];
    
    if (track) {
        [self.tracksByURL setObject:track forKey:url];
    }
    else {
        [self.tracksByURL removeObjectForKey:url];
    }
}

- (Track *)trackForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [self.player.items copy];
    
    if (items.count > indexPath.row) {
        AVPlayerItem *item = items[indexPath.row];
        return [self trackForPlayerItem:item];
    }
    
    return nil;
}

- (void)setUsers:(NSArray *)users
{
    _users = [users copy];
    
    [self.userListView reloadData];
}

- (User *)userForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.users.count > indexPath.item) {
        return self.users[indexPath.item];
    }
    
    return nil;
}

- (void)getDetailOfTrack:(Track *)track completion:(void(^)(TrackDetail *detail, NSError *error))completion
{
    TrackDetail *detail = self.detailsByTrack[track];
    if (detail) {
        completion(detail, nil);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://172.16.200.170:8888/details?artist=%@&title=%@", [detail.artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [detail.title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        }
        else {
            NSError *error;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                completion(nil, error);
            }
            else {
                TrackDetail *detail = [[TrackDetail alloc] initWithJSON:json];
                self.detailsByTrack[track] = detail;
                completion(detail, nil);
            }
        }
    }];
    [task resume];
}

- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo: %@", userInfo);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Track *track = [[Track alloc] initWithJSON:userInfo[@"track"]];
        [self insertNextTrack:track];
    });
}

- (void)pushTrackToAll:(Track *)track
{
    NSDictionary *payload = @{
        @"aps": @{
            @"alert": @"nope",
            @"sound": @"default"
        },
        @"track": @{
            TrackIDKey: track.identifier,
            TrackTitleKey: track.title,
            TrackArtistKey: track.artist,
            TrackAudioURLKey: [track.audioURL absoluteString],
            TrackImageURLKey: [track.imageURL absoluteString],
            TrackSourceKey: track.source,
            TrackForceKey: @(YES)
        },
        @"from": @{}
    };
    NSData *jsonAPNSData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    if (!jsonAPNSData) {
        return;
    }
    
    NSString *jsonAPNSString = [[NSString alloc] initWithData:jsonAPNSData encoding:NSUTF8StringEncoding];
    NSDictionary *json = @{
        @"default": @"nope",
        @"APNS_SANDBOX": jsonAPNSString
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    if (!jsonData) {
        return;
    }
    NSString *messageJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AWSSNSPublishInput *input = [[AWSSNSPublishInput alloc] init];
    input.topicArn = AmazonSNSGlobalTopicArn;
    input.message = messageJSON;
    input.messageStructure = @"json";
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    [sns publish:input];
}

- (IBAction)togglePlaying:(id)sender
{
    if (self.player.rate == 0) {
        [self.player play];
    }
    else {
        [self.player pause];
    }
}

- (IBAction)rewind:(id)sender
{
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
}

- (IBAction)forward:(id)sender
{
    NSMutableArray *items = [self.player.items mutableCopy];
    if (items.count > 0) {
        [items removeObjectAtIndex:0];
    }
    
    [self.player removeAllItems];
    
    for (AVPlayerItem *item in items) {
        if ([self.player canInsertItem:item afterItem:nil]) {
            [self.player insertItem:item afterItem:nil];
        }
    }
}

- (IBAction)toggleTrackList:(id)sender
{
    UIView *containerView = self.trackListContainerView;
    
    CGFloat constantToCover = self.view.bounds.size.height + 86;
    BOOL covered = containerView.frame.size.height != constantToCover;
    
    NSArray *constraints = self.trackListContainerView.constraints;
    
    for (NSLayoutConstraint *constraint in constraints) {
        if (constraint.firstItem == self.trackListContainerView && constraint.firstAttribute == NSLayoutAttributeHeight) {
            if (covered) {
                constraint.constant = constantToCover;
            }
            else {
                constraint.constant = 148;
            }
            [containerView setNeedsUpdateConstraints];
        }
    }
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.0 options:0 animations:^{
        [containerView layoutIfNeeded];
        self.addMusicButton.alpha = covered ? 1 : 0;
    } completion:nil];
    
    self.trackListToggleButton.selected = covered;
}

- (IBAction)addMusic:(id)sender
{
    [self performSegueWithIdentifier:PresentTrackSearchViewControllerSegue sender:sender];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.player.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    
    if (cell) {
        Track *track = [self trackForRowAtIndexPath:indexPath];
        cell.titleLabel.text = track.title;
        cell.artistLabel.text = track.artist;
        cell.thumbnailImageView.image = nil;
        cell.sourceImageView.image = nil;
        
        NSURL *imageURL = track.imageURL;
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                UIImage *image = [[UIImage alloc] initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.thumbnailImageView.image = image;
                });
            }
        }];
        [task resume];
        
        UIImage *sourceImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", track.source]];
        cell.sourceImageView.image = sourceImage;
        
        if (indexPath.row == 0) {
            cell.backgroundColor = [UIColor blackColor];
        }
    }
    
    return cell;
}

#pragma mark TrackSearchViewControllerDelegate

- (void)trackSearchViewController:(TrackSearchViewController *)controller didPickTrack:(Track *)track
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self insertNextTrack:track];
    }];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    
    if (cell) {
        cell.avatorImageView.image = nil;
        cell.satelliteRingView.animating = YES;
        cell.satelliteRingView.bpm = 120;
        cell.satelliteRingView.color = [UIColor whiteColor];
        
        User *user = [self userForItemAtIndexPath:indexPath];
        
        NSURL *avatorURL = user.avatorURL;
        NSURLRequest *request = [NSURLRequest requestWithURL:avatorURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Failed to fetch avator with error: %@", error);
            }
            else {
                UIImage *image = [[UIImage alloc] initWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.avatorImageView.image = image;
                });
            }
        }];
        [task resume];
        
        if (user.playing) {
            [self getDetailOfTrack:user.playing completion:^(TrackDetail *detail, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.satelliteRingView.bpm = detail.tempo;
                    cell.satelliteRingView.color = detail.mood.color;
                });
            }];
        }
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Track *track = [self trackForPlayerItem:self.player.currentItem];
    if (!track) {
        return;
    }
    
    [self pushTrackToAll:track];
}

@end
