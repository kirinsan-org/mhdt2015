//
//  TrackSearchViewController.m
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "TrackSearchViewController.h"
#import "TrackCell.h"

#pragma mark -

@interface TrackSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableSet *sessionTasks;

@property (nonatomic, copy) NSArray *tracks;

@end

#pragma mark -

@implementation TrackSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sessionTasks = [[NSMutableSet alloc] init];
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
    
    [self.searchBar becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void)searchWithText:(NSString *)text
{
    for (NSURLSessionTask *task in self.sessionTasks) {
        [task cancel];
    }
    [self.sessionTasks removeAllObjects];
    
    text = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://172.16.200.170:8888/search?q=%@", text]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
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
                self.tracks = results;
                [self.tableView reloadData];
            });
        }
        
    }];
    [task resume];
    [self.sessionTasks addObject:task];
}

- (Track *)trackForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tracks.count > indexPath.row) {
        return self.tracks[indexPath.row];
    }
    
    return nil;
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 1) {
        [self searchWithText:searchText];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tracks.count;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    cell.thumbnailImageView.image = image;
                });
            }
        }];
        [task resume];
        [self.sessionTasks addObject:task];
        
        UIImage *sourceImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", track.source]];
        cell.sourceImageView.image = sourceImage;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track *track = [self trackForRowAtIndexPath:indexPath];
    if (track) {
        id<TrackSearchViewControllerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(trackSearchViewController:didPickTrack:)]) {
            [delegate trackSearchViewController:self didPickTrack:track];
        }
    }
}

@end
