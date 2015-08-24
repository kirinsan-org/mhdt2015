//
//  TrackDetail.m
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "TrackDetail.h"

#pragma mark -

@interface TrackDetail ()

@property (nonatomic, copy) NSDictionary *json;

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *artist;
@property (nonatomic, readwrite) NSURL *imageURL;
@property (nonatomic, readwrite) NSUInteger tempo;
@property (nonatomic, readwrite) TrackMood *mood;

@end

#pragma mark -

@implementation TrackDetail

- (instancetype)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.json = json;
    
    self.title = json[TrackDetailTitleKey];
    self.artist = json[TrackDetailArtistKey];
    self.imageURL = [NSURL URLWithString:json[TrackDetailImageURLKey]];
    self.tempo =[json[TrackDetailTempoKey] unsignedIntegerValue];
    self.mood = [[TrackMood alloc] initWithJSON:json[TrackDetailMoodKey]];
    
    return self;
}

@end

#pragma mark -

@interface TrackMood ()

@property (nonatomic, copy) NSDictionary *json;

@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, readwrite) UIColor *color;

@end

#pragma mark -

@implementation TrackMood

- (instancetype)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.json = json;
    
    self.identifier = json[TrackMoodIDKey];
    self.text = json[TrackMoodTextKey];
    
    NSDictionary *color = json[TrackMoodColorKey];
    float r = [color[@"r"] floatValue];
    float g = [color[@"g"] floatValue];
    float b = [color[@"b"] floatValue];
    
    self.color = [UIColor colorWithRed:r green:g blue:b alpha:1];
    if (r == 1 && g == 1 && b == 1) {
        self.color = [UIColor colorWithHue:(CGFloat)arc4random() / UINT32_MAX saturation:0.6 brightness:1 alpha:1];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqual:[object identifier]];
    }
    
    return [super isEqual:object];
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
