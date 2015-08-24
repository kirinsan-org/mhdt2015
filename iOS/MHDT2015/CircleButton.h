//
//  CircleButton.h
//  MHDT2015
//
//  Created by Jun on 8/22/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SatelliteRingView.h"

@interface CircleButton : UIControl

@end

@interface ToggleCircleButton : CircleButton

@end

@interface PlayPauseButton : ToggleCircleButton

@property (nonatomic, weak) IBOutlet SatelliteRingView *satelliteRingView;

@end
