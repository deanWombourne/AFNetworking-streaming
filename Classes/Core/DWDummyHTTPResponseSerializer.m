//
//  DWDummyHTTPResponseSerializer.m
//  Pods
//
//  Created by Sam Dean on 08/08/2014.
//
//

#import "DWDummyHTTPResponseSerializer.h"

@implementation DWDummyHTTPResponseSerializer

- (id)responseObjectForResponse:(__unused NSURLResponse *)response data:(__unused NSData *)data error:(__unused NSError *__autoreleasing *)error
{
    return nil;
}

@end
