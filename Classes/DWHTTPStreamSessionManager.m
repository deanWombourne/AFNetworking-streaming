//
//  DWHTTPStreamSessionManager.m
//  Demo
//

#import "DWHTTPStreamSessionManager.h"

#import "DWHTTPStreamMetadata.h"
#import "DWDummyResponseSerializer.h"

@interface DWHTTPStreamSessionManager ()

@property (nonatomic, strong, readonly) NSMutableDictionary *streamMeteadataKeyedByTaskIdentifer;

@end

@implementation DWHTTPStreamSessionManager

@synthesize streamMeteadataKeyedByTaskIdentifer = _streamMeteadataKeyedByTaskIdentifer;

- (NSMutableDictionary *)streamMeteadataKeyedByTaskIdentifer {
    if (nil == _streamMeteadataKeyedByTaskIdentifer)
        _streamMeteadataKeyedByTaskIdentifer = [[NSMutableDictionary alloc] init];
    return _streamMeteadataKeyedByTaskIdentifer;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                         data:(void (^)(NSURLSessionDataTask *task, NSData *chunk))dataBlock
                      success:(void (^)(NSURLSessionDataTask *task))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    // Get a default task
    NSURLSessionDataTask *task = [super GET:URLString
                                 parameters:parameters
                                    success:^(NSURLSessionDataTask *task, __unused id response) {
                                        if (success)
                                            success(task);
                                    }
                                    failure:failure];
    
    // Register a chunk parser for this task
    DWHTTPStreamMetadata *delegate = [[DWHTTPStreamMetadata alloc] init];
    delegate.chunk = dataBlock;
    self.streamMeteadataKeyedByTaskIdentifer[@(task.taskIdentifier)] = delegate;
    
    // Return the task
    return task;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [super URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // Don't call super - we don't want to accumulate the data
    //[super URLSession:session dataTask:dataTask didReceiveData:data];
    
    DWHTTPStreamMetadata *delegate = self.streamMeteadataKeyedByTaskIdentifer[@(dataTask.taskIdentifier)];
    if (delegate.chunk)
        delegate.chunk(dataTask, data);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [super URLSession:session task:task didCompleteWithError:error];

    id identifier = @(task.taskIdentifier);
    [self.streamMeteadataKeyedByTaskIdentifer removeObjectForKey:identifier];
}

@end
