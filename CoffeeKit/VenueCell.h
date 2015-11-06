//
//  VenueCell.h
//  CoffeeKit
//
//  Created by Jean Rintoul on 11/6/15.
//  Copyright © 2015 Lir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *checkinsLabel;

@end
