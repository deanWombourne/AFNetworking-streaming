//
//  DWDummyResponseSerializer.m
//  Demo
//

#import "DWDummyResponseSerializer.h"

@implementation DWDummyResponseSerializer

- (id)responseObjectForResponse:(__unused NSURLResponse *)response
                           data:(__unused NSData *)data
                          error:(NSError *__autoreleasing *)error {
    
    if (error)
        *error = nil;
    
    return @[];
}

@end
