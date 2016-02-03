//
//  DWHTTPJSONItemSerializer.m
//  Pods
//
//  Created by NAP Sam on 16/06/2014.
//
//

#import "DWHTTPJSONItemSerializer.h"

@import SBJson;

@interface DWHTTPJSONItemSerializer : DWHTTPStreamItemSerializer

@property (nonatomic, strong) SBJson4Parser *parser;

@end

@implementation DWHTTPJSONItemSerializer

- (SBJson4Parser *)parser {
    if (nil == _parser) {
        SBJson4ValueBlock block = ^(NSDictionary *dictionary, BOOL *stop) {
            BOOL isDict = [dictionary isKindOfClass:[NSDictionary class]];
            if (isDict) {
                [self.delegate itemSerializer:self foundItem:dictionary];
            } else {
                NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:nil];
                [self.delegate itemSerializer:self foundError:error];
            }
        };
        
        SBJson4ErrorBlock eh = ^(NSError *error) {
            NSLog(@"JSONStream\tJSON parse error: %@", error);
            [self.delegate itemSerializer:self foundError:error];
        };
        
        self.parser = [SBJson4Parser unwrapRootArrayParserWithBlock:block
                                                       errorHandler:eh];
    }
    
    return _parser;
}

- (void)data:(NSData *)data forResponse:(__unused NSURLResponse *)response {
    [self.parser parse:data];
}

@end

@implementation DWHTTPJSONItemSerializerProvider

- (DWHTTPStreamItemSerializer *)itemSerializerWithIdentifier:(NSUInteger)identifier delegate:(id<DWHTTPStreamItemSerializationDelegate>)delegate {
    return [[DWHTTPJSONItemSerializer alloc] initWithIdentifier:identifier
                                                       delegate:delegate];
}

@end
