//
//  MasterViewController.m
//  CoffeeKit
//
//  Created by Jean Rintoul on 11/5/15.
//  Copyright © 2015 Lir. All rights reserved.
//

#import "MasterViewController.h"
#import <RestKit/RestKit.h>
#import "Venue.h"
#import "Location.h"
#import "VenueCell.h"
#import "Stats.h"

#define kCLIENTID @"5RJ0AHNCHOHOZD4VEEI3PKNJH0KN31QS0LGH5EHQYG1TCKIY"
#define kCLIENTSECRET @"JSCG1BDIOSXRTYJBD2WPUOACQWA5AF44GETTV40JANHZ5B3R"

@interface MasterViewController ()

//@property NSMutableArray *objects;
@property (nonatomic, strong) NSArray *venues;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureRestKit];
    [self loadVenues];
    
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
//    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    // define location object mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"crossStreet", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    
    // define relationship mapping
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    
    RKObjectMapping *statsMapping = [RKObjectMapping mappingForClass:[Stats class]];
    [statsMapping addAttributeMappingsFromDictionary:@{@"checkinsCount": @"checkins", @"tipsCount": @"tips", @"usersCount": @"users"}];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"stats" withMapping:statsMapping]];
    
}
- (void)loadVenues
{
    
    NSString *latLon = @"37.33,-122.03"; // approximate latLon of The Mothership (a.k.a Apple headquarters)
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : clientID,
                                  @"client_secret" : clientSecret,
                                  @"categoryId" : @"4bf58dd8d48988d1e0931735",
                                  @"v" : @"20140118"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _venues = mappingResult.array;
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
////    if ([[segue identifier] isEqualToString:@"showDetail"]) {
////        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
////        NSDate *object = self.objects[indexPath.row];
////        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
////        [controller setDetailItem:object];
////        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
////        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell" forIndexPath:indexPath];
    
    Venue *venue = _venues[indexPath.row];
    cell.nameLabel.text = venue.name;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.0fm", venue.location.distance.floatValue];
    cell.checkinsLabel.text = [NSString stringWithFormat:@"%d checkins", venue.stats.checkins.intValue];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

@end
