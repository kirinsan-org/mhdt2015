//
//  User.m
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "User.h"

#pragma mark -

@interface User ()

@property (nonatomic, copy) NSDictionary *json;

@property (nonatomic, readwrite) NSString *arn;
@property (nonatomic, readwrite) NSURL *avatorURL;
@property (nonatomic, readwrite) Track *playing;

@end

#pragma mark -

@implementation User

- (instancetype)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.json = json;
    
    self.arn = json[UserArnKey];
    self.avatorURL = [NSURL URLWithString:json[UserAvatorURLKey]];
    self.playing = [[Track alloc] initWithJSON:json[UserPlayingKey]];
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.arn isEqual:[object arn]];
    }
    
    return [super isEqual:object];
}

- (NSUInteger)hash
{
    return self.arn.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
