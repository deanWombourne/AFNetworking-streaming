//
//  DWHTTPStreamSessionManager.h
//  Demo
//

#import "AFHTTPSessionManager.h"

typedef void (^ DWHTTPStreamChunkBlock)(NSURLSessionDataTask *task, id chunk);

@interface DWHTTPStreamSessionManager : AFHTTPSessionManager

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                         data:(DWHTTPStreamChunkBlock)data
                      success:(void (^)(NSURLSessionDataTask *task))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
