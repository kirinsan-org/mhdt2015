//
//  CircleButton.m
//  MHDT2015
//
//  Created by Jun on 8/22/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "CircleButton.h"

#pragma mark -

@interface CircleButton ()

@property (nonatomic, weak) IBOutlet UIView *baseView;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

#pragma mark -

@implementation CircleButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.baseView.layer.cornerRadius = self.baseView.bounds.size.width / 2;
}

- (void)setHighlighted:(BOOL)highlighted
{    
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:0.1 animations:^{
        if (self.highlighted) {
            self.baseView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }
        else {
            self.baseView.transform = CGAffineTransformIdentity;
        }
    }];
}

@end

#pragma mark -

@implementation ToggleCircleButton

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected
{
    BOOL flag = self.selected != selected;
    
    [super setSelected:selected];
    
    if (flag) {
        [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:0 animations:^{
            if (selected) {
                self.imageView.transform = CGAffineTransformMakeTranslation(0, -self.imageView.bounds.size.height / 2);
            }
            else {
                self.imageView.transform = CGAffineTransformIdentity;
            }
        } completion:nil];
    }
}

@end

#pragma mark -

@implementation PlayPauseButton

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected
{
    BOOL flag = self.selected != selected;
    
    [super setSelected:selected];
    
    if (flag) {
        self.satelliteRingView.animating = selected;
    }
}

@end
