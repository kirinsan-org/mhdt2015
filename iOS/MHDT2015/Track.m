//
//  Track.m
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "Track.h"



#pragma mark -

@interface Track ()

@property (nonatomic, copy) NSDictionary *json;

@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *artist;
@property (nonatomic, readwrite) NSURL *audioURL;
@property (nonatomic, readwrite) NSURL *imageURL;
@property (nonatomic, readwrite) NSString *source;
@property (nonatomic, readwrite) BOOL force;

@end

#pragma mark -

@implementation Track

- (instancetype)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.json = json;
    
    self.identifier = json[TrackIDKey];
    self.title = json[TrackTitleKey];
    self.artist = json[TrackArtistKey];
    self.audioURL = [NSURL URLWithString:json[TrackAudioURLKey]];
    self.imageURL = [NSURL URLWithString:json[TrackImageURLKey]];
    self.source = json[TrackSourceKey];
    self.force = [json[@"force"] boolValue];
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqual:[object identifier]];
    }
    
    return [super isEqual:object];
}

- (NSString *)description
{
    return self.json.description;
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
