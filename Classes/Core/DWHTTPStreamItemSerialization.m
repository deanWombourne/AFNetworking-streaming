//
//  DWHTTPStreamItemSerializer.m
//  Pods
//
//  Created by NAP Sam on 16/06/2014.
//
//

#import "DWHTTPStreamItemSerialization.h"

@implementation DWHTTPStreamItemSerializer

- (void)dealloc {
    NSLog(@"Stream serializer dealloc");
}

- (void)data:(NSData *)data forResponse:(NSURLResponse *)response {
    [self.delegate itemSerializer:self foundItem:data];
}

@end

@implementation DWHTTPStreamItemSerializerProvider

- (DWHTTPStreamItemSerializer *)itemSerializer {
    return [[DWHTTPStreamItemSerializer alloc] init];
}

@end
