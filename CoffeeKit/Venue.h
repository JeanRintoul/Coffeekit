//
//  Venue.h
//  CoffeeKit
//
//  Created by Jean Rintoul on 11/6/15.
//  Copyright © 2015 Lir. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Location;
@class Stats;

@interface Venue : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Location *location;
@property (strong, nonatomic) Stats *stats;

@end
