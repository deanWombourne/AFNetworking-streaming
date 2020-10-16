//
//  DWHTTPStreamSessionManager.h
//  Demo
//

#if __has_include(<AFNetworking.h>)
#import <AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import "DWHTTPStreamItemSerialization.h"

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

/**
 * Provide this to automatically serialize the data as it arrives.
 *
 * The default provider creates an item serializer that simply passes back the data chunks as they arrive. You probably
 * want it to do more than that so implement your own serializer :)
 *
 * Take a look at the Json subpod for a JSON Stream parsing example. The Example folder shows how it would be used.
 */
@property (nonatomic, strong) id<DWHTTPStreamItemSerializerProvider> itemSerializerProvider;

@end
