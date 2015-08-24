//
//  User.h
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "Track.h"

static NSString *const UserArnKey = @"arn";
static NSString *const UserAvatorURLKey = @"avator";
static NSString *const UserPlayingKey = @"playing";

@interface User : NSObject <NSCopying>

- (instancetype)initWithJSON:(NSDictionary *)json;

@property (nonatomic, readonly) NSString *arn;
@property (nonatomic, readonly) NSURL *avatorURL;
@property (nonatomic, readonly) Track *playing;

@end
