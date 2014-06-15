//
//  DWHTTPStreamSessionManager.h
//  Demo
//

#import "AFHTTPSessionManager.h"

@interface DWHTTPStreamSessionManager : AFHTTPSessionManager

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                         data:(void (^)(NSURLSessionDataTask *task, NSData *chunk))data
                      success:(void (^)(NSURLSessionDataTask *task))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
