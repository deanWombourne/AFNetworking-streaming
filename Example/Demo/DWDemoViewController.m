//
//  DWDemoViewController.m
//  Demo
//
//  Created by NAP Sam on 14/06/2014.
//  Copyright (c) 2014 deanWombourne. All rights reserved.
//

#import "DWDemoViewController.h"

#import "DWHTTPStreamSessionManager.h"
#import "DWHTTPJSONItemSerializer.h"

#import "SBJson4Parser.h"

@interface DWDemoViewController ()

@property (nonatomic, strong) DWHTTPStreamSessionManager *manager;

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation DWDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // https://raw.githubusercontent.com/deanWombourne/AFNetworking-streaming/master/Example/example.json
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com"];
    self.manager = [[DWHTTPStreamSessionManager alloc] initWithBaseURL:url];
    self.manager.itemSerializerProvider = [[DWHTTPJSONItemSerializerProvider alloc] init];
    
    self.title = @"";
    
    self.results = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.title = @"Loading";

    [self.manager GET:@"deanWombourne/AFNetworking-streaming/master/Example/example.json"
           parameters:@{}
                 data:^(NSURLSessionDataTask *task, NSDictionary *dictionary) {
                     [self.results addObject:dictionary];
                     [self.tableView reloadData];
                 }
              success:^(NSURLSessionDataTask *task) {
                  NSLog(@"Response complete");
                  self.title = @"Done";
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  self.title = @"Failed";
              }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *item = self.results[indexPath.item];
    cell.textLabel.text = item[@"name"];
    
    return cell;
}

@end
