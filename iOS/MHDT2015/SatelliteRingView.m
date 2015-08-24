//
//  SatelliteRingView.m
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "SatelliteRingView.h"


#pragma mark -

@interface SatelliteRingView ()

@property (nonatomic, weak) IBOutlet UIView *satelliteView;
@property (nonatomic, weak) IBOutlet UIView *ringView;

@end

#pragma mark -

@implementation SatelliteRingView

- (void)awakeFromNib
{
    [self configureView];
}

- (void)prepareForInterfaceBuilder
{
    [self configureView];
    
    self.bpm = 120;
    self.ringWidth = 1;
    self.satelliteRadius = 4;
}

- (void)configureView
{
    UIView *ringView = [[UIView alloc] initWithFrame:self.bounds];
    ringView.backgroundColor = [UIColor clearColor];
    ringView.layer.cornerRadius = ringView.bounds.size.width / 2;
    [self addSubview:ringView];
    self.ringView = ringView;
    
    UIView *satelliteView = [[UIView alloc] initWithFrame:self.bounds];
    satelliteView.backgroundColor = [UIColor clearColor];
    satelliteView.layer.shadowOpacity = 0.8;
    satelliteView.layer.shadowOffset = CGSizeZero;
    satelliteView.layer.shadowRadius = 0;
    [self addSubview:satelliteView];
    self.satelliteView = satelliteView;
    
    self.color = self.color ?: [UIColor whiteColor];
    self.bpm = self.bpm;
    self.ringWidth = self.ringWidth;
    self.satelliteRadius = self.satelliteRadius;
}

- (void)setColor:(UIColor *)color
{
    _color = [color copy];
    
    self.satelliteView.layer.shadowColor = color.CGColor;
    self.ringView.layer.borderColor = color.CGColor;
}

- (void)setBpm:(CGFloat)bpm
{
    _bpm = bpm;
    
    if (self.animating) {
        [self startAnimation];
    }
}

- (void)setRingWidth:(CGFloat)ringWidth
{
    _ringWidth = ringWidth;
    
    self.ringView.layer.borderWidth = ringWidth;
}

- (void)setSatelliteRadius:(CGFloat)satelliteRadius
{
    _satelliteRadius = satelliteRadius;
    
    CGPoint point;
    point.x = CGRectGetMidX(self.satelliteView.bounds);
    point.y = CGRectGetMinY(self.satelliteView.bounds);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point radius:self.satelliteRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    self.satelliteView.layer.shadowPath = path.CGPath;
}

- (void)setAnimating:(BOOL)animating
{
    BOOL flag = _animating != animating;
    
    _animating = animating;
    
    if (flag) {
        if (animating) {
            [self startAnimation];
        }
        else {
            [self stopAnimation];
        }
    }
}

- (void)startAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 240.0 / self.bpm;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.byValue = @(M_PI * 2);
    animation.repeatCount = HUGE_VALF;
    
    [self.satelliteView.layer addAnimation:animation forKey:@"rotation"];
}

- (void)stopAnimation
{
    [self.satelliteView.layer removeAnimationForKey:@"rotation"];
}

@end
