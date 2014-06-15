//
//  DWHTTPStreamDelegte.h
//  Demo
//

#import <Foundation/Foundation.h>

typedef void (^ DWHTTPStreamChunkBlock)(NSURLSessionDataTask *task, id chunk);

@interface DWHTTPStreamMetadata : NSObject

@property (nonatomic, strong) DWHTTPStreamChunkBlock chunk;

@end
