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

- (BOOL) removeFilesFromPath:(NSString *)path;

@end

@implementation EXApperyServiceOperationLoadProject

#pragma mark - Protected interface implementation

- (BOOL) processReceivedData: (NSData *)data
{
    if (![super processReceivedData:data]) {
        NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                  NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Failed to load the project data", nil)};
        self.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        
        return NO;
    }
    
    NSError *processError = nil;
    NSString * projectLocation = [self buildLocationForProjectMetadata: self.projectMetadata error: &processError];
    
    if (processError) {
        self.error = processError;
        return NO;
    }
    
    // Remove all folders from project location
    [self removeFilesFromPath:[self projectsLocation]];
    
    [self unzipProject: data toLocation: projectLocation error: &processError];
    
    if (processError) {
        self.error = processError;
        return NO;
    }
    
    NSString *libsLocation = [NSString pathWithComponents:@[projectLocation, @"libs"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:libsLocation]){
        libsLocation = [NSString pathWithComponents:@[projectLocation, @"files/resources/lib"]];
    }
    
    if ([self copyCordovaLibsToLocation: libsLocation error: &processError] == NO) {
        NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                  NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Failed to copy cordova files", nil)};
        self.error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
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
        NSLog(@"Cannot prevent CSS and JS caching due to error: %@", processError);
    }
    self.projectLocation = [projectLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.projectStartPageName = [projectStartPageName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return YES;
}

#pragma mark - Private service methods

- (BOOL) removeFilesFromPath:(NSString *)path
{
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:path error:&error];
    
    if (error) {
        NSLog(@"Can't remove files from path: %@ error: %@", path, [error localizedDescription]);
        
        return NO;
    }
    
    for (NSString *filepath in directoryContents) {
        NSString *fullPath = [path stringByAppendingPathComponent:filepath];
        BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
        if (!removeSuccess || error) {
            // Continue
            NSLog(@"Can't remove file: %@ error: %@", fullPath, [error localizedDescription]);
        }
    }
    return YES;
}

- (NSString *) projectsLocation
{
    NSArray *directoriesInDomain = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolderPath = [directoriesInDomain objectAtIndex: 0];
    NSString *projectsLocation = [NSString pathWithComponents:@[documentsFolderPath, @"projects"]];
    
    return projectsLocation;
}

- (NSString *) buildLocationForProjectMetadata: (EXProjectMetadata *) projectMetadata error: (NSError **) error
{
    NSAssert(projectMetadata != nil, @"projectMetadata is undefined");

    return [NSString pathWithComponents:@[[self projectsLocation], projectMetadata.name]];
}

- (BOOL) unzipProject: (NSData *) zippedProject toLocation: (NSString *) location error: (NSError **) error
{
    NSAssert(zippedProject != nil, @"zippedProject is undefined");
    NSAssert(location != nil, @"location is undefined");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Remove old project folder if exist
    if ([fileManager fileExistsAtPath: location]) {
        if ([fileManager removeItemAtPath: location error: error] == NO) {
            return NO;
        }
    }
    
    if ([fileManager createDirectoryAtPath: location withIntermediateDirectories: YES attributes: nil error: error] == NO) {
        return NO;
    }
    
    // Configure storing project zip archive properties
    NSString *zippedProjectFileName = @"project.zip";
    NSString *zippedProjectFileFullPath = [location stringByAppendingPathComponent: zippedProjectFileName];
    
    // Save project zip archive to local folder
    if ([zippedProject writeToFile: zippedProjectFileFullPath atomically: YES] == NO) {
        NSLog(@"Error was occured during file saving to location: %@", location);
        if (error) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Error was occured during saving project file", nil)};
            *error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        }
        return NO;
    }
    
    // Unzip priject zip archive
    ZipArchive *archiver = [[ZipArchive alloc] init];
    if ([archiver UnzipOpenFile:zippedProjectFileFullPath]) {
        if ([archiver UnzipFileTo:location overWrite:YES] == NO) {
            NSLog(@"Error was occured during unzipping project file");
            if (error) {
                NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                          NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Unzipping file error", nil)};
                *error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
            }
            return NO;
        } 
        [archiver UnzipCloseFile];
    }
    
    // Remove saved zip archive
    if ([fileManager removeItemAtPath:zippedProjectFileFullPath error:error] == NO) {
        // Not critical, it is possible to continue
        NSLog(@"Error was occured during zip archive deleting");
    }
    
    // Validation of the archive
    if (![fileManager fileExistsAtPath:[location stringByAppendingString:@"/index.html"]]) {
        if (error) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Incorrect resources", nil)};
            *error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL) copyCordovaLibsToLocation:(NSString *)destination error:(NSError **)error
{
    NSLog(@"Coping www resources...");
    
    NSString *wwwResource = [[[NSBundle mainBundle] URLForResource:@"www" withExtension:@""] path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *wwwContent = [fileManager contentsOfDirectoryAtPath:wwwResource error:error];
    
    if (wwwContent == nil) {
        return NO;
    }
    
    for (NSString *entity in wwwContent) {
        NSString *dst = [destination stringByAppendingPathComponent:entity];
        if ([fileManager fileExistsAtPath:dst]) {
            if ([fileManager removeItemAtPath:dst error:error] == NO) {
                return NO;
            }
        }
        
        NSString *src = [wwwResource stringByAppendingPathComponent:entity];
        if ([fileManager copyItemAtPath:src toPath:dst error:error] == NO) {
            return NO;//!!!
        }
    }
    
    return YES;
}

- (NSString *) retreiveStartPageNameFromLocation: (NSString *) projectLocation error: (NSError **) error
{
    NSAssert(projectLocation != nil, @"projectLocation is undefined");
    NSAssert(error != nil, @"reference to error object was not defined");

    NSString *desriptorFilePath = [projectLocation stringByAppendingPathComponent: kDescriptorFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: desriptorFilePath]) {
        NSString *startPageName = [NSString stringWithContentsOfFile: desriptorFilePath encoding: NSUTF8StringEncoding error: error];
        if (*error == nil) {
            return [startPageName decodedUrlString];
        }
    }
    
    return kDefaultStartPageName;
}

- (BOOL) preventCSSandJSCachingForProject: (NSString *)projectLocation error: (NSError **)error
{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: projectLocation];
    NSString *versionStrign = [NSString stringWithFormat:@"?version=%lu\"", (unsigned long)[[NSDate date] timeIntervalSince1970]];
    NSString *file = nil;
    
    while (file = [dirEnum nextObject]) {
        if ([file hasSuffix:@".html"]) {
            NSString *htmlFilePath = [projectLocation stringByAppendingPathComponent:file];
            NSString *htlmFileString = [[NSString alloc] initWithContentsOfFile:htmlFilePath
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:error];

            htlmFileString = [htlmFileString stringByReplacingOccurrencesOfString:@".css\""
                                                                       withString:[@".css" stringByAppendingString:versionStrign]];
            
            htlmFileString = [htlmFileString stringByReplacingOccurrencesOfString:@".js\""
                                                                       withString:[@".js" stringByAppendingString:versionStrign]];
            [htlmFileString writeToFile:htmlFilePath
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:error];
            
            if (*error != nil) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - File manager helper

- (BOOL)replaceResource: (NSString *)resourceName ofType: (NSString *)resourceType atPath:(NSString *)rootPath error: (NSError **) error
{
    NSString *resourceFullPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
    
    if (resourceFullPath == nil) {
        if (error != nil) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Resource: was not found", nil)};
            *error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
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

- (BOOL) copyResource: (NSString *)resourceName ofType: (NSString *)resourceType toPath: (NSString *)destination error: (NSError **) error
{
    NSString *resourceFullPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
    
    if (resourceFullPath == nil) {
        if (error != nil) {
            NSDictionary *errInfo = @{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed", nil),
                                      NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Resource: was not found", nil)};
            *error = [[NSError alloc] initWithDomain:APPERI_SERVICE_ERROR_DOMAIN code:0 userInfo:errInfo];
        }
        return NO;
    }
	
	NSString *destinationFullPath = [destination stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@", [resourceName lowercaseString], resourceType]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
    if([fileManager fileExistsAtPath: destinationFullPath]) {
		if ([fileManager removeItemAtPath:destinationFullPath error: error] == NO) {
            return NO;
        }
	}
    
    if (![fileManager fileExistsAtPath:destination]) {
        if ([fileManager createDirectoryAtPath:destination withIntermediateDirectories: YES attributes:nil error:error] == NO) {
            return NO;
        }
    }
    
	if ([fileManager copyItemAtPath: resourceFullPath toPath: destinationFullPath error: error] == NO) {
        return NO;
    }
    
    return YES;
}

@end
