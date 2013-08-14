//
//  EXApperyServiceOperationLoadProject.m
//  Appery
//
//  Created by Sergey Seroshtan on 20.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXApperyServiceOperationLoadProject.h"

#import "ZipArchive.h"
#import "NSString+URLUtility.h"

static NSString * const kDescriptorFileName = @"descriptor.txt";
static NSString * const kDefaultStartPageName = @"index.html";

#pragma mark - Private interface declaration
@interface EXApperyServiceOperationLoadProject ()

/** Removed 'readonly' restriction for private purposes */
@property (nonatomic, retain) NSString *projectLocation;
@property (nonatomic, retain) NSString *projectStartPageName;

@end

@implementation EXApperyServiceOperationLoadProject

#pragma mark - Public interface implementation
#pragma mark - Properties synthesize
@synthesize projectMetadata = _projectMetadata;
@synthesize projectLocation = _projectLocation;
@synthesize projectStartPageName = _projectStartPageName;

#pragma mark - Lifecycle
- (void) dealloc {
    self.projectMetadata = nil;
    self.projectLocation = nil;
    self.projectStartPageName = nil;
    [super dealloc];
}

#pragma mark - Protected interface implementation
- (BOOL) processReceivedData: (NSData *)data {
    NSError *processError = nil;
    
    NSString * projectLocation = [self buildLocationForProjectMetadata: self.projectMetadata error: &processError];
    if (processError) {
        self.error = processError;
        return NO;
    }

    [self unzipProject: data toLocation: projectLocation error: &processError];
    if (processError) {
        self.error = processError;
        return NO;
    }
    
    if ([self copyCordovaLibsToLocation: projectLocation error: &processError] == NO) {
        return NO;
    }
    
    if ([self copyCordovaMediaToLocation: projectLocation error: &processError] == NO) {
        return NO;
    }
    
    NSString *projectStartPageName = [self retreiveStartPageNameFromLocation: projectLocation error: &processError];
    if (processError) {
        self.error = processError;
        return NO;
    }
    
    if ([self preventCSSandJSCachingForProject: projectLocation error: &processError] == NO) {
        self.error = processError;
        // Not critical so just log it.
        DLog(@"Cannot prevent CSS and JS caching due to error: %@", processError);
    }
    
    self.projectLocation = projectLocation;
    self.projectStartPageName = projectStartPageName;
    return YES;
}

#pragma mark - Private service methods

- (NSString *) buildLocationForProjectMetadata: (EXProjectMetadata *) projectMetadata error: (NSError **) error {
    NSAssert(projectMetadata != nil, @"projectMetadata is undefined");
    
    NSArray *directoriesInDomain = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolderPath = [directoriesInDomain objectAtIndex: 0];
    NSString *projectLocation = [documentsFolderPath stringByAppendingPathComponent: projectMetadata.name];
    
    return projectLocation;
}

- (BOOL) unzipProject: (NSData *) zippedProject toLocation: (NSString *) location error: (NSError **) error {
    NSAssert(zippedProject != nil, @"zippedProject is undefined");
    NSAssert(location != nil, @"location is undefined");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Remove old project folder if exist
    if ([fileManager fileExistsAtPath: location]) {
        if ([fileManager removeItemAtPath: location error: error] == NO) {
            return NO;
        }
    }
    
    if ([fileManager createDirectoryAtPath: location withIntermediateDirectories: YES attributes: nil
                                     error: error] == NO) {
        return NO;
    }
    
    // Configure storing project zip archive properties
    NSString *zippedProjectFileName = @"project.zip";
    NSString *zippedProjectFileFullPath = [location stringByAppendingPathComponent: zippedProjectFileName];
    
    // Save project zip archive to local folder
    if ([zippedProject writeToFile: zippedProjectFileFullPath atomically: YES] == NO) {
        DLog(@"Error was occured during file saving to location: %@", location);
        if (error) {
            NSString *errorDomain = NSLocalizedString(@"Error was occured during saving project file",
                                                      @"Saving file error");
            *error = [[[NSError alloc] initWithDomain: errorDomain code: 0 userInfo: nil] autorelease];
        }
        return NO;
    }
    
    // Unzip priject zip archive
    ZipArchive *archiver = [[ZipArchive alloc] init];
    if ([archiver UnzipOpenFile: zippedProjectFileFullPath]) {
        if ([archiver UnzipFileTo: location overWrite: YES] == NO) {
            DLog(@"Error was occured during unzipping project file");
            if (error) {
                NSString *errorDomain = NSLocalizedString(@"Error was occured during unzipping project file",
                                                          @"Unzipping file error");
                *error = [[[NSError alloc] initWithDomain: errorDomain code: 0 userInfo: nil] autorelease];
            }
            return NO;
        } 
        [archiver UnzipCloseFile];
    }
    [archiver release];
    
    // Remove saved zip archive
    if ([fileManager removeItemAtPath: zippedProjectFileFullPath error: error] == NO) {
        // Not critical, it is possible to continue
        DLog(@"Error was occured during zip archive deleting");
    }
    
    return YES;
}

- (BOOL) copyCordovaLibsToLocation: (NSString *)destination error: (NSError **)error {
    DLog(@"Coping javascript resources...");

    return [self replaceResource: @"cordova" ofType:@"js" atPath: destination error: error] &&
            [self replaceResource: @"childbrowser" ofType:@"js" atPath: destination error: error] &&
            [self replaceResource: @"barcodescanner" ofType:@"js" atPath: destination error: error];
}

- (BOOL) copyCordovaMediaToLocation: (NSString *) destination error: (NSError **) error {
    return [self copyResource: @"beep" ofType: @"wav" toPath: destination error: error];
}


- (NSString *) retreiveStartPageNameFromLocation: (NSString *) projectLocation error: (NSError **) error {
    NSAssert(projectLocation != nil, @"projectLocation is undefined");
    NSAssert(error != nil, @"reference to error object was not defined");

    NSString *desriptorFilePath = [projectLocation stringByAppendingPathComponent: kDescriptorFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: desriptorFilePath]) {
        NSString *startPageName = [NSString stringWithContentsOfFile: desriptorFilePath
                                                        encoding: NSUTF8StringEncoding error: error];
        if (*error == nil) {
            return [startPageName decodedUrlString];
        }
    }
    
    return kDefaultStartPageName;
}

- (BOOL) preventCSSandJSCachingForProject: (NSString *)projectLocation error: (NSError **)error {
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: projectLocation];
    
    NSString *file = nil;
    while (file = [dirEnum nextObject]) {
        if ([file hasSuffix:@".html"]) {
            
            NSString *htmlFilePath = [projectLocation stringByAppendingPathComponent: file];
            NSString *htmlFileString = [[NSString alloc] initWithContentsOfFile: htmlFilePath 
                    encoding: NSUTF8StringEncoding error: nil];
            
            htmlFileString = [htmlFileString
                    stringByReplacingOccurrencesOfString: @".css" 
                    withString: [@".css" stringByAppendingFormat: @"?time=%@", [[NSDate date] description]]];

            htmlFileString = [htmlFileString
                              stringByReplacingOccurrencesOfString: @".js" 
                              withString: [@".js" stringByAppendingFormat: @"?time=%@", [[NSDate date] description]]];

            
            [htmlFileString writeToFile: htmlFilePath atomically: YES
                    encoding: NSUTF8StringEncoding error: error];
            
            if(*error != nil) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - File manager helper
- (BOOL)replaceResource: (NSString *)resourceName ofType: (NSString *)resourceType atPath:(NSString *)rootPath
        error: (NSError **) error {
    
    NSString *resourceFullPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
    
    if (resourceFullPath == nil) {
        if (error != nil) {
            NSString *errorDomain = NSLocalizedString(@"Resource: was not found", @"Resource not found error domain");
            *error = [NSError errorWithDomain: errorDomain code: 0 userInfo: nil];
        }
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath: rootPath];
    NSString *file = nil;
    while (file = [dirEnum nextObject]) {
        if (![[file lastPathComponent] isEqualToString:[resourceFullPath lastPathComponent]]) {
            continue;
        }
        
        NSString *fileFullPath = [rootPath stringByAppendingPathComponent:file];
        
        if ([fileManager removeItemAtPath: fileFullPath error: error] == NO) {
            return NO;
        }
        
        if ([fileManager copyItemAtPath: resourceFullPath toPath: fileFullPath error: error] == NO) {
            return NO;
        }
        
        break;
    }
    return YES;
}

- (BOOL) copyResource: (NSString *)resourceName ofType: (NSString *)resourceType
               toPath: (NSString *)destination error: (NSError **) error {
    
    NSString *resourceFullPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
    
    if (resourceFullPath == nil) {
        if (error != nil) {
            NSString *errorDomain = NSLocalizedString(@"Resource: was not found", @"Resource not found error domain");
            *error = [NSError errorWithDomain: errorDomain code: 0 userInfo: nil];
        }
        return NO;
    }
	
	NSString *destinationFullPath = [destination stringByAppendingPathComponent: 
            [NSString stringWithFormat: @"%@.%@", [resourceName lowercaseString], resourceType]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath: destinationFullPath]) {
		if ([fileManager removeItemAtPath: destinationFullPath error: error] == NO) {
            return NO;
        }
	}
    
    if (![fileManager fileExistsAtPath:destination]) {
        if ([fileManager createDirectoryAtPath:destination withIntermediateDirectories: YES
                attributes:nil error:error] == NO) {
            return NO;
        }
    }
    
	if ([fileManager copyItemAtPath: resourceFullPath toPath: destinationFullPath error: error] == NO) {
        return NO;
    }
    
    return YES;
}

@end
