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

@implementation EXApperyServiceOperationLoadProjectsMetadata

@synthesize projectsMetadata = _projectsMetadata;

#pragma mark - EXApperyServiceOperation protected interface implementation
- (BOOL) processReceivedData: (NSData *)data {
    DLog(@"Projects metadata was loaded");
    NSString *serializedResponseString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    @try {
        NSDictionary *serializedResponseDictionary = [serializedResponseString JSONObject];
        NSArray *serializedProjectsMetadata = [serializedResponseDictionary objectForKey: @"projects"];
        NSMutableArray *projectsMetadata = [[NSMutableArray alloc] initWithCapacity: serializedProjectsMetadata.count];
        for (NSDictionary *serializedProjectMetadata in serializedProjectsMetadata) {
            EXProjectMetadata *projectMetadata = [[EXProjectMetadata alloc]
                                                  initWithMetadata: serializedProjectMetadata];
            [projectsMetadata addObject: projectMetadata];
            [projectMetadata release];
        }
        if (_projectsMetadata) {
            [_projectsMetadata release];
            _projectsMetadata = nil;
        }
        _projectsMetadata = [[NSArray alloc] initWithArray: projectsMetadata];
        [projectsMetadata release];
    }
    @finally {
        [serializedResponseString release];
    }
    return YES;
}

#pragma mark - Life cycle
- (void) dealloc {
    if (_projectsMetadata) {
        [_projectsMetadata release];
        _projectsMetadata = nil;
    }
    [super dealloc];
}
@end
