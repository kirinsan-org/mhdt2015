//
//  SatelliteRingView.h
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SatelliteRingView : UIView

@property (nonatomic, copy) IBInspectable UIColor *color;

@property (nonatomic) IBInspectable CGFloat bpm;
@property (nonatomic) IBInspectable CGFloat ringWidth;
@property (nonatomic) IBInspectable CGFloat satelliteRadius;

@property (nonatomic, getter=isAnimating) BOOL animating;

@end
