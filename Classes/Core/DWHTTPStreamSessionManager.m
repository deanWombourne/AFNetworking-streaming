//
//  DWHTTPStreamSessionManager.m
//  Demo
//

#import "DWHTTPStreamSessionManager.h"

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
@property (nonatomic, strong, readonly) NSMutableDictionary *streamMeteadataKeyedByTaskIdentifer;

@end

@implementation DWHTTPStreamSessionManager

@synthesize streamMeteadataKeyedByTaskIdentifer = _streamMeteadataKeyedByTaskIdentifer;

- (id)initWithBaseURL:(NSURL *)url sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if ((self = [super initWithBaseURL:url sessionConfiguration:configuration])) {
        _streamMeteadataKeyedByTaskIdentifer = [[NSMutableDictionary alloc] init];
        self.itemSerializerProvider = [[DWHTTPStreamItemSerializerProvider alloc] init];
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
    
    // Create the item parser for this request
    DWHTTPStreamItemSerializer *itemSerializer = [self.itemSerializerProvider itemSerializerWithIdentifier:task.taskIdentifier
                                                                                                  delegate:self];

    // Create and store the metadata for this task
    DWHTTPStreamMetadata *metadata = [DWHTTPStreamMetadata metadataWithChunkBlock:chunkBlock
                                                                   itemSerializer:itemSerializer
                                                                         dataTask:task];
    [self addStreamMeteadata:metadata withIdentifier:task.taskIdentifier];
    
    // Return the task
    return task;
}

#pragma mark - URLSession delegate overrides

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // Don't call super - we don't want to accumulate the data
    //[super URLSession:session dataTask:dataTask didReceiveData:data];
    
    DWHTTPStreamMetadata *metadata = [self getStreamMetadataWithIdentifier:dataTask.taskIdentifier];
    if (metadata.chunkBlock) {
        dispatch_async(metadata.queue, ^{
            [metadata.itemSerializer data:data forResponse:dataTask.response];
        });
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    DWHTTPStreamMetadata *metadata = [self getStreamMetadataWithIdentifier:task.taskIdentifier];
    dispatch_async(metadata.queue, ^{
        [super URLSession:session task:task didCompleteWithError:error];

        [self removeStreamMeteadataWithIdentifier:task.taskIdentifier];
    });
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
