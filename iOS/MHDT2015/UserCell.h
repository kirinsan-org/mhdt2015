//
//  UserCell.h
//  MHDT2015
//
//  Created by Jun on 8/23/15.
//  Copyright (c) 2015 kirinsan.org. All rights reserved.
//

#import "SatelliteRingView.h"

@interface UserCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatorImageView;

@property (nonatomic, weak) IBOutlet SatelliteRingView *satelliteRingView;

@end
