//
//  TrackDetail.h
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrackMood;

static NSString *const TrackDetailTitleKey = @"title";
static NSString *const TrackDetailArtistKey = @"artist";
static NSString *const TrackDetailImageURLKey = @"image";
static NSString *const TrackDetailTempoKey = @"tempo";
static NSString *const TrackDetailMoodKey = @"mood";

@interface TrackDetail : NSObject

- (instancetype)initWithJSON:(NSDictionary *)json;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSUInteger tempo;
@property (nonatomic, readonly) TrackMood *mood;

@end

static NSString *const TrackMoodIDKey = @"id";
static NSString *const TrackMoodTextKey = @"text";
static NSString *const TrackMoodColorKey = @"color";

@interface TrackMood : NSObject <NSCopying>

- (instancetype)initWithJSON:(NSDictionary *)json;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) UIColor *color;

@end