//
//  DWHTTPStreamSessionManager.m
//  Demo
//

#import "DWHTTPStreamSessionManager.h"

@interface DWHTTPStreamMetadata : NSObject

@property (nonatomic, strong, readonly) DWHTTPStreamChunkBlock chunkBlock;

+ (instancetype)metadataWithChunkBlock:(DWHTTPStreamChunkBlock)chunkBlock;

@end

@interface DWHTTPStreamSessionManager ()

@property (nonatomic, strong, readonly) NSLock *lock;
@property (nonatomic, strong, readonly) NSMutableDictionary *streamMeteadataKeyedByTaskIdentifer;

@end

@implementation DWHTTPStreamSessionManager

@synthesize streamMeteadataKeyedByTaskIdentifer = _streamMeteadataKeyedByTaskIdentifer;

- (id)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if ((self = [super initWithBaseURL:url sessionConfiguration:configuration])) {
        _streamMeteadataKeyedByTaskIdentifer = [[NSMutableDictionary alloc] init];
        _lock = [[NSLock alloc] init];
        self.lock.name = @"deanWombourne.afnetworking-streaming.metadatalock";
    }
    return self;
}

#pragma mark - Stream metadata manipulation

- (void)addStreamMeteadata:(DWHTTPStreamMetadata *)metadata withIdentifier:(NSUInteger)identifier {
    [self.lock lock];
    self.streamMeteadataKeyedByTaskIdentifer[@(identifier)] = metadata;
    [self.lock unlock];
}

- (void)removeStreamMeteadataWithIdentifier:(NSUInteger)identifier {
    [self.lock lock];
    [self.streamMeteadataKeyedByTaskIdentifer removeObjectForKey:@(identifier)];
    [self.lock unlock];
}

- (DWHTTPStreamMetadata *)getStreamMetadataWithIdentifier:(NSUInteger)identifier {
    [self.lock lock];
    id item = self.streamMeteadataKeyedByTaskIdentifer[@(identifier)];
    [self.lock unlock];
    return item;
}

#pragma mark - Public API

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                         data:(DWHTTPStreamChunkBlock)chunkBlock
                      success:(DWHTTPStreamSuccessBlock)success
                      failure:(DWHTTPStreamFailureBlock)failure {
    
    // Get a default task
    NSURLSessionDataTask *task = [super GET:URLString
                                 parameters:parameters
                                    success:^(NSURLSessionDataTask *task, __unused id response) {
                                        if (success)
                                            success(task);
                                    }
                                    failure:failure];
    
    // Register a chunk parser for this task
    DWHTTPStreamMetadata *metadata = [DWHTTPStreamMetadata metadataWithChunkBlock:chunkBlock];
    [self addStreamMeteadata:metadata withIdentifier:task.taskIdentifier];
    
    // Return the task
    return task;
}

#pragma mark - URLSession delegate overrides

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // Don't call super - we don't want to accumulate the data
    //[super URLSession:session dataTask:dataTask didReceiveData:data];
    
    DWHTTPStreamMetadata *delegate = [self getStreamMetadataWithIdentifier:dataTask.taskIdentifier];
    if (delegate.chunkBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            delegate.chunkBlock(dataTask, data);
        });
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [super URLSession:session task:task didCompleteWithError:error];

    [self removeStreamMeteadataWithIdentifier:task.taskIdentifier];
}

@end

@implementation DWHTTPStreamMetadata

+ (instancetype)metadataWithChunkBlock:(DWHTTPStreamChunkBlock)chunkBlock {
    DWHTTPStreamMetadata *m = [[DWHTTPStreamMetadata alloc] init];
    m->_chunkBlock = chunkBlock;
    return m;
}

@end
