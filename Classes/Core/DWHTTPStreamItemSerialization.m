//
//  DWHTTPStreamItemSerializer.m
//  Pods
//
//  Created by NAP Sam on 16/06/2014.
//
//

#import "DWHTTPStreamItemSerialization.h"

@implementation DWHTTPStreamItemSerializer

- (id)init {
    @throw [NSException exceptionWithName:@"DWHTTPStreamItemSerializerException"
                                   reason:@"The designated initializer is initWithIdentifier:delegate: - please use it."
                                 userInfo:nil];
}

- (id)initWithIdentifier:(NSUInteger)identifier delegate:(id<DWHTTPStreamItemSerializationDelegate>)delegate {
    if ((self = [super init])) {
        _streamIdentifier = identifier;
        _delegate = delegate;
    }
    return self;
}

- (void)data:(NSData *)data forResponse:(NSURLResponse *)response {
    [self.delegate itemSerializer:self foundItem:data];
}

@end

@implementation DWHTTPStreamItemSerializerProvider

- (DWHTTPStreamItemSerializer *)itemSerializerWithIdentifier:(NSUInteger)identifier delegate:(id<DWHTTPStreamItemSerializationDelegate>)delegate {
    return [[DWHTTPStreamItemSerializer alloc] initWithIdentifier:identifier
                                                         delegate:delegate];
}

@end
