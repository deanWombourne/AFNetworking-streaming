//
//  DWHTTPStreamSessionManager.h
//  Demo
//

#import "AFHTTPSessionManager.h"

typedef void (^ DWHTTPStreamChunkBlock)(NSURLSessionDataTask *task, id chunk);
typedef void (^ DWHTTPStreamSuccessBlock)(NSURLSessionDataTask *task);
typedef void (^ DWHTTPStreamFailureBlock)(NSURLSessionDataTask *task, NSError *error);

/**
 * A simple subclass of AFHTTPSessionManager that adds a method for chunk based parsing
 */
@interface DWHTTPStreamSessionManager : AFHTTPSessionManager

/**
 Call this to behave pretty much the same as GET:parameters:success:failure: but with the data
 returned in chunks instead of all at the end. This method doesn't build up the data internally so
 memory use is lower.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param data A block object to be exectued when a new chunk of data is received. This block has no return value and takes two arguments: the data task, and the chunk of data received.
 @param success A block object to be executed when the task finishes successfully. This block has no return value and takes two arguments: the data task, and the response object created by the client response serializer.
 @param failure A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a two arguments: the data task and the error describing the network or parsing error that occurred.
 */
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                         data:(DWHTTPStreamChunkBlock)data
                      success:(DWHTTPStreamSuccessBlock)success
                      failure:(DWHTTPStreamFailureBlock)failure;

@end
