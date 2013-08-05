//
//  EXProjectsMetadataViewController~iPhone.m
//  Appery
//
//  Created by Sergey Seroshtan on 27.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXProjectsMetadataViewController~iPhone.h"

#import "MBProgressHUD.h"

#import "EXProjectViewController.h"

#import "EXSelectViewController.h"

@interface EXProjectsMetadataViewController_iPhone () <EXProjectsObserver, UINavigationControllerDelegate>

@end

@implementation EXProjectsMetadataViewController_iPhone

#pragma mark - Initialization
- (id) initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) == nil) {
        return nil;
    }
    return self;
}

#pragma mark - Lifecycle
- (void) viewDidLoad {
    [super viewDidLoad];
    [self addProjectsObserver: self];
}

- (void) dealloc {
    [self removeProjectsObserver: self];
}

#pragma mark - EXProjectsObserver protocol implementation
- (void) projectMetadataWasSelected: (EXProjectMetadata *)projectMetadata {
    NSAssert(projectMetadata != nil, @"projectMetadata is not defined");
    
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo: rootView animated: YES];
    progressHud.labelText = NSLocalizedString(@"Loading project", @"Loading project progress hud title");
    
    [self.apperyService loadProjectForMetadata: projectMetadata
        succeed:^(NSString *projectLocation, NSString *startPageName) {
            [progressHud hide: NO];
            EXProjectViewController *projectViewController = 
                    [[EXProjectViewController alloc] initWithProjectMetadata: projectMetadata];
            projectViewController.apperyService = self.apperyService;
            projectViewController.wwwFolderName = projectLocation;
            projectViewController.startPage = startPageName;
            [self.navigationController pushViewController: projectViewController animated: YES];
        } failed:^(NSError *error) {
            [progressHud hide: NO];
            NSString *errorTitle = NSLocalizedString(@"Failed", @"Title for Failed alert");
            NSString *errorCancelButtonTitle = NSLocalizedString(@"Ok", @"Failed alert cancel button");
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle: errorTitle message: error.domain
                    delegate: nil cancelButtonTitle: errorCancelButtonTitle otherButtonTitles: nil];
            [errorAlert show];
            NSLog(@"Project loading failed due to: %@", [error localizedDescription]);
        }
    ];
}

@end
