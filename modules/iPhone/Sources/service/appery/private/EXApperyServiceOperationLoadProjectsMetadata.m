//
//  EXApperyServiceOperationLoadProjectsMetadata.h
//  Appery
//
//  Created by Sergey Seroshtan on 10.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyServiceOperationLoadProjectsMetadata.h"

#import <Cordova/CDVJSON.h>
#import "EXProjectMetadata.h"

@interface EXApperyServiceOperationLoadProjectsMetadata ()

@property (nonatomic, strong, readwrite) NSArray *projectsMetadata;
    
@end

@implementation EXApperyServiceOperationLoadProjectsMetadata

#pragma mark - EXApperyServiceOperation protected interface implementation

- (BOOL)processReceivedData:(NSData *)data
{
    if (![super processReceivedData:data]) {
        NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                  NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Incorrect email address or password", nil)};
        self.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        
        return NO;
    }
    
    NSLog(@"Apps metadata was loaded");

    NSError *err = nil;
    NSArray *serializedProjectsMetadata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (![serializedProjectsMetadata isKindOfClass:[NSArray class]]) {
        NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                  NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Bad request", nil)};
        self.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        
        return NO;
    }
    
    NSMutableArray *projectsMetadata = [[NSMutableArray alloc] initWithCapacity:serializedProjectsMetadata.count];
    
    for (NSDictionary *serializedProjectMetadata in serializedProjectsMetadata) {
        EXProjectMetadata *projectMetadata = [[EXProjectMetadata alloc] initWithMetadata:serializedProjectMetadata];
        [projectsMetadata addObject:projectMetadata];
    }
    
    self.projectsMetadata = [[NSArray alloc] initWithArray:projectsMetadata];
    
    return YES;
}

@end
