//
//  TrackSearchViewController.h
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Track.h"

@protocol TrackSearchViewControllerDelegate;

@interface TrackSearchViewController : UIViewController

@property (nonatomic, weak) id<TrackSearchViewControllerDelegate> delegate;

@end

@protocol TrackSearchViewControllerDelegate <NSObject>

- (void)trackSearchViewController:(TrackSearchViewController *)controller didPickTrack:(Track *)track;

@end
