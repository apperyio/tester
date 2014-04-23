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

- (BOOL) processReceivedData: (NSData *)data
{
    NSLog(@"Projects metadata was loaded");
    
    NSString *serializedResponseString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSDictionary *serializedResponseDictionary = [serializedResponseString JSONObject];
    NSArray *serializedProjectsMetadata = [serializedResponseDictionary objectForKey: @"projects"];
    NSMutableArray *projectsMetadata = [[NSMutableArray alloc] initWithCapacity: serializedProjectsMetadata.count];
    
    for (NSDictionary *serializedProjectMetadata in serializedProjectsMetadata) {
        EXProjectMetadata *projectMetadata = [[EXProjectMetadata alloc]
                                              initWithMetadata: serializedProjectMetadata];
        [projectsMetadata addObject: projectMetadata];
    }
    
    self.projectsMetadata = [[NSArray alloc] initWithArray: projectsMetadata];
    
    return YES;
}

@end
