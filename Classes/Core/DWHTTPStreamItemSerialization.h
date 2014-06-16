//
//  DWHTTPStreamItemSerialization.h
//  Pods
//
//  Created by NAP Sam on 16/06/2014.
//
//

#import "AFURLResponseSerialization.h"

@class DWHTTPStreamItemSerializer;

@protocol DWHTTPStreamItemSerializationDelegate <NSObject>

- (void)itemSerializer:(DWHTTPStreamItemSerializer *)itemSerializer foundItem:(id)item;
- (void)itemSerializer:(DWHTTPStreamItemSerializer *)itemSerializer foundError:(NSError *)error;

@end

@protocol DWHTTPStreamItemSerializerProvider <NSObject>

- (DWHTTPStreamItemSerializer *)itemSerializer;

@end

@interface DWHTTPStreamItemSerializer : NSObject

@property (nonatomic, weak) id<DWHTTPStreamItemSerializationDelegate> delegate;
@property (nonatomic, assign) NSUInteger streamIdentifier;

- (void)data:(NSData *)data forResponse:(NSURLResponse *)response;

@end

@interface DWHTTPStreamItemSerializerProvider : NSObject <DWHTTPStreamItemSerializerProvider>

@end
