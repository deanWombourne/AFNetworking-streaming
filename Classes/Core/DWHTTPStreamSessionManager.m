//
//  DWHTTPStreamSessionManager.m
//  Demo
//

#import "DWHTTPStreamSessionManager.h"


@interface AFHTTPSessionManager (legacy)

// Declaration included so we can compile against 2.x builds of AFNetworking
- (id)GET:(NSString *)URLString parameters:(nullable id)parameters
 progress:(id)progress
  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end


@interface DWHTTPStreamMetadata : NSObject

@property (nonatomic, copy, readonly) DWHTTPStreamChunkBlock chunkBlock;
@property (nonatomic, strong, readonly) DWHTTPStreamItemSerializer *itemSerializer;
@property (nonatomic, weak, readonly) NSURLSessionDataTask *dataTask;

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

+ (instancetype)metadataWithChunkBlock:(DWHTTPStreamChunkBlock)chunkBlock
                        itemSerializer:(DWHTTPStreamItemSerializer *)itemSerializer
                              dataTask:(NSURLSessionDataTask *)dataTask;

@end

@interface DWHTTPStreamSessionManager () <DWHTTPStreamItemSerializationDelegate>

@property (nonatomic, strong, readonly) NSLock *lock;
@property (nonatomic, strong, readonly) NSMutableDictionary *streamMetadataKeyedByTaskIdentifier;

@end

@implementation DWHTTPStreamSessionManager

@synthesize streamMetadataKeyedByTaskIdentifier = _streamMetadataKeyedByTaskIdentifier;

- (id)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if ((self = [super initWithBaseURL:url sessionConfiguration:configuration])) {
        _streamMetadataKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
        self.itemSerializerProvider = [[DWHTTPStreamItemSerializerProvider alloc] init];
        _lock = [[NSLock alloc] init];
        self.lock.name = @"deanWombourne.afnetworking-streaming.metadatalock";
    }
    return self;
}

#pragma mark - Stream metadata manipulation

- (void)addStreamMetadata:(DWHTTPStreamMetadata *)metadata withIdentifier:(NSUInteger)identifier {
    [self.lock lock];
    self.streamMetadataKeyedByTaskIdentifier[@(identifier)] = metadata;
    [self.lock unlock];
}

- (void)removeStreamMetadataWithIdentifier:(NSUInteger)identifier {
    [self.lock lock];
    [self.streamMetadataKeyedByTaskIdentifier removeObjectForKey:@(identifier)];
    [self.lock unlock];
}

- (DWHTTPStreamMetadata *)getStreamMetadataWithIdentifier:(NSUInteger)identifier {
    [self.lock lock];
    id item = self.streamMetadataKeyedByTaskIdentifier[@(identifier)];
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
    NSURLSessionDataTask *task = nil;

    SEL sel = @selector(GET:parameters:progress:success:failure:);
    if ([super respondsToSelector:sel]) {
        task = [super GET:URLString
               parameters:parameters
                 progress: nil
                  success:^(NSURLSessionDataTask *task, __unused id response) {
                      if (success)
                          success(task);
                  }
                  failure:failure];
    } else {
        task = [super GET:URLString
               parameters:parameters
                  success:^(NSURLSessionDataTask *task, __unused id response) {
                      if (success)
                          success(task);
                  }
                  failure:failure];
    }

    // Create the item parser for this request
    DWHTTPStreamItemSerializer *itemSerializer = [self.itemSerializerProvider itemSerializerWithIdentifier:task.taskIdentifier
                                                                                                  delegate:self];

    // Create and store the metadata for this task
    DWHTTPStreamMetadata *metadata = [DWHTTPStreamMetadata metadataWithChunkBlock:chunkBlock
                                                                   itemSerializer:itemSerializer
                                                                         dataTask:task];
    [self addStreamMetadata:metadata withIdentifier:task.taskIdentifier];

    // Return the task
    return task;
}

#pragma mark - URLSession delegate overrides

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // Don't call super if this is a stream we are handling - we don't want to accumulate the data
    DWHTTPStreamMetadata *metadata = [self getStreamMetadataWithIdentifier:dataTask.taskIdentifier];
    if (metadata) {
        if (metadata.chunkBlock) {
            dispatch_async(metadata.queue, ^{
                [metadata.itemSerializer data:data forResponse:dataTask.response];
            });
        }
    } else {
        [super URLSession:session dataTask:dataTask didReceiveData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    DWHTTPStreamMetadata *metadata = [self getStreamMetadataWithIdentifier:task.taskIdentifier];
    if (metadata) {
        dispatch_async(metadata.queue, ^{
            [super URLSession:session task:task didCompleteWithError:error];

            [self removeStreamMetadataWithIdentifier:task.taskIdentifier];
        });
    } else {
        [super URLSession:session task:task didCompleteWithError:error];
    }
}

#pragma mark - DWHTTPItemSerializer delegate methods

- (void)itemSerializer:(DWHTTPStreamItemSerializer *)itemSerializer foundError:(NSError *)error {
    DWHTTPStreamMetadata *metadata = [self getStreamMetadataWithIdentifier:itemSerializer.streamIdentifier];
    [metadata.dataTask cancel];
}

- (void)itemSerializer:(DWHTTPStreamItemSerializer *)itemSerializer foundItem:(id)item {
    DWHTTPStreamMetadata *metadata = [self getStreamMetadataWithIdentifier:itemSerializer.streamIdentifier];
    NSAssert(metadata != nil, @"Oops, found a data item for metadata that doesn't exist");
    dispatch_async(dispatch_get_main_queue(), ^{
        metadata.chunkBlock(metadata.dataTask, item);
    });
}

@end

@implementation DWHTTPStreamMetadata

+ (instancetype)metadataWithChunkBlock:(DWHTTPStreamChunkBlock)chunkBlock
                        itemSerializer:(DWHTTPStreamItemSerializer *)itemSerializer
                              dataTask:(NSURLSessionDataTask *)dataTask {
    DWHTTPStreamMetadata *m = [[DWHTTPStreamMetadata alloc] init];
    m->_chunkBlock = [chunkBlock copy];
    m->_itemSerializer = itemSerializer;
    m->_dataTask = dataTask;

    const char *queueName = [[NSString stringWithFormat:@"com.deanWombourne.afnetworking.items.%u", (unsigned int)m.itemSerializer.streamIdentifier] cStringUsingEncoding:NSASCIIStringEncoding];
    m->_queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);

    return m;
}

@end

