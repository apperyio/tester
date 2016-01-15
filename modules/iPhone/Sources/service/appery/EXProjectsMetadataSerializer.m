//
//  EXProjectsMetadataSerializer.m
//  Appery
//
//  Created by Sergey Tkachenko on 12/3/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import "EXProjectsMetadataSerializer.h"

#import "NSObject+Utils.h"
#import "EXProjectMetadata.h"

@implementation EXProjectsMetadataSerializer

+ (instancetype)serializer
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/json", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        return nil;
    }
    
    NSError *serializationError = nil;
    NSArray *serializedProjectsMetadata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];
    if (![serializedProjectsMetadata as:[NSArray class]]) {
        NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                  NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Bad request", nil)};
        *error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        
        return nil;
    }
    
    NSMutableArray *projectsMetadata = [[NSMutableArray alloc] initWithCapacity:serializedProjectsMetadata.count];
    
    for (NSDictionary *serializedProjectMetadata in serializedProjectsMetadata) {
        EXProjectMetadata *projectMetadata = [[EXProjectMetadata alloc] initWithMetadata:serializedProjectMetadata];
        [projectsMetadata addObject:projectMetadata];
    }
    
    return [[NSArray alloc] initWithArray:projectsMetadata];
}

@end
