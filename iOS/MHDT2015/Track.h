//
//  Track.h
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *TrackIDKey = @"id";
static NSString *TrackTitleKey = @"title";
static NSString *TrackArtistKey = @"artist";
static NSString *TrackAudioURLKey = @"url";
static NSString *TrackImageURLKey = @"image";
static NSString *TrackSourceKey = @"source";
static NSString *TrackForceKey = @"force";

static NSString *TrackSourceTypeSpotify = @"spotify";
static NSString *TrackSourceTypeSoundCloud = @"soundcloud";
static NSString *TrackSourceTypeRecochoku = @"recochoku";

@interface Track : NSObject <NSCopying>

- (instancetype)initWithJSON:(NSDictionary *)json;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSURL *audioURL;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSString *source;
@property (nonatomic, readonly) BOOL force;

@end
